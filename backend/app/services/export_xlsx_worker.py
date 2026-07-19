#!/usr/bin/env python3
"""Standalone xlsx export worker — 逐 sheet 写临时 XML → zf.write() → 删临时。

Usage:
    python export_xlsx_worker.py <tsv_path> <xlsx_path> <columns_json> [<spec_json_path>]

关键: 每个 sheet 先写临时 XML 文件, 再 zf.write() 加入 ZIP, 然后立即删除临时文件。
同一时刻磁盘上最多只有一个 sheet 的临时 XML(约 2-3GB)。
"""
import sys
import os
import json
import time
import zipfile
import tempfile

try:
    os.nice(10)
except OSError:
    pass

MAX_ROWS_PER_SHEET = 1000000


def _col_letter(n):
    r = ""
    while n > 0:
        n, rem = divmod(n - 1, 26)
        r = chr(65 + rem) + r
    return r


def _esc_bytes(val):
    """XML 转义, 返回 bytes。"""
    if val is None:
        return b""
    s = str(val).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")
    return s.encode("utf-8")


def _num_bytes(val):
    """尝试转数值, 返回 bytes 或 None。"""
    if val in ("NULL", "\\N", "", None):
        return None
    try:
        f = float(val)
        return (str(int(f)) if f == int(f) else repr(f)).encode()
    except (ValueError, TypeError):
        return None


def _build_row_bytes(row_num, values):
    """拼一行 XML, 返回 bytes。"""
    parts = [b'<row r="', str(row_num).encode(), b'">']
    for ci, val in enumerate(values):
        col = _col_letter(ci + 1).encode()
        ref = col + str(row_num).encode()
        if val is None or val == "":
            parts.append(b'<c r="' + ref + b'"/>')
            continue
        nb = _num_bytes(val)
        if nb is not None:
            parts.append(b'<c r="' + ref + b'"><v>' + nb + b'</v></c>')
        else:
            parts.append(b'<c r="' + ref + b'" t="inlineStr"><is><t>' + _esc_bytes(val) + b'</t></is></c>')
    parts.append(b'</row>')
    return b"".join(parts)


def _write_sheet_to_temp(col_labels, row_iter, desc="sheet"):
    """写一个 sheet XML 到临时文件, 返回文件路径。"""
    tmp = tempfile.mktemp(suffix=".xml")
    total = 0
    with open(tmp, "wb") as f:
        f.write(b'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
        f.write(b'<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>')
        f.write(_build_row_bytes(1, col_labels))
        rn = 1
        for vals in row_iter:
            rn += 1
            f.write(_build_row_bytes(rn, vals))
            total += 1
            if total % 10000 == 0:
                time.sleep(0.001)
        f.write(b'</sheetData></worksheet>')
    return tmp, total


def main():
    os.nice(10)
    tsv_path = sys.argv[1]
    xlsx_path = sys.argv[2]
    columns_json = sys.argv[3]
    spec_path = sys.argv[4] if len(sys.argv) > 4 else None

    sheet_names = []
    sheet_temps = []  # (temp_path, zip_entry_name) pairs

    try:
        # ── Phase 1: 统计 sheet(从 JSON spec) ──
        if spec_path and os.path.exists(spec_path):
            with open(spec_path, "r", encoding="utf-8") as f:
                spec = json.load(f)
            for sspec in spec.get("sheets", []):
                sname = sspec.get("name", f"Sheet{len(sheet_names)+1}")
                sheet_names.append(sname)
                cols = sspec["columns"]
                col_names = [c["name"] for c in cols]
                col_labels = [c["label"] for c in cols]

                def _spec_rows():
                    for row in sspec.get("rows", []):
                        yield [row.get(cn) for cn in col_names]

                tmp, cnt = _write_sheet_to_temp(col_labels, _spec_rows(), "summary")
                sheet_temps.append(tmp)

        # ── Phase 2: 明细 sheet(从 TSV, 百万行分 sheet) ──
        detail_columns = json.loads(columns_json)
        d_names = [c["name"] for c in detail_columns]
        d_labels = [c["label"] for c in detail_columns]

        # 先读取 TSV header 建立列映射
        with open(tsv_path, "r", encoding="utf-8", errors="replace") as tf:
            header = tf.readline().rstrip("\n").split("\t")
            col_idx = []
            for cn in d_names:
                try:
                    col_idx.append(header.index(cn))
                except ValueError:
                    col_idx.append(-1)

            detail_sheet_num = 0
            row_in_sheet = 0
            global_row = 0
            current_tmp = None
            current_f = None

            def _start_detail():
                nonlocal detail_sheet_num, current_tmp, current_f, row_in_sheet
                detail_sheet_num += 1
                sname = "明细" if detail_sheet_num == 1 else f"明细_{detail_sheet_num}"
                sheet_names.append(sname)
                current_tmp = tempfile.mktemp(suffix=".xml")
                current_f = open(current_tmp, "wb")
                current_f.write(b'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
                current_f.write(b'<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>')
                current_f.write(_build_row_bytes(1, d_labels))
                row_in_sheet = 1
                sheet_temps.append(current_tmp)

            def _close_detail():
                nonlocal current_f
                if current_f:
                    current_f.write(b'</sheetData></worksheet>')
                    current_f.close()
                    current_f = None

            _start_detail()

            for line in tf:
                fields = line.rstrip("\n").split("\t")
                row_data = [fields[i] if 0 <= i < len(fields) else "" for i in col_idx]
                row_in_sheet += 1
                current_f.write(_build_row_bytes(row_in_sheet, row_data))
                global_row += 1
                if global_row % 10000 == 0:
                    time.sleep(0.001)
                if row_in_sheet >= MAX_ROWS_PER_SHEET:
                    _close_detail()
                    _start_detail()

            _close_detail()

        # ── Phase 3: 打包 xlsx ──
        num_sheets = len(sheet_temps)
        ct_parts = [
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            '<Default Extension="xml" ContentType="application/xml"/>'
            '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>',
        ]
        wb_sheets = []
        wb_rels = []
        for i in range(num_sheets):
            sname = sheet_names[i]
            ct_parts.append(f'<Override PartName="/xl/worksheets/sheet{i+1}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>')
            wb_sheets.append(f'<sheet name="{sname}" sheetId="{i+1}" r:id="rId{i+1}"/>')
            wb_rels.append(f'<Relationship Id="rId{i+1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet{i+1}.xml"/>')
        ct_parts.append("</Types>")

        with zipfile.ZipFile(xlsx_path, "w", zipfile.ZIP_DEFLATED) as zf:
            zf.writestr("[Content_Types].xml", "".join(ct_parts))
            zf.writestr("_rels/.rels",
                '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
                '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>'
                '</Relationships>')
            zf.writestr("xl/workbook.xml",
                f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
                f'<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" '
                f'xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">'
                f'<sheets>{"".join(wb_sheets)}</sheets></workbook>')
            zf.writestr("xl/_rels/workbook.xml.rels",
                f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
                f'<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">'
                f'{"".join(wb_rels)}</Relationships>')
            # 逐个 sheet 写入 ZIP, 写完立即删临时文件(控制磁盘占用)
            for i, tmp in enumerate(sheet_temps):
                zf.write(tmp, f"xl/worksheets/sheet{i+1}.xml")
                try:
                    os.unlink(tmp)
                except OSError:
                    pass

        xlsx_size = os.path.getsize(xlsx_path)
        print(f"Done: {num_sheets} sheet(s), {global_row} detail rows, xlsx={xlsx_size} bytes")

    except Exception as e:
        # 清理所有临时文件
        for tmp in sheet_temps:
            try:
                os.unlink(tmp)
            except OSError:
                pass
        raise


if __name__ == "__main__":
    main()

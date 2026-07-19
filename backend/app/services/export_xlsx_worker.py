#!/usr/bin/env python3
"""Standalone xlsx export worker — 直接流式写 ZIP(无临时文件), 支持百万行分 sheet。

Usage:
    python export_xlsx_worker.py <tsv_path> <xlsx_path> <columns_json> [<spec_json_path>]

无 spec_json_path: 仅从 TSV 生成明细 sheets(日志查询导出)
有 spec_json_path: 先从 JSON 生成统计 sheet, 再从 TSV 生成明细 sheets(数据统计导出)

关键优化: 直接用 zipfile.open() 流式写入 sheet XML, 不生成临时文件。
"""
import sys
import os
import json
import time
import zipfile

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


def _esc(s):
    if s is None:
        return ""
    return str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def _num_str(val):
    if val in ("NULL", "\\N", "", None):
        return None
    try:
        f = float(val)
        return str(int(f)) if f == int(f) else repr(f)
    except (ValueError, TypeError):
        return None


def _write_row_to_zip(zf, cell_ref_row, values):
    """拼一行 XML 并直接写入 ZIP entry(字节级, 避免 Python 字符串拼接内存)。"""
    parts = [b'<row r="', str(cell_ref_row).encode(), b'">']
    for ci, val in enumerate(values):
        col = _col_letter(ci + 1).encode()
        ref = col + str(cell_ref_row).encode()
        if val is None or val == "":
            parts.append(b'<c r="' + ref + b'"/>')
            continue
        ns = _num_str(val)
        if ns is not None:
            parts.append(b'<c r="' + ref + b'"><v>' + ns.encode() + b'</v></c>')
        else:
            parts.append(b'<c r="' + ref + b'" t="inlineStr"><is><t>' + _esc(val).encode() + b'</t></is></c>')
    parts.append(b'</row>')
    zf.write(b"".join(parts))


def main():
    os.nice(10)
    tsv_path = sys.argv[1]
    xlsx_path = sys.argv[2]
    columns_json = sys.argv[3]
    spec_path = sys.argv[4] if len(sys.argv) > 4 else None

    sheet_count = 0
    sheet_names = []

    # 用 ZIP_STORED(不压缩), xlsx 的 XML 重复度高但 ZIP 压缩收益不大, 换速度
    with zipfile.ZipFile(xlsx_path, "w", zipfile.ZIP_DEFLATED) as zf:

        # ── Phase 1: 统计 sheet(从 JSON spec, 可选) ──
        if spec_path and os.path.exists(spec_path):
            with open(spec_path, "r", encoding="utf-8") as f:
                spec = json.load(f)
            for sspec in spec.get("sheets", []):
                sheet_count += 1
                sname = sspec.get("name", f"Sheet{sheet_count}")
                sheet_names.append(sname)
                cols = sspec["columns"]
                col_names = [c["name"] for c in cols]
                col_labels = [c["label"] for c in cols]

                with zf.open(f"xl/worksheets/sheet{sheet_count}.xml", "w") as sf:
                    sf.write(b'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
                    sf.write(b'<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>')
                    _write_row_to_zip(sf, 1, col_labels)
                    rn = 1
                    for row in sspec.get("rows", []):
                        rn += 1
                        _write_row_to_zip(sf, rn, [row.get(cn) for cn in col_names])
                    sf.write(b'</sheetData></worksheet>')

        # ── Phase 2: 明细 sheets(从 TSV, 百万行分 sheet, 流式写 ZIP) ──
        detail_columns = json.loads(columns_json)
        d_names = [c["name"] for c in detail_columns]
        d_labels = [c["label"] for c in detail_columns]

        detail_sheet_num = 0
        detail_row_in_sheet = 0
        detail_global_row = 0
        current_sf = None  # 当前 ZIP entry 的文件对象

        def _start_detail_sheet():
            nonlocal detail_sheet_num, current_sf, detail_row_in_sheet, sheet_count
            detail_sheet_num += 1
            sheet_count += 1
            sname = "明细" if detail_sheet_num == 1 else f"明细_{detail_sheet_num}"
            sheet_names.append(sname)
            current_sf = zf.open(f"xl/worksheets/sheet{sheet_count}.xml", "w")
            current_sf.write(b'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
            current_sf.write(b'<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>')
            _write_row_to_zip(current_sf, 1, d_labels)
            detail_row_in_sheet = 1

        def _close_detail_sheet():
            nonlocal current_sf
            if current_sf:
                current_sf.write(b'</sheetData></worksheet>')
                current_sf.close()
                current_sf = None

        _start_detail_sheet()

        with open(tsv_path, "r", encoding="utf-8", errors="replace") as tf:
            header = tf.readline().rstrip("\n").split("\t")
            col_idx = []
            for cn in d_names:
                try:
                    col_idx.append(header.index(cn))
                except ValueError:
                    col_idx.append(-1)

            for line in tf:
                fields = line.rstrip("\n").split("\t")
                row_data = [fields[i] if 0 <= i < len(fields) else "" for i in col_idx]
                detail_row_in_sheet += 1
                _write_row_to_zip(current_sf, detail_row_in_sheet, row_data)
                detail_global_row += 1
                if detail_global_row % 10000 == 0:
                    time.sleep(0.001)
                if detail_row_in_sheet >= MAX_ROWS_PER_SHEET:
                    _close_detail_sheet()
                    _start_detail_sheet()

        _close_detail_sheet()

        # ── Phase 3: 写固定 XML(Content_Types, rels, workbook) ──
        ct_parts = [
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
            '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">'
            '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>'
            '<Default Extension="xml" ContentType="application/xml"/>'
            '<Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>',
        ]
        wb_sheets = []
        wb_rels = []
        for i in range(sheet_count):
            sname = sheet_names[i]
            ct_parts.append(f'<Override PartName="/xl/worksheets/sheet{i+1}.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>')
            wb_sheets.append(f'<sheet name="{_esc(sname)}" sheetId="{i+1}" r:id="rId{i+1}"/>')
            wb_rels.append(f'<Relationship Id="rId{i+1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet{i+1}.xml"/>')
        ct_parts.append("</Types>")

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

    print(f"Done: {sheet_count} sheet(s), {detail_global_row} detail rows")


if __name__ == "__main__":
    main()

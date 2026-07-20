#!/usr/bin/env python3
"""xlsx export worker — awk 做 XML 生成(C速度), Python 仅编排+打包ZIP。

Usage:
    python export_xlsx_worker.py <tsv_path> <xlsx_path> <columns_json> [<spec_json_path>]

流程:
    1. (可选) JSON spec → 统计 sheet XML(数据小, Python 直接写)
    2. awk 读 TSV → 生成明细 sheet XML(Python 从 pipe 读, 转发到临时文件)
    3. Python 打包所有 sheet 到 ZIP(xlsx)

awk 处理百万行只需 ~150s(vs Python ~1500s), CPU 大幅下降。
"""
import sys
import os
import json
import time
import zipfile
import tempfile
import subprocess

try:
    os.nice(10)
except OSError:
    pass

MAX_ROWS_PER_SHEET = 1000000
AWK_SCRIPT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tsv_to_xlsx.awk")

_XML_HEAD = b'<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
_WS_OPEN = b'<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>'
_WS_CLOSE = b'</sheetData></worksheet>'


def _col_letter(n):
    r = ""
    while n > 0:
        n, rem = divmod(n - 1, 26)
        r = chr(65 + rem) + r
    return r


def _esc_bytes(val):
    if val is None:
        return b""
    s = str(val).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")
    return s.encode("utf-8")


def _build_row_bytes(row_num, values):
    parts = [b'<row r="', str(row_num).encode(), b'">']
    for ci, val in enumerate(values):
        col = _col_letter(ci + 1).encode()
        ref = col + str(row_num).encode()
        if val is None or val == "":
            parts.append(b'<c r="' + ref + b'"/>')
            continue
        try:
            f = float(val)
            nb = str(int(f)).encode() if f == int(f) else repr(f).encode()
            parts.append(b'<c r="' + ref + b'"><v>' + nb + b'</v></c>')
        except (ValueError, TypeError):
            parts.append(b'<c r="' + ref + b'" t="inlineStr"><is><t>' + _esc_bytes(val) + b'</t></is></c>')
    parts.append(b'</row>')
    return b"".join(parts)


def main():
    os.nice(10)
    tsv_path = sys.argv[1]
    xlsx_path = sys.argv[2]
    columns_json = sys.argv[3]
    spec_path = sys.argv[4] if len(sys.argv) > 4 else None

    sheet_names = []
    sheet_count = 0
    global_row = 0

    # 临时文件列表(用于异常清理)
    temp_xmls = []
    current_temp = None
    current_f = None

    try:
        with zipfile.ZipFile(xlsx_path, "w", zipfile.ZIP_DEFLATED) as zf:

            # ── Phase 1: 统计 sheet(从 JSON spec, 数据小) ──
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

                    tmp = tempfile.mktemp(suffix=".xml")
                    temp_xmls.append(tmp)
                    with open(tmp, "wb") as wf:
                        wf.write(_XML_HEAD + _WS_OPEN)
                        wf.write(_build_row_bytes(1, col_labels))
                        rn = 1
                        for row in sspec.get("rows", []):
                            rn += 1
                            wf.write(_build_row_bytes(rn, [row.get(cn) for cn in col_names]))
                        wf.write(_WS_CLOSE)

                    zf.write(tmp, f"xl/worksheets/sheet{sheet_count}.xml")
                    os.unlink(tmp)
                    temp_xmls.pop()

            # ── Phase 2: awk 读 TSV → 生成明细 sheet XML ──
            detail_columns = json.loads(columns_json)
            d_labels = [c["label"] for c in detail_columns]

            # 启动 awk 子进程
            awk_cmd = ["awk", "-f", AWK_SCRIPT,
                       "-v", f"MAX_ROWS={MAX_ROWS_PER_SHEET}",
                       "-v", "SHEET_PREFIX=明细",
                       tsv_path]

            proc = subprocess.Popen(awk_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)

            detail_sheet_num = 0

            for raw_line in proc.stdout:
                line = raw_line.rstrip(b"\n")

                if line.startswith(b"SHEET_START:"):
                    # 新建 sheet
                    detail_sheet_num += 1
                    sheet_count += 1
                    sname = line[len(b"SHEET_START:"):].decode("utf-8")
                    sheet_names.append(sname)
                    current_temp = tempfile.mktemp(suffix=".xml")
                    temp_xmls.append(current_temp)
                    current_f = open(current_temp, "wb")
                    current_f.write(_XML_HEAD)
                    current_f.write(b'<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>')

                elif line.startswith(b"SHEET_END"):
                    # 关闭 sheet, 加入 ZIP, 删除临时
                    if current_f:
                        current_f.write(b'</sheetData></worksheet>')
                        current_f.close()
                        current_f = None
                        zf.write(current_temp, f"xl/worksheets/sheet{sheet_count}.xml")
                        os.unlink(current_temp)
                        temp_xmls.pop()
                        current_temp = None

                elif line.startswith(b"DONE:"):
                    # 解析总行数
                    try:
                        global_row = int(line[len(b"DONE:"):])
                    except ValueError:
                        pass

                else:
                    # XML 数据行, 直接写入当前 sheet 文件
                    if current_f:
                        current_f.write(raw_line)

            proc.wait()
            if proc.returncode != 0:
                stderr = proc.stderr.read().decode("utf-8", errors="replace")[:300]
                raise RuntimeError(f"awk failed (exit={proc.returncode}): {stderr}")

            # ── Phase 3: 写固定 XML ──
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
                wb_sheets.append(f'<sheet name="{sname}" sheetId="{i+1}" r:id="rId{i+1}"/>')
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

        xlsx_size = os.path.getsize(xlsx_path)
        print(f"Done: {sheet_count} sheet(s), {global_row} detail rows, xlsx={xlsx_size} bytes")

    except Exception:
        # 清理
        if current_f:
            try:
                current_f.close()
            except Exception:
                pass
        for tmp in temp_xmls:
            try:
                os.unlink(tmp)
            except OSError:
                pass
        raise


if __name__ == "__main__":
    main()

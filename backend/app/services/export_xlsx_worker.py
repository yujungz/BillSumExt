#!/usr/bin/env python3
"""Standalone xlsx export worker — 直接生成 XML(不依赖 openpyxl), 5-10x 更快更低 CPU。

Usage:
    python export_xlsx_worker.py <tsv_path> <xlsx_path> <columns_json>

读取 mysql --batch 的 TSV 输出，直接拼 XML 生成 xlsx(跳过 openpyxl 对象层)。
每 10000 行 sleep 1ms 让出 CPU；os.nice 降低调度优先级。
"""
import sys
import os
import json
import time
import zipfile
import tempfile

# 降低进程优先级，不抢占 uvicorn CPU
try:
    os.nice(10)
except OSError:
    pass

# xlsx 常量 XML
_CT = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>'
_RELS = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'
_WB = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Data" sheetId="1" r:id="rId1"/></sheets></workbook>'
_WB_RELS = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/></Relationships>'


def _col_letter(n):
    """1→A, 26→Z, 27→AA"""
    r = ""
    while n > 0:
        n, rem = divmod(n - 1, 26)
        r = chr(65 + rem) + r
    return r


def _esc(s):
    """XML 转义"""
    return str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def _num_str(val):
    """尝试返回数值字符串, 非数返回 None"""
    if val in ("NULL", "\\N", "", None):
        return None
    try:
        f = float(val)
        return str(int(f)) if f == int(f) else repr(f)
    except (ValueError, TypeError):
        return None


def _row_xml(row_num, values):
    """拼一行 XML"""
    parts = [f'<row r="{row_num}">']
    for ci, val in enumerate(values):
        cell_ref = f"{_col_letter(ci + 1)}{row_num}"
        if val is None or val == "":
            parts.append(f'<c r="{cell_ref}"/>')
            continue
        ns = _num_str(val)
        if ns is not None:
            parts.append(f'<c r="{cell_ref}"><v>{ns}</v></c>')
        else:
            parts.append(f'<c r="{cell_ref}" t="inlineStr"><is><t>{_esc(val)}</t></is></c>')
    parts.append("</row>")
    return "".join(parts)


def main():
    os.nice(10)
    tsv_path = sys.argv[1]
    xlsx_path = sys.argv[2]
    columns_json = sys.argv[3]

    columns = json.loads(columns_json)
    col_names = [c["name"] for c in columns]
    col_labels = [c["label"] for c in columns]

    # 写 sheet XML 到临时文件(流式, 低内存)
    sheet_tmp = tempfile.mktemp(suffix=".xml")
    with open(sheet_tmp, "w", encoding="utf-8") as sf:
        sf.write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
        sf.write('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>')

        # 表头
        sf.write(_row_xml(1, col_labels))

        with open(tsv_path, "r", encoding="utf-8", errors="replace") as tf:
            # mysql --batch 第一行是列名
            header = tf.readline().rstrip("\n").split("\t")
            col_idx = []
            for cn in col_names:
                try:
                    col_idx.append(header.index(cn))
                except ValueError:
                    col_idx.append(-1)

            row_num = 2
            for line in tf:
                fields = line.rstrip("\n").split("\t")
                row_data = [fields[i] if 0 <= i < len(fields) else "" for i in col_idx]
                sf.write(_row_xml(row_num, row_data))
                row_num += 1
                # 每 10000 行让出 CPU 1ms
                if row_num % 10000 == 0:
                    time.sleep(0.001)

        sf.write("</sheetData></worksheet>")

    # 打包 xlsx (ZIP)
    with zipfile.ZipFile(xlsx_path, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", _CT)
        zf.writestr("_rels/.rels", _RELS)
        zf.writestr("xl/workbook.xml", _WB)
        zf.writestr("xl/_rels/workbook.xml.rels", _WB_RELS)
        zf.write(sheet_tmp, "xl/worksheets/sheet1.xml")

    os.unlink(sheet_tmp)


if __name__ == "__main__":
    main()

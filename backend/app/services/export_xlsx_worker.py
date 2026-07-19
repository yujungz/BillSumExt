#!/usr/bin/env python3
"""Standalone xlsx export worker — 直接生成 XML(不依赖 openpyxl), 支持百万行分 sheet。

Usage:
    python export_xlsx_worker.py <tsv_path> <xlsx_path> <columns_json>

读取 mysql --batch 的 TSV 输出，直接拼 XML 生成 xlsx。
每 100 万行自动分 sheet（Data / Data_2 / Data_3 ...）。
"""
import sys
import os
import json
import time
import zipfile
import tempfile

# 降低进程优先级
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
    return str(s).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def _num_str(val):
    if val in ("NULL", "\\N", "", None):
        return None
    try:
        f = float(val)
        return str(int(f)) if f == int(f) else repr(f)
    except (ValueError, TypeError):
        return None


def _row_xml(row_num, values):
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

    sheet_files = []  # 临时 XML 文件路径列表
    sheet_names = []  # sheet 显示名

    with open(tsv_path, "r", encoding="utf-8", errors="replace") as tf:
        header = tf.readline().rstrip("\n").split("\t")
        col_idx = []
        for cn in col_names:
            try:
                col_idx.append(header.index(cn))
            except ValueError:
                col_idx.append(-1)

        sheet_num = 0
        sheet_file = None
        row_in_sheet = 0
        global_row = 0

        def _start_sheet():
            nonlocal sheet_num, sheet_file, row_in_sheet
            sheet_num += 1
            sname = "Data" if sheet_num == 1 else f"Data_{sheet_num}"
            sheet_names.append(sname)
            sf = tempfile.mktemp(suffix=".xml")
            sheet_file = open(sf, "w", encoding="utf-8")
            sheet_file.write('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
            sheet_file.write('<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>')
            # 每个 sheet 都写表头
            sheet_file.write(_row_xml(1, col_labels))
            row_in_sheet = 1  # header counted
            sheet_files.append(sf)

        def _close_sheet():
            nonlocal sheet_file
            if sheet_file:
                sheet_file.write("</sheetData></worksheet>")
                sheet_file.close()
                sheet_file = None

        _start_sheet()

        for line in tf:
            fields = line.rstrip("\n").split("\t")
            row_data = [fields[i] if 0 <= i < len(fields) else "" for i in col_idx]
            row_in_sheet += 1
            sheet_file.write(_row_xml(row_in_sheet, row_data))
            global_row += 1
            if global_row % 10000 == 0:
                time.sleep(0.001)
            # 超过单 sheet 上限，新建 sheet
            if row_in_sheet >= MAX_ROWS_PER_SHEET:
                _close_sheet()
                _start_sheet()

        _close_sheet()

    # 生成动态 XML
    num_sheets = len(sheet_files)
    ct_parts = [
        '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>',
        '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">',
        '<Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>',
        '<Default Extension="xml" ContentType="application/xml"/>',
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

    ct_xml = "".join(ct_parts)
    wb_xml = f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets>{"".join(wb_sheets)}</sheets></workbook>'
    wb_rels_xml = f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">{"".join(wb_rels)}</Relationships>'
    rels_xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'

    # 打包 xlsx
    with zipfile.ZipFile(xlsx_path, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", ct_xml)
        zf.writestr("_rels/.rels", rels_xml)
        zf.writestr("xl/workbook.xml", wb_xml)
        zf.writestr("xl/_rels/workbook.xml.rels", wb_rels_xml)
        for i, sf in enumerate(sheet_files):
            zf.write(sf, f"xl/worksheets/sheet{i+1}.xml")
            os.unlink(sf)

    print(f"Done: {global_row} rows in {num_sheets} sheet(s)")


if __name__ == "__main__":
    main()

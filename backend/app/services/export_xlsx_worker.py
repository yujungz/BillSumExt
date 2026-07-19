#!/usr/bin/env python3
"""Standalone xlsx export worker — 直接生成 XML, 支持统计+明细合并 + 百万行分 sheet。

Usage:
    python export_xlsx_worker.py <tsv_path> <xlsx_path> <columns_json> [<spec_json_path>]

无 spec_json_path: 仅从 TSV 生成明细 sheets(日志查询导出)
有 spec_json_path: 先从 JSON 生成统计 sheet, 再从 TSV 生成明细 sheets(数据统计导出)
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
_XML_HEAD = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
_WS_OPEN = '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>'
_WS_CLOSE = '</sheetData></worksheet>'


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


def _write_sheet_xml(sf_path, col_labels, rows_iter, has_total_fields=None):
    """写一个 sheet XML 文件。rows_iter 产出 list[str] 行数据。"""
    with open(sf_path, "w", encoding="utf-8") as wf:
        wf.write(_XML_HEAD + _WS_OPEN)
        wf.write(_row_xml(1, col_labels))
        rn = 1
        for vals in rows_iter:
            rn += 1
            wf.write(_row_xml(rn, vals))
        wf.write(_WS_CLOSE)


def main():
    os.nice(10)
    tsv_path = sys.argv[1]
    xlsx_path = sys.argv[2]
    columns_json = sys.argv[3]
    spec_path = sys.argv[4] if len(sys.argv) > 4 else None

    sheet_files = []
    sheet_names = []

    # ── Phase 1: 统计 sheet(从 JSON spec, 可选) ──
    if spec_path and os.path.exists(spec_path):
        with open(spec_path, "r", encoding="utf-8") as f:
            spec = json.load(f)
        for sspec in spec.get("sheets", []):
            sname = sspec.get("name", "统计")
            sheet_names.append(sname)
            cols = sspec["columns"]
            col_names = [c["name"] for c in cols]
            col_labels = [c["label"] for c in cols]

            sf = tempfile.mktemp(suffix=".xml")
            with open(sf, "w", encoding="utf-8") as wf:
                wf.write(_XML_HEAD + _WS_OPEN)
                wf.write(_row_xml(1, col_labels))
                rn = 1
                for row in sspec.get("rows", []):
                    rn += 1
                    wf.write(_row_xml(rn, [row.get(cn) for cn in col_names]))
                wf.write(_WS_CLOSE)
            sheet_files.append(sf)

    # ── Phase 2: 明细 sheets(从 TSV, 百万行分 sheet) ──
    detail_columns = json.loads(columns_json)
    d_names = [c["name"] for c in detail_columns]
    d_labels = [c["label"] for c in detail_columns]

    detail_sheet_num = 0
    detail_file = None
    detail_row_in_sheet = 0
    detail_global_row = 0

    def _start_detail_sheet():
        nonlocal detail_sheet_num, detail_file, detail_row_in_sheet
        detail_sheet_num += 1
        sname = "明细" if detail_sheet_num == 1 else f"明细_{detail_sheet_num}"
        sheet_names.append(sname)
        sf = tempfile.mktemp(suffix=".xml")
        detail_file = open(sf, "w", encoding="utf-8")
        detail_file.write(_XML_HEAD + _WS_OPEN)
        detail_file.write(_row_xml(1, d_labels))
        detail_row_in_sheet = 1
        sheet_files.append(sf)

    def _close_detail_sheet():
        nonlocal detail_file
        if detail_file:
            detail_file.write(_WS_CLOSE)
            detail_file.close()
            detail_file = None

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
            detail_file.write(_row_xml(detail_row_in_sheet, row_data))
            detail_global_row += 1
            if detail_global_row % 10000 == 0:
                time.sleep(0.001)
            if detail_row_in_sheet >= MAX_ROWS_PER_SHEET:
                _close_detail_sheet()
                _start_detail_sheet()

    _close_detail_sheet()

    # ── Phase 3: 打包 xlsx ──
    num_sheets = len(sheet_files)
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
        wb_sheets.append(f'<sheet name="{_esc(sname)}" sheetId="{i+1}" r:id="rId{i+1}"/>')
        wb_rels.append(f'<Relationship Id="rId{i+1}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet{i+1}.xml"/>')
    ct_parts.append("</Types>")

    ct_xml = "".join(ct_parts)
    wb_xml = f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets>{"".join(wb_sheets)}</sheets></workbook>'
    wb_rels_xml = f'<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">{"".join(wb_rels)}</Relationships>'
    rels_xml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'

    with zipfile.ZipFile(xlsx_path, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("[Content_Types].xml", ct_xml)
        zf.writestr("_rels/.rels", rels_xml)
        zf.writestr("xl/workbook.xml", wb_xml)
        zf.writestr("xl/_rels/workbook.xml.rels", wb_rels_xml)
        for i, sf in enumerate(sheet_files):
            zf.write(sf, f"xl/worksheets/sheet{i+1}.xml")
            os.unlink(sf)

    print(f"Done: {num_sheets} sheet(s), {detail_global_row} detail rows")


if __name__ == "__main__":
    main()

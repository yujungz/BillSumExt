#!/usr/bin/env python3
"""通用 xlsx 导出子进程 — 读取 JSON spec, 生成 xlsx, 完全独立于 uvicorn GIL。

Usage:
    python generic_xlsx_worker.py <spec_json_path> <xlsx_output_path>

spec JSON 格式:
{
  "sheets": [
    {
      "name": "Sheet名",
      "columns": [{"name": "field_key", "label": "显示标题"}, ...],
      "rows": [{"field_key": value, ...}, ...],
      "total_fields": ["field_key", ...]   // 可选, 需要合计的列
    },
    ...
  ]
}
"""
import sys
import os
import json
import time
import openpyxl

# 降低进程优先级，不抢占 uvicorn CPU
try:
    os.nice(10)
except OSError:
    pass


def _convert(val):
    """尝试将字符串转为数值(mysql --batch 输出均为字符串)。"""
    if val is None:
        return None
    if isinstance(val, str):
        if val in ("NULL", "\\N", ""):
            return None
        try:
            return int(val)
        except ValueError:
            try:
                return float(val)
            except ValueError:
                return val
    return val


def main():
    spec_path = sys.argv[1]
    xlsx_path = sys.argv[2]

    with open(spec_path, "r", encoding="utf-8") as f:
        spec = json.load(f)

    wb = openpyxl.Workbook(write_only=True)

    MAX_PER_SHEET = 1000000

    for sheet_spec in spec.get("sheets", []):
        base_name = sheet_spec.get("name", "Sheet")
        cols = sheet_spec["columns"]
        col_names = [c["name"] for c in cols]
        labels = [c["label"] for c in cols]

        sheet_idx = 0
        row_in_sheet = 0
        ws = None

        def _new_ws():
            nonlocal ws, sheet_idx, row_in_sheet
            sheet_idx += 1
            sname = base_name if sheet_idx == 1 else f"{base_name}_{sheet_idx}"
            ws = wb.create_sheet(sname)
            ws.append(labels)
            row_in_sheet = 1

        _new_ws()

        for row in sheet_spec.get("rows", []):
            if row_in_sheet >= MAX_PER_SHEET:
                _new_ws()
            ws.append([_convert(row.get(cn)) for cn in col_names])
            row_in_sheet += 1
            if row_in_sheet % 10000 == 0:
                time.sleep(0.001)

        # 合计行(可选)
        total_fields = sheet_spec.get("total_fields")
        if total_fields:
            ws.append([])
            total_row = [""] * len(cols)
            total_row[0] = "合计"
            for tf in total_fields:
                idx = col_names.index(tf) if tf in col_names else -1
                if idx >= 0:
                    sm = sum(
                        (r.get(tf) or 0) for r in sheet_spec.get("rows", [])
                        if isinstance(r.get(tf), (int, float))
                    )
                    total_row[idx] = sm
            ws.append(total_row)

    wb.save(xlsx_path)


if __name__ == "__main__":
    main()

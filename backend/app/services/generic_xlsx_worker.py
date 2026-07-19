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

    for sheet_spec in spec.get("sheets", []):
        ws = wb.create_sheet(sheet_spec.get("name", "Sheet"))
        cols = sheet_spec["columns"]
        col_names = [c["name"] for c in cols]

        # 表头
        ws.append([c["label"] for c in cols])

        # 数据行
        row_num = 0
        for row in sheet_spec.get("rows", []):
            ws.append([_convert(row.get(cn)) for cn in col_names])
            row_num += 1
            if row_num % 10000 == 0:
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

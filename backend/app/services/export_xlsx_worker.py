#!/usr/bin/env python3
"""Standalone xlsx export worker — runs as a SUBPROCESS to avoid GIL blocking uvicorn.

Usage:
    python export_xlsx_worker.py <tsv_path> <xlsx_path> <columns_json>

Reads a TSV file (from `mysql --batch`), converts to xlsx using openpyxl
write_only mode, and writes to <xlsx_path>. The <columns_json> specifies
which columns to include and their display labels:

    [{"name": "id", "label": "用户ID"}, {"name": "username", "label": "用户名"}, ...]
"""
import sys
import json
import openpyxl


def _convert(val):
    """Convert mysql --batch string output to appropriate Python type."""
    if val == "NULL" or val == "\\N" or val == "":
        return None
    # Strip non-numeric noise
    try:
        return int(val)
    except ValueError:
        try:
            return float(val)
        except ValueError:
            return val


def main():
    tsv_path = sys.argv[1]
    xlsx_path = sys.argv[2]
    columns_json = sys.argv[3]

    columns = json.loads(columns_json)
    col_names = [c["name"] for c in columns]
    col_labels = [c["label"] for c in columns]

    wb = openpyxl.Workbook(write_only=True)
    ws = wb.create_sheet("Data")

    # Header row
    ws.append(col_labels)

    with open(tsv_path, "r", encoding="utf-8", errors="replace") as f:
        # First line is mysql --batch column names (tab-separated)
        header = f.readline().rstrip("\n").split("\t")
        # Build index: for each desired column, find its position in TSV
        col_idx = []
        for cn in col_names:
            try:
                col_idx.append(header.index(cn))
            except ValueError:
                col_idx.append(-1)

        # Data rows
        for line in f:
            fields = line.rstrip("\n").split("\t")
            row = []
            for idx in col_idx:
                if 0 <= idx < len(fields):
                    row.append(_convert(fields[idx]))
                else:
                    row.append(None)
            ws.append(row)

    wb.save(xlsx_path)


if __name__ == "__main__":
    main()

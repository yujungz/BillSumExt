"""Helpers for writing DB values into openpyxl worksheets safely.

DB fields (e.g. username, channel_name, model_name) may contain XML-illegal
control chars (\\x00-\\x08, \\x0b, \\x0c, \\x0e-\\x1f) that openpyxl rejects
with 'X cannot be used in worksheets'. They may also come back as Decimal or
other driver types. Use cell_value()/sanitize_row() on every cell write."""

import re
import datetime
from decimal import Decimal

# 非法控制字符，保留 \t(\x09) \n(\x0a) \r(\x0d)
_ILLEGAL_CELL_CHARS = re.compile(r'[\x00-\x08\x0b\x0c\x0e-\x1f]')


def cell_value(v):
    """Coerce a single value to an openpyxl-safe cell value."""
    if v is None:
        return None
    if isinstance(v, str):
        return _ILLEGAL_CELL_CHARS.sub('', v)
    if isinstance(v, (int, float, bool)):
        return v
    if isinstance(v, (datetime.datetime, datetime.date, datetime.time)):
        return v
    if isinstance(v, Decimal):
        return float(v)
    return _ILLEGAL_CELL_CHARS.sub('', str(v))


def sanitize_row(row):
    """Apply cell_value to each element; return a list."""
    return [cell_value(v) for v in row]

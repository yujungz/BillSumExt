"""Shared helpers for subprocess-based xlsx export (avoids GIL blocking uvicorn)."""
import os
import sys
import json
import tempfile
import subprocess

GENERIC_WORKER = os.path.join(os.path.dirname(__file__), "generic_xlsx_worker.py")

# 临时文件优先用 /dev/shm(内存磁盘, 零磁盘 I/O)
_TMP_DIR = "/dev/shm" if os.path.isdir("/dev/shm") else None


async def generate_xlsx_subprocess(loop, spec):
    """通过 generic_xlsx_worker 子进程生成 xlsx, 返回临时文件路径。
    spec 格式见 generic_xlsx_worker.py 文档。
    子进程独立 Python 解释器, 不占 uvicorn GIL。"""
    # 写 spec 到临时 JSON(/dev/shm)
    spec_fd, spec_path = tempfile.mkstemp(suffix=".json", dir=_TMP_DIR)
    with os.fdopen(spec_fd, "w", encoding="utf-8") as f:
        json.dump(spec, f, ensure_ascii=False, default=str)

    xlsx_path = tempfile.mktemp(suffix=".xlsx", dir=_TMP_DIR)

    def _run_worker():
        return subprocess.run(
            [sys.executable, GENERIC_WORKER, spec_path, xlsx_path],
            capture_output=True, timeout=3600,
        )

    proc = await loop.run_in_executor(None, _run_worker)
    os.unlink(spec_path)

    if proc.returncode != 0:
        try:
            os.unlink(xlsx_path)
        except OSError:
            pass
        raise RuntimeError(f"xlsx worker failed: {proc.stderr.decode('utf-8', errors='replace')[:300]}")

    return xlsx_path

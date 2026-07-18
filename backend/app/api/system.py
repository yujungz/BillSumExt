"""System API - binlog management, user management, system logs, and SQL execution."""

import asyncio
import os
import re
import subprocess
import tempfile
import logging

from fastapi import APIRouter, Query, UploadFile, File, HTTPException, Request
from pydantic import BaseModel
from app import database as db
from app.config import AppConfig

log = logging.getLogger(__name__)
router = APIRouter(prefix="/api/system", tags=["system"])

# ── Binlog Management ────────────────────────────────────────────────

@router.get("/binlog")
async def get_binlog_info():
    rows = await db.fetch_all("SHOW BINARY LOGS")
    return {"binlogs": rows}


class PurgeRequest(BaseModel):
    before: str = ""


@router.post("/binlog/purge")
async def purge_binlog(req: PurgeRequest):
    if req.before:
        await db.execute(f"PURGE BINARY LOGS TO '{req.before}'")
    else:
        await db.execute("PURGE BINARY LOGS BEFORE NOW()")
    return {"success": True}


# ── undo tablespace 管理 ──

_UNDO_NAME_RE = re.compile(r'^innodb_undo_\d+$')


def _validate_undo_name(name: str):
    if not _UNDO_NAME_RE.match(name):
        raise HTTPException(400, detail=f"无效的 undo tablespace 名: {name}")


@router.get("/undo")
async def list_undo():
    try:
        rows = await db.fetch_all(
            "SELECT NAME, STATE, ROUND(FILE_SIZE / 1024 / 1024, 2) AS size_mb "
            "FROM information_schema.INNODB_TABLESPACES WHERE NAME LIKE '%undo%'"
        )
        return {"undo": rows}
    except Exception as e:
        raise HTTPException(500, detail=f"查询 undo 失败: {str(e)[:300]}")


class UndoNameReq(BaseModel):
    name: str


@router.post("/undo/set-inactive")
async def undo_set_inactive(req: UndoNameReq):
    _validate_undo_name(req.name)
    try:
        await db.execute(f"ALTER UNDO TABLESPACE `{req.name}` SET INACTIVE")
        return {"success": True}
    except Exception as e:
        raise HTTPException(500, detail=f"关闭 undo 失败: {str(e)[:300]}")


@router.post("/undo/set-active")
async def undo_set_active(req: UndoNameReq):
    _validate_undo_name(req.name)
    try:
        await db.execute(f"ALTER UNDO TABLESPACE `{req.name}` SET ACTIVE")
        return {"success": True}
    except Exception as e:
        raise HTTPException(500, detail=f"激活 undo 失败: {str(e)[:300]}")


@router.post("/undo/create")
async def undo_create(req: UndoNameReq):
    """新建 undo tablespace(用于满足≥2 active 后才能 inactive 清除)。"""
    name = req.name.strip()
    if not re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', name):
        raise HTTPException(400, detail="无效的 undo tablespace 名(仅字母/数字/下划线)")
    try:
        await db.execute(f"CREATE UNDO TABLESPACE `{name}` ADD DATAFILE '{name}.ibu'")
        return {"success": True}
    except Exception as e:
        raise HTTPException(500, detail=f"创建 undo 失败: {str(e)[:300]}")


@router.post("/undo/drop")
async def undo_drop(req: UndoNameReq):
    """删除 undo tablespace: 先 SET INACTIVE → 等 STATE 非 active → DROP。"""
    name = req.name.strip()
    if not re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*$', name):
        raise HTTPException(400, detail="无效的 undo tablespace 名")
    try:
        # 1. 先设 INACTIVE
        try:
            await db.execute(f"ALTER UNDO TABLESPACE `{name}` SET INACTIVE")
        except Exception:
            pass  # 可能已经 inactive
        # 2. 轮询等待 STATE 变为非 active(最多 30 秒)
        ready = False
        for _ in range(15):
            await asyncio.sleep(2)
            row = await db.fetch_one(
                "SELECT STATE FROM information_schema.INNODB_TABLESPACES WHERE NAME=%s", (name,)
            )
            if row and "active" not in (row.get("STATE") or "").lower():
                ready = True
                break
        # 3. DROP
        await db.execute(f"DROP UNDO TABLESPACE `{name}`")
        if not ready:
            return {"success": True, "warning": f"{name} 未完全释放就尝试删除，可能需重试"}
        return {"success": True}
    except Exception as e:
        raise HTTPException(500, detail=f"删除 undo 失败: {str(e)[:300]}")





@router.post("/execute-sql")
async def execute_sql(site: str = Query(...), file: UploadFile = File(...)):
    config = AppConfig.load()
    db_name = config.db_name(site)
    mc = config.mysql

    suffix = os.path.splitext(file.filename or "import.sql")[1] or ".sql"
    with tempfile.NamedTemporaryFile(suffix=suffix, delete=False, mode="wb") as tmp:
        content = await file.read()
        tmp.write(content)
        tmp_path = tmp.name

    try:
        cmd = [
            "mysql",
            f"--host={mc.host}", f"--port={mc.port}",
            f"--user={mc.user}", f"--password={mc.password}",
            "--default-character-set=utf8mb4", "--skip-ssl",
            db_name,
        ]
        with open(tmp_path, "r", encoding="utf-8") as f:
            proc = subprocess.run(cmd, stdin=f, capture_output=True, text=True, timeout=600)
        if proc.returncode != 0:
            raise HTTPException(400, detail=f"SQL执行失败: {proc.stderr[:500]}")
    finally:
        os.unlink(tmp_path)

    return {"success": True, "message": f"SQL文件已执行到数据库 {db_name}"}


# ── User Management ──────────────────────────────────────────────────

_USERS_TABLE = "sum_all.system_users"

DEFAULT_USERS = [
    {"username": "admin", "password": "Bill1@3", "role": "super", "status": "enabled",
     "name": "超级管理员", "contact": "", "notes": "超级管理员，拥有所有权限"},
    {"username": "query", "password": "Fin12#", "role": "normal", "status": "enabled",
     "name": "查询用户", "contact": "", "notes": "普通用户，仅可查询"},
]

PROTECTED_USERS = {"admin", "query"}


async def _ensure_users_table():
    """Create the system_users table and seed default users on first access."""
    await db.execute(f"""
        CREATE TABLE IF NOT EXISTS {_USERS_TABLE} (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(80) NOT NULL UNIQUE,
            password VARCHAR(255) NOT NULL,
            role VARCHAR(20) NOT NULL DEFAULT 'normal',
            status VARCHAR(20) NOT NULL DEFAULT 'enabled',
            name VARCHAR(80) DEFAULT '',
            contact VARCHAR(200) DEFAULT '',
            notes VARCHAR(500) DEFAULT '',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)
    for u in DEFAULT_USERS:
        row = await db.fetch_one(
            f"SELECT id FROM {_USERS_TABLE} WHERE username=%s", (u["username"],)
        )
        if not row:
            await db.execute(
                f"INSERT INTO {_USERS_TABLE} (username, password, role, status, name, contact, notes) "
                f"VALUES (%s, %s, %s, %s, %s, %s, %s)",
                (u["username"], u["password"], u["role"], u["status"], u["name"], u["contact"], u["notes"]),
            )
            log.info("Default user '%s' created", u["username"])


class UserProfile(BaseModel):
    name: str = ""
    contact: str = ""
    notes: str = ""


class UserPassword(BaseModel):
    password: str


class UserStatus(BaseModel):
    status: str  # "enabled" or "disabled"


class LoginRequest(BaseModel):
    username: str
    password: str


class UserCreate(BaseModel):
    username: str
    password: str
    role: str = "normal"
    status: str = "enabled"
    name: str = ""
    contact: str = ""
    notes: str = ""


@router.get("/users")
async def list_users():
    await _ensure_users_table()
    rows = await db.fetch_all(
        f"SELECT username, role, status, name, contact, notes FROM {_USERS_TABLE} ORDER BY id"
    )
    return {"users": rows}


@router.post("/users")
async def create_user(body: UserCreate):
    await _ensure_users_table()
    if body.username in PROTECTED_USERS:
        raise HTTPException(400, detail=f"用户名 '{body.username}' 为系统保留")
    if not body.username or len(body.username) < 2:
        raise HTTPException(400, detail="用户名至少2位")
    if not body.password or len(body.password) < 4:
        raise HTTPException(400, detail="密码至少4位")
    if body.role not in ("super", "normal"):
        raise HTTPException(400, detail="角色无效")
    existing = await db.fetch_one(
        f"SELECT id FROM {_USERS_TABLE} WHERE username=%s", (body.username,)
    )
    if existing:
        raise HTTPException(400, detail=f"用户名 '{body.username}' 已存在")
    await db.execute(
        f"INSERT INTO {_USERS_TABLE} (username, password, role, status, name, contact, notes) "
        f"VALUES (%s, %s, %s, %s, %s, %s, %s)",
        (body.username, body.password, body.role, body.status, body.name, body.contact, body.notes),
    )
    return {"success": True}


@router.delete("/users/{username}")
async def delete_user(username: str):
    if username in PROTECTED_USERS:
        raise HTTPException(400, detail=f"用户 '{username}' 为系统保留，不可删除")
    row = await db.fetch_one(
        f"SELECT id FROM {_USERS_TABLE} WHERE username=%s", (username,)
    )
    if not row:
        raise HTTPException(404, detail="用户不存在")
    await db.execute(f"DELETE FROM {_USERS_TABLE} WHERE username=%s", (username,))
    return {"success": True}


@router.put("/users/{username}/password")
async def update_password(username: str, body: UserPassword):
    await _ensure_users_table()
    if not body.password or len(body.password) < 4:
        raise HTTPException(400, detail="密码长度至少4位")
    row = await db.fetch_one(
        f"SELECT id FROM {_USERS_TABLE} WHERE username=%s", (username,)
    )
    if not row:
        raise HTTPException(404, detail="用户不存在")
    await db.execute(
        f"UPDATE {_USERS_TABLE} SET password=%s WHERE username=%s",
        (body.password, username),
    )
    return {"success": True}


@router.put("/users/{username}/status")
async def update_status(username: str, body: UserStatus):
    if username in PROTECTED_USERS:
        if body.status != "enabled":
            raise HTTPException(400, detail=f"用户 '{username}' 不可禁用")
    if body.status not in ("enabled", "disabled"):
        raise HTTPException(400, detail="状态值无效")
    await db.execute(
        f"UPDATE {_USERS_TABLE} SET status=%s WHERE username=%s",
        (body.status, username),
    )
    return {"success": True}


@router.put("/users/{username}/profile")
async def update_profile(username: str, body: UserProfile):
    await db.execute(
        f"UPDATE {_USERS_TABLE} SET name=%s, contact=%s, notes=%s WHERE username=%s",
        (body.name, body.contact, body.notes, username),
    )
    return {"success": True}


@router.put("/users/me/profile")
async def update_my_profile(body: UserProfile, username: str = Query(...)):
    await db.execute(
        f"UPDATE {_USERS_TABLE} SET name=%s, contact=%s, notes=%s WHERE username=%s",
        (body.name, body.contact, body.notes, username),
    )
    return {"success": True}


@router.put("/users/me/password")
async def update_my_password(body: UserPassword, username: str = Query(...)):
    if not body.password or len(body.password) < 4:
        raise HTTPException(400, detail="密码长度至少4位")
    await db.execute(
        f"UPDATE {_USERS_TABLE} SET password=%s WHERE username=%s",
        (body.password, username),
    )
    return {"success": True}


@router.post("/login")
async def login(body: LoginRequest):
    """Simple login — verify username/password, return user info."""
    await _ensure_users_table()
    row = await db.fetch_one(
        f"SELECT username, role, status, name, contact, notes FROM {_USERS_TABLE} WHERE username=%s AND password=%s",
        (body.username, body.password),
    )
    if not row:
        raise HTTPException(401, detail="用户名或密码错误")
    if row["status"] != "enabled":
        raise HTTPException(403, detail="该用户已被禁用")
    await add_log(body.username, "login", "", "用户登录")
    return {"user": {
        "username": row["username"], "role": row["role"], "name": row["name"] or "",
        "contact": row["contact"] or "", "notes": row["notes"] or "",
    }}


@router.post("/logout")
async def logout(body: dict = None):
    username = "unknown"
    if body and isinstance(body, dict):
        username = body.get("username", "unknown")
    await add_log(username, "logout", "", "用户登出")
    return {"success": True}


# ── System Logs ──────────────────────────────────────────────────────

_LOG_TABLE = "sum_all.system_logs"


async def _ensure_logs_table():
    await db.execute(f"""
        CREATE TABLE IF NOT EXISTS {_LOG_TABLE} (
            id BIGINT AUTO_INCREMENT PRIMARY KEY,
            username VARCHAR(80) NOT NULL,
            action VARCHAR(50) NOT NULL,
            module VARCHAR(100) DEFAULT '',
            detail VARCHAR(1000) DEFAULT '',
            ip VARCHAR(50) DEFAULT '',
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
    """)


async def add_log(username: str, action: str, module: str = "", detail: str = ""):
    """Write a system log entry. Safe to call before table exists (will create it)."""
    try:
        await _ensure_logs_table()
        await db.execute(
            f"INSERT INTO {_LOG_TABLE} (username, action, module, detail) VALUES (%s, %s, %s, %s)",
            (username, action, module, detail),
        )
    except Exception as e:
        log.warning("Failed to write system log: %s", e)


class LogActionRequest(BaseModel):
    username: str
    action: str        # 'export'
    module: str        # e.g. '数据统计', '财务报表', '日志查询'
    detail: str = ""   # free-text params description


@router.post("/log-action")
async def log_action(body: LogActionRequest):
    await add_log(body.username, body.action, body.module, body.detail)
    return {"success": True}


@router.get("/logs")
async def get_logs(
    page: int = 1, size: int = 50,
    date_start: str = "", date_end: str = "",
    keyword: str = "",
):
    await _ensure_logs_table()
    offset = (page - 1) * size

    conditions = []
    params = []
    if date_start:
        conditions.append("CONVERT_TZ(created_at, '+00:00', '+08:00') >= %s")
        params.append(date_start)
    if date_end:
        conditions.append("CONVERT_TZ(created_at, '+00:00', '+08:00') <= %s")
        params.append(date_end + " 23:59:59")
    if keyword:
        conditions.append("(username LIKE %s OR module LIKE %s OR detail LIKE %s OR action LIKE %s)")
        kw = f"%{keyword}%"
        params.extend([kw, kw, kw, kw])

    where = ""
    if conditions:
        where = "WHERE " + " AND ".join(conditions)

    count_row = await db.fetch_one(f"SELECT COUNT(*) as cnt FROM {_LOG_TABLE} {where}", tuple(params) if params else None)
    total = count_row["cnt"] if count_row else 0

    rows = await db.fetch_all(
        f"SELECT id, username, action, module, detail, "
        f"CONVERT_TZ(created_at, '+00:00', '+08:00') as created_at "
        f"FROM {_LOG_TABLE} {where} ORDER BY id DESC LIMIT %s OFFSET %s",
        tuple(params) + (size, offset) if params else (size, offset),
    )
    return {"logs": rows, "total": total, "page": page, "size": size}


class LogsClearBefore(BaseModel):
    days: int


@router.delete("/logs")
async def clear_all_logs():
    await _ensure_logs_table()
    await db.execute(f"DELETE FROM {_LOG_TABLE}")
    return {"success": True}


@router.post("/logs/clear-before")
async def clear_logs_before(body: LogsClearBefore):
    await _ensure_logs_table()
    await db.execute(
        f"DELETE FROM {_LOG_TABLE} WHERE created_at < NOW() - INTERVAL %s DAY",
        (body.days,),
    )
    return {"success": True}

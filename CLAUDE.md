# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Backend dev (FastAPI + hot reload)
cd backend && pip install -r requirements.txt && uvicorn app.main:app --reload --port 8000

# Frontend dev (Vite + HMR, proxies /api -> :8000)
cd frontend && npm install && npm run dev

# Production deploy (single container, Docker)
docker network create billsum_net
docker network connect billsum_net test-mysql8
docker-compose up -d --build

# View logs
docker logs -f billsum-app
```

## Architecture Overview

**Multi-site billing statistics app** — tracks AI service consumption logs across 6 remote sites (ai, csp, pinova, wzg, qn, digitalcloud), imports them into a local MySQL, and generates cost/financial reports.

### Stack

| Layer | Tech |
|-------|------|
| Frontend | Vue 3 (Composition API) + Element Plus + Vite 6 |
| Backend | Python 3.11 + FastAPI + Uvicorn |
| DB | MySQL 8+ via aiomysql (async pool, max 10 / min 1) |
| SSH | Paramiko (remote mysqldump + SFTP) |
| Prod | docker-compose single container (Nginx reverse proxy + Uvicorn) |

### Project Structure

```
backend/app/
  main.py            — FastAPI app: CORS, lifespan, 7 routers, /api/health
  config.py          — AppConfig (Pydantic + JSON persist) for 6 sites + local db
  database.py        — aiomysql pool wrapper (execute, fetch_one/all, execute_many)
  api/               — 7 route modules, one per domain (transfer, query, statistics, settings, system, finance, conduction)
  services/          — business logic layer:
    transfer_service.py   — 4-step pipeline: remote mysqldump → SFTP → local import → fill (old2new + uptnew SQL)
    stats_service.py      — aggregation SQL by month/day/user/channel/model with tiered pricing
    finance_service.py    — supplier reconciliation, user stats, site report generation (Excel + ZIP)
    query_service.py      — paginated queries, column metadata cache, fuzzy search
    ssh_service.py        — Paramiko SSH client (key auth, exec_command, SFTP)
    parser_service.py     — extract discount/buyer/supplier from free-text notes
    expr_parser.py        — decode base64 pricing formulas → CASE WHEN with tiered token ranges
    sql_templates.py      — old2new + uptnew DDL/DML template generators
    conduction_*.py       — independent DB-to-DB data conduction pipeline (separate config, SSH, commands)

frontend/src/
  main.js            — createApp + ElementPlus(zhCn) + router
  App.vue            — left sidebar (200px) + router-view with <keep-alive>
  api/index.js       — axios instance (baseURL=/api, 2h timeout) + all API functions
  router/index.js    — 6 lazy-loaded routes: /transfer (default), /query, /stats, /finance, /config, /system
  views/             — one view per route, all Chinese locale
  components/        — PaginationBar, ConductionPanel, ConductionTableSelect, ConductionEndpointForm
```

### Key Data Flow

1. **Config** → Configure SSH credentials + remote DB per site in /config (saved to `/app/data/config.json`)
2. **Transfer** → 4-step pipeline per site:
   - Remote mysqldump via SSH → compressed .tgz
   - SFTP download to local
   - Extract + import into `sum_{site}` database
   - Fill: old2new SQL creates stats table from raw table; uptnew SQL applies pricing + customer info
3. **Pricing** → During fill, `expr_parser.py` decodes base64 formulas (supports tiered pricing by token count ranges) → generates UPDATE with CASE WHEN
4. **Query/Stats/Finance** → Query aggregated data from processed logs tables

### Database Naming

- `sum_{site}` per site database
- `sum_all` — shared registry of log table names
- `logs{period}orig` — raw imported table (e.g. `logs202604orig`)
- `logs{period}` — stats table after fill (e.g. `logs202604`)
- `ex_channels`, `ex_users`, `ex_tokens` — extended lookup tables

### Fill Modes (per site in config)

| Mode | Sites | Behavior |
|------|-------|----------|
| full | wzg, pinova, ai | Join ex_users + ex_tokens + ex_channels during fill |
| simple | csp | Join ex_users + ex_channels only (no ex_tokens) |
| minimal | qn, digitalcloud | Register table name only, no extra UPDATEs |

## Important Design Patterns

- **Async background tasks** — Long ops (transfer, conduction, export) use `asyncio.create_task()` with progress reported via in-memory status dicts (`_tasks`, `_export_tasks`, `_STATS_EXPORT_TASKS`). Polling endpoint returns progress.
- **Column metadata cache** — `query_service._columns_cache` (in-memory dict) cleared when tables are dropped/recreated.
- **AppConfig cache** — `AppConfig._cache` invalidated by mtime check on save.
- **SQL injection protection** — Table names validated against `r'^[a-zA-Z_][a-zA-Z0-9_]*$'` before use in queries.
- **Chunked export** — Large dataset exports use keyset pagination (`l.id < ?`) to avoid expensive OFFSET, with multi-file splitting (1M rows per sheet for openpyxl write_only mode).
- **Two independent configs** — `config.json` (AppConfig) handles main app settings; `conduction.json` handles conduction pipeline endpoints separately.
- **No test frameworks or linters** — `requirements.txt` has no pytest/flake8/etc. The project currently has no test infrastructure.
- **SSH key auth only** — `ssh_service.py` uses Paramiko key-based auth (no password fallback). Conduction SSH supports both key and password.

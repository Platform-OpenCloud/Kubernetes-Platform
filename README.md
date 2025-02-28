# Project Overview

## Directory Structure

```yaml
Kubernetes-Platform
├─ .env
├─ app
│  ├─ api
│  │  ├─ dependencies
│  │  │  ├─ auth.py
│  │  │  ├─ database.py
│  │  │  └─ __init__.py
│  │  ├─ v1
│  │  │  ├─ endpoints
│  │  │  │  ├─ auth.py
│  │  │  │  └─ user.py
│  │  │  ├─ routers.py
│  │  │  └─ __init__.py
│  │  └─ __init__.py
│  ├─ celery_app.py
│  ├─ core
│  │  ├─ config.py
│  │  ├─ security.py
│  │  └─ __init__.py
│  ├─ crud
│  │  └─ __init__.py
│  ├─ db
│  │  ├─ base.py
│  │  ├─ migrations
│  │  ├─ session.py
│  │  └─ __init__.py
│  ├─ main.py
│  ├─ models
│  │  └─ __init__.py
│  ├─ schemas
│  │  └─ __init__.py
│  ├─ tests
│  └─ __init__.py
├─ Dockerfile
├─ GitOps
├─ LICENSE
├─ poetry.lock
├─ pyproject.toml
├─ README.md
└─ requirements.txt

```

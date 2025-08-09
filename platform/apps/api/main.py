from fastapi import FastAPI, Depends, Header, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import Optional, Dict, Any
import secrets

from apps.api.runner import run_job

app = FastAPI(title="MuzIQ Agent Platform")
from pydantic import BaseModel
import secrets

class AgentIn(BaseModel):
    name: str

AGENTS = {}

from pathlib import Path
import json

# --- AGENT PERSISTENCE (BEGIN) ---
STORAGE_DIR = Path("/app/storage")
STORAGE_DIR.mkdir(parents=True, exist_ok=True)
AGENTS_PATH = STORAGE_DIR / "agents.json"

AGENTS: dict[str, dict] = {}

def load_agents():
    global AGENTS
    if AGENTS_PATH.exists():
        try:
            AGENTS = json.loads(AGENTS_PATH.read_text())
        except Exception:
            AGENTS = {}
    else:
        AGENTS = {}

def save_agents():
    AGENTS_PATH.write_text(json.dumps(AGENTS, indent=2))

@app.on_event("startup")
async def _load_agents_on_start():
    load_agents()
    print(f"[agents] loaded {len(AGENTS)} agent(s) from {AGENTS_PATH}")

class AgentCreate(BaseModel):
    name: str

class AgentImport(BaseModel):
    agent_id: str
    api_key: str
    name: str | None = None

import json
import os
import secrets

AGENTS_FILE = "/app/storage/agents.json"

def load_agents():
    if os.path.exists(AGENTS_FILE):
        with open(AGENTS_FILE, "r") as f:
            return json.load(f)
    return {}

def save_agents(data):
    os.makedirs(os.path.dirname(AGENTS_FILE), exist_ok=True)
    with open(AGENTS_FILE, "w") as f:
        json.dump(data, f, indent=2)

@app.post("/agents")
def create_agent():
    # Generate new credentials
    agent_id = secrets.token_hex(8)
    api_key = secrets.token_hex(16)

    # Load, update, and save
    agents = load_agents()
    agents[agent_id] = {"api_key": api_key}
    save_agents(agents)

    print("\n========================================")
    print("MuzIQ AGENT CREATED & SAVED")
    print(f"agent_id = {agent_id}")
    print(f"api_key  = {api_key}")
    print("========================================\n")

    return {"agent_id": agent_id, "api_key": api_key}

@app.post("/agents/import")  # import existing credentials
def import_agent(agent: AgentImport):
    AGENTS[agent.agent_id] = {"name": agent.name or "imported", "api_key": agent.api_key}
    save_agents()
    return {"ok": True, "agent_id": agent.agent_id}
# --- AGENT PERSISTENCE (END) ---
@app.post("/agents")
def create_agent(agent: AgentIn):
    agent_id = secrets.token_hex(8)
    api_key = secrets.token_hex(16)
    AGENTS[agent_id] = {"name": agent.name, "api_key": api_key}
    return {"agent_id": agent_id, "api_key": api_key}

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000","http://127.0.0.1:5173","http://localhost:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# serve artifacts
app.mount("/files", StaticFiles(directory="/app/storage/files"), name="files")

# super simple in-memory stores (we'll replace later)
AGENTS: Dict[str, Dict[str, str]] = {}
JOBS: Dict[str, Dict[str, Any]] = {}

class AgentIn(BaseModel):
    name: str

class JobIn(BaseModel):
 agent_id: str
 payload: Dict[str, Any]

def require_api_key(x_api_key: Optional[str] = Header(None)):
    if not x_api_key or x_api_key not in {v["api_key"] for v in AGENTS.values()}:
        raise HTTPException(status_code=401, detail="Invalid or missing API key")
    return x_api_key

@app.get("/health")
def health(): return {"ok": True}

@app.post("/agents/register")
def register_agent(agent: AgentIn):
    agent_id = secrets.token_hex(8)
    api_key = secrets.token_hex(16)
    AGENTS[agent_id] = {"name": agent.name, "api_key": api_key}
    return {"agent_id": agent_id, "api_key": api_key}

from fastapi import Request

@app.post("/jobs")
async def submit_job(request: Request,
                     x_agent_id: str = Header(None),
                     x_api_key: str = Header(None)):

    data = await request.json()

    # If agent_id not in body, try pulling from headers
    agent_id = data.get("agent_id") or x_agent_id
    payload = data.get("payload") or data

    if not agent_id:
        raise HTTPException(status_code=400, detail="Missing agent_id in body or headers")

    if not x_api_key:
        raise HTTPException(status_code=400, detail="Missing API key in headers")

    # ✅ Here you validate the API key
    if AGENTS.get(agent_id) != x_api_key:
        raise HTTPException(status_code=401, detail="Invalid API key")

    # ✅ Continue with your existing job logic
    job_id = run_job(agent_id, payload)
    return {"job_id": job_id, "status": "submitted"}


@app.get("/jobs/{job_id}")
def job_status(job_id: str):
    job = JOBS.get(job_id)
    if not job: raise HTTPException(status_code=404, detail="Unknown job")
    return {"job_id": job_id, **job}
import secrets

# --- Auto-register default demo agent at startup ---
from fastapi import BackgroundTasks

@app.on_event("startup")
async def startup_event():
    agent_id = "local-demo-agent"
    api_key = secrets.token_hex(16)
    AGENTS[agent_id] = {"name": "local-demo", "api_key": api_key}
    print("\n" + "="*40)
    print("MuzIQ DEMO AGENT CREATED")
    print(f"agent_id = {agent_id}")
    print(f"api_key  = {api_key}")
    print("="*40 + "\n")


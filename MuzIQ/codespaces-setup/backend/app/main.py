from fastapi import FastAPI, HTTPException
from fastapi.responses import JSONResponse
from pydantic import BaseModel
import os, httpx, networkx as nx

app = FastAPI(title="MuzIQ API", version="0.1.0")

G = nx.DiGraph()
G.add_node("root", type="concept", label="Music")
G.add_edge("root", "ai_gen", relation="produces")

class GenerateRequest(BaseModel):
    prompt: str
    duration_sec: int = 10

@app.get("/health")
def health():
    return {"ok": True}

@app.get("/graph/nodes")
def graph_nodes():
    data = [{"id": n, **(G.nodes[n] or {})} for n in G.nodes]
    return {"nodes": data, "edges": list(G.edges(data=True))}

@app.post("/generate")
async def generate_audio(req: GenerateRequest):
    provider = os.getenv("MUSIQ_GENERATION_PROVIDER", "stub")
    if provider == "stub":
        return JSONResponse({"status": "ok", "audio_url": None, "note": "Stubbed generation—connect a provider."})
    elif provider == "replicate":
        api_token = os.getenv("REPLICATE_API_TOKEN")
        if not api_token:
            raise HTTPException(status_code=400, detail="Missing REPLICATE_API_TOKEN")
        async with httpx.AsyncClient(timeout=60) as client:
            r = await client.post(
                "https://api.replicate.com/v1/predictions",
                headers={"Authorization": f"Token " + api_token},
                json={"version": "<model-version>", "input": {"prompt": req.prompt, "duration": req.duration_sec}}
            )
            data = r.json()
            return JSONResponse({"status": "ok", "audio_url": data.get("output")})
    else:
        raise HTTPException(status_code=400, detail=f"Unknown provider: {provider}")

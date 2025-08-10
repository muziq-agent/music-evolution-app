#!/usr/bin/env bash
set -e
# Python venv + backend deps
python -m venv .venv
. .venv/bin/activate
pip install --upgrade pip
pip install fastapi uvicorn[standard] pydantic[dotenv] httpx networkx soundfile librosa

# Frontend scaffold (Vite React) + deps
cd frontend
npm create vite@latest . -- --template react
npm install
npm install axios

# Overwrite default App.jsx with our minimal UI
cat > src/App.jsx <<'APP'
import { useState } from 'react'
import axios from 'axios'

function App() {
  const [prompt, setPrompt] = useState("")
  const [status, setStatus] = useState(null)
  const [audioUrl, setAudioUrl] = useState(null)
  const [note, setNote] = useState(null)

  const generate = async () => {
    setStatus("Generating…"); setAudioUrl(null); setNote(null)
    try {
      const res = await axios.post('/api/generate', { prompt, duration_sec: 10 })
      setStatus("Done"); setAudioUrl(res.data.audio_url); setNote(res.data.note)
    } catch (e) {
      setStatus("Error"); setNote(e?.response?.data?.detail || e.message)
    }
  }

  return (
    <div style={{ padding: 24, fontFamily: 'system-ui' }}>
      <h1>MuzIQ — Codespaces Demo</h1>
      <p>AI music generation (stub by default) and a small graph peek.</p>
      <div style={{ marginTop: 16 }}>
        <input style={{ padding: 8, width: 420 }} placeholder="e.g., dreamy lo-fi beat"
          value={prompt} onChange={e => setPrompt(e.target.value)} />
        <button style={{ marginLeft: 8, padding: '8px 12px' }} onClick={generate}>Generate</button>
      </div>
      {status && <p style={{ marginTop: 12 }}>Status: {status}</p>}
      {note && <p><em>{note}</em></p>}
      {audioUrl && <audio controls src={audioUrl} style={{ marginTop: 12, display: 'block' }} />}
      <h2 style={{ marginTop: 32 }}>Graph peek</h2>
      <pre style={{ background: '#f6f6f6', padding: 12 }}>Try: curl /api/graph/nodes</pre>
    </div>
  )
}
export default App
APP

# Vite proxy to backend
cat > vite.config.js <<'VITE'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: { '/api': { target: 'http://localhost:8000', changeOrigin: true, rewrite: p => p.replace(/^\/api/, '') } }
  }
})
VITE

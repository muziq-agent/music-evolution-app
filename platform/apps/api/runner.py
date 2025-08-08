import time, uuid, wave, struct, math

def _write_sine_wav(path: str, secs: int = 2, freq: int = 440, sr: int = 44100):
    nframes = secs * sr
    with wave.open(path, "w") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(sr)
        for i in range(nframes):
            val = int(32767.0 * math.sin(2*math.pi*freq*(i/sr)))
            w.writeframes(struct.pack("<h", val))

def run_job(payload: dict) -> dict:
    time.sleep(1)  # simulate work
    out_id = uuid.uuid4().hex[:8]
    path = f"/app/storage/files/{out_id}.wav"
    dur = int(payload.get("duration_sec", 2))
    _write_sine_wav(path, secs=max(1, min(dur, 10)))
    return {
        "artifacts": [{"type":"audio","path": f"/files/{out_id}.wav"}],
        "metadata": {"note": "demo sine tone","payload_echo": payload},
        "logs": "runner: generated demo WAV"
    }

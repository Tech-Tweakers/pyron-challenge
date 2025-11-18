# api/main.py
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
from redis import Redis
from rq import Queue
from pymongo import MongoClient
from fastapi.responses import HTMLResponse
from bson.json_util import dumps
import os
import datetime
import uvicorn


app = FastAPI()

# ENV
REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))

MONGO_URI = os.getenv("MONGO_URI", "mongodb://mongo:27017")
MONGO_DB_NAME = os.getenv("MONGO_DB", "pyron")

# Redis connection
redis_conn = Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
queue = Queue("webhook-jobs", connection=redis_conn)

# Mongo connection
mongo_client = MongoClient(MONGO_URI)
db = mongo_client[MONGO_DB_NAME]


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/ready")
def ready():
    # basic checks
    try:
        redis_conn.ping()
        mongo_client.admin.command("ping")
        return {"status": "ready"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/webhook")
async def webhook(request: Request):
    try:
        payload = await request.json()
        if not isinstance(payload, dict):
            raise HTTPException(status_code=400, detail="Invalid JSON")
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid JSON body")

    meta = {
        "received_at": datetime.datetime.utcnow(),
        "source_ip": request.client.host,
    }

    # fire-and-forget audit log
    try:
        db.webhook_audit.insert_one({"payload": payload, "meta": meta})
    except Exception as e:
        print("Mongo audit error:", e)

    # Enqueue job
    try:
        queue.enqueue("worker.process_job", payload, meta)
    except Exception as e:
        print("Queue error:", e)
        raise HTTPException(status_code=500, detail="Queue failure")

    return JSONResponse({"accepted": True}, status_code=202)


@app.get("/", response_class=HTMLResponse)
def index():
    docs = list(db.webhook_audit.find().sort("meta.received_at", -1).limit(20))

    html_entries = ""
    for d in docs:
        html_entries += f"<pre>{dumps(d, indent=2)}</pre><hr>"

    if not html_entries:
        html_entries = "<p>Nenhum webhook recebido ainda.</p>"

    return f"""
    <html>
        <head>
            <title>PyRon Webhook Audit Viewer</title>
            <style>
                body {{ font-family: monospace; padding: 20px; background: #111; color: #eee; }}
                hr {{ border: 0; border-top: 1px solid #444; margin: 20px 0; }}
                pre {{ background: #222; padding: 10px; border-radius: 5px; }}
            </style>
        </head>
        <body>
            <h2>Últimos webhooks recebidos (limite: 20)</h2>
            {html_entries}
        </body>
    </html>
    """


if __name__ == "__main__":
    USE_SSL = os.getenv("USE_SSL", "false").lower() == "true"
    HOST = "0.0.0.0"

    if USE_SSL:
        print(">> Starting API with SSL enabled")
        uvicorn.run(
            "main:app",
            host=HOST,
            port=8443,
            ssl_keyfile="/certs/key.pem",
            ssl_certfile="/certs/cert.pem",
        )
    else:
        print(">> Starting API without SSL")
        uvicorn.run(
            "main:app",
            host=HOST,
            port=8000,
        )

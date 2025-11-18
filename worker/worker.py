# worker/worker.py
from redis import Redis
from rq import Worker, Queue
from pymongo import MongoClient
import os
import datetime

REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", "6379"))
MONGO_URI = os.getenv("MONGO_URI", "mongodb://mongo:27017")
MONGO_DB_NAME = os.getenv("MONGO_DB", "pyron")

redis_conn = Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)
mongo_client = MongoClient(MONGO_URI)
db = mongo_client[MONGO_DB_NAME]


# Job logic
def process_job(payload, meta):
    print("Processing job:", payload)

    doc = {
        "payload": payload,
        "processed_at": datetime.datetime.utcnow(),
        "meta": meta,
    }

    db.processed_signals.insert_one(doc)


# Required for RQ Worker import using strings
import worker

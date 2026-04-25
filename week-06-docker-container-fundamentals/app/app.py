from flask import Flask
import os
import redis
import time

app = Flask(__name__)

# Connect to Redis using the service name from docker-compose
# "redis" resolves to the Redis container's IP via Docker DNS
redis_host = os.environ.get("REDIS_HOST", "redis")
redis_port = int(os.environ.get("REDIS_PORT", "6379"))

def get_redis():
    try:
        r = redis.Redis(host=redis_host, port=redis_port, decode_responses=True)
        r.ping()
        return r
    except redis.ConnectionError:
        return None

@app.route("/")
def home():
    r = get_redis()
    if r:
        visits = r.incr("visit_count")
        return f"<h1>Week 6 Container Lab</h1><p>Visit count: {visits}</p><p>Hostname: {os.uname().nodename}</p><p>Redis: connected</p>"
    else:
        return f"<h1>Week 6 Container Lab</h1><p>Redis: not connected</p><p>Hostname: {os.uname().nodename}</p>"

@app.route("/health")
def health():
    r = get_redis()
    redis_status = "connected" if r else "disconnected"
    return {"status": "healthy", "redis": redis_status}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
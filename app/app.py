from flask import Flask, jsonify, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
import os

app = Flask(__name__)

REQUESTS = Counter("app_requests_total", "Total requests", ["endpoint"])


@app.route("/")
def home():
    REQUESTS.labels("/").inc()
    return jsonify(status="ok", message="DevSecOps pipeline demo app")


@app.route("/health")
def health():
    REQUESTS.labels("/health").inc()
    return jsonify(status="healthy"), 200


@app.route("/metrics")
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)


if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host="0.0.0.0", port=port)
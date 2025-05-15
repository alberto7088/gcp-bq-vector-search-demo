# main.py

import os
import json
import time
import logging
import requests

from functions_framework import http
from google.cloud import bigquery
from flask import abort

# ─── Configuration ─────────────────────────────────────────────────────────────
BQ_TABLE   = os.getenv("BQ_TABLE")
MODEL      = os.getenv("EMBED_MODEL", "all-MiniLM-L6-v2")
HF_TOKEN   = os.getenv("HF_API_TOKEN")
HF_URL   = ("https://api-inference.huggingface.co/pipeline/feature-extraction/sentence-transformers/{MODEL}")
TOP_K      = 5
# ─── Clients & Logger ──────────────────────────────────────────────────────────
bq        = bigquery.Client()
logger    = logging.getLogger("query_handler")
logger.setLevel(logging.INFO)


def embed_text(text: str) -> list[float]:
    """
    Call HF feature-extraction pipeline to get a 384-dim embedding.
    """
    resp = requests.post(
        HF_URL,
        headers={
            "Authorization": f"Bearer {HF_TOKEN}",
            "Content-Type": "application/json",
        },
        json={"inputs": text},  # single input → feature-extraction
        timeout=10,
    )
    resp.raise_for_status()
    data = resp.json()

    if isinstance(data, list) and data and isinstance(data[0], list):
        # HF returns one list per token → mean-pool
        tokens = data[0]
        dim = len(tokens[0])
        return [sum(tok[i] for tok in tokens) / len(tokens) for i in range(dim)]
    if isinstance(data, list) and all(isinstance(v, (float, int)) for v in data):
        return data

    raise ValueError(f"Unexpected embedding format: {data!r}")


@http
def query_handler(request):
    """
    HTTP entry point.
    Expects JSON body:
      { "query": "<your question>", "top_k": 5 }
    Returns JSON: [{ "content": "...", "similarity": 0.95}, …]
    """
    start = time.time()
    body = request.get_json(silent=True) or {}
    text = body.get("query")
    if not text:
        abort(400, "JSON must include non-empty 'query' field")

    k = body.get("top_k", TOP_K)
    try:
        k = int(k)
    except Exception:
        abort(400, "'top_k' must be an integer")

    try:
        emb = embed_text(text)
    except requests.HTTPError as e:
        logger.error("HF API error: %s %s", e.response.status_code, e.response.text)
        abort(502, "Embedding service error")
    except Exception as e:
        logger.exception("Failed to embed text")
        abort(500, "Internal embedding error")

    if len(emb) != 384:
        logger.error("Got embedding of len %d (expected 384)", len(emb))
        abort(500, "Invalid embedding length")

    arr = ",".join(f"{v:.18f}" for v in emb)
    sql = f"""
            WITH params AS (
              SELECT
                [{arr}] AS q_emb
            )
            SELECT
              e.content,
              1 - ML.DISTANCE(e.embedding, p.q_emb, "COSINE") AS similarity
            FROM
              `{BQ_TABLE}` AS e,
              params AS p
            ORDER BY similarity DESC
            LIMIT {k};
    """

    try:
        job = bq.query(sql)
        rows = [{"content": r.content, "similarity": r.similarity} for r in job]
    except Exception:
        logger.exception("BigQuery search failed")
        abort(502, "Vector search error")

    total_ms = int((time.time() - start) * 1000)
    logger.info("Query handled in %d ms, returned %d rows", total_ms, len(rows))
    return (json.dumps(rows), 200, {"Content-Type": "application/json"})

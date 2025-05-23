# main.py

import os
import json
import time
import logging
import requests

from functions_framework import http
from google.cloud import bigquery
from flask import abort
from sentence_transformers import SentenceTransformer

# ─── Configuration ─────────────────────────────────────────────────────────────
BQ_TABLE   = os.getenv("BQ_TABLE")
MODEL      = os.getenv("EMBED_MODEL", "all-MiniLM-L6-v2")
HF_TOKEN   = os.getenv("HF_API_TOKEN")
HF_MODEL   = f"sentence-transformers/{MODEL}"
TOP_K      = 5
# ─── Clients & Logger ──────────────────────────────────────────────────────────
bq        = bigquery.Client()
logger    = logging.getLogger("query_handler")
logger.setLevel(logging.INFO)

model = SentenceTransformer(HF_MODEL)

def embed_text(text: str) -> list[float]:
    """
    Call HF feature-extraction pipeline to get a 384-dim embedding.
    """
    logger.info(f"Using model: {model}")

    try:
        embeddings = model.encode([text])
    except Exception as e:
        raise ValueError(f"Couldn't fetch embeddings because of {e}")

    return embeddings[0]


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
    logger.info(f'Query received: {text}')

    if not text:
        abort(400, "JSON must include non-empty 'query' field")

    k = body.get("top_k", TOP_K)
    try:
        k = int(k)
    except Exception:
        abort(400, "'top_k' must be an integer")

    try:
        emb = embed_text(text)
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

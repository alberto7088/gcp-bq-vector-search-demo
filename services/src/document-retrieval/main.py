import os
import json
import requests

from functions_framework import http
from google.cloud import bigquery

BF_TABLE    = os.environ["BQ_TABLE"]
MODEL       = os.environ.get("EMBED_MODEL", "sentence-transformers/all-MiniLM-L6-v2")
TOP_K       = int(os.environ.get("TOP_K", "5"))
HF_TOKEN    = os.environ["HF_API_TOKEN"]

bq = bigquery.Client()

def embed_text(text: str) -> list[float]:
    """Call HF Inference API to get a sentence embedding."""
    url = f"https://api-inference.huggingface.co/models/{MODEL}"
    headers = {
        "Authorization": f"Bearer {HF_TOKEN}",
        "Content-Type": "application/json",
    }
    # HF will return token-level vectors; for sentence models it often returns a 1×384 array directly
    resp = requests.post(url, headers=headers, json={"inputs": text})
    resp.raise_for_status()
    data = resp.json()
    # If shape is [seq_len, dim], average to get one vector
    if isinstance(data[0][0], list):
        tokens = data[0]
        dim    = len(tokens[0])
        return [ sum(tok[i] for tok in tokens)/len(tokens) for i in range(dim) ]
    # Else if already [dim], just return it
    return data[0]

@http
def query_handler(request):
    """HTTP Cloud Function: { "query":"…", "top_k":3 } → nearest chunks from BQ."""
    body = request.get_json(silent=True) or {}
    q_text = body.get("query")
    k      = int(body.get("top_k", TOP_K))
    if not q_text:
        return ("Bad Request: JSON must include 'query'", 400)

    # 1) Embed
    embedding = embed_text(q_text)

    # 2) VECTOR_SEARCH in BigQuery
    emb_list = ",".join(f"{v:.18f}" for v in embedding)
    sql = f"""
    WITH q AS (SELECT [{emb_list}] AS embedding)
    SELECT content, distance
    FROM VECTOR_SEARCH(
      TABLE `{BQ_TABLE}`, 'embedding',
      (SELECT embedding FROM q),
      TOP_K => {k}, DISTANCE_TYPE => 'COSINE'
    )
    ORDER BY distance;
    """
    job = bq.query(sql)
    results = [{"content": r.content, "distance": r.distance} for r in job]

    return (json.dumps(results), 200, {"Content-Type": "application/json"})

# 🧠 RAG with BigQuery, Terraform & Cloud Functions

A minimal Retrieval-Augmented Generation (RAG) application that uses **BigQuery** for vector search, **Cloud Functions** to embed and process queries, and **Terraform** for infrastructure-as-code deployment. It’s optimized for prototyping semantic search systems over internal or public documents using Hugging Face embeddings.

---

## 🔍 What This Project Does

- Accepts an HTTP request with a user query.
- Uses a locally loaded Hugging Face transformer (`all-MiniLM-L6-v2`) to embed the query.
- Sends the embedding to BigQuery for **cosine similarity** search over a precomputed document embedding table.
- Returns the top 5 most relevant documents.

---

## 🧱 Tech Stack

| Layer         | Tool                         |
|---------------|------------------------------|
| Embedding     | 🤗 Hugging Face Transformers (local model) |
| Storage       | 🗂️ BigQuery (FLOAT64 repeated vectors) |
| API Logic     | 🔧 Google Cloud Functions (2nd gen) |
| Deployment    | 🚀 Terraform (modular structure) |
| Secrets Mgmt  | 🔐 Google Secret Manager (optional) |

---
## 🚀 Getting Started

### 1. Clone the repo

```bash
git clone https://github.com/yourusername/rag-bq-terraform.git
cd rag-bq-terraform
```

---

### 2. Set up your environment

You'll need:
- A GCP project with billing enabled

Set the following **GitHub Secrets** (for deployment via CI/CD):

| Secret Name         | Description                                      |
|---------------------|--------------------------------------------------|
| `GCP_CREDENTIALS_DEV` | JSON credentials for the service account         |
| `TF_STATE_BUCKET_DEV` | GCS bucket name for Terraform state              |
| `GCP_PROJECT_DEV`   | GCP project ID                                   |
| `STATE_SA_EMAIL_DEV` | Email of the service account used by Terraform   |
| `INVOKER_MEMBER_DEV` | IAM member allowed to invoke the Cloud Function  |

Specify the **region** and Hugging Face API token in your `.tfvars` file:

```hcl
region         = "europe-west1"
hf_api_token   = "projects/my-project/secrets/hf-token"
```

> The `hf_api_token` should refer to a secret stored in **Google Secret Manager**.

---

### 3. Trigger a Deployment

Push a commit to the `main` branch to run the GitHub Actions workflow and deploy the infrastructure.

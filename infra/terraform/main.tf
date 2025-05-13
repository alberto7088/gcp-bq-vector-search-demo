terraform {
  required_version = ">= 1.0.0"

  required_providers {
    google      = { source = "hashicorp/google"      version = "~> 5.0" },
    google-beta = { source = "hashicorp/google-beta" version = "~> 5.0" }
  }

  backend "gcs" {
    bucket = var.tf_state_bucket
    prefix = "${var.env}/terraform/state"
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.region
}

provider "google-beta" {
  project = var.gcp_project
  region  = var.region
}

module "state_bucket" {
  source         = "./modules/bucket"
  gcp_project    = var.gcp_project
  region         = var.region
  bucket_name    = var.tf_state_bucket
  force_destroy  = true
  state_sa_email = var.state_sa_email
}

locals {
  code_bucket = module.state_bucket.bucket_name
}

resource "google_project_service" "bigquery" {
  project = var.gcp_project
  service = "bigquery.googleapis.com"
}

resource "google_bigquery_dataset" "rag" {
  project    = var.gcp_project
  dataset_id = "rag_demo"
  location   = var.region
  depends_on = [google_project_service.bigquery]
}

module "bq_queries" {
  source      = "./modules/bigquery"
  project_id  = var.gcp_project
  dataset_id  = google_bigquery_dataset.this.dataset_id
  table_id    = "queries"
  schema_file = "${path.module}/modules/bigquery/schemas/queries.json"
}

module "bq_embeddings" {
  source      = "./modules/bigquery"
  project_id  = var.gcp_project
  dataset_id  = var.dataset_id
  table_id    = "embeddings"
  schema_file = "${path.module}/modules/bigquery/schemas/embeddings.json"
}

resource "google_project_service" "run" {
  project             = var.gcp_project
  service             = "run.googleapis.com"
  disable_on_destroy  = false
}

resource "google_project_service" "cloudfunctions" {
  project             = var.gcp_project
  service             = "cloudfunctions.googleapis.com"
  disable_on_destroy  = false
}

module "hf_secret_access" {
  source       = "./modules/secret-manager"
  secret_id    = var.hf_api_token
  accessor     = var.invoker_member
}

data "google_secret_manager_secret_version" "hf" {
  secret  = var.hf_api_token
  version = "latest"
}

module "document-retrieval" {
  source              = "./modules/cloud-function"
  gcp_project         = var.gcp_project
  region              = var.region
  bucket_name         = local.code_bucket
  function_name       = "document-retrieval"
  runtime             = "python39"
  entry_point         = "query_handler"
  trigger_http        = true
  available_memory_mb = 1024
  timeout             = 300
  source_dir          = "${path.module}/../../services/src/document-retrieval"
  min_instances       = 0
  max_instances       = 10
  invoker_member      = var.invoker_member

  environment_variables = {
    ENVIRONMENT     = var.env
    HF_API_TOKEN    = data.google_secret_manager_secret_version.hf.secret_data
    EMBED_MODEL     = var.embed_model
    BQ_TABLE        = "${var.gcp_project}.${var.dataset_id}.embeddings"
  }

  depends_on = [
    google_project_service.cloudfunctions,
    google_project_service.run
  ]
}

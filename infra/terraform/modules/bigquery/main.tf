# Enable BigQuery API
resource "google_project_service" "bq_api" {
  project = var.project_id
  service = "bigquery.googleapis.com"
}

# Dataset
resource "google_bigquery_dataset" "this" {
  project   = var.project_id
  dataset_id = var.dataset_id
  location  = var.location
}

# Table with VECTOR column defined in JSON schema
resource "google_bigquery_table" "this" {
  project    = var.project_id
  dataset_id = google_bigquery_dataset.this.dataset_id
  table_id   = var.table_id

  # schema_file must be a local path relative to your root module
  schema = file(var.schema_file)
}
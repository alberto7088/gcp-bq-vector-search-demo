# Table with VECTOR column defined in JSON schema
resource "google_bigquery_table" "this" {
  provider   = google-beta.beta
  project    = var.project_id
  dataset_id = var.dataset_id
  table_id   = var.table_id

  # schema_file must be a local path relative to your root module
  schema = file(var.schema_file)
}
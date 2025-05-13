# Table with VECTOR column defined in JSON schema
resource "google_bigquery_table" "this" {
  project    = var.project_id
  dataset_id = var.dataset_id
  table_id   = var.table_id
  schema = file(var.schema_file)
}
# Table with VECTOR column defined in JSON schema
resource "google_bigquery_table" "this" {
  provider   = google-beta.beta
  project    = var.project_id
  dataset_id = var.dataset_id
  table_id   = var.table_id
  schema = file(var.schema_file)

  dynamic "vector_search_spec" {
    for_each = var.vector_search_enabled ? [1] : []
    content {
      type = "VECTOR_INDEX"

      # Specifies which column contains the vector data
      columns = [var.embedding_column_name]

      vector_search_dimensions {
        dimension = var.vector_dimension
      }
      distance_type = "COSINE"
    }
  }
}
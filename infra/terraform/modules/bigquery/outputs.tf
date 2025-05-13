output "dataset_id" {
  value = var.dataset_id
}
output "table_id" {
  value = google_bigquery_table.this.table_id
}
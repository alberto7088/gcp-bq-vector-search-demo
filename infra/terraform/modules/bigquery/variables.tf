variable "project_id" {
  type        = string
  description = "GCP project"
}
variable "location" {
  type        = string
  description = "BigQuery dataset location (e.g. EU)"
  default     = "EU"
}
variable "dataset_id" {
  type        = string
  description = "BigQuery dataset name"
}
variable "table_id" {
  type        = string
  description = "BigQuery table name"
}
variable "schema_file" {
  type        = string
  description = "Path to JSON schema file"
}
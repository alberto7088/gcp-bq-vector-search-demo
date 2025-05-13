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

variable "vector_search_enabled" {
  description = "Enable vector search capabilities"
  type        = bool
  default     = true
}

variable "vector_dimension" {
    description = "Length of the embedding vector"
    type        = number
    default = 384

}

variable "embedding_column_name" {
  description = "Column name containing the vector embeddings"
  type        = string
  default     = "embedding"  # Default column name for embeddings
}
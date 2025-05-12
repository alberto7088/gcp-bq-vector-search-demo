variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "europe-west2"
}

variable "tf_state_bucket" {
  description = "Name of the GCS bucket used for remote state and function source archives"
  type        = string
}

variable "env" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "state_sa_email" {
  description = "Service account email"
  type        = string
}

variable "invoker_member" {
  description = "Who can invoke the function (e.g. user:alice@… or serviceAccount:… )"
  type        = string
}

variable "dataset_id" {
  type    = string
  default = "rag_demo"
}

variable "hf_api_token" {
  description = "Hugging Face API key"
  type        = string
}

variable "embed_model" {
  type    = string
  default = "all-MiniLM-L6-v2"
}

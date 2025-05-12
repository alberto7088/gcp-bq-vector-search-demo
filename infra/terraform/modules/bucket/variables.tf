variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP region to create the bucket in."
  type        = string
}

variable "bucket_name" {
  description = "Name of the GCS bucket. This value should be provided via your tfvars file."
  type        = string
}

variable "force_destroy" {
  description = "Allow bucket to be destroyed even if it has objects"
  type        = bool
  default     = false
}

variable "state_sa_email" {
  description = "Service account email"
  type        = string
}

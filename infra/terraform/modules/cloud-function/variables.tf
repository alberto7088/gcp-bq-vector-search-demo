variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "bucket_name" {
  description = "Name of the GCS bucket to store function archives"
  type        = string
}

variable "function_name" {
  description = "Name of the Cloud Function"
  type        = string
}

variable "runtime" {
  description = "Runtime for the Cloud Function (e.g., python39)"
  type        = string
}

variable "entry_point" {
  description = "The entry point of the Cloud Function"
  type        = string
}

variable "trigger_http" {
  description = "Boolean indicating if the function is triggered by HTTP"
  type        = bool
  default     = true
}

variable "available_memory_mb" {
  description = "Amount of memory (in MB) allocated to the function"
  type        = number
  default     = 1024
}

variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 300
}

variable "source_dir" {
  description = "Directory containing the function source code"
  type        = string
}

variable "environment_variables" {
  description = "Additional environment variables to set"
  type        = map(string)
  default     = {}
}

variable "min_instances" {
  description = "Minimum number of function instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of function instances"
  type        = number
  default     = 100
}

variable "invoker_member" {
  description = "Who can invoke the function (e.g. user:alice@… or serviceAccount:… )"
  type        = string
}

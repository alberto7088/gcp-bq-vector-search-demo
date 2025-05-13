variable "secret_id" {
  description = "The resource name or ID of the Secret Manager secret (e.g. 'openai-api-key')"
  type        = string
}

variable "accessor" {
  description = "The IAM member to grant access, e.g. 'serviceAccount:my-sa@project.iam.gserviceaccount.com'"
  type        = string
}
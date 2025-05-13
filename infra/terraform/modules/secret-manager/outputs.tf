output "binding_id" {
  description = "The ID of the IAM binding created on the secret"
  value       = google_secret_manager_secret_iam_member.accessor.id
}

output "secret_id" {
  description = "The Secret Manager secret that was granted access"
  value       = var.secret_id
}

output "accessor" {
  description = "The principal who was granted access"
  value       = var.accessor
}
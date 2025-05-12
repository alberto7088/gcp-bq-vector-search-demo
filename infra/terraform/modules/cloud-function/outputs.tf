output "function_name" {
  description = "Name of the deployed Cloud Function"
  value       = google_cloudfunctions2_function.this.name
}

output "function_url" {
  description = "HTTPS trigger URL for the function"
  value       = google_cloudfunctions2_function.this.service_config[0].uri
}
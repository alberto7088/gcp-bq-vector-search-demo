output "bucket_name" {
  description = "Name of the bucket where the Terraform state is stored."
  value       = data.google_storage_bucket.this.name
}

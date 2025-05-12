data "google_storage_bucket" "this" {
  name    = var.bucket_name
  project = var.gcp_project
}

# Then still manage the IAM binding:
resource "google_storage_bucket_iam_member" "state_object_admin" {
  bucket = data.google_storage_bucket.this.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${var.state_sa_email}"
}

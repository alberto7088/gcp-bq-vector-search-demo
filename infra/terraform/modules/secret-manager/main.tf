resource "google_secret_manager_secret_iam_member" "accessor" {
  secret_id = var.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = var.accessor
}
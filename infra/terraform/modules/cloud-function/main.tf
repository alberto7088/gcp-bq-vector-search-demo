data "archive_file" "function_zip" {
  type        = "zip"
  source_dir  = var.source_dir
  output_path = "${path.module}/function.zip"
}

locals {
  function_zip_hash = data.archive_file.function_zip.output_base64sha256
}

resource "google_storage_bucket_object" "function_archive" {
  name   = "${var.function_name}/function.zip"
  bucket = var.bucket_name
  source = data.archive_file.function_zip.output_path
}

resource "google_cloudfunctions2_function" "this" {
  name                = var.function_name
  project             = var.gcp_project
  location            = var.region

  build_config{
    runtime             = var.runtime
    entry_point         = var.entry_point

    source{
      storage_source {
        bucket = var.bucket_name
        object = google_storage_bucket_object.function_archive.name
      }
    }
  }

  service_config {
    min_instance_count = var.min_instances
    max_instance_count = var.max_instances
    available_memory   = "${var.available_memory_mb}Mi"
    timeout_seconds    = var.timeout

    environment_variables = merge(
      var.environment_variables,
      { FUNCTION_ZIP_HASH = local.function_zip_hash }
    )
  }
}

resource "google_cloud_run_service_iam_member" "invoker" {
  project  = var.gcp_project
  location = var.region
  service  = google_cloudfunctions2_function.this.name
  role   = "roles/run.invoker"
  member = var.invoker_member
}


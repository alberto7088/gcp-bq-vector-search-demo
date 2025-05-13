terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      # Version constraints are inherited from the root module
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      # Version constraints are inherited from the root module
      configuration_aliases = [google-beta]
    }
  }
}
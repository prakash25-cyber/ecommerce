terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  region = var.region
}

# Output to quickly help you tag and push your website container from VS Code
output "registry_push_instruction" {
  value       = "docker tag website-image ${var.region}-docker.pkg.dev/${var.project_id}/ecommerce-web-repo/frontend:v1"
  description = "Run this in your terminal to tag your built web container for your secure Artifact Registry."
}
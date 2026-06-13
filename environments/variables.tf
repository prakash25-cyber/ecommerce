variable "project_name" {
  type        = string
  description = "The display name of the Google Cloud Project"
  default     = "ecommerce sonufoot"
}

variable "project_id" {
  type        = string
  description = "The globally unique ID for the new GCP Project"
  default     = "ecommerce-sonufoot-prod"
}

variable "billing_account" {
  type        = string
  description = "The Google Cloud Billing Account ID linked to your profile"
  default     = "01BB08-28AADD-2E6CC0" # <-- Replace this with your actual billing account ID
}

variable "region" {
  type        = string
  description = "The primary cloud data center region for deployment"
  default     = "us-central1"
}
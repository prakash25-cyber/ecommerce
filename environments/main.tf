# ==========================================
# 1. PROJECT CREATION & API ENABLEMENT
# ==========================================

resource "google_project" "ecommerce_project" {
  name            = var.project_name
  project_id      = var.project_id
  billing_account = var.billing_account
}

resource "google_project_service" "enabled_apis" {
  for_each = toset([
    "compute.googleapis.com",
    "container.googleapis.com",
    "artifactregistry.googleapis.com",
    "iam.googleapis.com"
  ])
  project            = google_project.ecommerce_project.project_id
  service            = each.key
  disable_on_destroy = false
}

# ==========================================
# 2. LAYERED SECURITY & PRIVATE NETWORKING
# ==========================================

resource "google_artifact_registry_repository" "web_images" {
  project       = google_project.ecommerce_project.project_id
  location      = var.region
  repository_id = "ecommerce-web-repo"
  description   = "Secure private storage for the sonufoot storefront app images"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true # Protects against supply chain container overrides
  }
  depends_on = [google_project_service.enabled_apis]
}

resource "google_compute_network" "secure_vpc" {
  project                 = google_project.ecommerce_project.project_id
  name                    = "ecommerce-secure-vpc"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.enabled_apis]
}

resource "google_compute_subnetwork" "secure_subnet" {
  project                  = google_project.ecommerce_project.project_id
  name                     = "ecommerce-secure-subnet"
  ip_cidr_range            = "10.0.0.0/22"
  region                   = var.region
  network                  = google_compute_network.secure_vpc.id
  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.4.0.0/14"
  }
  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.8.0.0/20"
  }
}

resource "google_compute_router" "private_router" {
  project = google_project.ecommerce_project.project_id
  name    = "private-gke-router"
  region  = var.region
  network = google_compute_network.secure_vpc.id
}

resource "google_compute_router_nat" "secure_nat" {
  project                            = google_project.ecommerce_project.project_id
  name                               = "secure-nat-gateway"
  router                             = google_compute_router.private_router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# ==========================================
# 3. GKE ORCHESTRATION & LOAD BALANCERS
# ==========================================

resource "google_container_cluster" "secure_cluster" {
  project          = google_project.ecommerce_project.project_id
  name             = "sonufoot-secure-cluster"
  location         = var.region
  network          = google_compute_network.secure_vpc.id
  subnetwork       = google_compute_subnetwork.secure_subnet.id
  enable_autopilot = true

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false # Connect locally via standard gcloud control plane channels
  }
}

resource "google_compute_global_address" "public_lb_ip" {
  project      = google_project.ecommerce_project.project_id
  name         = "sonufoot-frontend-public-ip"
  address_type = "EXTERNAL"

  # FIX: Forces the global static IP to wait until the Compute API is turned on
  depends_on = [google_project_service.enabled_apis]
}

resource "google_compute_address" "internal_lb_ip" {
  project      = google_project.ecommerce_project.project_id
  name         = "backend-internal-lb-ip"
  subnetwork   = google_compute_subnetwork.secure_subnet.id
  address_type = "INTERNAL"
  purpose      = "SHARED_LOADBALANCING"
  region       = var.region

  # FIX: Forces the internal IP to wait until the Compute API is turned on
  depends_on = [google_project_service.enabled_apis]
}
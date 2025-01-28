resource "google_compute_network" "psc_vpc" {
  name                    = var.psc_vpc_name
  project                 = var.attachment_project_id
  auto_create_subnetworks = false # Disabling auto creation of subnetworks
}

resource "google_compute_subnetwork" "psc_subnet_primary" {
  project       = var.attachment_project_id
  name          = var.psc_subnet_primary_name
  ip_cidr_range = var.psc_subnet_primary_ip_cidr_range
  region        = var.region_primary
  network       = google_compute_network.psc_vpc.id
}

resource "google_compute_subnetwork" "psc_subnet_secondary" {
  project       = var.attachment_project_id
  name          = var.psc_subnet_secondary_name
  ip_cidr_range = var.psc_subnet_secondary_ip_cidr_range
  region        = var.region_primary
  network       = google_compute_network.psc_vpc.id
}
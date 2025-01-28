resource "google_project_service_identity" "alloydb_sa" {
  provider = google-beta

  project = var.project_id
  service = "alloydb.googleapis.com"
}

resource "random_string" "key_suffix" {
  length  = var.key_suffix_length
  special = var.key_suffix_special
  upper   = var.key_suffix_upper
}

resource "google_kms_key_ring" "keyring_region_central" {
  project  = var.project_id
  name     = "keyring-${var.region_central}-${random_string.key_suffix.result}"
  location = var.region_central
}

resource "google_kms_crypto_key" "key_region_central" {
  name     = "key-${var.region_central}-${random_string.key_suffix.result}"
  key_ring = google_kms_key_ring.keyring_region_central.id
}

resource "google_kms_crypto_key_iam_member" "alloydb_sa_iam" {
  crypto_key_id = google_kms_crypto_key.key_region_central.id
  role          = join(",", var.alloydb_sa_iam_role) # Join roles with comma
  member        = "serviceAccount:${google_project_service_identity.alloydb_sa.email}"
}

## Cross Region Secondary Cluster Keys

resource "google_kms_key_ring" "keyring_region_east" {
  project  = var.project_id
  name     = "keyring-${var.region_east}-${random_string.key_suffix.result}"
  location = var.region_east
}

resource "google_kms_crypto_key" "key_region_east" {
  name     = "key-${var.region_east}-${random_string.key_suffix.result}"
  key_ring = google_kms_key_ring.keyring_region_east.id
}

resource "google_kms_crypto_key_iam_member" "alloydb_sa_iam_secondary" {
  crypto_key_id = google_kms_crypto_key.key_region_east.id
  role          = join(",", var.alloydb_sa_iam_role)
  member        = "serviceAccount:${google_project_service_identity.alloydb_sa.email}"
}
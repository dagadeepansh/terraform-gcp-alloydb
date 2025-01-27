module "alloydb_primary" {
  source  = "GoogleCloudPlatform/alloy-db/google"
  version = "~> 3.0"

  project_id        = var.project_id
  cluster_location  = var.region_central
  cluster_id        = var.cluster_id

  primary_instance = {
    instance_id        = var.primary_instance.instance_id
    display_name       = var.primary_instance.display_name
    machine_type       = "db-custom-${var.primary_instance.machine_cpu_count}-3840" # Changed interpolation
    availability_type  = var.primary_instance.availability_type
    database_flags     = var.primary_instance.database_flags
    labels             = var.primary_instance.labels
    annotations        = var.primary_instance.annotations
    gce_zone           = var.primary_instance.gce_zone
    ssl_mode           = var.primary_instance.ssl_mode
    require_connectors = var.primary_instance.require_connectors
    query_insights_config = var.primary_instance.query_insights_config
    enable_public_ip   = var.primary_instance.enable_public_ip
    cidr_range         = var.primary_instance.cidr_range
  }

  read_pool_instance = [
    for i, read_instance in var.read_pool_instance : {
      instance_id        = read_instance.instance_id
      display_name       = read_instance.display_name
      machine_type       = "db-custom-${read_instance.machine_cpu_count}-3840" # Changed interpolation
      availability_type  = read_instance.availability_type
      database_flags     = read_instance.database_flags
      gce_zone           = read_instance.gce_zone
      node_count         = read_instance.node_count
      ssl_mode           = read_instance.ssl_mode
      require_connectors = read_instance.require_connectors
      query_insights_config = read_instance.query_insights_config
      enable_public_ip   = read_instance.enable_public_ip
      cidr_range         = read_instance.cidr_range
    }
  ]

  cluster_initial_user = {
    user     = var.cluster_initial_user
    password = var.cluster_initial_password
  }

  psc_enabled                  = var.psc_enabled
  psc_allowed_consumer_projects = var.psc_allowed_consumer_projects
  cluster_encryption_key_name   = google_kms_crypto_key.key_region_central.id
  continuous_backup_encryption_key_name = google_kms_crypto_key.key_region_central.id

  automated_backup_policy = {
    location                      = var.region_central
    backup_window                 = var.backup_window
    enabled                       = var.automated_backup_enabled
    weekly_schedule               = var.weekly_schedule
    quantity_based_retention_count = var.quantity_based_retention_count
    time_based_retention_count     = var.time_based_retention_count
    labels                        = var.backup_labels
    backup_encryption_key_name    = google_kms_crypto_key.key_region_central.id
  }

  depends_on = [
    google_kms_crypto_key_iam_member.alloydb_sa_iam,
    google_kms_crypto_key.key_region_central
  ]
}

resource "google_project_service_identity" "alloydb_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "alloydb.googleapis.com"
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
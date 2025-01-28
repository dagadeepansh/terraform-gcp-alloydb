module "alloydb_replica" {
  source  = "GoogleCloudPlatform/alloy-db/google"
  version = "~> 3.0"

  project_id           = var.project_id
  cluster_location     = var.region_east
  cluster_id           = var.cluster_id_replica
  primary_cluster_name = var.primary_cluster_name # Keep this if you want to link to a primary

  psc_enabled                  = var.psc_enabled
  psc_allowed_consumer_projects = var.psc_allowed_consumer_projects

  cluster_encryption_key_name   = google_kms_crypto_key.key_region_east.id
  
  continuous_backup_enable               = true
  continuous_backup_recovery_window_days = 10
  continuous_backup_encryption_key_name = google_kms_crypto_key.key_region_east.id

  automated_backup_policy = {
    location                      = var.region_east
    backup_window                 = var.backup_window
    enabled                       = var.automated_backup_enabled
    weekly_schedule               = var.weekly_schedule
    quantity_based_retention_count = var.quantity_based_retention_count
    time_based_retention_count     = var.time_based_retention_count
    labels                        = var.backup_labels
    backup_encryption_key_name    = google_kms_crypto_key.key_region_east.id
  }

  # Using the primary_instance variable for the replica's primary instance
  primary_instance = {
    instance_id        = var.replica_primary_instance_id
    display_name       = var.primary_instance.instance_id
    display_name       = var.primary_instance.display_name
    database_flags     = var.primary_instance.database_flags
    labels             = var.primary_instance.labels
    annotations        = var.primary_instance.annotations
    gce_zone           = var.primary_instance.gce_zone
    availability_type  = var.primary_instance.availability_type
    machine_type       = "db-custom-${var.primary_instance.machine_cpu_count}-3840" # Assuming you want the same machine type as primary
    ssl_mode           = var.primary_instance.ssl_mode
    require_connectors = var.primary_instance.require_connectors
    machine_cpu_count  = var.primary_instance.machine_cpu_count 
    query_insights_config = var.primary_instance.query_insights_config
    enable_public_ip   = var.primary_instance.enable_public_ip
    cidr_range         = var.primary_instance.cidr_range
    client_connection_config = {
      require_connectors = false
      ssl_config         = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }
  }

  depends_on = [
    module.alloydb_primary,
    google_kms_crypto_key_iam_member.alloydb_sa_iam_secondary,
    google_kms_crypto_key.key_region_east,
  ]
}

## Cross Region Secondary Cluster Keys


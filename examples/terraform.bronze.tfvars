#Bronze: 1 Instance - 1 Instance in 1 zone in 1 Region with no HA and no DR.

project_id                    = "cloudlake-dev-1"
psc_attachment_project_id     = "terraform-cloudbuild"
psc_attachment_project_number = "805128748265"
region_primary                = "us-central1"
region_replica                = "us-east4" # Keep this for potential future use, even if not used in Bronze
cluster_name                  = "primary-cluster-psc"
cluster_id                    = "primary-central-cluster-id"
backup_window                 = "1800s"
automated_backup_enabled      = true
cluster_initial_user          = "postgres"
# cluster_initial_password intentionally omitted. Terraform will prompt.

weekly_schedule = {
  days_of_week = ["FRIDAY"]
  start_times  = ["02:00:00:000"]
}

quantity_based_retention_count = 1
time_based_retention_count     = null

backup_labels = {
  test = "alloydb-cluster-with-prim"
}

continuous_backup_recovery_window_days = 10

primary_instance = {
  instance_id        = "cluster-primary-central-instance1-psc"
  display_name       = "Primary Instance"
  database_flags     = {} # Now managed *within* the module
  labels             = {}
  annotations        = {}
  gce_zone           = "us-central1-a" #  Specify a zone for ZONAL availability.  CRITICAL CHANGE
  availability_type  = "ZONAL"
  machine_cpu_count  = 2
  ssl_mode           = "ENCRYPTED_ONLY" # Enforce encrypted connections
  require_connectors = false
  query_insights_config = {
    query_string_length     = 1024
    record_application_tags = false
    record_client_address   = false
    query_plans_per_minute  = 5
  }
  enable_public_ip = false
  cidr_range       = []
}

read_pool_instances = [] # No read pool instances for the Bronze pattern

key_suffix_length   = 3
key_suffix_special  = false
key_suffix_upper    = false
alloydb_sa_iam_role = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]

# Replica settings (keep these for consistency, but they won't be used unless you configure a replica)
replica_instance_id      = "cluster-replica-east-instance1-psc"
continuous_backup_enable = true
cluster_id_replica       = "replica-east-cluster-id"

replica_instance = {
  require_connectors = false
  ssl_mode           = "ENCRYPTED_ONLY"
}

psc_vpc_network = "psc-vpc" # Added this
# GOLD: 3 Instances - 2 Instances in 2 zones in Region1 and at-least 1 Instance in 1 zone in Region 2 with HA and DR enabled. Zonal Failover is automatic and regional failover is manual.

project_id                    = "cloudlake-dev-1" # Replace with your project ID
psc_attachment_project_id     = "terraform-cloudbuild"
psc_attachment_project_number = "805128748265"
region_primary                = "us-central1"                # Primary Region
region_replica                = "us-east4"                   # Secondary Region (DR Region)
cluster_name                  = "primary-cluster-psc"        # Or more descriptive name
cluster_id                    = "primary-central-cluster-id" # Or more descriptive name
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
  test = "alloydb-cluster-gold" # Use distinct labels
}

continuous_backup_recovery_window_days = 10

primary_instance = {
  instance_id        = "primary-instance-us-central1"
  display_name       = "Primary Instance (us-central1)"
  database_flags     = {} # Managed within the module
  labels             = {}
  annotations        = {}
  gce_zone           = "us-central1-a" # Zone 1 in primary region
  availability_type  = "REGIONAL"      #  CRITICAL: Use REGIONAL for HA within primary region
  machine_cpu_count  = 2
  ssl_mode           = "ENCRYPTED_ONLY"
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

read_pool_instances = [
  {
    instance_id        = "readpool-instance-us-central1"
    display_name       = "Read Pool Instance (us-central1-f)" # Descriptive name
    node_count         = 1
    database_flags     = {}
    availability_type  = "ZONAL"         # Zonal, in a *different* zone than primary
    gce_zone           = "us-central1-f" # Zone 2 in primary region - MUST be different
    machine_cpu_count  = 2               # Match primary for consistency
    ssl_mode           = "ENCRYPTED_ONLY"
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
]

key_suffix_length   = 3
key_suffix_special  = false
key_suffix_upper    = false
alloydb_sa_iam_role = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]

# --- Replica Instance Configuration ---
replica_instance_id      = "replica-instance-us-east4" # Clear, region-specific ID
continuous_backup_enable = true
cluster_id_replica       = "replica-east-cluster-id" # ID for the *replica* cluster

replica_instance = {
  require_connectors = false
  ssl_mode           = "ENCRYPTED_ONLY"
}
psc_vpc_network = "psc-vpc" # Added this
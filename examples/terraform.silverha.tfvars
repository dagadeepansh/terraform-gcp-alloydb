# Silver HA: 2 Instances - 2 Instances in 2 zones in 1 Regions with HA enabled and no DR. Failover is zonal and automatic.

project_id                    = "cloudlake-dev-1" # Replace with your project ID
psc_attachment_project_id     = "terraform-cloudbuild"
psc_attachment_project_number = "805128748265"
region_primary                = "us-central1"                # Specify your desired region
region_replica                = "us-east4"                   # Keep this for consistency
cluster_name                  = "primary-cluster-psc"        # Or a name specific to this setup
cluster_id                    = "primary-central-cluster-id" # Or a name specific to this setup
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
  test = "alloydb-cluster-silver-ha" #  Good practice to use different labels
}

continuous_backup_recovery_window_days = 10

primary_instance = {
  instance_id        = "cluster-primary-central-instance1-psc"
  display_name       = "Primary Instance"
  database_flags     = {} # Managed within the module
  labels             = {}
  annotations        = {}
  gce_zone           = "us-central1-a" # Zone 1 for the primary instance
  availability_type  = "REGIONAL"      #  CRITICAL: Use REGIONAL for HA
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

read_pool_instances = [
  {
    instance_id        = "cluster-primary-central-instance1-psc-r1-psc"
    display_name       = "Read Pool Instance (Zone 2)" #  Descriptive name
    node_count         = 1                             #One instance in zone 2.
    database_flags     = {}                            #Managed within the module
    availability_type  = "ZONAL"                       # Zonal, but in a *different* zone
    gce_zone           = "us-central1-f"               # Zone 2 - MUST be different from primary
    machine_cpu_count  = 2                             #  Match primary, for failover
    ssl_mode           = "ENCRYPTED_ONLY"
    require_connectors = false
    query_insights_config = { # Defaults
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

# Replica settings (keep for consistency, but not directly used in this pattern)
replica_instance_id      = "cluster-replica-east-instance1-psc"
continuous_backup_enable = true
cluster_id_replica       = "replica-east-cluster-id"

replica_instance = {
  require_connectors = false
  ssl_mode           = "ENCRYPTED_ONLY"
}

psc_vpc_network = "psc-vpc" # Added this
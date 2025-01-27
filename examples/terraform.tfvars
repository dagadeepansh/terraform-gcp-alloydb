project_id ="cloudlake-dev-1"
attachment_project_id="terraform-cloudbuild"
attachment_project_number="805128748265"
cluster_name="gmb"
psc_vpc_network="psc-vpc" 
psc_subnet_pri="psc-subnet-1"
psc_subnet_sec="psc-subnet-2"
region_central                       = "us-central1"
region_east = "us-east1"  # Example value
cluster_id                           = "cluster-us-central1-psc"
primary_instance_id                  = "cluster-us-central1-instance1-psc"
cluster_id_east                      = "cluster-us-east1-psc"
replica_primary_instance_id          = "cluster-us-east1-instance1-psc"
primary_instance_availability_type_east = "ZONAL"
primary_instance_display_name        = "Primary Instance"
cpu_count                            = "2"
primary_instance_availability_type   = "REGIONAL"
primary_instance_tier                = "db-custom-1-3840"
read_pool_instances = [
  {
    instance_id        = "cluster-us-central1-r1-psc"
    display_name       = "Read Pool Instance 1"
    availability_type  = "REGIONAL"
    tier               = "db-custom-1-3840"
  },
  {
    instance_id        = "cluster-us-central1-r2-psc"
    display_name       = "Read Pool Instance 2"
    availability_type  = "REGIONAL"
    tier               = "db-custom-1-3840"
  }
]
cluster_initial_user                 = "postgres"
cluster_initial_password             = "fQj6$h{q#YIKlIE7" # Replace this with a strong password
psc_enabled                          = true
psc_allowed_consumer_projects        = ["805128748265"] # Replace with consumer project number
backup_window                        = "1800s"
automated_backup_enabled             = true
weekly_schedule = {
  days_of_week = ["FRIDAY"]
  start_times  = ["2:00:00:00"]
}
quantity_based_retention_count        = 1
time_based_retention_count            = null
backup_labels = {
  test = "alloydb-cluster-with-prim"
}
key_suffix_length                    = 3
key_suffix_special                   = false
key_suffix_upper                     = false
alloydb_sa_iam_role = [
  "roles/cloudkms.cryptoKeyEncrypterDecrypter",
  "roles/secretmanager.admin"
]
secret_manager_replica_location      = "us-central1"
primary_instance = {
  instance_id        = "cluster-us-central1-instance1-psc"  # Unique ID for your primary instance
  display_name       = "My Primary AlloyDB Instance"  # User-friendly display name
  database_flags = {
    "log_error_verbosity"     = "VERBOSE"
    "log_connections"         = "on"
    "log_disconnections"       = "on"
    "log_statement"           = "all"          # Log all statements (for debugging, consider "ddl" or "mod" in production)
    "log_min_messages"        = "warning"      # Log messages at warning level and above
    "log_min_error_statement" = "error"        # Log errors at error level and above
    "log_min_duration_statement" = "1000"        # Log statements taking longer than 1000ms (1 second)
    "password.enforce_complexity" = "on" # parameter is needed for instance with public IP address
    "alloydb.enable_pgaudit"      = "on"
    "alloydb.iam_authentication"  = "on"
  }
  labels = {
    environment = "dev"
    purpose     = "alloydb-testing"
  }
  annotations = {
    note = "This is the primary instance for the AlloyDB cluster."
  }
  gce_zone           = "us-central1-a" # Choose an appropriate zone in your region
  availability_type  = "REGIONAL"        # Or "ZONAL" if you need a zonal instance
  machine_cpu_count  = 4                # Choose an appropriate CPU count (must be one of [2, 4, 8, 16, 32, 64, 96, 128])
  ssl_mode           = "ENCRYPTED_ONLY" # Determines the SSL mode for connections to the instance.
  require_connectors = false             # Determines whether to enforce authenticated connections using AlloyDB connectors
  query_insights_config = {
    query_string_length     = 1500
    record_application_tags = true
    record_client_address   = false
    query_plans_per_minute  = 10
  }
  enable_public_ip   = false # Set to true only if you need public IP access (not recommended for production)
  cidr_range         = null # Only needed if enable_public_ip is true, specify allowed CIDR ranges
}

# Read Pool Instances Configuration (Optional)
read_pool_instance = [
  {
    instance_id        = "cluster-us-central1-r1-psc"
    display_name       = "My Read Pool Instance 1"
    node_count         = 2       # Number of nodes in the read pool instance (default is 1)
    database_flags = {            # You can customize database flags for read pool instances
      "log_statement" = "ddl"     # Example: Log only DDL statements on this read pool instance
    }
    availability_type  = "REGIONAL"
    gce_zone           = "us-central1-b"
    machine_cpu_count  = 2
    ssl_mode           = "ENCRYPTED_ONLY"
    require_connectors = false
    query_insights_config = {
      query_string_length     = 1024
      record_application_tags = false
      record_client_address   = false
      query_plans_per_minute  = 5
    }
    enable_public_ip   = false
    cidr_range         = null
  },
  {
    instance_id        = "cluster-us-central1-r2-psc"
    display_name       = "My Read Pool Instance 2"
    node_count         = 1
    availability_type  = "ZONAL"
    gce_zone           = "us-central1-f"
    machine_cpu_count  = 2
    ssl_mode           = "ENCRYPTED_ONLY"
    require_connectors = false
    enable_public_ip   = false
    cidr_range         = null
  }
]

project_id                = "cloudlake-dev-1"
attachment_project_id     = "terraform-cloudbuild"
attachment_project_number = "805128748265"
region_primary            = "us-central1" # Keeping original value
region_replica            = "us-east4"    # From your provided values
cluster_name              = "primary-cluster-psc"
cluster_id                = "primary-central-cluster-id"
psc_enabled               = true # Keeping original value
psc_vpc_network           = "psc-vpc"
backup_window             = "1800s"        # Keeping original value
automated_backup_enabled  = true           # Keeping original value
cluster_initial_user      = "alloydbadmin" # Keeping default from variables.tf

# cluster_initial_password is intentionally omitted. Terraform will prompt.

weekly_schedule = {
  days_of_week = ["FRIDAY"]
  start_times  = ["02:00:00:000"] # Using provided corrected format
}

quantity_based_retention_count = 1    # Keeping original value
time_based_retention_count     = null # Keeping original value

backup_labels = {
  test = "alloydb-cluster-with-prim" # Keeping original value
}

continuous_backup_recovery_window_days = 10 # Keeping original value

primary_instance = {
  instance_id  = "cluster-primary-central-instance1-psc" # From your provided values
  display_name = "Primary Instance"                      # Keeping original value
  database_flags = {
    "log_error_verbosity"         = "default"
    "log_connections"             = "on"
    "log_disconnections"          = "on"
    "log_statement"               = "all"
    "log_min_messages"            = "warning"
    "log_min_error_statement"     = "error"
    "log_min_duration_statement"  = "-1"
    "password.enforce_complexity" = "on" # parameter is needed for instance with public IP address
    "alloydb.enable_pgaudit"      = "on"
    "alloydb.iam_authentication"  = "on"
  }
  labels             = {}                                # Keeping original value
  annotations        = {}                                # Keeping original value
  gce_zone           = null                              # Keeping original value
  availability_type  = "ZONAL"                           # Keeping original value
  machine_cpu_count  = 2                                 # Using provided cpu_count = 2
  ssl_mode           = "ALLOW_UNENCRYPTED_AND_ENCRYPTED" # Keeping original value
  require_connectors = false                             # Keeping original value
  query_insights_config = {
    query_string_length     = 1024  # Keeping original value
    record_application_tags = false # Keeping original value
    record_client_address   = false # Keeping original value
    query_plans_per_minute  = 5     # Keeping original value
  }
  enable_public_ip = false # Keeping original value
  cidr_range       = []    # Keeping original value
}

read_pool_instances = [
  {
    instance_id        = "cluster-primary-central-instance1-psc-r1-psc" # Combining primary instance ID and suffix
    display_name       = "Read Pool Instance r1-psc"                    # Clear display name
    node_count         = 1
    database_flags     = {}               # You might want to specify flags here
    availability_type  = "ZONAL"          # Or "REGIONAL"
    gce_zone           = null             #  Specify if needed
    machine_cpu_count  = 2                #From the the machine cpu count
    ssl_mode           = "ENCRYPTED_ONLY" # Keeping the ssl mode.
    require_connectors = false            # Default
    query_insights_config = {             # Defaults
      query_string_length     = 1024
      record_application_tags = false
      record_client_address   = false
      query_plans_per_minute  = 5
    }
    enable_public_ip = false # Default
    cidr_range       = []    # Default
  },
  {
    instance_id        = "cluster-primary-central-instance1-psc-r2-psc" # Combining primary instance ID and suffix
    display_name       = "Read Pool Instance r2-psc"                    # Clear display name
    node_count         = 2
    database_flags     = {}               # You might want to specify flags here
    availability_type  = "ZONAL"          # Or "REGIONAL"
    gce_zone           = null             # Specify if needed
    machine_cpu_count  = 2                #  From the the machine cpu count
    ssl_mode           = "ENCRYPTED_ONLY" #Keeping the ssl mode
    require_connectors = false            # Default
    query_insights_config = {             # Defaults
      query_string_length     = 1024
      record_application_tags = false
      record_client_address   = false
      query_plans_per_minute  = 5
    }
    enable_public_ip = false # Default
    cidr_range       = []    # Default
  }
]

psc_consumer_address_name            = "psc-consumer-address"                         # Keeping original value
psc_consumer_address_type            = "INTERNAL"                                     # Keeping original value
psc_fwd_rule_name                    = "psc-fwd-rule-consumer-endpoint"               # Keeping original value
psc_fwd_rule_allow_psc_global_access = true                                           # Keeping original value
psc_consumer_address                 = "10.2.0.10"                                    # Keeping original value
psc_vpc_name                         = "psc-endpoint-vpc"                             # Keeping original value
psc_subnet_primary_name              = "psc-subnet-primary"                           # Keeping original value
psc_subnet_primary_ip_cidr_range     = "10.2.0.0/24"                                  # Keeping original value
psc_subnet_secondary_name            = "psc-subnet-secondary"                         # Keeping original value
psc_subnet_secondary_ip_cidr_range   = "10.3.0.0/24"                                  # Keeping original value
key_suffix_length                    = 3                                              # Keeping original value
key_suffix_special                   = false                                          # Keeping original value
key_suffix_upper                     = false                                          # Keeping original value
alloydb_sa_iam_role                  = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"] # Keeping original value
replica_instance_id                  = "cluster-replica-east-instance1-psc"           # From your provided values
continuous_backup_enable             = true                                           # Keeping original value
cluster_id_replica                   = "replica-east-cluster-id"                      # From your provided values

replica_instance = { # Renamed to avoid conflict
  require_connectors = false
  ssl_mode           = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
}
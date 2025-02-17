# GOLD: 3 Instances - 2 Instances in 2 zones in Region1 and at-least 1 Instance in 1 zone in Region 2 with HA and DR enabled. Zonal Failover is automatic and regional failover is manual.

locals {
  project_id         = "np-bjqk-6962e2b6d12d"    #project ID of the project where alloydb will be created
  primary_location   = "northamerica-northeast1" #location of region where primary cluster alloydb will be created
  region_replica     = "northamerica-northeast2" #location where replicat clkuster will be created
  label              = "alloydb-gold"
  psc_project_number = "242924471764" #psc project number of the project in which PSC is created

  primary_cluster_id           = "gold-cluster-1"
  primary_cluster_display_name = "primary-cluster-psc-gold-1"
  primary_secret_id            = "postgres_secret_14Feb"
  primary_initial_user         = "postgres"

  replica_cluster_id_suffix    = "replica" # Suffix to replica cluster ID
  replica_cluster_display_name = "replica-cluster-psc-gold-1"
  replica_instance_id          = "replica-instance-psc-gold-1" # Consider making it dynamic if needed

  security_cia                  = "cia"
  security_pci                  = "pci"
  security_data_confidentiality = "confidential"
  machine_cpu_count             = 2
}

module "alloydb_gold" {
  source = "../../../../terraform-gcp-alloydb"
  #version = "1.0.9"

  project_id                    = local.project_id
  region_primary                = local.primary_location
  cluster_id                    = local.primary_cluster_id
  cluster_name                  = local.primary_cluster_display_name
  secret_id                     = local.primary_secret_id
  security_cia                  = local.security_cia
  security_pci                  = local.security_pci
  security_data_confidentiality = local.security_data_confidentiality

  psc_enabled                   = true
  psc_attachment_project_number = local.psc_project_number

  backup_window            = "1800s"
  automated_backup_enabled = true
  weekly_schedule = {
    days_of_week = ["FRIDAY"]
    start_times  = ["02:00:00:000"]
  }
  quantity_based_retention_count = 1
  time_based_retention_count     = null
  backup_labels                  = { test = "alloydb-cluster-gold-primary" } # Differentiated label

  continuous_backup_recovery_window_days = 10
  cluster_initial_user                   = local.primary_initial_user

  primary_instance = {
    instance_id       = "${local.primary_cluster_display_name}-instance1-psc"
    display_name      = "Primary Instance Gold (${local.primary_location})"
    availability_type = "REGIONAL"
    database_flags    = {}
    labels = {
      security_cia                  = local.security_cia
      security_pci                  = local.security_pci
      security_data_confidentiality = local.security_data_confidentiality
    }
    annotations        = {}
    gce_zone           = "${local.primary_location}-a" # Explicit zone in primary region
    require_connectors = false
    ssl_mode           = "ENCRYPTED_ONLY"
    query_insights_config = {
      query_string_length     = 1024
      record_application_tags = false
      record_client_address   = false
      query_plans_per_minute  = 5
    }
    enable_public_ip  = false
    cidr_range        = []
    machine_cpu_count = local.machine_cpu_count
  }

  read_pool_instances = [
    {
      instance_id        = "${local.primary_cluster_display_name}-instance1-psc-r1"
      display_name       = "Primary Read Pool Instance r1-psc" # Descriptive name
      node_count         = 1
      database_flags     = {}
      availability_type  = "ZONAL"
      gce_zone           = "${local.primary_location}-b" # Zone 2 in primary region - MUST be different
      machine_cpu_count  = local.machine_cpu_count
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
    },
    {
      instance_id        = "${local.primary_cluster_display_name}-instance1-psc-r2"
      display_name       = "Primary Read Pool Instance r2-psc"
      node_count         = 1
      database_flags     = {}
      availability_type  = "ZONAL"
      gce_zone           = "${local.primary_location}-c" # Zone 3 in primary region
      machine_cpu_count  = local.machine_cpu_count
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
}

module "alloydb_replica" {
  source = "../../../../terraform-gcp-alloydb"
  #version = "1.0.9"  # Use a specific version if possible
  primary_cluster_name          = module.alloydb_gold.cluster_name
  project_id                    = local.project_id
  security_cia                  = local.security_cia
  security_pci                  = local.security_pci
  security_data_confidentiality = local.security_data_confidentiality
  region_primary = local.region_replica
  psc_enabled                   = true
  psc_attachment_project_number = local.psc_project_number
  region_replica                = local.region_replica
  cluster_id                    = "${local.replica_cluster_id_suffix}-${local.region_replica}-${local.primary_cluster_id}"
  cluster_name                  = "${module.alloydb_gold.cluster_name}-replica" # Name based on primary
  cluster_type                  = "SECONDARY"

  backup_window            = "1800s"
  automated_backup_enabled = true
  weekly_schedule = {
    days_of_week = ["FRIDAY"]
    start_times  = ["02:00:00:000"]
  }
  quantity_based_retention_count = 1
  time_based_retention_count     = null
  backup_labels                  = { test = "alloydb-cluster-gold-replica" } # Differentiated label

  continuous_backup_recovery_window_days = 10
  primary_instance = { # The main instance in the replica cluster is a "primary_instance" from the module's POV
    instance_id       = local.replica_instance_id
    display_name      = "Replica Instance Gold (${local.region_replica})"
    instance_type     = "SECONDARY" # But its *type* is READ_POOL
    gce_zone          = "${local.region_replica}-a"
    availability_type = "ZONAL"
    machine_config = {
      cpu_count = local.machine_cpu_count
    }
    labels = {
      security_cia                  = local.security_cia
      security_pci                  = local.security_pci
      security_data_confidentiality = local.security_data_confidentiality
    }
    database_flags = {}

    machine_cpu_count  = local.machine_cpu_count
    enable_public_ip   = false
    cidr_range         = []
    annotations        = {}
    gce_zone           = "${local.primary_location}-a" # Explicit zone in primary region
    require_connectors = false
    ssl_mode           = "ENCRYPTED_ONLY"
    ip_configuration = {
      require_ssl = true
      psc_config = {
        psc_enabled = true
        allowed_consumer_projects = [local.psc_project_number]
      }
    }
    query_insights_config = {
      query_string_length     = 1024
      record_application_tags = false
      record_client_address   = false
      query_plans_per_minute  = 5
    }
  }

  # Optional: Add read_pool_instances to the replica cluster if needed
  read_pool_instances = [] // Or define read pool instances here, like in the primary
}

resource "google_project_service_identity" "alloydb_sa" {
  provider = google-beta
  project  = local.project_id
  service  = "alloydb.googleapis.com"
}

resource "random_string" "key_suffix" {
  length  = 3
  special = false
  upper   = false
}

resource "google_kms_key_ring" "keyring_region_replica" {
  project  = local.project_id
  name     = "keyring-${local.region_replica}-${random_string.key_suffix.result}"
  location = local.region_replica
}

resource "google_kms_crypto_key" "key_region_replica" {
  name     = "key-${local.region_replica}-${random_string.key_suffix.result}"
  key_ring = google_kms_key_ring.keyring_region_replica.id
}

resource "google_kms_crypto_key_iam_member" "alloydb_sa_iam_secondary" {
  crypto_key_id = google_kms_crypto_key.key_region_replica.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_project_service_identity.alloydb_sa.email}"
}

### Working example of creating Database and Run query by using local_exec provisioner
## Pre-requisite: 1. Must enable Public IP for the Primary Instance
##                2. Must whitelist the runner IP in the Authorized network

# Create Table in the default postgres db
# resource "null_resource" "run_query" {
#   depends_on = [module.alloydb_primary]
#   provisioner "local-exec" {
#     command     = <<EOF
#       PGPASSWORD="postgres" 
#       psql -h ${module.alloydb_primary.primary_instance.public_ip_address} \
#            -U "postgres"  \
#            -p 5432  \
#            -d postgres \
#            -c "CREATE TABLE my_table (id SERIAL PRIMARY KEY, name VARCHAR(255));"
#     EOF
#     interpreter = ["bash", "-c"]
#     }
# }

# Create a new db
# resource "null_resource" "create_database" {
#   depends_on = [module.alloydb_primary]
#   provisioner "local-exec" {
#     command     = <<EOF
#       PGPASSWORD="postgres" \
#       psql -h ${module.alloydb_primary.primary_instance.public_ip_address} \
#            -U "${var.cluster_initial_user}" \
#            -p 5432 \
#            -c "CREATE DATABASE ${var.database_name};"
#     EOF
#     interpreter = ["bash", "-c"]
#     environment = {
#       # Set timeout as needed
#       # PGDATABASE = var.database_name
#     }
#   }
# }

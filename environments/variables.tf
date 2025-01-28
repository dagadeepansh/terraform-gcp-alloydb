variable "project_id" {
  type = string
  description = "The ID of the project where resources will be created."
}

variable "region_central" {
  type = string
  description = "The region to deploy resources in."
}

variable "cluster_id" {
  type = string
  description = "The ID of the AlloyDB cluster."
}

variable "primary_instance_id" {
  type = string
  description = "The ID of the primary instance."
}

variable "primary_instance_display_name" {
  type = string
  description = "The display name of the primary instance."
  default = "Primary Instance"
}

variable "cpu_count" {
  type = string
  description = "Number of CPUs for the machine type (e.g., 2, 4, 8, etc.)."
}

variable "primary_instance_availability_type" {
  type = string
  description = "The availability type of the primary instance (e.g., REGIONAL, ZONAL)."
  default = "REGIONAL"
}

variable "primary_instance_tier" {
  type = string
  description = "Instance tier"
  default = "db-custom-1-3840"
}

variable "read_pool_instances" {
  type = list(object({
    instance_id        = string
    display_name       = string
    availability_type  = string
    tier               = string
  }))
  description = "List of read pool instances."
}

variable "cluster_initial_user" {
  type = string
  description = "The initial user for the cluster."
}

variable "cluster_initial_password" {
  type = string
  description = "The password for the initial user."
}

variable "psc_enabled" {
  type = bool
  description = "Whether to enable PSC for the cluster."
  default = true
}

variable "psc_allowed_consumer_projects" {
  type = list(string)
  description = "List of consumer project numbers allowed for PSC connections."
}

variable "backup_window" {
  type = string
  description = "The backup window time (e.g., 1800s)."
  default = "1800s"
}

variable "automated_backup_enabled" {
  type = bool
  description = "Whether automated backup is enabled."
  default = true
}

variable "weekly_schedule" {
  type = object({
    days_of_week = list(string)
    start_times  = list(string)
  })
  description = "The weekly schedule for backups."
  default = {
    days_of_week = ["FRIDAY"]
    start_times = ["2:00:00:00"]
  }
}

variable "quantity_based_retention_count" {
  type = number
  description = "The number of backups to retain based on quantity."
  default = 1
}

variable "time_based_retention_count" {
  type = number
  description = "The number of backups to retain based on time (not implemented in the original code)."
  default = null
}

variable "backup_labels" {
  type = map(string)
  description = "Labels to apply to the backups."
  default = {
    test = "alloydb-cluster-with-prim"
  }
}

variable "key_suffix_length" {
  type = number
  description = "The length of the random suffix for KMS key names."
  default = 3
}

variable "key_suffix_special" {
  type = bool
  description = "Whether to include special characters in the random suffix."
  default = false
}

variable "key_suffix_upper" {
  type = bool
  description = "Whether to include uppercase characters in the random suffix."
  default = false
}

variable "alloydb_sa_iam_role" {
  type = list(string)
  description = "The IAM roles to assign to the AlloyDB service account."
  default = ["roles/cloudkms.cryptoKeyEncrypterDecrypter"]
}

variable "secret_manager_replica_location" {
  type = string
  description = "Replica location for the secret manager"
  default = "us-central1"
}

variable "region_east" {
  type = string
  description = "The region for the cross-region replica."
}

variable "attachment_project_number" {
  type = string
  description = "Project number for the PSC attachment (if needed)."
}

variable "attachment_project_id" {
  type = string
  description = "Project Id for the PSC attachment (if needed)."
}

variable "cluster_id_east" {
  type        = string
  description = "The ID of the AlloyDB cluster in the east region."
}

variable "replica_primary_instance_id" {
  type        = string
  description = "The ID of the primary instance for the cross-region replica cluster."
}

variable "primary_instance_availability_type_east" {
  type        = string
  description = "The availability type of the primary instance in east region (e.g., REGIONAL, ZONAL)."
}

variable "primary_cluster_name" {
  type        = string
  description = "The name of the primary cluster (used to configure the replica)."
  default     = null # By default this is not set, making the east cluster independent
}

variable "psc_subnet_pri" {
  type        = string
  description = "Subnet for the primary PSC endpoint."
}

variable "psc_subnet_sec" {
  type        = string
  description = "Subnet for the secondary PSC endpoint."
}

 variable "psc_vpc_network" {
   type        = string  // Adjust the type if necessary (e.g., list(string), map(string), etc.)
   description = "Description of the psc_vpc_network variable (optional but recommended)"
   # Add default if you have a suitable default value, otherwise it will be required
   # default = "default-vpc-network"
 }

 variable "cluster_name" {
   type        = string  
   description = "Description of the cluster_name variable"
   # default = "" 
 }

variable "primary_instance" {
  description = "Primary cluster configuration that supports read and write operations."
  type = object({
    instance_id        = string,
    display_name       = optional(string),
    database_flags     = optional(map(string), {
      "log_error_verbosity" = "default" 
      "log_connections" = "on"
      "log_disconnections" = "on"
      "log_statement" = "all"
      "log_min_messages" = "warning"
      "log_min_error_statement" = "error"
      "log_min_duration_statement" = "-1"
      "password.enforce_complexity" = "on" # parameter is needed for instance with public IP address
      "alloydb.enable_pgaudit" = "on"
      "alloydb.iam_authentication" = "on"
    })
    labels             = optional(map(string))
    annotations        = optional(map(string))
    gce_zone           = optional(string)
    availability_type  = optional(string)
    machine_cpu_count  = optional(number, 2)
    ssl_mode           = optional(string)
    require_connectors = optional(bool)
    query_insights_config = optional(object({
      query_string_length     = optional(number)
      record_application_tags = optional(bool)
      record_client_address   = optional(bool)
      query_plans_per_minute  = optional(number)
    }))
    enable_public_ip = optional(bool, false)
    cidr_range       = optional(list(string))
  })

  validation {
    condition     = can(regex("^(2|4|8|16|32|64|96|128)$", var.primary_instance.machine_cpu_count))
    error_message = "machine_cpu_count must be one of [2, 4, 8, 16, 32, 64, 96, 128]"
  }
  validation {
    condition     = can(regex("^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$", var.primary_instance.instance_id))
    error_message = "Primary Instance ID should satisfy the following pattern ^[a-z]([a-z0-9-]{0,61}[a-z0-9])?$"
  }

  validation {
    condition = var.primary_instance.query_insights_config == null || (
      try(var.primary_instance.query_insights_config.query_string_length, 0) >= 256 &&
      try(var.primary_instance.query_insights_config.query_string_length, 0) <= 4500
    )
    error_message = "Query string length must be between 256 and 4500. The default value is 1024."
  }

  validation {
    condition = var.primary_instance.query_insights_config == null || (
      try(var.primary_instance.query_insights_config.query_plans_per_minute, 0) >= 0 &&
      try(var.primary_instance.query_insights_config.query_plans_per_minute, 0) <= 20
    )
    error_message = "Query plans per minute must be between 0 and 20. The default value is 5."
  }
}

variable "read_pool_instance" {
  description = "List of Read Pool Instances to be created"
  type = list(object({
    instance_id        = string
    display_name       = string
    node_count         = optional(number, 1)
    database_flags     = optional(map(string))
    availability_type  = optional(string)
    gce_zone           = optional(string)
    machine_cpu_count  = optional(number, 2)
    ssl_mode           = optional(string,"ENCRYPTED_ONLY")
    require_connectors = optional(bool)
    query_insights_config = optional(object({
      query_string_length     = optional(number)
      record_application_tags = optional(bool)
      record_client_address   = optional(bool)
      query_plans_per_minute  = optional(number)
    }))
    enable_public_ip = optional(bool, false)
    cidr_range       = optional(list(string))
  }))
  default = []
  validation {
    condition     = try(alltrue([for rp in var.read_pool_instance : contains(["2", "4", "8", "16", "32", "64", "96", "128"], tostring(rp.machine_cpu_count))]), false) || var.read_pool_instance == null
    error_message = "machine_cpu_count must be one of [2, 4, 8, 16, 32, 64, 96, 128]"
  }
}
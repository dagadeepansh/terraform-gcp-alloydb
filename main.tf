/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

module "alloydb_primary" {
  source  = "GoogleCloudPlatform/alloy-db/google"
  version = "~> 3.0"

  #cluster_id       = "cluster-${var.region_primary}-psc"
  project_id           = var.project_id
  cluster_location     = var.region_primary
  cluster_id           = var.cluster_id
  cluster_display_name = var.cluster_name

  psc_enabled                   = var.psc_enabled
  psc_allowed_consumer_projects = [var.attachment_project_number]

  cluster_encryption_key_name = google_kms_crypto_key.key_region_primary.id
  automated_backup_policy = {
    location      = var.region_primary
    backup_window = var.backup_window
    enabled       = var.automated_backup_enabled
    weekly_schedule = {
      days_of_week = var.weekly_schedule.days_of_week
      start_times  = var.weekly_schedule.start_times
    }
    quantity_based_retention_count = var.quantity_based_retention_count
    time_based_retention_count     = var.time_based_retention_count
    labels                         = var.backup_labels
    backup_encryption_key_name     = google_kms_crypto_key.key_region_primary.id
  }

  continuous_backup_recovery_window_days = var.continuous_backup_recovery_window_days
  continuous_backup_encryption_key_name  = google_kms_crypto_key.key_region_primary.id

  primary_instance = {
    instance_id           = var.primary_instance.instance_id
    display_name          = var.primary_instance.display_name
    machine_type          = "db-custom-${var.primary_instance.machine_cpu_count}-3840" # Changed interpolation
    availability_type     = var.primary_instance.availability_type
    database_flags        = var.primary_instance.database_flags
    labels                = var.primary_instance.labels
    annotations           = var.primary_instance.annotations
    gce_zone              = var.primary_instance.gce_zone
    require_connectors    = var.primary_instance.require_connectors
    ssl_mode              = var.primary_instance.ssl_mode
    query_insights_config = var.primary_instance.query_insights_config
    enable_public_ip      = var.primary_instance.enable_public_ip
    cidr_range            = var.primary_instance.cidr_range
  }

  read_pool_instance = [
    for _, read_instance in var.read_pool_instances : {
      instance_id           = read_instance.instance_id
      display_name          = read_instance.display_name
      node_count            = read_instance.node_count
      machine_type          = "db-custom-${read_instance.machine_cpu_count}-3840" # Changed interpolation
      availability_type     = read_instance.availability_type
      database_flags        = read_instance.database_flags
      gce_zone              = read_instance.gce_zone
      require_connectors    = var.primary_instance.require_connectors
      ssl_mode              = var.primary_instance.ssl_mode
      query_insights_config = read_instance.query_insights_config
      enable_public_ip      = read_instance.enable_public_ip
      cidr_range            = read_instance.cidr_range
    }
  ]

  cluster_initial_user = {
    user     = var.cluster_initial_user
    password = var.cluster_initial_password
  }

  depends_on = [
    google_kms_crypto_key_iam_member.alloydb_sa_iam,
    google_kms_crypto_key.key_region_primary,
  ]
}

# Create psc endpoing using alloydb psc attachment

resource "google_compute_address" "psc_consumer_address" {
  name         = var.psc_consumer_address_name
  project      = var.attachment_project_id
  region       = var.region_primary
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = google_compute_network.psc_vpc.name
  subnetwork   = google_compute_subnetwork.psc_subnet_primary.id
  address_type = var.psc_consumer_address_type
  address      = var.psc_consumer_address
}

resource "google_compute_forwarding_rule" "psc_fwd_rule_consumer" {
  name                    = var.psc_fwd_rule_name
  region                  = var.region_primary
  project                 = var.attachment_project_id
  target                  = module.alloydb_primary.primary_instance.psc_instance_config[0].service_attachment_link
  load_balancing_scheme   = "" # need to override EXTERNAL default when target is a service attachment
  network                 = google_compute_network.psc_vpc.name
  ip_address              = google_compute_address.psc_consumer_address.id
  allow_psc_global_access = var.psc_fwd_rule_allow_psc_global_access
  subnetwork              = google_compute_subnetwork.psc_subnet_primary.id
}
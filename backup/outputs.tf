/**
 * Copyright 2021 Google LLC
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

#-------------------------------------------------
# AlloyDB Primary Cluster Outputs
#-------------------------------------------------

output "project_id" {
  description = "Project ID of the Alloy DB Cluster created"
  value       = var.project_id
}
output "alloydb_cluster_name" {
  description = "The name of the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_name
}

output "alloydb_cluster_id" {
  description = "The UID of the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_id
}

output "alloydb_cluster_reconciling" {
  description = "Whether reconcile is set for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_reconciling
}

output "alloydb_cluster_state" {
  description = "The state of the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_state
}

output "alloydb_cluster_initial_user" {
  description = "The initial user for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_initial_user
  sensitive   = true
}

output "alloydb_cluster_encryption_info" {
  description = "The encryption info for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_encryption_info
}

output "alloydb_cluster_encryption_key_versions" {
  description = "The encryption key versions for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_encryption_key_versions
}

output "alloydb_cluster_etag" {
  description = "The etag for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_etag
}

output "alloydb_cluster_database_flags" {
  description = "The database flags for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_database_flags
}

output "alloydb_cluster_continuous_backup_info" {
  description = "The continuous backup info for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_continuous_backup_info
}

output "alloydb_cluster_continuous_backup_config" {
  description = "The continuous backup config for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_continuous_backup_config
}

output "alloydb_cluster_backup_source" {
  description = "The backup source for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_backup_source
}

output "alloydb_cluster_automated_backup_policy" {
  description = "The automated backup policy for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_automated_backup_policy
}

output "alloydb_cluster_annotations" {
  description = "The annotations for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_annotations
}

output "alloydb_cluster_display_name" {
  description = "The display name for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_display_name
}

output "alloydb_cluster_location" {
  description = "The location for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_location
}

output "alloydb_cluster_network" {
  description = "The network for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_network
}

output "alloydb_cluster_project" {
  description = "The project for the AlloyDB cluster."
  value       = module.alloydb_primary.cluster_project
}

#-------------------------------------------------
# AlloyDB Primary Instance Outputs
#-------------------------------------------------

output "alloydb_primary_instance_name" {
  description = "The name of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_name
}

output "alloydb_primary_instance_id" {
  description = "The UID of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_uid
}

output "alloydb_primary_instance_reconciling" {
  description = "Whether reconcile is set for the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_reconciling
}

output "alloydb_primary_instance_state" {
  description = "The state of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_state
}

output "alloydb_primary_instance_ip_address" {
  description = "The IP address of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_ip_address
}

output "alloydb_primary_instance_endpoint" {
  description = "The endpoint of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_endpoint
}

output "alloydb_primary_instance_psc_instance_config" {
  description = "The PSC instance config of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_psc_instance_config
}

output "alloydb_primary_instance_endpoint_port" {
  description = "The endpoint port of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_endpoint_port
}

output "alloydb_primary_instance_instance_type" {
  description = "The instance type of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_type
}

output "alloydb_primary_instance_display_name" {
  description = "The display name of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_display_name
}

output "alloydb_primary_instance_gce_zone" {
  description = "The GCE zone of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_gce_zone
}

output "alloydb_primary_instance_database_flags" {
  description = "The database flags of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_database_flags
}

output "alloydb_primary_instance_read_pool_config" {
  description = "The read pool config of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_read_pool_config
}

output "alloydb_primary_instance_query_insights_config" {
  description = "The query insights config of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_query_insights_config
}

output "alloydb_primary_instance_machine_cpu_count" {
  description = "The machine config of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_machine_cpu_count
}

output "alloydb_primary_instance_state" {
  description = "The state of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_state
}

output "alloydb_primary_instance_annotations" {
  description = "The annotations of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_annotations
}

output "alloydb_primary_instance_labels" {
  description = "The labels of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_labels
}

output "alloydb_primary_instance_availability_type" {
  description = "The availability type of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_availability_type
}

output "alloydb_primary_instance_writable_node" {
  description = "The writable node of the primary instance."
  value       = module.alloydb_primary.primary_instance.instance_writable_node
}

#-------------------------------------------------
# AlloyDB Read Pool Instance Outputs
#-------------------------------------------------

output "alloydb_read_pool_instance_ids" {
  description = "The IDs of the read pool instances."
  value       = module.alloydb_primary.read_pool_instances[*].instance_id
}

#-------------------------------------------------
# KMS Outputs
#-------------------------------------------------

output "kms_key_ring_central_name" {
  description = "The name of the central KMS key ring."
  value       = google_kms_key_ring.keyring_region_central.name
}

output "kms_crypto_key_central_id" {
  description = "The ID of the central KMS crypto key."
  value       = google_kms_crypto_key.key_region_central.id
}

#-------------------------------------------------
# PSC Outputs
#-------------------------------------------------
output "alloydb_psc_service_attachment_link" {
  description = "The service attachment link for PSC connection."
  value       = module.alloydb_primary.primary_instance.psc_instance_config[0].service_attachment_link
}

output "psc_consumer_address_name" {
  description = "The name of the PSC consumer address."
  value       = google_compute_address.psc_consumer_address.name
}

output "psc_consumer_forwarding_rule_id" {
  description = "The ID of the PSC consumer forwarding rule."
  value       = google_compute_forwarding_rule.psc_fwd_rule_consumer.id
}
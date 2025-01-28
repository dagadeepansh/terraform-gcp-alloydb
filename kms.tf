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

resource "google_project_service_identity" "alloydb_sa" {
  provider = google-beta
  project  = var.project_id
  service  = "alloydb.googleapis.com"
}

resource "random_string" "key_suffix" {
  length  = var.key_suffix_length
  special = var.key_suffix_special
  upper   = var.key_suffix_upper
}

resource "google_kms_key_ring" "keyring_region_primary" {
  project  = var.project_id
  name     = "keyring-${var.region_primary}-${random_string.key_suffix.result}"
  location = var.region_primary
}

resource "google_kms_crypto_key" "key_region_primary" {
  name     = "key-${var.region_primary}-${random_string.key_suffix.result}"
  key_ring = google_kms_key_ring.keyring_region_primary.id
}


resource "google_kms_crypto_key_iam_member" "alloydb_sa_iam" {
  crypto_key_id = google_kms_crypto_key.key_region_primary.id
  role          = join(",", var.alloydb_sa_iam_role)
  member        = "serviceAccount:${google_project_service_identity.alloydb_sa.email}"
}


## Cross Region Secondary Cluster Keys

resource "google_kms_key_ring" "keyring_region_replica" {
  project  = var.project_id
  name     = "keyring-${var.region_replica}-${random_string.key_suffix.result}"
  location = var.region_replica
}

resource "google_kms_crypto_key" "key_region_replica" {
  name     = "key-${var.region_replica}-${random_string.key_suffix.result}"
  key_ring = google_kms_key_ring.keyring_region_replica.id
}

resource "google_kms_crypto_key_iam_member" "alloydb_sa_iam_secondary" {
  crypto_key_id = google_kms_crypto_key.key_region_replica.id
  role          = join(",", var.alloydb_sa_iam_role)
  member        = "serviceAccount:${google_project_service_identity.alloydb_sa.email}"
}
# resource "google_service_account" "vault_kms_service_account" {
#   account_id   = "vault-gcpkms"
#   display_name = "Vault KMS for auto-unseal"
# }

# data "google_service_account" "myaccount" {
#   account_id = "330044736238-compute@developer.gserviceaccount.com"
# }

resource "google_service_account" "default" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

# Create a KMS key ring
resource "google_kms_key_ring" "key_ring" {
  project  = var.project_id
  name     = var.key_ring
  location = var.keyring_location
}

# Create a crypto key for the key ring
resource "google_kms_crypto_key" "crypto_key" {
  name            = var.crypto_key
  key_ring        = google_kms_key_ring.key_ring.self_link
  rotation_period = "100000s"
}

# Add the service account to the Keyring
resource "google_kms_key_ring_iam_binding" "vault_iam_kms_binding" {
  key_ring_id = google_kms_key_ring.key_ring.id
  role        = "roles/owner"

  members = [
    "serviceAccount:${google_service_account.default.email}",
  ]
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.cluster_location

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       =  var.initial_node_count
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "my-node-pool"
  location   = "us-central1"
  cluster    = google_container_cluster.primary.name
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = var.node_machine_type
    image_type   = var.node_image_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# resource "google_container_cluster" "primary" {
#   name     = var.cluster_name
#   project  = var.project_id
#   location = var.cluster_location

#   initial_node_count = var.initial_node_count
#   network            = var.network
#   subnetwork         = var.subnetwork

#   maintenance_policy {
#     daily_maintenance_window {
#       start_time = "03:00"
#     }
#   }

#   enable_binary_authorization = true

#   node_config {
#     machine_type = var.node_machine_type
#     image_type   = var.node_image_type

#     oauth_scopes = [
#       "https://www.googleapis.com/auth/compute",
#       "https://www.googleapis.com/auth/devstorage.read_only",
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring",
#     ]
#   }
# }

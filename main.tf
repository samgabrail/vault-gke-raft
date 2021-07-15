module "gke-cluster" {
  source = "./modules/google-gke-cluster/"
  // credentials_file           = var.credentials_file
  region             = var.region
  project_id         = var.project_id
  keyring_location   = var.keyring_location
  key_ring           = var.key_ring
  crypto_key         = var.crypto_key
  cluster_name       = var.cluster_name
  cluster_location   = var.cluster_location
  network            = "projects/${var.project_id}/global/networks/default"
  subnetwork         = "projects/${var.project_id}/regions/${var.region}/subnetworks/default"
  initial_node_count = var.cluster_node_count
}

module "tls" {
  source   = "./modules/tls-private"
  hostname = "*.vault-internal"
}

module "vault" {
  source           = "./modules/vault"
  num_vault_pods   = var.num_vault_pods
  cluster_endpoint = module.gke-cluster.endpoint
  cluster_cert     = module.gke-cluster.ca_certificate
  vault_tls_ca     = module.tls.ca_cert
  vault_tls_cert   = module.tls.cert
  project_id       = var.project_id
  vault_tls_key    = module.tls.key
  crypto_key       = var.crypto_key
  key_ring         = var.key_ring
  keyring_location = var.keyring_location
}

module "consul" {
  source           = "./modules/consul"
  num_consul_pods  = var.num_consul_pods
  cluster_endpoint = module.gke-cluster.endpoint
  cluster_cert     = module.gke-cluster.ca_certificate
}

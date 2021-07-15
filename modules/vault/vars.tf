variable "num_vault_pods" {
  type        = number
}

variable "cluster_endpoint" {
}

variable "cluster_cert" {
}

variable "vault_tls_ca" {
}

variable "vault_tls_cert" {
}

variable "vault_tls_key" {
}
variable "project_id" {
  type        = string
}
variable "key_ring" {
  type      = string
}

variable "crypto_key" {
  type      = string
}

variable "keyring_location" {
  type      = string
}
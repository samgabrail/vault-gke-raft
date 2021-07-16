variable "project_id" {
  type        = string
}

// variable "credentials_file" {
//   type        = string
// }

variable "region" {
  type        = string
}

variable "cluster_name" {
  type        = string
}
variable "cluster_location" {
  type        = string
}
variable "cluster_node_count" {
  type        = number
}

variable "num_vault_pods" {
  type        = number
}

variable "num_consul_pods" {
  type        = number
}

variable "key_ring" {
  type      = string
  default   = "vault-autounseal-keyring1"
}

variable "crypto_key" {
  type      = string
  default   = "vault-autounseal-key2"
}

variable "keyring_location" {
  type      = string
  default   = "global"
}
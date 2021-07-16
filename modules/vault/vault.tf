resource "helm_release" "vault" {
  name       = "vault"
  chart = "https://github.com/hashicorp/vault-helm/archive/refs/tags/v0.13.0.tar.gz"
  # repository = "https://helm.releases.hashicorp.com"
  # chart      = "vault-helm"
  # version = "0.13.0"
  namespace  = kubernetes_namespace.vault.metadata.0.name

  values = [<<EOF
global:
  tlsDisable: false
server:
  extraEnvironmentVars:
    VAULT_ADDR: https://127.0.0.1:8200
    VAULT_SKIP_VERIFY: true
    VAULT_CACERT: /vault/userconfig/vault-tls/vault.ca
  extraVolumes:
    - type: secret
      name: vault-tls
  ha:
    enabled: true
    replicas: ${var.num_vault_pods}    

    raft:      
      # Enables Raft integrated storage
      enabled: true
      config: |
        ui = true
        service_registration "consul" {
          address      = "consul-consul-server.consul.svc.cluster.local:8500"
        }
        listener "tcp" {
          tls_disable = 0
          address = "[::]:8200"
          cluster_address = "[::]:8201"
          tls_cert_file = "/vault/userconfig/vault-tls/vault.crt"
          tls_key_file  = "/vault/userconfig/vault-tls/vault.key"
          tls_client_ca_file = "/vault/userconfig/vault-tls/vault.ca"           
        }

        storage "raft" {
          path = "/vault/data"
        }
        seal "gcpckms" {
          project     = "${var.project_id}"
          region      = "${var.keyring_location}"
          key_ring    = "${var.key_ring}"
          crypto_key  = "${var.crypto_key}"
        }
ui:
  enabled: true
  serviceType: "LoadBalancer"
  serviceNodePort: null
  externalPort: 8200
EOF
  ]
}


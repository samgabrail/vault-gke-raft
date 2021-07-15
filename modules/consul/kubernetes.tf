resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
  depends_on = [var.cluster_endpoint]
}

// resource "kubernetes_secret" "consul-tls" {
//   metadata {
//     name      = "consul-tls"
//     namespace = kubernetes_namespace.consul.metadata.0.name
//   }

//   data = {
//     "consul.ca"      = var.consul_tls_ca
//     "consul.crt"     = var.consul_tls_cert
//     "consul.key"     = var.consul_tls_key
//   }

//   type = "Opaque"
// }
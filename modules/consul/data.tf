data "google_client_config" "current" {
} 

data "kubernetes_service" "consul_svc" {
  depends_on = [
    helm_release.consul
  ]

  metadata {
    namespace = "consul"
    name      = "consul-ui"
  }
}


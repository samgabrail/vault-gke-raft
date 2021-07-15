resource "helm_release" "consul" {
  name          = "consul"
  chart = "https://github.com/hashicorp/consul-helm/archive/refs/tags/v0.32.1.tar.gz"
  # repository = "https://helm.releases.hashicorp.com"
  # chart         = "consul-helm"
  # version = "0.32.1"
  namespace     = kubernetes_namespace.consul.metadata.0.name

  values = [<<EOF
global:
  datacenter: dc1

server:
  replicas: ${var.num_consul_pods}
  bootstrapExpect: ${var.num_consul_pods}

connectInject:
  enabled: true
  default: false
  replicas: 1
EOF
]
}


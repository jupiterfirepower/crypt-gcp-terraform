locals {
  #admin-password = random_password.grafana.result
  namespace = "monitoring"
}

resource "kubernetes_namespace" "kube-namespace" {
  metadata {
    name = local.namespace
  }
  depends_on = [var.gke-name]
}

resource "helm_release" "prometheus" {
  name             = "prometheus"
  chart            = "kube-prometheus-stack"  # prometheus + grafana dashboards.
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = local.namespace
  version          = "57.2.0" # chart version
 
  create_namespace = true
  wait             = true
  #reset_values     = true
  max_history      = 3

  values = [
    templatefile("${path.module}/templates/prometheus-values.yaml", {
      pod_security_enabled             = true
      server_persistent_volume_enabled = false
      server_resources_limits_cpu      = "100m"
      server_resources_limits_memory   = "100Mi"
      server_resources_requests_cpu    = "100m"
      server_resources_requests_memory = "100Mi"
    })
  ]

  depends_on = [kubernetes_namespace.kube-namespace]
}

resource "null_resource" "prometheus-patch" {
  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl patch svc prometheus-grafana -n ${local.namespace} -p '{"spec": {"type": "LoadBalancer"}}'
    kubectl patch svc prometheus-kube-prometheus-prometheus -n ${local.namespace} -p '{"spec": {"type": "LoadBalancer"}}'
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [helm_release.prometheus]
}

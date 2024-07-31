/*resource "cloudflare_record" "cluster" {
  zone_id = "000"
  name    = "cluster"
  value   = "192.0.2.1"
  type    = "A"
}*/

locals {
  admin-password = random_password.grafana.result
  namespace = "monitoring"
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_secret" "grafana" {
  metadata {
    name      = "grafana"
    namespace = local.namespace
  }

  data = {
    admin-user     = "admin"
    admin-password = local.admin-password
  }
}

resource "random_password" "grafana" {
  length = 24
}

resource "helm_release" "grafana" {
  name             = "grafana"
  repository       = "https://grafana.github.io/helm-charts"
  #repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "grafana"
  version          = "7.3.7"
  namespace        = local.namespace
  create_namespace = true

  set {
    name = "grafana\\.ini.server.root_url"
    value = "htps://crypt.grafana.org"
  }
   
  values = [
    templatefile("${path.module}/templates/grafana-values.yaml", {
      admin_existing_secret = kubernetes_secret.grafana.metadata[0].name
      admin_user_key        = "admin-user"
      admin_password_key    = "admin-password"
      #prometheus_svc        = "${helm_release.prometheus.name}-server"
      prometheus_svc        = "prometeus-server"
      replicas              = 1
    })
  ]
 /*
  values = [templatefile("values.yaml", {
    root_url = "https://${cloudflare_record.cluster.hostname}"
  })]

  

  set_sensitive {
    name = "grafana\\.ini.server.auth\\.github.client_secret"
    value = "very-secret"
  }*/

  /*values = [ templatefile("${path.module}/templates/grafana-values.yaml", {
      pod_security_enabled             = true
      server_persistent_volume_enabled = false
      server_resources_limits_cpu      = "100m"
      server_resources_limits_memory   = "100Mi"
      server_resources_requests_cpu    = "100m"
      server_resources_requests_memory = "100Mi"
  }) ]*/
  /*values = [ templatefile("${path.module}/templates/values.yaml", {
      pod_security_enabled             = true
      server_persistent_volume_enabled = false
      server_resources_limits_cpu      = "100m"
      server_resources_limits_memory   = "100Mi"
      server_resources_requests_cpu    = "100m"
      server_resources_requests_memory = "100Mi"
  })]*/
}
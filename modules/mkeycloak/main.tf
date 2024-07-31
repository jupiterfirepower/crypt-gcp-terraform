locals {
  keycloak_namespace = "keycloak"
  postgres_namespace = "postgres"
  password = random_password.password.result
  pgadmin_user_password = random_password.password.result
  pgadmin_user_name     = "pgadmin"
}


resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = local.keycloak_namespace
  }
}

resource "kubernetes_namespace" "postgres" {
  metadata {
    name = local.postgres_namespace
  }
}
/*
resource "helm_release" "keycloak" {
  name             = "keycloak"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "my-keycloak"
  namespace        = kubernetes_namespace.istio_system.metadata.0.name
  create_namespace = true
  version          = "19.3.4"
}*/

# export KUBECONFIG=~/.kube/kubeconfig-dev # <--- path to your kubeconfig file, used by kubectl to connect to the cluster API
# export KUBE_CONFIG_PATH=~/.kube/kubeconfig-dev # need for Terraform Kubernetes/Helm provider
/*
resource "helm_release" "postgres" {
  name       = "postgres"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "postgresql"
  namespace  = kubernetes_namespace.postgres.metadata.0.name
  version          = "15.2.0" # chart version
  create_namespace = true

  set {
    name  = "cluster.enabled"
    value = "false"
  }

  set {
    name  = "primary.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "service.annotations.prometheus\\.io/port"
    value = "9127"
    type  = "string"
  }

  /*set {
    name  = "primary.initdb.scripts.create_database"
    value = chomp(file("${path.module}/../database/0.create_database.sql"))
  }*/

  /*set {
    name  = "global.postgresql.username"
    value = local.pgadmin_user_name
  }

  set {
    name  = "global.postgresql.password"
    value = local.pgadmin_user_password
  }
  
  set {
    name = "postgresql.postgresPassword"
    value = var.postgres_admin_password
  }
  
  set {
    name = "auth.enablePostgresUser"
    value = "true"
  }
}
/*

resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  
  set {
    name  = "postgresql.auth.postgresPassword"
    value = "mysecretpassword" # Updated password value
  }

  set {
    name  = "postgresql.auth.username"
    value = "pouya"
  }

  set {
    name  = "postgresql.auth.password"
    value = "authpassword"
  }

  set {
    name  = "postgresql.postgresqlDatabase"
    value = "bitnami_keycloak" # If necessary, update the database name
  }

  set {
    name  = "postgresql.postgresqlPassword"
    value = "mysecretpassword" # Same as the new password value
  }

  set {
    name  = "postgresql.postgresqlUsername"
    value = "pouya" # Same as the username
  }
}
*/

resource "helm_release" "keycloak" {
  name             = "keycloak"
  repository       = "https://charts.bitnami.com/bitnami"
  chart            = "keycloak"
  version          = "19.4.1" # chart version
  namespace        = kubernetes_namespace.keycloak.metadata.0.name
  create_namespace = true

  /*values = [
    templatefile("${path.module}/helm-values/keycloak.yaml", {
      domain : var.domain,
      admin_user : var.admin_user
      http_relative_path : var.http_relative_path
      replica_count : var.replica_count
      cpu_request : var.cpu_request
      memory_request : var.memory_request
      memory_limit : var.memory_limit
      enable_autoscaling : var.enable_autoscaling
      enable_metrics : var.enable_metrics
      enable_service_monitor : var.enable_service_monitor
      enable_prometheus_rule : var.enable_prometheus_rule
      prometheus_namespace : var.prometheus_namespace
      keycloak_logging_level : var.keycloak_logging_level
    })
  ]
  set_sensitive {
    name  = "auth.adminPassword"
    value = var.keycloak_admin_password
  }
  set_sensitive {
    name  = "postgres.auth.postgresPassword"
    value = var.postgres_admin_password
  }
  set_sensitive {
    name  = "postgres.auth.password"
    value = var.postgres_user_password
  }

  set {
    name  = "postgresql.postgresqlDatabase"
    value = "bitnami_keycloak" # If necessary, update the database name
  }*/

  # depends_on = [helm_release.postgres]
}

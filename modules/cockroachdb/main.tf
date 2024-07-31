locals {
  cockroachdb_namespace = "cockroach"
  password = random_password.password.result
  pgadmin_user_name     = "pgadmin"
  pgadmin_user_password = random_password.password.result
}


resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "kubernetes_namespace" "cockroach" {
  metadata {
    name = local.cockroachdb_namespace
  }
}

resource "helm_release" "cockroach_db" {
  name       = "cockroachdb"
  repository = "https://charts.cockroachdb.com/"
  chart      = "cockroachdb"
  namespace  = kubernetes_namespace.cockroach.metadata.0.name
  version          = "12.0.4" # chart version
  create_namespace = true

  set {
    name  = "cluster.enabled"
    value = "false"
  }

  set {
    name  = "primary.service.type"
    value = "LoadBalancer"
  }
}
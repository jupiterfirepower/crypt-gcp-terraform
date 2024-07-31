locals {
  postgres_namespace = "postgres"
  password = random_password.password.result
  pgadmin_user_name     = "pgadmin"
  pgadmin_user_password = random_password.password.result
}


resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "kubernetes_namespace" "postgres" {
  metadata {
    name = local.postgres_namespace
  }
}

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

  set {
    name  = "global.postgresql.username"
    value = local.pgadmin_user_name
  }

  set {
    name  = "global.postgresql.password"
    value = local.pgadmin_user_password
  }
  
  set {
    name = "postgresql.postgresPassword"
    value = local.password
  }
  
  set {
    name = "auth.enablePostgresUser"
    value = "true"
  }
}
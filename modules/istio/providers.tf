locals {
  kube_host = "https://${var.kube-host}" 
  kube_client_certificate = base64decode(var.kube-client_certificate)
  kube_client_key         = base64decode(var.kube-client_key)
  kube_cluster_ca_certificate = base64decode(var.kube-cluster_ca_certificate)
  api_version = "client.authentication.k8s.io/v1beta1"
  gke_auth_plugin = "gke-gcloud-auth-plugin"
}

provider "helm" {
    kubernetes {
       host                   = local.kube_host
       client_certificate     = local.kube_client_certificate
       client_key             = local.kube_client_key
       cluster_ca_certificate = local.kube_cluster_ca_certificate

       exec {
         api_version = local.api_version
         command     = local.gke_auth_plugin
       }
    }
}

provider "kubernetes" {
    host                   = local.kube_host
    client_certificate     = local.kube_client_certificate
    client_key             = local.kube_client_key
    cluster_ca_certificate = local.kube_cluster_ca_certificate

    exec {
      api_version = local.api_version
      command     = local.gke_auth_plugin
    }
}
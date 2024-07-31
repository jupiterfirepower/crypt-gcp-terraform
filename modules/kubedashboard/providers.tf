locals {
  kube_host = "https://${var.kube-host}" 
  kube_client_certificate = base64decode(var.kube-client_certificate)
  kube_client_key         = base64decode(var.kube-client_key)
  kube_cluster_ca_certificate = base64decode(var.kube-cluster_ca_certificate)
}

provider "helm" {
    kubernetes {
       host                   = local.kube_host
       client_certificate     = local.kube_client_certificate
       client_key             = local.kube_client_key
       cluster_ca_certificate = local.kube_cluster_ca_certificate

       exec {
         api_version = "client.authentication.k8s.io/v1beta1"
         command     = "gke-gcloud-auth-plugin"
       }
    }
}

provider "kubernetes" {
    host                   = local.kube_host
    client_certificate     = local.kube_client_certificate
    client_key             = local.kube_client_key
    cluster_ca_certificate = local.kube_cluster_ca_certificate

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "gke-gcloud-auth-plugin"
    }
}
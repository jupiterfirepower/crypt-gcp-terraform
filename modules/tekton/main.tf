data "google_service_account" "terraform" {
  project    = "crypt-420813"
  account_id = "crypttrader@crypt-420813.iam.gserviceaccount.com" #var.terraform_sa_email
}

# Terraform needs to manage cluster
resource "google_project_iam_member" "terraform-gke-admin" {
  project = "crypt-420813"
  role    = "roles/container.admin"
  member  = "serviceAccount:${data.google_service_account.terraform.email}"
}

# Terraform needs to manage K8S RBAC
# https://cloud.google.com/kubernetes-engine/docs/how-to/role-based-access-control#iam-rolebinding-bootstrap
resource "kubernetes_cluster_role_binding" "terraform_clusteradmin" {
  depends_on = [
    google_project_iam_member.terraform-gke-admin,
  ]

  metadata {
    name = "cluster-admin-binding-terraform"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = data.google_service_account.terraform.email
  }

  # must create a binding on unique ID of SA too
  subject {
    api_group = "rbac.authorization.k8s.io"
    kind      = "User"
    name      = data.google_service_account.terraform.unique_id
  }
}

# Nginx Ingress Configuration using Helm Provider
/*
# Provider configuration (Helm)
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  version    = "1.2.0"
  
  set {
    name  = "controller.service.enabled"
    value = "true"
  }

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.ingressClass"
    value = "nginx"
  }

  set {
    name  = "controller.publishService.enabled"
    value = "true"
  }

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  # Add more configuration values as needed
}*/



resource "null_resource" "tekton-deploy" {
  provisioner "local-exec" {
    command = <<EOT
    export USE_GKE_GCLOUD_AUTH_PLUGIN=True && \
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/operator/latest/release.yaml && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/chains/latest/release.yaml && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml && \
    kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [var.gke-name]
}
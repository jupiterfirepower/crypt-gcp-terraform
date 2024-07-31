resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd${lower(var.environment)}"
  }
  depends_on = [var.gke-name]
}

resource "helm_release" "argocd-dev" {
  name       = "argocd${lower(var.environment)}"
  chart      = "argo-cd"
  repository = "https://argoproj.github.io/argo-helm"
  # version    = "6.7.13" # chart version https://artifacthub.io/packages/helm/argo/argo-cd
  create_namespace = true
  namespace  = "argocd-${lower(var.environment)}"
  timeout    = "1200"
  values     = [templatefile("./argocd/values/install.yaml", {})]
  depends_on = [kubernetes_namespace.argocd]
}

resource "null_resource" "argocd-password" {
  provisioner "local-exec" {
    working_dir = "./argocd"
    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl -n argocd-${lower(var.environment)} get secret argocd-initial-admin-secret -o jsonpath={.data.password} | base64 -d > argocd-login.txt
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [helm_release.argocd-dev]
}

resource "null_resource" "argocd-patch" {
  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl patch svc ${helm_release.argocd-dev.name}-server -n ${helm_release.argocd-dev.namespace} -p '{"spec": {"type": "LoadBalancer"}}'
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [null_resource.argocd-password]
}



resource "null_resource" "ingress-nginx" {
  provisioner "local-exec" {
    command = <<EOT
    export USE_GKE_GCLOUD_AUTH_PLUGIN=True && \
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.44.0/deploy/static/provider/cloud/deploy.yaml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [var.gke-name]
}
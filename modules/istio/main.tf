###################Install Istio (Service Mesh) #######################################

locals {
  namespace = "istio-system"
  password = random_password.password.result
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = local.namespace
  }
}

# # If installation profile is default -> no need to add istio-injection labels
resource "kubernetes_namespace" "istio_ingress" {
  metadata {
    name = "istio-ingress"
    labels = {
      "istio-injection" : "enabled"
    }
  }
}

resource "kubernetes_secret" "grafana" {
  #provider = kubernetes.local
  metadata {
    name      = "grafana"
    namespace = "istio-system"
    labels = {
      app = "grafana"
    }
  }
  data = {
    username   = "admin"
    passphrase = local.password
  }
  type       = "Opaque"
  depends_on = [kubernetes_namespace.istio_system]
}

resource "kubernetes_secret" "kiali" {
  #provider = kubernetes.local
  metadata {
    name      = "kiali"
    namespace = "istio-system"
    labels = {
      app = "kiali"
    }
  }
  data = {
    username   = "admin"
    passphrase = local.password
  }
  type       = "Opaque"
  depends_on = [kubernetes_namespace.istio_system]
}

resource "local_file" "istio-config" {
  content = templatefile("${path.module}/istio-aks.tmpl", {
    enableGrafana = true
    enableKiali   = true
    enableTracing = true
  })
  filename = ".istio/istio-aks.yaml"
}

resource "helm_release" "istio_base" {
  name             = "istio-base"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "base"
  namespace        = kubernetes_namespace.istio_system.metadata.0.name
  create_namespace = true
  version          = "1.21.0"

  timeout         = 120
  cleanup_on_fail = true
  force_update    = false

  depends_on = [kubernetes_namespace.istio_system]
}

resource "helm_release" "istiod" {
  name             = "istiod"
  repository       = "https://istio-release.storage.googleapis.com/charts"
  chart            = "istiod"
  namespace        = kubernetes_namespace.istio_system.metadata.0.name
  create_namespace = true
  version          = "1.21.0"

  timeout = 120

  cleanup_on_fail = true
  force_update    = false

  set {
    name  = "global.proxy.resources.limits.memory"
    value = "64Mi"
  }

  set {
    name  = "global.proxy.resources.limits.cpu"
    value = "50m"
  }

  set {
    name  = "global.proxy.resources.requests.memory"
    value = "64Mi"
  }

  set {
    name  = "global.proxy.resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "pilot.resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "pilot.resources.requests.memory"
    value = "128Mi"
  }

  # to install the CRDs first
  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingress"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"

  timeout         = 120
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.istio_ingress.metadata.0.name

  set {
    name  = "resources.requests.cpu"
    value = "50m"
  }

  set {
    name  = "resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "100m"
  }

  set {
    name  = "resources.limits.memory"
    value = "128Mi"
  }

  depends_on = [kubernetes_namespace.istio_ingress, helm_release.istiod]
}

resource "null_resource" "istio-addons" {
  provisioner "local-exec" {
    command = <<EOT
    export KUBECONFIG=~/.kube/cryptk8s && \
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/addons/kiali.yaml && \
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/addons/prometheus.yaml && \
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/addons/jaeger.yaml && \
    kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.21/samples/addons/grafana.yaml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [helm_release.istio_ingress]
}

/*
for ADDON in kiali jaeger prometheus 
do
    ADDON_URL="https://raw.githubusercontent.com/istio/istio/release-1.20/samples/addons/$ADDON.yaml"
    kubectl apply -f $ADDON_URL
done
# Visualize Istio Mesh console using Kiali
kubectl port-forward svc/kiali 20001:20001 -n istio-system

# Get to the Prometheus UI
kubectl port-forward svc/prometheus 9090:9090 -n istio-system

# Visualize metrics in using Grafana
kubectl port-forward svc/grafana 3000:3000 -n istio-system

# Visualize application traces via Jaeger
kubectl port-forward svc/jaeger 16686:16686 -n istio-system
*/


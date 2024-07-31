# Finaly, Helm install the Dashboard
resource "helm_release" "kubernetes-dashboard" {
  depends_on = [kubernetes_cluster_role_binding.tiller-rights]
  name       = "kubernetes-dashboard"
  chart      = "stable/kubernetes-dashboard"
  namespace  = "kube-system"
}

# Rights for Dashboard
# Secret
resource "kubernetes_secret" "dashboard-secret" {
  metadata {
    name      = "kubernetes-dashboard-certs"
    namespace = "kube-system"

    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
}

# Service Account called kubernetes-dashboard already created by HELM during 
# the installation of the chart

# Role
resource "kubernetes_role" "dashboard-role" {
  metadata {
    name      = "kubernetes-dashboard-minimal"
    namespace = "kube-system"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create"]
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["create"]
  }

  rule {
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs"]
    verbs          = ["get", "update", "delete"]
  }

  rule {
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["kubernetes-dashboard-settings"]
    verbs          = ["get", "update"]
  }

  rule {
    api_groups     = [""]
    resources      = ["services"]
    resource_names = ["heapster"]
    verbs          = ["proxy"]
  }

  rule {
    api_groups     = [""]
    resources      = ["services/proxy"]
    resource_names = ["heapster", "http:heapster:", "https:heapster:"]
    verbs          = ["get"]
  }
}

# Role Binding
resource "kubernetes_role_binding" "dashboard-rolebinding" {
  metadata {
    name      = "kubernetes-dashboard-minimal"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "kubernetes-dashboard-minimal"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kube-system"
  }
}

# Create Admin user for accessing to the DashBoard later (generating Token)

resource "kubernetes_service_account" "admin-account" {
  metadata {
    name      = "admin-user"
    namespace = "kube-system"
  }
}

resource "kubernetes_role_binding" "admin-rolebinding" {
  metadata {
    name = "admin-user"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "admin-user"
    namespace = "kube-system"
  }
}
/*
###
# Create a new Kubernetes namespace for the application deployment
###
resource "kubernetes_namespace" "kubernetes_dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }
  depends_on = [var.gke-name]
}

resource "helm_release" "crypt-kubernetes-dashboard" {

  name = "crypt-kubernetes-dashboard"

  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  namespace  = "default"  

  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "protocolHttp"
    value = "true"
  }

  set {
    name  = "service.externalPort"
    value = 80
  }

  set {
    name  = "replicaCount"
    value = 2
  }

  set {
    name  = "rbac.clusterReadOnlyRole"
    value = "true"
  }
}*/
/*
###
# Install the Kubernetes Dashboard using the Helm provider
###
resource "helm_release" "kubernetes_dashboard" {
  # Name of the release in the cluster
  name       = "kubernetes-dashboard"

  # Name of the chart to install
  repository = "https://kubernetes.github.io/dashboard/"

  # Version of the chart to use
  chart      = "kubernetes-dashboard"

  version = "7.3.2" # chart version

  # Wait for the Kubernetes namespace to be created
  depends_on = [kubernetes_namespace.kubernetes_dashboard]

  # Set the namespace to install the release into
  namespace  = kubernetes_namespace.kubernetes_dashboard.metadata[0].name

  create_namespace = true

  # Set service type to LoadBalancer
  set {
    name  = "service.type"
    value = "LoadBalancer"
  }

  # Set service external port to 9080
  set {
    name  = "service.externalPort"
    value = "9080"
  }

  # Set protocol to HTTP (not HTTPS)
  set {
    name  = "protocolHttps"
    value = "true"
  }

  # Enable insecure login (no authentication)
  #set {
  #  name  = "enableInsecureLogin"
  #  value = "true"
  #}

  # Enable cluster read only role (no write access) for the dashboard user
  set {
    name  = "rbac.clusterReadOnlyRole"
    value = "true"
  }

  # Enable metrics scraper (required for the CPU and memory usage graphs)
  set {
    name  = "metricsScraper.enabled"
    value = "true"
  }

  set {
    name = "extraArgs"
    value = "{--token-ttl=0}"
  }

  # Wait for the release to be deployed
  wait = true
}

locals {
  ingress_host = "dashboard.k8s.backend.io"
}


resource "kubernetes_ingress" "kubernetes-dashboard-ingress" {
  metadata {
    name = helm_release.kubernetes_dashboard.name
    namespace = kubernetes_namespace.kubernetes_dashboard.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class": "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol": "HTTPS"
      "nginx.ingress.kubernetes.io/proxy-body-size": "1000000m"
    }
  }
  spec {
    tls {
      hosts = [ local.ingress_host ]
    }

    rule {
      host = local.ingress_host
      http {
        path {
          path = "/"

          backend {
            service_name = "kubernetes-dashboard"
            service_port = "443"
          }
        }
      }
    }
  }
}

# Service Account
resource "kubernetes_service_account" "admin_user" {
  metadata {
    namespace = kubernetes_namespace.kubernetes_dashboard.metadata[0].name
    name = "admin-user"
  }

  depends_on = [
    helm_release.kubernetes_dashboard
  ]

  automount_service_account_token = true
}

# ClusterRoleBinding 
resource "kubernetes_cluster_role_binding" "admin_user" {
  metadata {
    name = "admin-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "admin-user"
    namespace = kubernetes_namespace.kubernetes_dashboard.metadata[0].name
  }
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.admin_user
  ]
}

resource "kubernetes_secret" "kubernetes_dashboard_token" {
  metadata {
    name      = "admin-user-token"
    namespace = kubernetes_namespace.kubernetes_dashboard.metadata[0].name
    annotations = {
      "kubernetes.io/service-account.name" = "admin-user"
    }
  }
  type = "kubernetes.io/service-account-token"

  wait_for_service_account_token = true

  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.admin_user
  ]
}
*/
/*
resource "kubernetes_ingress" "kubernetes-dashboard-ingress" {
  metadata {
    name = helm_release.kubernetes-dashboard.name
    namespace = kubernetes_namespace.kubernetes-dashboard-namespace.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class": "nginx"
      "nginx.ingress.kubernetes.io/backend-protocol": "HTTPS"
      "nginx.ingress.kubernetes.io/proxy-body-size": "1000000m"
    }
  }
  spec {
    tls {
      hosts = [
        "dashboard.k8s.${var.master_ip}.${var.ingress_domain}"
      ]
    }

    rule {
      host = "dashboard.k8s.${var.master_ip}.${var.ingress_domain}"
      http {
        path {
          path = "/"

          backend {
            service_name = "kubernetes-dashboard"
            service_port = "443"
          }
        }
      }
    }
  }
}

# Service Account
data "kubernetes_service_account" "admin-user" {
  depends_on = [
    helm_release.kubernetes-dashboard
  ]
  metadata {
    namespace = kubernetes_namespace.kubernetes-dashboard-namespace.metadata[0].name
    name = "admin-user"
  }
}

# ClusterRoleBinding 
resource "kubernetes_cluster_role_binding" "admin-user-crb" {
   depends_on = [
    data.kubernetes_service_account.admin-user
  ]
  metadata {
    name = "admin-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "admin-user"
    namespace = kubernetes_namespace.kubernetes-dashboard-namespace.metadata[0].name
  }
}


# token
data "kubernetes_secret_v1" "kubernetes-dashboard-token" {
  metadata {
    name = "${data.kubernetes_service_account.admin-user.default_secret_name}"
    namespace = kubernetes_namespace.kubernetes-dashboard-namespace.metadata[0].name
  }
  binary_data = {
    "data.token" = ""
  }
}

resource "kubernetes_service_account" "admin_user" {
  metadata {
    name      = "admin-user"
    namespace = "kubernetes-dashboard"
  }

  depends_on = [helm_release.kubernetes_dashboard]
}

resource "kubernetes_cluster_role_binding" "admin_user_binding" {
  metadata {
    name = "admin_user_binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "admin-user"
    namespace = "kubernetes-dashboard"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  depends_on = [kubernetes_service_account.admin_user]
}

resource "kubernetes_secret" "admin-user-token" {
  
  metadata {
    name = "admin-user-token"
    namespace = "kubernetes-dashboard"

    annotations = {
      "kubernetes.io/service-account.name" = "admin-user"
    }
  }

  type = "kubernetes.io/service-account-token"
  depends_on = [kubernetes_service_account.admin_user]
}
*/
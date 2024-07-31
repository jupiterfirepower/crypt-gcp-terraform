# Enable APIs for Network project (GCP Project acting as Shared VPC host)
# Declare APIs
variable "net_project_gcp_services" {
  description = "The list of apis necessary for the project"
  type        = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "monitoring.googleapis.com",
    "logging.googleapis.com",
    "containerregistry.googleapis.com",
    "containerscanning.googleapis.com",
    "ondemandscanning.googleapis.com",
    "artifactregistry.googleapis.com",
    "storage.googleapis.com",
  ]
}

# Enable APIs
resource "google_project_service" "network" {
  for_each                   = toset(var.net_project_gcp_services)
  project                    = var.projectId 
  service                    = each.key
  disable_dependent_services = true
  disable_on_destroy         = false
}

/*
# Enable APIs
resource "google_project_service" "network" {
  for_each                   = toset(var.net_project_gcp_services)
  project                    = var.projectId # "crypt-420813" 
  service                    = each.key
  disable_dependent_services = true
  disable_on_destroy         = false

  #provisioner "local-exec" {
  #  command = "gcloud -q compute networks delete default --project=${var.projectId}"
  #}
}

resource "google_compute_network" "default" {
  name  = var.network_name
  #routing_mode                    = "REGIONAL"
  mtu   = 1460
  auto_create_subnetworks         = false
  delete_default_routes_on_create = false
  enable_ula_internal_ipv6 = true

  depends_on = [
    #google_project_service.compute,
    #google_project_service.container
    google_project_service.network
  ]
}

resource "google_compute_subnetwork" "private" {
  name = var.network_name

  ip_cidr_range = "10.0.0.0/16"
  region        = var.region

  #stack_type       = "IPV4_IPV6"
  #ipv6_access_type = "INTERNAL"

  network = google_compute_network.default.id

  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.1.0/24"
  }

  depends_on = [
    google_compute_network.default
  ]
}
*/
/*
#  Google Container Registry (GCR) 
resource "google_container_registry" "registry" {
  # count = var.deploy_registry ? 1 : 0
  project  = var.projectId
  location = var.region

  depends_on = [
    google_project_service.network
  ]
}

resource "google_artifact_registry_repository" "repository" {
  location      = var.region
  repository_id = "cryptrepository"
  description   = "Crypt docker repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}*/

data "google_container_registry_repository" "primary" {
}


resource "google_container_cluster" "primary_gke_cluster" {
  name     = var.clusterName
  location = var.region # Replace this with your desired region
  project  = var.projectId
  #node_locations = var.zones

  enable_shielded_nodes    = true
  remove_default_node_pool = true
  initial_node_count       = 1
  #enable_autopilot         = true
  #enable_l4_ilb_subsetting = true
  
  logging_service          = "logging.googleapis.com/kubernetes"
  monitoring_service       = "monitoring.googleapis.com/kubernetes"

  #network    = google_compute_network.default.id
  #subnetwork = google_compute_subnetwork.private.id

  release_channel {
    channel = "STABLE"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    #horizontal_pod_autoscaling {
    #  disabled = false
    #}
  }

  networking_mode = "VPC_NATIVE"
/*
  ip_allocation_policy {
    #stack_type                    = "IPV4_IPV6"
    services_secondary_range_name = google_compute_subnetwork.private.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.private.secondary_ip_range[1].range_name
  }*/

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/16"
    services_ipv4_cidr_block = "/22"
  }


  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false

  timeouts {
    create = "20m"
    update = "20m"
  }

  node_config {
    disk_size_gb = 20
  }

  lifecycle {
    ignore_changes = [node_pool]
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.clusterName}-pool"
  location   = var.region # Replace this with your desired region
  cluster    = google_container_cluster.primary_gke_cluster.name
  node_count = 1
  project = var.projectId

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  autoscaling {
    min_node_count = var.minNode
    max_node_count = var.maxNode
  }

  timeouts {
    create = "20m"
    update = "20m"
  }

  node_config {
    preemptible  = true
    machine_type = var.machineType
    disk_size_gb = 20

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

resource "google_compute_firewall" "validate_nginx" {
  project = var.projectId
  name    = "validate-nginx"
  network = "projects/crypt-420813/global/networks/default"
  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }
  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
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
}

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  namespace = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"

  #values = [var.helm.nginx-ingress.values]

  set {
    name  = "controller.replicaCount"
    value = "2"
  }
  set {
    name  = "controller.nodeSelector.kubernetes.io/role"
    value = "master"
  }

  set {
    name  = "rbac.create"
    value = "false"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }
}*/

/*
# Install or upgrade a Helm Release noted as "nginx-ingress"
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress" # unique name for the helm release
  namespace  = "default" # kubernetes namespace where the helm release will reside
  repository = "https://kubernetes-charts.storage.googleapis.com/" # helm repository where the chart is hosted
  chart      = "nginx-ingress" # helm chart to be installed

  set {
    name  = "controller.replicaCount"
    value = "2"
  }
  set {
    name  = "controller.nodeSelector.kubernetes.io/role"
    value = "master"
  }
}

# Install Nginx Ingress using Helm Chart
resource "helm_release" "nginx_ingress" {
  name       = "nginx-ingress"
  repository = "${helm_repository.stable.metadata.0.name}"
  chart      = "nginx-ingress"

  set {
    name  = "rbac.create"
    value = "false"
  }

  set {
    name  = "controller.service.externalTrafficPolicy"
    value = "Local"
  }

  set {
    name  = "controller.service.loadBalancerIP"
    value = "${azurerm_public_ip.nginx_ingress.ip_address}"
  }
}*/

data "google_client_config" "provider" {}

data "template_file" "kubeconfig" {
  template = file("${path.module}/kubeconfig.tpl")

  vars = {
    cluster_name           = var.clusterName
    cluster_endpoint       = "https://${google_container_cluster.primary_gke_cluster.endpoint}"
    cluster_ca_certificate = google_container_cluster.primary_gke_cluster.master_auth[0].cluster_ca_certificate
    access_token           = data.google_client_config.provider.access_token
  }
  depends_on = [google_container_cluster.primary_gke_cluster]
}

resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = "${path.module}/kubeconfig"
  file_permission = "0666"
  depends_on = [google_container_cluster.primary_gke_cluster]
}

resource "null_resource" "copy-kubeconfig" {
  provisioner "local-exec" {
    command = <<EOT
    cp -fp "${path.module}/kubeconfig" ~/.kube/cryptk8s
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  depends_on = [local_file.kubeconfig]
}
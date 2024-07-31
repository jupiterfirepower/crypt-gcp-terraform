# creating virtual network
/*module vnetwork {
  source                = "./vnetwork"
  resource_group_name   = var.resource_group_name
  location              = var.resource_group_location
  address_space         = var.vnetCIDR
  subnet_address_prefix = var.subnetCIDRs
  environment           = var.environment
}*/

# Creating GKE
module "gke_cluster" {
  source = "./gke_cluster"
  
  network_name = var.network_name
  region       = var.region
  zones        = var.zones
  clusterName  = var.clusterName
  minNode      = var.minNode
  maxNode      = var.maxNode
  machineType  = var.machineType
  projectId    = var.projectId
}

# Creating NGNX
module ingress-ngnx {
  source              = "./ngnx"
  gke-name            = module.gke_cluster.cluster_name
  kube-host           = module.gke_cluster.cluster_endpoint
  kube-client_certificate = module.gke_cluster.client_certificate
  kube-client_key         = module.gke_cluster.client_key
  kube-cluster_ca_certificate  = module.gke_cluster.cluster_ca_certificate
  environment         = var.environment
}

# Creating Tekton
module tekton {
  source              = "./tekton"
  gke-name            = module.gke_cluster.cluster_name
  kube-host           = module.gke_cluster.cluster_endpoint
  kube-client_certificate = module.gke_cluster.client_certificate
  kube-client_key         = module.gke_cluster.client_key
  kube-cluster_ca_certificate  = module.gke_cluster.cluster_ca_certificate
  environment         = var.environment
}


# Creating ArgoCd
module argocd {
  source              = "./argocd"
  gke-name            = module.gke_cluster.cluster_name
  kube-host           = module.gke_cluster.cluster_endpoint
  kube-client_certificate = module.gke_cluster.client_certificate
  kube-client_key         = module.gke_cluster.client_key
  kube-cluster_ca_certificate  = module.gke_cluster.cluster_ca_certificate
  environment         = var.environment
}
/*
# Creating Postgres
module postgres {
  source              = "./postgres"
  gke-name            = module.gke_cluster.cluster_name
  kube-host           = module.gke_cluster.cluster_endpoint
  kube-client_certificate = module.gke_cluster.client_certificate
  kube-client_key         = module.gke_cluster.client_key
  kube-cluster_ca_certificate  = module.gke_cluster.cluster_ca_certificate
  environment         = var.environment
}

# Creating CockroachDB
module cockroachdb {
  source              = "./cockroachdb"
  gke-name            = module.gke_cluster.cluster_name
  kube-host           = module.gke_cluster.cluster_endpoint
  kube-client_certificate = module.gke_cluster.client_certificate
  kube-client_key         = module.gke_cluster.client_key
  kube-cluster_ca_certificate  = module.gke_cluster.cluster_ca_certificate
  environment         = var.environment
}*/

/*
# Creating Kubernetes Dashboards
module kubedashboards {
  source              = "./kubedashboard"
  gke-name            = module.gke_cluster.cluster_name
  kube-host           = module.gke_cluster.cluster_endpoint
  kube-client_certificate = module.gke_cluster.client_certificate
  kube-client_key         = module.gke_cluster.client_key
  kube-cluster_ca_certificate  = module.gke_cluster.cluster_ca_certificate
  environment         = var.environment
}
*/

/*
# Creating Prometheus and Grafana
module prometheus {
  source              = "./prometheus"
  eks-name            = module.gke_cluster.cluster_name
  kube-host           = module.gke_cluster.cluster_endpoint
  kube-client_certificate = module.gke_cluster.client_certificate
  kube-client_key         = module.gke_cluster.client_key
  kube-cluster_ca_certificate  = module.gke_cluster.cluster_ca_certificate
  environment         = var.environment
}*/

/*
# Creating Prometheus and Grafana
module prometheus {
  source              = "./prometheus"
  gke-name            = module.gke_cluster.cluster_name
  kube-host           = module.gke_cluster.cluster_endpoint
  kube-client_certificate = module.gke_cluster.client_certificate
  kube-client_key         = module.gke_cluster.client_key
  kube-cluster_ca_certificate  = module.gke_cluster.cluster_ca_certificate
  environment         = var.environment
}

# Creating Istio
module istio {
  source              = "./istio"
  gke-name            = module.gke_cluster.cluster_name
  kube-host           = module.gke_cluster.cluster_endpoint
  kube-client_certificate = module.gke_cluster.client_certificate
  kube-client_key         = module.gke_cluster.client_key
  kube-cluster_ca_certificate  = module.gke_cluster.cluster_ca_certificate
  environment         = var.environment
}*/

/*
# Creating Kubernetes Dashboards
module kubedashboards {
  source              = "./kubedashboard"
  gke-name            = module.gke_cluster.cluster_name
  kube-host           = module.gke_cluster.cluster_endpoint
  kube-client_certificate = module.gke_cluster.client_certificate
  kube-client_key         = module.gke_cluster.client_key
  kube-cluster_ca_certificate  = module.gke_cluster.cluster_ca_certificate
  environment         = var.environment
}
*/

# Creating Grafana
/*module grafana {
  source              = "./grafana"
  eks-name            = module.eks.kubernetes_cluster_name
  kube-host           = module.eks.host
  kube-client_certificate = module.eks.client_certificate
  kube-client_key         = module.eks.client_key
  kube-cluster_ca_certificate  = module.eks.cluster_ca_certificate
  environment         = var.environment
}*/

/*
# Creating Keycloak
module mkeycloak {
  source              = "./mkeycloak"
  eks-name            = module.eks.kubernetes_cluster_name
  kube-host           = module.eks.host
  kube-client_certificate = module.eks.client_certificate
  kube-client_key         = module.eks.client_key
  kube-cluster_ca_certificate  = module.eks.cluster_ca_certificate
  http_relative_path = "/"
  replica_count = 1
  cpu_request = "50m"
  memory_request = "100Mi"
  memory_limit = "200Mi"
  enable_autoscaling = false
  enable_metrics = false
  enable_service_monitor  = false
  enable_prometheus_rule = false
  prometheus_namespace = "monitoring"
  keycloak_logging_level = "INFO"
  domain = "cryptkeycloak.org"
  admin_user = "admin"
  keycloak_admin_password = "passWord123"
  postgres_admin_password = "passWord123"
  postgres_user_password = "passWord123"
  environment         = var.environment
}*/


#base64decode(module.eks.kube_config.cluster_ca_certificate)
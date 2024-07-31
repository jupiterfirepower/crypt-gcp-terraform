variable "region" {
  description = "Deployment region"
}
variable "clusterName" {
  description = "Name of our Cluster"
}
variable "minNode" {
  description = "Minimum Node Count"
}
variable "maxNode" {
  description = "maximum Node Count"
}
variable "machineType" {
  description = "Node Instance machine type"
}

variable "projectId" {
  description = "Google Cloud Project Id"
}

variable "network_name" {
  description = "Google Cloud Project Id"
}

variable zones {
  type    = list(string)
}
# environment
variable "environment" {
  type        = string
  description = "Environment"
}

variable "region" {
  type        = string
  description = "Deployment region"
}
variable "clusterName" {
  type        = string
  description = "Name of our Cluster"
}
variable "minNode" {
  type        = number
  description = "Minimum Node Count"
}
variable "maxNode" {
  type        = number
  description = "maximum Node Count"
}
variable "machineType" {
  type        = string
  description = "Node Instance machine type"
}
variable "projectId" {
  type        = string
  description = "Project Name"
}
variable "network_name" {
  type        = string
  description = "Project Name"
}
variable "zones" {
  type    = list(string)
  description = "Zone Names"
}


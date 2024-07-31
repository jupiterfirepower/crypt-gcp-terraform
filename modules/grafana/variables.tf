variable "eks-name" {
  type    = string
}

variable "kube-host" {
  type    = string
}

variable "kube-client_certificate" {
  type    = string
}

variable "kube-client_key" {
  type    = string
}

variable "kube-cluster_ca_certificate" {
  type    = string
}

variable environment {
  type    = string
}

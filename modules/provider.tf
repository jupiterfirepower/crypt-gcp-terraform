terraform {
  required_version = "~> v1.8.2"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.25.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.5"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}

provider "google" {
  credentials = file("~/WORK/crypt-420813-0f7a4e118fef.json")
  project     = var.projectId
  region      = var.region
}
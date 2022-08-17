terraform {
  required_providers {
    local = {
      source = "hashicorp/local"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
}

provider "helm" {
  kubernetes {
    host = var.cluster_host 
    cluster_ca_certificate = var.certificate_ca
    token = var.token
  }
}

provider "kubernetes" {
  host = var.cluster_host
    cluster_ca_certificate = var.certificate_ca
    token = var.token
  }

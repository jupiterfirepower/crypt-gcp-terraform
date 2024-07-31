output "cluster_endpoint" {
  value = google_container_cluster.primary_gke_cluster.endpoint
}

output client_certificate {
  value     = google_container_cluster.primary_gke_cluster.master_auth[0].client_certificate
  sensitive = true
}

output client_key {
  value     = google_container_cluster.primary_gke_cluster.master_auth[0].client_key
  sensitive = true
}

output "cluster_ca_certificate" {
  value     = google_container_cluster.primary_gke_cluster.master_auth[0].cluster_ca_certificate
  sensitive = true
}

#output "cluster_username" {
#  value     = google_container_cluster.primary_gke_cluster.master_auth.0.username
#  sensitive = true
#}

#output "cluster_password" {
#  value     = google_container_cluster.primary_gke_cluster.master_auth.0.password
#  sensitive = true
#}

output "master_version" {
  description = "The Kubernetes master version."
  value       = google_container_cluster.primary_gke_cluster.master_version
}

output "cluster_name" {
  description = "The Kubernetes master version."
  value       = google_container_cluster.primary_gke_cluster.name
}

output "gcr_location" {
  value = data.google_container_registry_repository.primary.repository_url
}



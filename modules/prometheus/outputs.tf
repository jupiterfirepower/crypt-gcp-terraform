# AKS cluster name 
output "prometeus_name" {
  value       = helm_release.prometheus.name
  description = "Name of the Prometeus in Cluster"
}
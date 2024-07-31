
locals {
  sonar_cube_namespace = "sonarqube"
}

# Create a new Kubernetes namespace for the sinarcube application deployment
resource "kubernetes_namespace" "sonar_cube" {
  metadata {
    name = local.sonar_cube_namespace
  }
  depends_on = [var.gke-name]
}

resource "helm_release" "primary_sonar_cube" {

  name = "sonar-cube"
  namespace  = kubernetes_namespace.sonar_cube.metadata.name 

  repository = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart      = "sonarqube"
  version    = "10.5.0" 
  create_namespace = true
}
terraform {
    required_providers {
    helm = {
        source  = "hashicorp/helm"
        version = "~> 2.0" # Fuerza a Terraform a usar la versión moderna v2.x que sí admite el bloque kubernetes
    }
    }
}

# 1. Declarar el proveedor de Helm apuntando al clúster que creará AWS
provider "helm" {
    kubernetes {
    # Lee el archivo de configuración descargado 
    config_path = "/home/kubeconfig.yaml" 
    }
}

# 2. Definir el recurso automatizado de Prometheus y Grafana
resource "helm_release" "prometheus_stack" {
    name             = "prometheus"
    repository       = "https://prometheus-community.github.io/helm-charts"
    chart            = "kube-prometheus-stack"
	atomic           = true
	cleanup_on_fail  = true
    namespace        = "monitoring"
    create_namespace = true

    values = [
		file("${path.module}/values-finops.yaml")
	]

}

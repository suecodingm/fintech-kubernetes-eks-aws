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
    # Lee el archivo de configuración descargado dinámicamente por el main.tf
    config_path = "/home/kubeconfig.yaml" 
    }
}

# 2. Definir el recurso automatizado de Prometheus y Grafana
resource "helm_release" "prometheus_stack" {
    name             = "prometheus"
    repository       = "https://prometheus-community.github.io/helm-charts"
    chart            = "kube-prometheus-stack"
    namespace        = "monitoring"
    create_namespace = true

    # Automatizar la exposición de Grafana como NodePort
    set {
    name  = "grafana.service.type"
    value = "NodePort"
    }

    set {
    name  = "grafana.service.nodePort"
    value = "31668"
    }

    # Desactivar componentes pesados para proteger la RAM del laboratorio
    set {
    name  = "alertmanager.enabled"
    value = "false"
    }

    # ¡LA CLAVE! No arrancar hasta que el kubeconfig esté en tu máquina local
    #depends_on = [null_resource.get_kubeconfig]
}

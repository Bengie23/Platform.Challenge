locals  {
    namespaces = {
        (kubernetes_namespace.namespace-for-quebec.metadata[0].name) = {
            DeveloperRole = "QuebecDev"
            short = "qc"
            expected_port = 8080
        },
        (kubernetes_namespace.namespace-for-montreal.metadata[0].name) = {
            DeveloperRole = "MontrealDev"
            short = "mtl"
            expected_port = 9090
        },
        (kubernetes_namespace.namespace-for-mexico.metadata[0].name) = {
            DeveloperRole = "MexDev"
            short = "mx"
            expected_port = 7070
        }
    }
}

# deployments

resource "kubernetes_deployment" "platform-helloer-deployments" {
    for_each = local.namespaces
    metadata {
        name    =   "platform-helloer-deployment"
        namespace = each.key
        labels  =   {
            app =   "helloer"
        }
    }
    spec    {
        replicas    =   1
        selector {
            match_labels    =   {
                app =   "helloer"
            }
        }
        template {
            metadata {
                labels = {
                    app = "helloer"
                }
            }
            spec {
                container {
                    name    =   "helloer"
                    image   =   "benswengineer/helloer"
                    port {
                        container_port = 80
                    }
                    env {
                        name     = "DeveloperRole"
                        value    = each.value.DeveloperRole
                    }
                }
            }
        }
    }
}

# services
resource "kubernetes_service" "exposure-services" {
    for_each = local.namespaces
    metadata {
        name    =   "helloer-service-${each.value.short}"
        namespace   =   each.key
    }
    spec {
        selector = {
            app     = "helloer"
        }
        port {
            port            =   each.value.expected_port
            target_port     =   8080
        }
        type = "LoadBalancer"
    }

    provisioner "local-exec" {
        command = "sleep 3; open -a \"Google Chrome\"  http://localhost:${each.value.expected_port}/api/hello;"
    }
}
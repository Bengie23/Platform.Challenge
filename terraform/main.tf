terraform   {
    required_providers  {
        kubernetes  =   {
            source  =   "hashicorp/kubernetes"
            version =   "2.11.0"
        }
    }
}

provider "kubernetes"   {
    config_path    = "~/.kube/config"
    config_context = "minikube"
}

# namespaces

resource "kubernetes_namespace" "namespace-for-montreal"  {
    metadata    {
        name    =   "platform-montreal-ns"
    }
}

resource "kubernetes_namespace" "namespace-for-quebec"  {
    metadata    {
        name    =   "platform-quebec-ns"
    }
}

resource "kubernetes_namespace" "namespace-for-mexico"  {
    metadata    {
        name    =   "platform-mexico-ns"
    }
}

# roles
resource "kubernetes_cluster_role"  "senior-dev-role"   {
    metadata    {
        name        =   "senior-dev-role"
    }

    rule {
        api_groups  =   [""]
        resources   =   ["pods", "deployments"]
        verbs       =   ["list", "get"]
    }
}

resource "kubernetes_cluster_role"  "junior-dev-role"   {
    metadata    {
        name        =   "junior-dev-role"
    }

    rule {
        api_groups  =   [""]
        resources   =   ["pods"]
        verbs       =   ["list", "get"]
    }
}

resource "kubernetes_cluster_role"  "lead-dev-role"   {
    metadata    {
        name        =   "lead-dev-role"
    }

    rule {
        api_groups  =   [""]
        resources   =   ["pods", "deployments", "services", "secrets"]
        verbs       =   ["list", "get", "create", "delete", "scale"]
    }
}

# bind user "Max" as senior dev to montreal namespace
resource "kubernetes_role_binding" "senior_devs_for_montreal" {
    metadata    {
        name        =   "senior_devs_for_montreal"
        namespace   =   kubernetes_namespace.namespace-for-montreal.metadata[0].name
    }
    role_ref    {
        api_group   =   "rbac.authorization.k8s.io"
        kind        =   "ClusterRole"
        name        =   kubernetes_cluster_role.senior-dev-role.metadata[0].name
    }
    
    subject {
        kind    =   "User"
        name    =   "Max"
        namespace   =   kubernetes_namespace.namespace-for-montreal.metadata[0].name
    }
}

# bind user "Max" as senior dev to mexico namespace 
resource "kubernetes_role_binding" "senior_devs_for_mexico" {
    metadata    {
        name        =   "senior_devs_for_mexico"
        namespace   =   kubernetes_namespace.namespace-for-mexico.metadata[0].name
    }
    role_ref    {
        api_group   =   "rbac.authorization.k8s.io"
        kind        =   "ClusterRole"
        name        =   kubernetes_cluster_role.senior-dev-role.metadata[0].name
    }
    
    subject {
        kind    =   "User"
        name    =   "Max"
        namespace   =   kubernetes_namespace.namespace-for-mexico.metadata[0].name
    }
}

# bind user "Jamie" as junior dev to quebec namespace
resource "kubernetes_role_binding" "junior_devs_for_quebec" {
    metadata    {
        name        =   "junior_devs_for_quebec"
        namespace   =   kubernetes_namespace.namespace-for-quebec.metadata[0].name
    }
    role_ref    {
        api_group   =   "rbac.authorization.k8s.io"
        kind        =   "ClusterRole"
        name        =   kubernetes_cluster_role.senior-dev-role.metadata[0].name
    }
    
    subject {
        kind    =   "User"
        name    =   "Jamie"
        namespace   =   kubernetes_namespace.namespace-for-quebec.metadata[0].name
    }
}

# Bind user "Ben" as lead dev to all namespaces
resource "kubernetes_cluster_role_binding" "lead_dev_for_all_namespaces" {
    metadata    {
        name    =   "lead_dev_for_all_namespaces"
    }

    role_ref    {
        kind    =   "ClusterRole"
        name    =   kubernetes_cluster_role.lead-dev-role.metadata[0].name
        api_group   =   "rbac.authorization.k8s.io"
    }

    subject {
        kind    =   "User"
        name    =   "Ben"
    }
}

locals  {
    namespaces = {
        (kubernetes_namespace.namespace-for-quebec.metadata[0].name) = {
            DeveloperRole = "QuebecDev"
        },
        (kubernetes_namespace.namespace-for-montreal.metadata[0].name) = {
            DeveloperRole = "MontrealDev"
        },
        (kubernetes_namespace.namespace-for-mexico.metadata[0].name) = {
            DeveloperRole = "MexDev"
        }
    }
}
resource "kubernetes_deployment" "platform-helloer-deployment" {
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

resource "kubernetes_service" "exposure-service-mexico" {
    metadata {
        name    =   "helloer-service-mexico"
        namespace   =   kubernetes_namespace.namespace-for-mexico.metadata[0].name
    }
    spec {
        selector = {
            app     = "helloer"
        }
        port {
            port            =   7070
            target_port     =   8080
        }
        type = "LoadBalancer"
    }
}

resource "kubernetes_service" "exposure-service-quebec" {
    metadata {
        name    =   "helloer-service-quebec"
        namespace   =   kubernetes_namespace.namespace-for-quebec.metadata[0].name
    }
    spec {
        selector = {
            app     = "helloer"
        }
        port {
            port            =   8080
            target_port     =   8080
        }
        type = "LoadBalancer"
    }
}
resource "kubernetes_service" "exposure-service-montreal" {
    metadata {
        name    =   "helloer-service-montreal"
        namespace   =   kubernetes_namespace.namespace-for-montreal.metadata[0].name
    }
    spec {
        selector = {
            app     = "helloer"
        }
        port {
            port            =   9090
            target_port     =   8080
        }
        type = "LoadBalancer"
    }
}







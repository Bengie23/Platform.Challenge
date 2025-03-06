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

resource "kubernetes_namespace" "namespace-for-montreal"  {
    metadata    {
        name    =   "platform-montreal-ns"
    }
}

resource "kubernetes_cluster_role"  "senior-dev-role"   {
    metadata    {
        name        =   "senior-dev-role"
    }

    rule {
        api_groups  =   [""]
        resources   =   ["pods"]
        verbs       =   ["list", "get"]
    }
}

resource "kubernetes_role_binding" "role_binding_1" {
    metadata    {
        name        =   "role_binding_1"
        namespace   =   kubernetes_namespace.namespace-for-montreal.metadata[0].name
    }
    role_ref    {
        api_group   =   "rbac.authorization.k8s.io"
        kind        =   "ClusterRole"
        name        =   kubernetes_cluster_role.senior-dev-role.metadata[0].name
    }
    subject {
        kind    =   "User"
        name    =   "Ben"
        namespace   =   kubernetes_namespace.namespace-for-montreal.metadata[0].name
    }
    subject {
        kind    =   "User"
        name    =   "Max"
        namespace   =   kubernetes_namespace.namespace-for-montreal.metadata[0].name
    }
}

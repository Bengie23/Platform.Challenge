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

resource "kubernetes_role_binding" "senior-devs-for-montreal" {
    metadata    {
        name        =   "senior-devs-for-montreal"
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

resource "kubernetes_role_binding" "senior-devs-for-mexico" {
    metadata    {
        name        =   "senior-devs-for-mexico"
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

resource "kubernetes_role_binding" "junior-devs-for-quebec" {
    metadata    {
        name        =   "junior-devs-for-quebec"
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

resource "kubernetes_cluster_role_binding" "lead-dev-for-all-namespaces" {
    metadata    {
        name    =   "lead-dev-for-all-namespaces"
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

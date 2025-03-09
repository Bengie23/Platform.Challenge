# SCALING ACROSS MULTIPLE CLUSTERS

## How to scale 
Following the same idea of a software company allocating software developers in 3 different locations, I have identified two main ways to scale.

### Replicas
The current Terraform manifest describes deployments using `replicas = 1`. This is intentional, the idea is to set up deployments that can scale as more developers are hired for every location independently.

**Scenario:**
When the team has identified that the Helloer API, which every developer needs as a dependency, is not handling the load, the lead developer has permissions to scale a deployment.

run command
```console
kubectl scale --replicas=2 deployment/helloer-deployment
 ```

 ### Multi-cluster / Multi-cloud

One of the benefits of deploying infrastructure using Terraform is that the resources/objects can target multiple clusters/providers. Configuring multiple providers will help us to deploy in multiple Cloud providers, including AWS, Azure, or Google.

Here's a little example of how this kind of manifest would look like:

```Terraform
provider "aws" {
    # provider configuration
}

provider "azurerm" {
    # provider configuration
}

resources "kind" "name" {
    # resource configuration
}

# other resources....
 ```

 ## Strategies for RBAC management

 **Clustered vs Namespaced**

 Terraform provides (namespaced) roles, cluster roles and in the same way, (namespaced) bindings and cluster bindings. This offers the ability to target either namespaces or entired cluster roles/users. 

 **Designate resources for specific roles**

 As shown in the current Terraform manifest, we can stablish user roles permissions to manipulate specific resources.


 **Designate verbs for specific roles**

 As shown in the current Terraform manifest, we can stablish user roles permissions to use specific verbs.

```Terraform
 resource "kubernetes__role"  "junior-dev-role"   {
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
        verbs       =   ["list", "get", "create", "delete"]
    }
}
```
 ## Automation tools or scripts to facilitate scaling
 ### Kubernetes Horizontal Pod Autoscaler (HPA)
 it's a native (to Terraform) resource that provides horizontal scaling for a pod based on CPU utilization, memory usage and/or other metrics.

```Terraform
resource "kubernetes_horizontal_pod_autoscaler" "example" {
    metadata    {
        name        =   "pod-autoscaler-example"
        namespace   =   "default"
    }

    spec    {
        scale_target_ref    {
            api_version     =   "apps/v1"
            kind            =   "Deployment"
            name            =   "example-deployment"
        }

        min_replicas    =   1
        max_replicas    =   10

        metrics {
            type    =   "Resource"

            resource    {
                name    =   "cpu"
                target  {
                    type    =   "Utilization"
                    average_utilization =   80
                }
            }
        }
    }
}
 ```
 **Note:** This terraform definition is provided for informational purposes, Adapt and test it before production use.

 ### Kubernetes Vertical Pod Autoscaler
 It's also a native Terraform resource that automatically adjusts the CPU and memory requests for your pod based on usage.

 ```Terraform
resource "kubernetes_horizontal_pod_autoscaler" "example" {
    metadata    {
        name        =   "pod-autoscaler-example"
        namespace   =   "default"
    }

    spec    {
        scale_target_ref    {
            api_version     =   "apps/v1"
            kind            =   "Deployment"
            name            =   "example-deployment"
        }

        update_policy   {
            update_mode =   "Auto"
        }
    }
}
 ```

  **Note:** This terraform definition is provided for informational purposes, Adapt and test it before production use.

  ### Kubectl scripting
  As described in [How to scale using replicas](#replicas) we can use kubectl scripting to scale pods, updating the replicas property by executing the scale command.

 ## Consistency and manageability
Since Terraform is multi-cluster oriented, implementing autoscaling resources like [KVPA](#kubernetes-vertical-pod-autoscaler) and [KHPA](#kubernetes-horizontal-pod-autoscaler-hpa) across multiple cluster and cloud providers enables consistency and manageability.

Another interesting tool for manageability and consistency is defining variables in Terraform configuration file `variables.tf`

Implementing a null resource is another way to extend the consistency and manageability of scaling mechanisms, this resource allows the execution of a command, for scaling purposes, a kubectl scale command. This way, instead of manually running the kubectl command against an specific cluster/pod/deployment/namespace, Terraform allows the execution of the given comman against any configured providers/clusters.

```Terraform
resource "null_resource" "scale_deployment" {
    provisioner "local-exec"    {
        command = "kubectl scale --replicas=2 deployment/helloer-deployment"
    }

    depends_on  =   [kubernetes_deployment.helloer-deployment]
}
 ```

  **Note:** This terraform definition is provided for informational purposes, Adapt and test it before production use.

  ## Other tools to explore
  * Argocd
  * Jenkins
  * Flux
  * GitHub Actions
  

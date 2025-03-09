# Interacting with the repository to create and manage their namespaces.

## Deployment Context
Within our Terraform deployment we have created several objects, including: namespaces, roles, role bindings, deployments and services.

### Namespaces
Namespaces created from terraform deployment:
* platform-montreal-ns
* platform-mexico-ns
* platform-quebec-ns

If we run:
```console
kubectl get ns
 ```

 We get:
 
 ![alt text](./screenshots/user/image.png)

 **Purpose**

The purpose for those namespaces rely on the requirement of a software company that allocates software developers in 3 cities: Quebec, Montreal and Mexico.
When a developer is hired, depending on their role, they will have access to different namespaces, this will be described next.
#### How to create a new namespace?
**Using kubectl command**
```console
kubectl create namespace my-namespace
 ```

 **Using terraform**
 ```terraform
resource "kubernetes_namespace" "example" {
  metadata {
    annotations = {
      name = "example-annotation"
    }

    labels = {
      mylabel = "label-value"
    }

    name = "terraform-example-namespace"
  }
}
 ```
 ```console
terraform import kubernetes_namespace.example terraform-example-namespace
 ```

 **Note:** When using import, terraform accepts the request for a new namespace, affecting the terraform state, but it does not update the .tf manifest, this has to be done manually.
### RBAC Implementation
The RBAC implementation deployed within the existing terraform manifest described the next 3 roles:
* junior-dev-role
    
    It has [list, get] permissions against [pods] objects
* senior-dev-role
   
   It has [list, get] permissions against [pods, deployments] objects
* lead-dev-role

    It has [list, get, create, delete, scale] permissions against [pods, deployments, services, secrets] objects


For demo purposes, I have implemented the next bindings:
* **junior-dev-role** has access to the namespaces: **[platform-quebec-ns]**
* **senior-dev-role** has access to the namespaces: **[platform-montreal-ns, platform-mexico-ns]**
* **lead-dev-role** has access to the namespaces: **[platform-montreal-ns, platform-mexico-ns, platform-quebec-ns]**

In the same way, the current manifest describes 3 users:
* Max (senior dev)
* Jamie (junior dev)
* Ben (lead dev)

Finally, the mix of namespaces + roles + bindings + users shoud correspond to this:
![kubernetes_challenge_diagram](https://github.com/user-attachments/assets/5c77ec34-6aeb-4306-bb2c-2b9f08abe77d)
### Deployments
For every new namespace, we have created a deployment resource, specific to the corresponding namespace. In this case we are just using a simple environment variable to demonstrate the customization of these deployments.
The Helloer application is a simple Hello World API, with a little customization: it relies on environment variables to determine the language of the system.

For Quebec namespace, the application should return: `Salute, le monde`

For Montreal namespace, the application should return: `Hello World`

For Mexico namespace, the application should return `Hola Mundo`

### Services
In the same wey, for every new namespace, we have created a service resource, specific to the corresponding namespace. This is needed to expose the services behind each pod, for each namespace.

**Note:** Considering we are running our terraform locally, and not against a cloud provider, the execution of a `minikube tunnel` command, is required to allow the host to access deployed application's endpoints.

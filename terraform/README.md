# Deploying infrastructure with Terraform

## Prerequisites
**Make sure to complete the prerequisites described in OPERATOR.md**

Install Terraform
```console
brew tap hashicorp/tap
 ```

and

```console
brew install hashicorp/tap/terraform
 ```

 Validate installation with

 ```console
terraform -help
 ```


## Navigate to terraform path
## Init

```console
terraform init
 ```
## Deploy

```console
terraform plan
 ```
**Note:** Verify minikube tunnel is running in another terminal window.

 and

 ```console
terraform apply
 ```
**Note:** The apply command will prompt for confirmation, typing 'yes' is required to proceed.

## Result

If everything went well, we should be able to see something like this
![alt text](/terraform/screenshots//image.png)


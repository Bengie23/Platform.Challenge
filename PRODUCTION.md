# PRODUCTION
## Security Enhancements

### Replace user-specific RBAC with group-specific RBAC
In the current version of our Terraform manifest we stablished user-role associations. This is intentional for simplified demo purposes, in a production environment, we should prioritize group-role associations.

Group-role associations provide access to cluster resources depending on the groups a user belongs to. Those groups are not managed by Kubernetes itself, instead, they are managed by an external identity provider like Azure AD (now Azure Entra Id).

This implementation benefits from the best of 2 tools and allows kubernetes to extend its native RBAC configuration.

### Implement Network Policies

Network Policies are used to restrict communications between pods. The native Kubernetes behaviour is to allow communication between pods, but network policies override this to limit the native behaviour.

## High Availability & Fault Tolerance

* Deploying Kubernetes control plane to multiple nodes for replication purposes

* Set up a load balancer from cloud providers that distribute the load across the previously set up control plane nodes.

* Deploy resources (for applications) across multiple, relevant availability zones.

* Use autoscaler mechanisms described in `SCALING.md`

## Monitoring & Logging Setups

Implement tools that improve the observability around clusters and their deployed resources.

**Prometheus**
It's an open source system for monitoring and alerting toolkit designed fo reliability and scalability, alllowing you to collect, store, query and analyze metrics for a Kubernetes cluster and deployed applications.

**Grafana** 
It's an open source system for monitoring and observability enabling visualization, analytics, alerting in a Kubernetes environment.

## Backup & Disaster Recovery Plans
The standard best practice for backup and disaster recovery is to implement scheduled snapshots through cron jobs.

### Related tools
**Velero:** Backup and restore Kubernetes resources

**Kasten K10:** Disaster recovery solution for Kubernetes

**Rancher:** Backup and recovery solutions for clusters.

**Cloud-Specific:** AWS EBS Snapshots, Azure Disk Snapshots, GCP Persisten Disk Snapshots.

**DB-specific:** pg_dump, mysqldump.


## Performance Optimization
### Scaling Optimization
* Optimize KVPA
* Optimize KHPA

### Implement Affinity & Taints/Tolerations
Affinity refers to describing the resource charactersitics or specific hardware features . When affinity is configured, Kubernetes will make sure nodes that do not satisfy the requirements are not used for deploying a given resource.

Similarly, taints/tolerations allow Kubernetes to mark nodes as not-applicable for a certain deployment unless they tolerate those taints.

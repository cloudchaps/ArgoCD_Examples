### Application Set

In Argo CD, ApplicationSets allow you to automatically generate multiple ArgoCD Applications from a template.
This is extremely useful when managing many environments, clusters, or services in a Kubernetes GitOps setup.
Instead of manually creating many Application resources, you define one ApplicationSet that dynamically generates them.
What an ApplicationSet Does
An ApplicationSet consists of:

1️⃣ Generators → produce a list of parameters
2️⃣ Template → used to generate ArgoCD Applications

Conceptually:
Generator → list of values
Template → creates Application objects
Example result:

ApplicationSet
   ├── App Dev
   ├── App Staging
   └── App Production
Basic Structure
Example ApplicationSet:
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: guestbook
spec:
  generators:
  - list:
      elements:
      - cluster: dev
      - cluster: prod
  template:
    metadata:
      name: '{{cluster}}-guestbook'

This generates:

dev-guestbook
prod-guestbook
ApplicationSet Generators

Generators determine how the applications are created.

The most common ones used in real-world DevOps environments are:
- List Generator
- Cluster Generator
- Git Directory Generator
- Matrix Generator
- Pull Request Generator

1️⃣ List Generator
The List Generator creates applications from a static list of values.
Example:
generators:
- list:
    elements:
    - cluster: dev
      url: https://kubernetes-dev
    - cluster: prod
      url: https://kubernetes-prod

Template:
template:
  metadata:
    name: '{{cluster}}-app'
Result:
dev-app
prod-app
When to use
- Small environments where clusters or environments are manually defined.
Example:
dev
staging
prod

2️⃣ Cluster Generator
The Cluster Generator automatically creates applications for all clusters registered in ArgoCD.
This is useful in multi-cluster deployments.
Example:
generators:
- clusters: {}
Template example:
metadata:
  name: '{{name}}-monitoring'
Result:
cluster1-monitoring
cluster2-monitoring
cluster3-monitoring

Use case
- Deploy the same tool to every cluster:
- monitoring stack
- logging
- security agents

Example tools:
- Prometheus
- Datadog
- Fluentbit

3️⃣ Git Directory Generator
The Git Directory Generator automatically creates applications based on directories inside a Git repository.
Example repo:
repo
 ├── service-a
 ├── service-b
 └── service-c

Generator:
generators:
- git:
    repoURL: https://github.com/company/apps
    revision: main
    directories:
    - path: "*"

Generated applications:
service-a
service-b
service-c
Each folder becomes a separate ArgoCD Application.

Use case
- Very common in microservice architectures.

repo
 ├── payments
 ├── orders
 ├── auth
 └── inventory
ArgoCD automatically deploys all services.

4️⃣ Matrix Generator
The Matrix Generator combines multiple generators to create every possible combination of parameters.
Concept:
Generator A × Generator B
Example:
Clusters:
dev
prod
Applications:
service-a
service-b
Matrix result:
dev-service-a
dev-service-b
prod-service-a
prod-service-b

Example configuration:
generators:
- matrix:
    generators:
    - clusters: {}
    - git:
        repoURL: https://github.com/company/apps
        directories:
        - path: "*"
Use case
- Deploy all services to all clusters automatically.

5️⃣ Pull Request Generator
The Pull Request Generator automatically creates temporary preview environments for pull requests.
It integrates with Git providers such as:
- GitHub
- GitLab

Example configuration:
generators:
- pullRequest:
    github:
      owner: company
      repo: myapp

Result:

PR-14-preview
PR-15-preview
PR-16-preview

Each PR gets its own temporary environment.
Example preview URL:
pr-15.myapp.dev.company.com
Use case
- Used for preview environments in CI/CD pipelines.
- Developers can test features before merging.

Workflow:
Developer creates PR
↓
ApplicationSet creates preview environment
↓
Team tests feature
↓
PR merged
↓
Preview environment deleted
Real GitOps Architecture Example

Large organizations use ApplicationSets like this:

Git repo
 ├── services
 │   ├── auth
 │   ├── payments
 │   └── orders
 │
 └── clusters
     ├── dev
     ├── staging
     └── prod

ApplicationSet with Matrix Generator creates:

dev-auth
dev-payments
dev-orders

staging-auth
staging-payments
staging-orders
[text](../../AZURE/devbox.json) [text](../../AZURE/devbox.lock)
prod-auth
prod-payments
prod-orders

Everything is automated.
### Declaration Tools
1️⃣ Plain Kubernetes Manifests (Raw YAML)

This is the simplest option.
Your repository just contains Kubernetes YAML files.
Example repo:
repo
 ├── deployment.yaml
 ├── service.yaml
 └── ingress.yaml
Example deployment:
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp

Characteristics
✔ simplest approach
✔ no templating required
✔ easy to understand
❌ not ideal for multiple environments
❌ leads to duplication

2️⃣ Helm
ArgoCD can deploy applications packaged as Helm charts.
Example repo:
repo
 ├── Chart.yaml
 ├── values.yaml
 └── templates/
 ArgoCD internally runs something similar to:
 helm template
 to generate Kubernetes manifests.

Characteristics
✔ parameterized deployments
✔ supports environment values
✔ widely used
Example in Application spec:
source:
  repoURL: https://github.com/company/app
  path: chart
  helm:
    valueFiles:
      - values-prod.yaml

3️⃣ Kustomize
Another popular tool supported natively by ArgoCD is Kustomize.
Kustomize lets you patch and customize base manifests without templates.
Example structure:
repo
 ├── base
 │   └── deployment.yaml
 └── overlays
     └── prod
         └── kustomization.yaml
resources:
- ../../base

replicas: 3

Characteristics
✔ native Kubernetes tool
✔ good for environment overlays
✔ no templating language

4️⃣ Jsonnet
ArgoCD also supports Jsonnet.
Jsonnet is used to generate Kubernetes manifests programmatically.
Example:
{
  deployment: {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: { name: "myapp" }
  }
}

Characteristics
✔ powerful templating
✔ programmable configs
❌ harder to learn
❌ less common in typical DevOps teams

5️⃣ Custom Plugins
ArgoCD allows custom config management plugins.
Example tools:
Terraform
- Pulumi
- custom scripts
These plugins generate Kubernetes manifests before deployment.
Example workflow:
Git repo
   ↓
Plugin generates manifests
   ↓
ArgoCD applies them to Kubernetes
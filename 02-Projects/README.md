### Projects
In Argo CD, Projects (called AppProjects) are used to organize, secure, and control access to applications deployed to Kubernetes.
It allows administrators to define:
what repositories can be used
- which clusters/namespaces apps can deploy to
- which Kubernetes resources are allowed
- who can manage the applications

Purpose of Projects
Projects help enforce multi-team governance in ArgoCD.
Example scenario:
Cluster
 ├── Dev Team
 ├── Platform Team
 └── Data Team

Each team should only:
- deploy their own apps
- use specific repositories
- deploy to specific namespaces
Projects enforce these rules.

Basic Project Structure
Example AppProject:
apiVersion: argoproj.io/v1alpha1
kind: AppProject
metadata:
  name: dev-project
  namespace: argocd

spec:
  sourceRepos:
    - https://github.com/company/*
  
  destinations:
    - namespace: dev
      server: https://kubernetes.default.svc

  clusterResourceWhitelist:
    - group: '*'
      kind: '*'

This project allows applications to:
- use repos from github.com/company
- deploy to the dev namespace
- create cluster resources

1️⃣ Restrictions
Projects can restrict where and what applications can deploy.
- Repository Restrictions
Controls which Git repositories applications can use.
Example:
sourceRepos:
- https://github.com/company/*

Now applications cannot use external repos.
Example blocked repo:
https://github.com/random-user/app
This prevents supply-chain risks.
- Destination Restrictions
Controls which clusters and namespaces applications can deploy to.
Example:
destinations:
- namespace: dev
  server: https://kubernetes.default.svc
This means apps cannot deploy to production namespaces.
- Resource Restrictions
You can control which Kubernetes resources are allowed.
Example:
namespaceResourceWhitelist:
- group: apps
  kind: Deployment

Allowed resources:
    Deployment
Blocked resources:
    Ingress
    DaemonSet
    StatefulSet
This is useful when limiting risky resources.

2️⃣ Allowances
Projects can explicitly allow certain resources.
There are two main types:
Namespace resources
Example:
namespaceResourceWhitelist:
- group: apps
  kind: Deployment
These resources are allowed inside namespaces.
- Cluster resources
    Cluster-wide resources must be allowed explicitly.
Example:
clusterResourceWhitelist:
- group: networking.k8s.io
  kind: Ingress
Without this, ArgoCD will block cluster-scoped resources.
Cluster-scoped examples:
- ClusterRole
- ClusterRoleBinding
- CustomResourceDefinition

3️⃣ Roles (RBAC)
Projects support role-based access control.
Roles determine who can manage applications inside the project.
Example:
roles:
- name: developers
  description: Developer access
  policies:
  - p, proj:dev-project:developers, applications, get, dev-project/*, allow
  - p, proj:dev-project:developers, applications, sync, dev-project/*, allow

This role allows:
- view applications
- sync applications
But may block:
- delete apps
- modify settings

Role Tokens
Roles can generate JWT tokens.
Example:
roles:
- name: ci-pipeline
  policies:
  - p, proj:dev-project:ci-pipeline, applications, sync, dev-project/*, allow
These tokens are often used by:
- CI pipelines
- automation systems
Example tools:
- Jenkins
- GitHub Actions
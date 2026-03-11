### Sync Options
In Argo CD, Sync Options control how and when ArgoCD applies the desired state from Git to the cluster running on Kubernetes.
A sync operation means:
Git desired state
      ↓
ArgoCD compares with
      ↓
Live Kubernetes cluster
      ↓
Applies changes to make them match

Sync options modify this behavior and are critical for GitOps automation and safety.

1️⃣ Automated Sync
Automated Sync allows ArgoCD to automatically apply changes whenever the Git repository changes.
Example configuration:
spec:
  syncPolicy:
    automated: {}
Behavior:
Git change
   ↓
ArgoCD detects change
   ↓
ArgoCD automatically syncs

Benefits
✔ true GitOps workflow
✔ no manual intervention
✔ continuous delivery

2️⃣ Self-Healing
Self-healing ensures that manual changes in the cluster are reverted to match Git.
Example configuration:
spec:
  syncPolicy:
    automated:
      selfHeal: true
Example scenario:
Deployment in Git:
replicas: 3
Someone manually changes it in the cluster:
kubectl scale deployment app --replicas=6
ArgoCD detects drift and reverts it back to 3 replicas.

Purpose
✔ prevents configuration drift
✔ enforces Git as the single source of truth

3️⃣ Pruning and No Prune at Resource Level
Pruning removes resources that exist in the cluster but no longer exist in Git.
Example:
Git repository before:
deployment.yaml
service.yaml
configmap.yaml
Git repository after:
deployment.yaml
service.yaml

ArgoCD will delete:

configmap.yaml
Enable pruning
spec:
  syncPolicy:
    automated:
      prune: true
No Prune at Resource Level
Sometimes a specific resource should never be deleted, even if removed from Git.
Example annotation:
metadata:
  annotations:
    argocd.argoproj.io/sync-options: Prune=false
Now ArgoCD will not delete that resource.

Example use case:
- persistent volumes
- manually managed secrets

4️⃣ Selective Sync
Selective Sync allows you to sync only specific resources instead of the entire application.
Example use case:
Application contains:
- Deployment
- Service
- ConfigMap
- Ingress
But you want to update only:
Deployment
Selective sync allows that.
Example CLI usage:
argocd app sync myapp --resource apps:Deployment:default/mydeployment

Benefits
✔ faster updates
✔ safer partial deployments
✔ useful for debugging

5️⃣ Fail on Shared Resources
This option prevents ArgoCD from modifying resources managed by multiple applications.
Example problem:
Application A → manages ConfigMap
Application B → tries to modify the same ConfigMap
Without protection, this can cause conflicts.
Enable fail-on-shared-resource:
spec:
  syncPolicy:
    syncOptions:
      - FailOnSharedResource=true
Now ArgoCD will:
detect shared resource
      ↓
fail the sync operation

Benefits
✔ prevents application conflicts
✔ improves multi-team environments

6️⃣ Replace Resources
By default ArgoCD performs kubectl apply.
This performs a patch update.
Sometimes this fails when:
- immutable fields change
- resources require full recreation
- The Replace option tells ArgoCD to use:
kubectl replace
Example configuration:
spec:
  syncPolicy:
    syncOptions:
      - Replace=true
Behavior:
- Delete resource
- Create new resource
- Example scenario

A Service changes type:
ClusterIP → NodePort
Some fields are immutable, so patching fails.
Using Replace=true recreates the resource.
## Diffing Customization
In Argo CD, Diffing Customization allows you to control how ArgoCD compares the desired state in Git with the live state in the cluster running on Kubernetes.
Normally ArgoCD performs a comparison:
Git (desired state)
        vs
Live cluster state
If differences exist, the application becomes OutOfSync.
However, many Kubernetes controllers automatically modify resources after deployment, which can cause false differences. Diffing customization allows ArgoCD to ignore those expected differences.
Why Diffing Customization is Needed
Kubernetes frequently changes resources automatically.
Examples:
- Autoscalers change replica counts
- Admission controllers inject containers or labels
- Controllers add default values
- Tools modify annotations or metadata

Without diff customization, ArgoCD may show:
Application Status: OutOfSync
even when everything is working correctly.

Main Diffing Customization Methods
1️⃣ Ignore Specific Fields (jsonPointers)
You can configure ArgoCD to ignore specific fields when comparing resources.
Example: ignoring replica differences in a Deployment.
spec:
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/replicas
Why this is useful
A Horizontal Pod Autoscaler may dynamically change replicas, and ArgoCD should not revert them.
This avoids conflicts with the Kubernetes Horizontal Pod Autoscaler.

2️⃣ Ignore Differences by Manager
Kubernetes tracks which controller modified fields using managedFields.
You can instruct ArgoCD to ignore fields modified by specific controllers.
Example:
ignoreDifferences:
- group: "*"
  kind: "*"
  managedFieldsManagers:
  - kube-controller-manager
This tells ArgoCD:
Ignore fields modified by the Kubernetes controller manager.

3️⃣ Ignore Specific Metadata
Some tools automatically inject labels or annotations.
Example configuration:
ignoreDifferences:
- group: "*"
  kind: "*"
  jsonPointers:
  - /metadata/annotations
This prevents diff noise from tools that inject metadata.
Istio Case Example (Very Common)

## A frequent real-world example involves Istio.
Istio uses a mutating admission webhook to automatically inject a sidecar proxy container into application pods.
What Happens Without Diff Customization
Deployment in Git:
containers:
- name: app
  image: myapp:v1
After deployment, Istio injects a container:
containers:
- name: app
  image: myapp:v1

- name: istio-proxy
  image: istio/proxyv2

Now ArgoCD compares:
Git version:
   1 container
Live cluster:
   2 containers

Result:
Application Status: OutOfSync
Even though the system is working correctly.
Fixing the Istio Diff Issue
You can configure ArgoCD to ignore the injected container.
Example:
spec:
  ignoreDifferences:
  - group: apps
    kind: Deployment
    jsonPointers:
    - /spec/template/spec/containers
More precise configuration can ignore only the injected sidecar.
Example ignoring managed fields from Istio:

ignoreDifferences:
- group: "*"
  kind: "*"
  managedFieldsManagers:
  - istio-sidecar-injector

Now ArgoCD ignores modifications performed by Istio.

Result:
Application Status: Synced
Where Diff Customization Can Be Configured
Diff rules can be defined in two places.
Application Level
Inside the application manifest:
spec:
  ignoreDifferences:
This applies only to that application.
Global Configuration
Defined in the ArgoCD configuration map.

Example:

argocd-cm

This applies diff rules across all applications.

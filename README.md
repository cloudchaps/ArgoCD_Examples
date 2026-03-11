### Declaration Forms
1️⃣ Imperative (CLI creation)
You create the application using the CLI from Argo CD CLI.
Example:
argocd app create myapp \
  --repo https://github.com/example/repo.git \
  --path k8s \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace default
Characteristics
✔ Fast for testing
✔ Useful for demos
❌ Not GitOps-friendly
❌ Harder to track in version control

2️⃣ Declarative (Application YAML)
You define the Application as a Kubernetes manifest.
Example:
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/example/repo.git
    targetRevision: HEAD
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated: {}
Apply it:
kubectl apply -f application.yaml
Characteristics
✔ Fully GitOps compliant
✔ Version controlled in Git
✔ Reproducible deployments
✔ Infrastructure-as-code

3️⃣ App-of-Apps Pattern
One parent ArgoCD application manages multiple child applications.
Example structure:
git-repo
 ├── apps
 │   ├── app1.yaml
 │   ├── app2.yaml
 │   └── app3.yaml
 └── root-app.yaml
 Root application:
 source:
  repoURL: https://github.com/company/platform.git
  path: apps
Characteristics
✔ Manage many applications centrally
✔ Common in platform engineering
✔ Used for cluster bootstrapping
Example use case
Deploy an entire platform:
- ingress
- monitoring
- logging
- applications
- with one root application.

4️⃣ ApplicationSet (Dynamic Applications)
Using Argo CD ApplicationSet.
ApplicationSets automatically generate multiple Applications from templates.
Example:
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: cluster-apps
spec:
  generators:
  - list:
      elements:
      - cluster: dev
      - cluster: staging
      - cluster: prod
  template:
    metadata:
      name: myapp-{{cluster}}
    spec:
      project: default
      source:
        repoURL: https://github.com/example/repo.git
        path: k8s
      destination:
        server: https://kubernetes.default.svc
        namespace: default
Characteristics
✔ Automatically generates apps
✔ Great for multi-cluster deployments
✔ Reduces duplication

5️⃣ UI creation
Applications can also be created from the ArgoCD web UI.
Steps:
- Open ArgoCD dashboard
- Click New App
- Fill repo / path / cluster
- Create
Characteristics
✔ Easy for beginners
✔ Good for experimentation
❌ Not GitOps compliant
❌ Harder to track
### Tracking Strategies
In Argo CD, tracking strategies define how ArgoCD tracks the version of your application source in Git or Helm repositories so it knows when a new version should be deployed to the cluster running on Kubernetes.
Different strategies are used depending on whether the application is sourced from:
- a Git repository
- a Helm chart repository
Why Tracking Strategies Exist
ArgoCD continuously checks the source repository and compares it with the running application.
Example workflow:
Git / Helm repo
       ↓
ArgoCD tracks version
       ↓
New version detected
       ↓
Application becomes OutOfSync

The tracking strategy defines what “new version” means.

1️⃣ Tracking a Git Branch (HEAD)
This is the most common strategy.
ArgoCD tracks the latest commit on a branch, usually main or master.
Example:
spec:
  source:
    repoURL: https://github.com/company/app
    targetRevision: HEAD
or
targetRevision: main
Behavior
Git branch: main
Commit A
Commit B
Commit C  ← ArgoCD deploys this
When a new commit appears:
Commit D
ArgoCD detects the change and marks the application OutOfSync.

Use Case
✔ Continuous delivery
✔ Active development environments
Example environments:
dev
staging

2️⃣ Tracking a Specific Git Commit
Instead of tracking a branch, ArgoCD can track a specific commit hash.
Example:
targetRevision: e8c1a92
Behavior
Commit A
Commit B
Commit C
Commit D
If targetRevision is Commit B, ArgoCD always deploys Commit B.
Even if newer commits exist.

Use Case
✔ fully reproducible deployments
✔ production releases
✔ rollback stability
Example:
prod environment locked to specific commit

3️⃣ Tracking Git Tags
ArgoCD can track Git tags.
Example:
targetRevision: v1.2.0
Example Git history:
v1.0
v1.1
v1.2
v1.3
If ArgoCD tracks v1.2, it deploys the commit associated with that tag.
Behavior
Tag-based releases allow controlled versioning.

Use Case
✔ release-based deployments
✔ semantic versioning workflows
Common CI/CD pattern:
CI pipeline
   ↓
Create tag v1.3
   ↓
ArgoCD deploys that version

4️⃣ Tracking Helm Latest Version
If using Helm charts, ArgoCD can track the latest chart version.
Example configuration:
source:
  repoURL: https://charts.company.com
  chart: myapp
  targetRevision: "*"

Behavior
Helm repository versions:
1.0.0
1.1.0
1.2.0
ArgoCD deploys:
1.2.0
Whenever a new version appears:
1.3.0
ArgoCD detects the update.

Use Case
✔ continuously updating Helm charts
✔ dev/test environments

5️⃣ Tracking Helm Version Ranges
Helm supports semantic version ranges.
Example:
targetRevision: "1.2.x"
Helm versions:
1.2.1
1.2.4
1.2.7
1.3.0
ArgoCD deploys the latest version matching the range:
1.2.7
But it will not deploy:
1.3.0
Example ranges
1.2.x      → latest patch
>=1.2.0    → minimum version
<2.0.0     → avoid major upgrades

Use Case
✔ safe automatic upgrades
✔ prevent breaking changes
Common production strategy:
>=1.4.0 <2.0.0
This allows minor updates but avoids major upgrades.

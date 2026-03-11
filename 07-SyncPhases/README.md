### Sync Phases and Waves

In Argo CD, Sync Phases control when resources are applied during a deployment, while Sync Waves and Resource Hooks control the order and lifecycle actions during the deployment process in a Kubernetes cluster.
These features are critical when deploying complex applications where resources must be created in a specific order.
Example:
Database → Backend API → Frontend
You cannot deploy the frontend before the backend is available.

1️⃣ Sync Phases
A Sync Phase determines when a resource is executed during the synchronization process.
ArgoCD supports the following phases:

Phase	Purpose
PreSync	Runs before normal resources are applied
Sync	Default phase where most resources are deployed
PostSync	Runs after deployment completes
SyncFail	Runs if the sync operation fails

These phases are implemented using Resource Hooks.

2️⃣ Resource Hooks
Resource Hooks allow you to run custom Kubernetes resources during specific phases of the sync process.
They are defined using annotations.
Example:
metadata:
  annotations:
    argocd.argoproj.io/hook: PreSync
Common hook types:
Hook	Purpose
PreSync	Run tasks before deployment
Sync	Run tasks during deployment
PostSync	Run tasks after deployment
SyncFail	Run tasks if deployment fails
Example: Database Migration Hook

Before deploying an application, you may need to run database migrations.

Example job:

apiVersion: batch/v1
kind: Job
metadata:
  name: db-migration
  annotations:
    argocd.argoproj.io/hook: PreSync

Workflow:
PreSync Job → run database migration
Sync → deploy application
PostSync → run validation

3️⃣ Sync Waves
Sync Waves allow you to control the order in which resources are deployed within a phase.
This is done using the annotation:
argocd.argoproj.io/sync-wave
Example:
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "0"

Resources with lower wave numbers deploy first.

Example order:

Resource	Wave
Database	-1
Backend	0
Frontend	1
Deployment order:
Wave -1 → Database
Wave 0 → Backend
Wave 1 → Frontend
Example Scenario

Application architecture:

PostgreSQL Database
Backend API
Frontend UI

We want the deployment order:
Database → Backend → Frontend
Database
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "-1"
Backend
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "0"
Frontend
metadata:
  annotations:
    argocd.argoproj.io/sync-wave: "1"

Result:

Wave -1 → Database
Wave 0 → Backend
Wave 1 → Frontend

4️⃣ Hook Lifecycle Policies
Hooks can be automatically deleted after execution using:
argocd.argoproj.io/hook-delete-policy
Common options:
Policy	Behavior
HookSucceeded	Delete hook after success
HookFailed	Delete hook after failure
BeforeHookCreation	Delete previous hook before running a new one

Example:
metadata:
  annotations:
    argocd.argoproj.io/hook: PreSync
    argocd.argoproj.io/hook-delete-policy: HookSucceeded
Complete Deployment Flow Example

Example full workflow:

PreSync Phase
   ↓
Run DB Migration Job

Sync Phase
   ↓
Wave -1 → Database
Wave 0  → Backend
Wave 1  → Frontend

PostSync Phase
   ↓
Run Smoke Tests

SyncFail Phase (if error)
   ↓
Run rollback script
Practical Real-World Example

Typical microservice deployment:

1. PreSync → Run schema migrations
2. Sync wave -1 → Deploy database
3. Sync wave 0 → Deploy backend services
4. Sync wave 1 → Deploy frontend
5. PostSync → Run health checks

This guarantees correct deployment order.
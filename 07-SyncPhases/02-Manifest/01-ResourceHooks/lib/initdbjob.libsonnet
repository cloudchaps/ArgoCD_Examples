{
    initjob(name, namespace, argocdhook, argocdwave, deletepolicy, image, version, commands)::{
        apiVersion: 'batch/v1',
        kind: 'Job',
        metadata: {
            name: 'migration-' + name,
            namespace: namespace,
            annotations: {
                'argocd.argoproj.io/hook': argocdhook,
                'argocd.argoproj.io/sync-wave': argocdwave,
                'argocd.argoproj.io/hook-delete-policy': deletepolicy
            }
        },
        spec: {
            template: {
                spec: {
                    restartPolicy: 'Never',
                    containers: [
                        {
                            name: name,
                            image: image + ':' + version,
                            command: commands
                        }
                    ]
                }
            }
        }
    }
}
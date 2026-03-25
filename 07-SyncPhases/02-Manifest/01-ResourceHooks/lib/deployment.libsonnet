{
    deployment(name, namespace, argocdwave, argocdhook, image, version, replicas, port)::{
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
            name: name,
            namespace: namespace,
            labels: { app: name }
            annotations: {
                'argocd.argoproj.io/hook': argocdhook,
                'argocd.argoproj.io/sync-wave': argocdwave,
            }
        },
        spec: {
            replicas: replicas,

            selector: {
                matchLabels: { app: name }
            },

            template: {
                metadata: {
                    labels: { app: name }
                },

                spec: {
                    containers: [
                        {
                            name: name,
                            image: image + ":" + version,

                            ports: [
                                { containerPort: port }
                            ],

                        }
                    ]
                }
            }
        }
    }
}
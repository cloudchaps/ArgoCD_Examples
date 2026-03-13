{
    deployment(name, image, replicas, port)::{
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
            name: name
            labels: { app: name }
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
                            image: image,

                            ports: [
                                { containerPort: port }
                            ],

                            resources: {
                                requests: {
                                    cpu: "100m",
                                    memory: "128Mi"
                                },
                                limits: {
                                    cpu: "200m",
                                    memory: "256Mi"
                                }
                            }
                        }
                    ]
                }
            }
        }
    }
}
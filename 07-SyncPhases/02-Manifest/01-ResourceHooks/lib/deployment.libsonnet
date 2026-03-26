{
    deployment(name, namespace, image, version, replicas, port, argocdwave=null, argocdhook=null, configmapName=null)::{
        apiVersion: 'apps/v1',
        kind: 'Deployment',
        metadata: {
            name: name,
            namespace: namespace,
            labels: { app: name },
            annotations: if argocdhook != null || argocdwave != null then {
                [if argocdhook != null then 'argocd.argoproj.io/hook']: argocdhook,
                [if argocdwave != null then 'argocd.argoproj.io/sync-wave']: argocdwave,
            } else {}
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
                        } + (
                            if configmapName != null then {
                                volumeMounts: [
                                    {
                                        name: configmapName + '-volume',
                                        mountPath: '/etc/nginx/nginx.conf',
                                        subPath: 'nginx.conf',
                                    }
                                ],
                            } else {}
                        )
                    ],
                } + (
                    if configmapName != null then {
                        volumes: [
                            {
                                name: configmapName + '-volume',
                                configMap: { name: configmapName },
                            }
                        ],
                    } else {}
                )
            }
        }
    }
}
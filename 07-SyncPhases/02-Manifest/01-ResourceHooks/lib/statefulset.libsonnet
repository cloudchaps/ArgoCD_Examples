local toEnvList(envObj) =
  std.map(
    function(k)
      {
        name: k,
        value: envObj[k],
      },
    std.objectFields(envObj)
  );

{
    statefulset(name, argocdhook, argocdwave, image, version, port, envVariables={})::{
        apiVersion: 'apps/v1',
        kind: 'StatefulSet',
        metadata: {
            name: name,
            labels: { app: name },
            annotations: {
                'argocd.argoproj.io/hook': argocdhook,
                'argocd.argoproj.io/sync-wave': argocdwave
            }
        },
        spec: {
            serviceName: name,
            selector: {
                matchLabels: {
                    app: name
                }
            },
            template : {
                metadata: {
                    labels: {
                        app: name
                    }
                },
                spec: {
                    containers: [
                        {
                            name: name,
                            image: image  + ':' + version,

                            ports: [
                                { containerPort: port }
                            ],

                            env: toEnvList(envVariables)
                        }
                    ],
                }
            }
        }
    }
    
}
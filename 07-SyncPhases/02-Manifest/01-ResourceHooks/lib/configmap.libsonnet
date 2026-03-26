{
    configmap(name, namespace, dataconfig, argocdwave=null)::{
        apiVersion: 'v1',
        kind: 'ConfigMap',

        metadata: {
            name: name,
            namespace: namespace,
            labels: { app: name },
            annotations: if argocdwave != null then {
                'argocd.argoproj.io/sync-wave': argocdwave,
            } else {}
        },
        data: dataconfig
    }
}
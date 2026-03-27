{
    configmap(name, namespace, dataconfig, argocdwave=null, argocdhook=null)::{
        apiVersion: 'v1',
        kind: 'ConfigMap',

        metadata: {
            name: name,
            namespace: namespace,
            labels: { app: name },
            annotations: if argocdhook != null || argocdwave != null then {
                [if argocdhook != null then 'argocd.argoproj.io/hook']: argocdhook,
                [if argocdwave != null then 'argocd.argoproj.io/sync-wave']: argocdwave,
            } else {}
        },
        data: dataconfig
    }
}
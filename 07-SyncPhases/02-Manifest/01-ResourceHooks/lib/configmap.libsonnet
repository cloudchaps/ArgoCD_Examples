{
    configmap(name, namespace, dataconfig)::{
        apiVersion: 'v1',
        kind: 'ConfigMap',

        metadata: {
            name: name,
            namespace: namespace,
            labels: { app: name }
        },
        data: dataconfig
    }
}
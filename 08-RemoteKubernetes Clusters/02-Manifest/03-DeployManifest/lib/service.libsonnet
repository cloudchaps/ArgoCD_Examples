{
    service(name, namespace, port, selector=null)::{
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
            name: name,
            namespace: namespace,
            labels: { app: name }
        },
        spec: {
            selector: {
                app: if selector != null then selector else name
            },
            ports: [
                {
                    protocol: 'TCP',
                    port: port,
                    targetPort: port
                }
            ]
        }
    }
}
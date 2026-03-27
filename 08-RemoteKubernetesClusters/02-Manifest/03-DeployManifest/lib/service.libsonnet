{
    service(name, namespace, port, selector=null, serviceType='ClusterIP')::{
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
            name: name,
            namespace: namespace,
            labels: { app: name }
        },
        spec: {
            type: serviceType,
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
local appName = 'guestbook-ui';
local image = 'gcr.io/google-samples/gb-frontend:v5';
local replicas = 1;
local port = 80;

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      name: appName,
    },
    spec: {
      replicas: replicas,
      revisionHistoryLimit: 3,
      selector: {
        matchLabels: {
          app: appName,
        },
      },
      template: {
        metadata: {
          labels: {
            app: appName,
          },
        },
        spec: {
          containers: [
            {
              image: image,
              name: appName,
              ports: [
                {
                  containerPort: port,
                },
              ],
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      name: appName,
    },
    spec: {
      selector: {
        app: appName,
      },
      ports: [
        {
          protocol: 'TCP',
          port: port,
          targetPort: port,
        },
      ],
    },
  },
]

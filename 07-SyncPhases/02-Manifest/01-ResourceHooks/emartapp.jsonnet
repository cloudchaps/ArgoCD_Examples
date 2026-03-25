local statefulset = import './lib/statefulset.libsonnet';
local service = import './lib/service.libsonnet';
local initjob = import './lib/initdbjob.libsonnet';
local deployment = import './lib/deployment.libsonnet';
local configmap = import './lib/configmap.libsonnet';

// ── Config ────────────────────────────────────────────────────────────────────

local namespace = 'emartapp-application';

local databases = [
  {
    name: 'mongo',
    image: 'mongo',
    version: '4',
    port: 27017,
    serviceName: 'emongo',
    env: {
      MONGO_INITDB_DATABASE: 'epoc',
      MONGO_URI: "mongodb://admin:example@mongo-service:27017/epoc?authSource=admin",
    },
    initCommands: [
      'mongo', '--host', 'mongo', '--eval',
      "db=db.getSiblingDB('epoc');db.createCollection('users');print('Database epoc initialized');",
    ],
  },
  {
    name: 'mysql',
    image: 'mysql',
    version: '8.0.33',
    port: 3306,
    serviceName: 'emartdb',
    env: {
      MYSQL_ROOT_PASSWORD: 'emartdbpass',
      MYSQL_DATABASE: 'books',
    },
    initCommands: ['sh', '-c', "sleep 10 && echo 'Done!'"],
  },
];

local deployments = [
  {
    name: 'nginx-deployment',
    image: 'nginx',
    argocdwave: '0',
    argocdhook: 'PreSync'
    version: 'latest',
    replicas: 1,
    port: 80,
    serviceName: 'nginx-service',
    configmap: {
      name: 'nginx-config',
      data: {
        'nginx.conf': |||
          events {}
          http {
            upstream client {
                server client:4200;
            }
            server {
                listen 80;
                location / {
                    proxy_set_header Host $host;
                    proxy_set_header X-Real-IP $remote_addr;
                    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                    proxy_set_header X-Forwarded-Proto $scheme;
                    proxy_http_version 1.1;
                    proxy_set_header Upgrade $http_upgrade;
                    proxy_set_header Connection "upgrade";
                    proxy_pass http://client/;
                }
                location /api {
                    proxy_pass http://nodeapi-service:5000;
                }
                location /webapi {
                    proxy_pass http://javaapi-service:9000;
                }
            }
          }
        |||,
      },
    },
  },
  {
    name: 'nginx-deployment',
    image: 'nginx',
    argocdwave: '-1',
    version: 'latest',
    replicas: 1,
    port: 80,
    serviceName: 'nginx-service',
  }
];

// ── Resource generation ───────────────────────────────────────────────────────

local dbResources = std.flatMap(function(db) [
  statefulset.statefulset(
    name=db.name,
    namespace=namespace,
    argocdhook='PreSync',
    argocdwave='-1',
    image=db.image,
    version=db.version,
    port=db.port,
    envVariables=db.env,
  ),
  service.service(
    name=db.serviceName,
    namespace=namespace,
    port=db.port,
  ),
  initjob.initjob(
    name='migration-' + db.name,
    argocdhook='PreSync',
    argocdwave='-1',
    deletepolicy='BeforeHookCreation,HookSucceeded',
    image=db.image,
    version=db.version,
    commands=db.initCommands,
  ),
], databases);

local deploymentResources = std.flatMap(function(d) [
  deployment.deployment(
    name=d.name,
    namespace=namespace,
    argocdwave=d.argocdwave,
    argocdhook=d.argocdhook,
    image=d.image,
    version=d.version,
    replicas=d.replicas,
    port=d.port,
  ),
  service.service(
    name=d.serviceName,
    namespace=namespace,
    port=d.port,
  ),
] + (
  if std.objectHas(d, 'configmap') then [
    configmap.configmap(
      name=d.configmap.name,
      namespace=namespace,
      dataconfig=d.configmap.data,
    ),
  ] else []
), deployments);

// ── Output ────────────────────────────────────────────────────────────────────

dbResources + deploymentResources

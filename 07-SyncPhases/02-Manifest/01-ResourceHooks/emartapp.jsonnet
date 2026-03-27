local statefulset = import './lib/statefulset.libsonnet';
local service = import './lib/service.libsonnet';
local initjob = import './lib/initdbjob.libsonnet';
local deployment = import './lib/deployment.libsonnet';
local configmap = import './lib/configmap.libsonnet';

// ── Config ────────────────────────────────────────────────────────────────────

local namespace = 'emartapp-application';

local databases = [
  {
    name: 'emongo',
    image: 'mongo',
    version: '4',
    port: 27017,
    serviceName: 'emongo',
    env: {
      MONGO_INITDB_DATABASE: 'epoc',
    MONGO_URI: 'mongodb://admin:example@emongo:27017/epoc?authSource=admin',
    },
    initCommands: [
      'mongo', '--host', 'emongo', '--eval',
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
    argocdwave: '4',
    version: 'latest',
    replicas: 1,
    port: 80,
    serviceName: 'nginx-service',
    configmap: {
      name: 'nginx-config',
      wave: '3',
      hook: 'Sync',
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
    name: 'javaapi-service',
    image: 'darosa87/emartappjavaapi',
    argocdwave: '1',
    argocdhook: 'Sync',
    version: 'latest',
    replicas: 2,
    port: 9000,
    serviceName: 'javaapi-service'
  },
  {
    name: 'nodeapi-service',
    image: 'darosa87/emartnodeapi',
    argocdwave: '2',
    argocdhook: 'Sync',
    version: 'latest',
    replicas: 2,
    port: 5000,
    serviceName: 'nodeapi-service'
  },
  {
    name: 'client',
    image: 'darosa87/cloudchaps',
    argocdwave: '3',
    argocdhook: 'Sync',
    version: '2.0',
    replicas: 2,
    port: 4200,
    serviceName: 'client'
  }
];

// ── Resource generation ───────────────────────────────────────────────────────

local dbResources = std.flatMap(function(db) [
  statefulset.statefulset(
    name=db.name,
    namespace=namespace,
    argocdhook='Sync',
    argocdwave='0',
    image=db.image,
    version=db.version,
    port=db.port,
    envVariables=db.env,
  ),
  service.service(
    name=db.serviceName,
    namespace=namespace,
    port=db.port,
    selector=db.name,
  ),
  initjob.initjob(
    name=db.name,
    namespace=namespace,
    argocdhook='PostSync',
    argocdwave='0',
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
    image=d.image,
    version=d.version,
    replicas=d.replicas,
    port=d.port,
    argocdwave=if std.objectHas(d, 'argocdwave') then d.argocdwave else null,
    argocdhook=if std.objectHas(d, 'argocdhook') then d.argocdhook else null,
    configmapName=if std.objectHas(d, 'configmap') then d.configmap.name else null,
  ),
  service.service(
    name=d.serviceName,
    namespace=namespace,
    port=d.port,
    selector=d.name,
  ),
] + (
  if std.objectHas(d, 'configmap') then [
    configmap.configmap(
      name=d.configmap.name,
      namespace=namespace,
      dataconfig=d.configmap.data,
      argocdwave=if std.objectHas(d.configmap, 'wave') then d.configmap.wave else null,
      argocdhook=if std.objectHas(d.configmap, 'hook') then d.configmap.hook else null,
    ),
  ] else []
), deployments);

// ── Output ────────────────────────────────────────────────────────────────────

dbResources + deploymentResources

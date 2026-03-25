local statefulset = import './lib/statefulset.libsonnet';
local service = import "./lib/service.libsonnet";
local initjob = import "./lib/initdbjob.libsonnet";

[
    statefulset.statefulset(
        name="mongo",
        argocdhook="PreSync",
        argocdwave="-1",
        image="mongo",
        version="4",
        port=27017,
        envVariables={
            MONGO_INITDB_DATABASE: "epoc",
            MONGO_URI: "mongodb://admin:example@mongo-service:27017/epoc?authSource=admin"
        }
    ),
    service.service(
        name="mongo",
        port=27017
    ),
    statefulset.statefulset(
        name="mysql",
        argocdhook="PreSync",
        argocdwave="-1",
        image="mysql",
        version="8.0.33",
        port=3306,
        envVariables={
            MYSQL_ROOT_PASSWORD: "emartdbpass",
            MYSQL_DATABASE: "books"
        }
    ),
    service.service(
        name="mysql",
        port=3306
    ),
    initjob.initjob(
        name="migrationdb",
        argocdhook="PreSync",
        argocdwave="-1",
        deletepolicy="BeforeHookCreation,HookSucceeded",
        image="mysql",
        version="8.0.33",
        commands=["sh","-c","sleep 10","echo 'Done!'"]
    )
]
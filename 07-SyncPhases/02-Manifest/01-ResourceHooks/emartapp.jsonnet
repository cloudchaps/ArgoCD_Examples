local statefulset = import './lib/statefulset.libsonnet';
local service = import "./lib/service.libsonnet";

[
    statefulset.mongodb(
        name="mongo",
        argocdhook="PreSync",
        argocdwave="-1",
        image="mongo",
        version="4",
        port=27017,
        envVariables={
            MONGO_INITDB_DATABASE: "epoc"
        }
    ),
    service.mongodb(
        name="mongo",
        port=27017
    ),
    statefulset.mysql(
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
    service.mysql(
        name="mysql",
        port=3306
    )
]
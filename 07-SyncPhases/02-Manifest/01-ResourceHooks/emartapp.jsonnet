local statefulset = import './lib/statefulset.libsonnet';
local service = import "./lib/service.libsonnet";

[
  statefulset.statefulset(
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
    service.service(
        name="mongo",
        port=27017
    )
]
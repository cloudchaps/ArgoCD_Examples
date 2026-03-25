local statefulset = import './lib/statefulset.libsonnet';

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
  )
]
local deployment = import "./lib/deployment.libsonnet";
local service = import "./lib/service.libsonnet";

[
    deployment.deployment(
        name="guestbook",
        image="gcr.io/google-samples/gb-frontend:v5",
        replicas=1,
        port=80
    ),
    service.service(
        name="guestbook",
        port=80
    )
]
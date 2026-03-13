local deployment = import "./lib/deployment.jsonnet";
local service = import "./lib/service.jsonnet";

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
## node-webserver

### SETUP
1. Find the ECR registry base address for your target environment
2. `echo "<address>" > ecr_registry`

### Use
`make local-shell` puts you in the container

`make run` runs the container locally

`make push` pushes to the registry if configured

`make deploy` deploys using deployment.tmp.yaml

each command can be supplied an option tag parameter

ex. `make deploy tag=test` will build an image with that tag, push it, and deploy it

### Current functionality
- Start a webserver
- Log a heartbeat every 15 seconds
- Return GET /any/path/you/want with the supplied path after a random delay
- Log that a request was made and the response time
- Kills itself every 1-5 minutes


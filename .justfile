# https://just.systems/man/en/

[private]
@default:
    just --list --unsorted

# Run linter.
@lint:
    docker run --rm --read-only --volume=$PWD:$PWD:ro --workdir=$PWD kokuwaio/just:1.57.0
    docker run --rm --read-only --volume=$PWD:$PWD:ro --workdir=$PWD kokuwaio/shellcheck:v0.11.0
    docker run --rm --read-only --volume=$PWD:$PWD:ro --workdir=$PWD kokuwaio/hadolint:v2.14.0
    docker run --rm --read-only --volume=$PWD:$PWD:ro --workdir=$PWD kokuwaio/yamllint:v1.38.0
    docker run --rm --read-only --volume=$PWD:$PWD:rw --workdir=$PWD kokuwaio/markdownlint:0.49.0 --fix
    docker run --rm --read-only --volume=$PWD:$PWD:ro --workdir=$PWD kokuwaio/renovate-config-validator:43
    docker run --rm --read-only --volume=$PWD:$PWD:ro --workdir=$PWD woodpeckerci/woodpecker-cli:v3 lint

# Build image with local docker daemon.
@build:
    docker buildx build . --platform=linux/amd64,linux/arm64 --build-arg=NPM_CONFIG_REGISTRY

# Print image size.
size:
    #!/usr/bin/env bash
    docker run --quiet --detach --publish=5000:5000 --name=registry registry >/dev/null
    docker build . --build-arg=NPM_CONFIG_REGISTRY --quiet --tag localhost:5000/i --push >/dev/null
    printf "uncompressed: %'14d bytes (on your disk)\n" "$(docker image inspect localhost:5000/i --format='{{{{.Size}}')"
    printf "compressed:   %'14d bytes (transferred from registry to disk)\n" "$(docker manifest inspect localhost:5000/i --insecure | jq .layers[].size | tr '\n' '+' | cat - <(echo "0") | bc)"
    docker rm registry --force --volumes >/dev/null 2>&1

# Inspect image layers with `dive`.
@dive TARGET="":
    dive build . --target={{ TARGET }} --build-arg=NPM_CONFIG_REGISTRY

# Test created image.
@test:
    docker buildx build . --load --tag=kokuwaio/markdownlint:dev --build-arg=NPM_CONFIG_REGISTRY
    docker run --rm --read-only --volume=$PWD:$PWD:ro --workdir=$PWD kokuwaio/markdownlint:dev

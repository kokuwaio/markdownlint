# Markdownlint Plugin

[![pulls](https://img.shields.io/docker/pulls/kokuwaio/markdownlint)](https://hub.docker.com/repository/docker/kokuwaio/markdownlint)
[![size](https://img.shields.io/docker/image-size/kokuwaio/markdownlint)](https://hub.docker.com/repository/docker/kokuwaio/markdownlint)
[![dockerfile](https://img.shields.io/badge/source-Dockerfile%20-blue)](https://github.com/kokuwaio/markdownlint/blob/main/Dockerfile)
[![license](https://img.shields.io/github/license/kokuwaio/markdownlint)](https://github.com/kokuwaio/markdownlint/blob/main/LICENSE)
[![issues](https://img.shields.io/github/issues/kokuwaio/markdownlint)](https://github.com/kokuwaio/markdownlint/issues)

A [Woodpecker CI](https://woodpecker-ci.org) plugin for [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli) to lint markdown files.  
Also usable with Gitlab, Github or locally, see examples for usage.

## Features

- preconfigure markdownlint-cli parameters
- searches for markdown files recursive
- runnable with local docker daemon

## Example

Woodpecker:

```yaml
steps:
  markdownlint:
    image: kokuwaio/markdownlint
    depends_on: []
    settings:
      dot: true
      enable: [MD013, MD041]
    when:
      event: pull_request
      path: [.markdownlint.yaml, "**/*.md"]]
```

Gitlab:

```yaml
markdownlint:
  stage: lint
  needs: []
  image: kokuwaio/markdownlint
  variables:
    PLUGIN_DOT: true
    PLUGIN_ENABLE: MD013,MD041
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      changes: [.markdownlint.yaml, "**/*.md"]
```

CLI:

```bash
docker run --rm --volume=$(pwd):$(pwd):ro --workdir=$(pwd) kokuwaio/markdownlint --fix
```

## Settings

| Settings Name | Environment        | Default | Description                                              |
| --------------| ------------------ | ------- | -------------------------------------------------------- |
| `config-file` | PLUGIN_CONFIG_FILE | `none`  | Configuration file (JSON, JSONC, JS, YAML, or TOML)      |
| `dot`         | PLUGIN_DOT         | `true`  | Include files/folders with a dot (for example `.github`) |
| `enable`      | PLUGIN_ENABLE      | `none`  | Enable certain rules, e.g. --enable=MD013,MD041          |
| `disable`     | PLUGIN_DISABLE     | `none`  | Disable certain rules, e.g. --disable=MD013,MD041        |

## Alternatives

| Image                                                                                    | Comment                           | amd64 | arm64 |
| ---------------------------------------------------------------------------------------- | --------------------------------- |:-----:|:-----:|
| [kokuwaio/markdownlint](https://hub.docker.com/r/kokuwaio/markdownlint)                  | Woodpecker plugin                 | [![size](https://img.shields.io/docker/image-size/kokuwaio/markdownlint?arch=amd64&label=)](https://hub.docker.com/repository/docker/kokuwaio/markdownlint) | [![size](https://img.shields.io/docker/image-size/kokuwaio/markdownlint?arch=arm64&label=)](https://hub.docker.com/repository/docker/kokuwaio/markdownlint) |
| [ghcr.io/igorshubovych/markdownlint-cli](https://ghcr.io/igorshubovych/markdownlint-cli) | not a Woodpecker plugin, official | [![size](https://img.shields.io/docker/image-size/kokuwaio/markdownlint?arch=amd64&label=)](https://hub.docker.com/repository/docker/ghcr.io/igorshubovych/markdownlint-cli) | [![size](https://img.shields.io/docker/image-size/ghcr.io/igorshubovych/markdownlint-cli?arch=arm64&label=)](https://hub.docker.com/repository/docker/ghcr.io/igorshubovych/markdownlint-cli) |
| [tmknom/markdownlint](https://hub.docker.com/r/tmknom/markdownlint)                      | not a Woodpecker plugin           | [![size](https://img.shields.io/docker/image-size/tmknom/markdownlint?arch=amd64&label=)](https://hub.docker.com/repository/docker/tmknom/markdownlint) | [![size](https://img.shields.io/docker/image-size/tmknom/markdownlint?arch=arm64&label=)](https://hub.docker.com/repository/docker/tmknom/markdownlint) |
| [thegeeklab/markdownlint-cli](https://hub.docker.com/r/thegeeklab/markdownlint-cli)      | not a Woodpecker plugin           | [![size](https://img.shields.io/docker/image-size/thegeeklab/markdownlint-cli?arch=amd64&label=)](https://hub.docker.com/repository/docker/thegeeklab/markdownlint-cli) | [![size](https://img.shields.io/docker/image-size/thegeeklab/markdownlint-cli?arch=arm64&label=)](https://hub.docker.com/repository/docker/thegeeklab/markdownlint-cli) |
| [peterdavehello/markdownlint](https://hub.docker.com/r/peterdavehello/markdownlint)      | not a Woodpecker plugin           | [![size](https://img.shields.io/docker/image-size/peterdavehello/markdownlint?arch=amd64&label=)](https://hub.docker.com/repository/docker/peterdavehello/markdownlint) | [![size](https://img.shields.io/docker/image-size/peterdavehello/markdownlint?arch=arm64&label=)](https://hub.docker.com/repository/docker/peterdavehello/markdownlint) |
| [06kellyjac/markdownlint-cli](https://hub.docker.com/r/06kellyjac/markdownlint-cli)      | not a Woodpecker plugin, outdated | [![size](https://img.shields.io/docker/image-size/06kellyjac/markdownlint-cli?arch=amd64&label=)](https://hub.docker.com/repository/docker/06kellyjac/markdownlint-cli) | [![size](https://img.shields.io/docker/image-size/06kellyjac/markdownlint-cli?arch=arm64&label=)](https://hub.docker.com/repository/docker/06kellyjac/markdownlint-cli) |

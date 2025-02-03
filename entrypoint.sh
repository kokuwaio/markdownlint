#!/bin/bash
set -eu;

##
## check if any markdown file is present
##

FILES=$(find "$(pwd)" -type f -name '*.md')
if [[ ! "$FILES" ]]; then
	echo "No markdown file found!"
	exit 1
fi

##
## build command
##

COMMAND="markdownlint"
if [[ -n "${PLUGIN_CONFIG_FILE:-}" ]]; then
	COMMAND="$COMMAND --config=$PLUGIN_CONFIG_FILE"
fi
if [[ "${PLUGIN_DOT:-true}" == "true" ]]; then
	COMMAND="$COMMAND --dot"
fi
if [[ -n "${PLUGIN_ENABLE:-}" ]]; then
	COMMAND="$COMMAND --enable=$PLUGIN_ENABLE"
fi
if [[ -n "${PLUGIN_DISABLE:-}" ]]; then
	COMMAND="$COMMAND --disable=$PLUGIN_DISABLE"
fi
COMMAND="$COMMAND $(pwd)"

# custom args, e.g. docker run --rm --volume=$(pwd):$(pwd) --workdir=$(pwd) --env=CI=test kokuwaio/yamllint --format=json
if [[ -n "${1:-}" ]]; then
	COMMAND="$COMMAND $*"
fi

##
## build environment
##

echo "$COMMAND"
eval "$COMMAND"

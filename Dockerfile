##
## Download node and markdownlint
##

FROM docker.io/library/debian:13.2-slim@sha256:18764e98673c3baf1a6f8d960b5b5a1ec69092049522abac4e24a7726425b016 AS build
SHELL ["/bin/bash", "-u", "-e", "-o", "pipefail", "-c"]
WORKDIR /build
# hadolint ignore=DL3008
RUN --mount=type=cache,target=/var/lib/apt/lists,sharing=locked \
	apt-get -qq update && \
	apt-get -qq install --yes --no-install-recommends ca-certificates wget gpg gpg-agent dirmngr xz-utils && \
	rm -rf /etc/*- /var/lib/dpkg/*-old /var/lib/dpkg/status /var/cache/* /var/log/*

# fetch gpg keys for verification
# https://github.com/nodejs/node?tab=readme-ov-file#release-keys
RUN gpg --keyserver=hkps://keyserver.ubuntu.com --recv-keys \
		5BE8A3F6C8A5C01D106C0AD820B1A390B168D356 \
		DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
		CC68F5A3106FF448322E48ED27F5E38D5B0A215F \
		8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
		890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
		C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
		108F52B48DB57BB0CC439B2997B01419BD92F80A \
		A363A499291CBBC940DD62E41F10027AF002F8B0

# https://github.com/nodejs/node/tags
# https://github.com/nodejs/node#verifying-binaries
# https://nodejs.org/en/download/releases/
# https://endoflife.date/nodejs

ARG TARGETARCH
RUN --mount=type=cache,target=/build \
	[[ $TARGETARCH == amd64 ]] && export ARCH=x64; \
	[[ $TARGETARCH == arm64 ]] && export ARCH=arm64; \
	[[ -z ${ARCH:-} ]] && echo "Unknown arch: $TARGETARCH" && exit 1; \
	wget --no-hsts --quiet \
		"https://nodejs.org/download/release/v24.11.1/node-v24.11.1-linux-$ARCH.tar.xz" \
		"https://nodejs.org/download/release/v24.11.1/SHASUMS256.txt" \
		"https://nodejs.org/download/release/v24.11.1/SHASUMS256.txt.sig" && \
	sha256sum --quiet --check --strict --ignore-missing SHASUMS256.txt && \
	gpg --verify SHASUMS256.txt.sig SHASUMS256.txt && \
	tar --xz --extract --file="node-v24.11.1-linux-$ARCH.tar.xz" --exclude=bin/npx --exclude=bin/corepack --exclude=lib/node_modules/corepack --exclude=include --exclude=share --no-same-owner && \
	mv "node-v24.11.1-linux-$ARCH" /opt/node && \
	find /opt/node -type f ! -name node -a ! -name npm -a ! -name \*.js -a ! -name \*.cjs -a ! -name package.json -a ! -name vendors.json -delete && \
	find /opt/node -type d -empty -delete

ARG NPM_CONFIG_REGISTRY
RUN --mount=type=tmpfs,target=/tmp PATH="$PATH:/opt/node/bin" npm install "markdownlint-cli@0.45.0" --global --no-fund --cache=/tmp && \
	find /opt/node/lib/node_modules/markdownlint-cli -type f ! -name \*.js -a ! -name \*.cjs -a ! -name \*.mjs -a ! -name package.json -delete && \
	find /opt/node/lib/node_modules/markdownlint-cli -type d -empty -delete

##
## Final stage
##

FROM docker.io/library/debian:13.2-slim@sha256:18764e98673c3baf1a6f8d960b5b5a1ec69092049522abac4e24a7726425b016
COPY --chmod=555 --from=build /opt/node/bin/node /opt/node/bin/
COPY             --from=build /opt/node/lib/node_modules/markdownlint-cli /opt/node/lib/node_modules/markdownlint-cli
COPY --chmod=555 entrypoint.sh /usr/local/bin/entrypoint.sh
ENV PATH="$PATH:/opt/node/bin"
RUN ln -s /opt/node/lib/node_modules/markdownlint-cli/markdownlint.js /opt/node/bin/markdownlint && markdownlint --version
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
USER 1000:1000

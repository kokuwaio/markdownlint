##
## Download node and markdownlint
##

FROM docker.io/library/debian:12.11-slim@sha256:6ac2c08566499cc2415926653cf2ed7c3aedac445675a013cc09469c9e118fdd AS build
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
		C0D6248439F1D5604AAFFB4021D900FFDB233756 \
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

RUN --mount=type=cache,target=/build \
	ARCH=$(dpkg --print-architecture); \
	[[ $ARCH == amd64 ]] && export SUFFIX=x64; \
	[[ $ARCH == arm64 ]] && export SUFFIX=arm64; \
	[[ -z ${SUFFIX:-} ]] && echo "Unknown arch: $ARCH" && exit 1; \
	wget --no-hsts --quiet \
		"https://nodejs.org/download/release/v22.17.1/node-v22.17.1-linux-$SUFFIX.tar.xz" \
		"https://nodejs.org/download/release/v22.17.1/SHASUMS256.txt" \
		"https://nodejs.org/download/release/v22.17.1/SHASUMS256.txt.sig" && \
	sha256sum --quiet --check --strict --ignore-missing SHASUMS256.txt && \
	gpg --verify SHASUMS256.txt.sig SHASUMS256.txt && \
	tar --xz --extract --file="node-v22.17.1-linux-$SUFFIX.tar.xz" --exclude=bin/npx --exclude=bin/corepack --exclude=lib/node_modules/corepack --exclude=include --exclude=share --no-same-owner && \
	mv "node-v22.17.1-linux-$SUFFIX" /opt/node

ARG NPM_CONFIG_REGISTRY
RUN --mount=type=tmpfs,target=/tmp PATH="$PATH:/opt/node/bin" npm install "markdownlint-cli@0.45.0" --global --no-fund --cache=/tmp

##
## Final stage
##

FROM docker.io/library/debian:12.11-slim@sha256:6ac2c08566499cc2415926653cf2ed7c3aedac445675a013cc09469c9e118fdd
COPY --chmod=555 --from=build /opt/node/bin/node /opt/node/bin/
COPY             --from=build /opt/node/lib/node_modules/markdownlint-cli /opt/node/lib/node_modules/markdownlint-cli
COPY --chmod=555 entrypoint.sh /usr/local/bin/entrypoint.sh
ENV PATH="$PATH:/opt/node/bin"
RUN ln -s /opt/node/lib/node_modules/markdownlint-cli/markdownlint.js /opt/node/bin/markdownlint && markdownlint --version
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
USER 1000:1000

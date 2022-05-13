FROM --platform=$BUILDPLATFORM debian:bullseye-slim as build

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG REPOSITORY_OWNER=decke/smtprelay
ARG APP_VERSION=v1.8.0

SHELL ["/bin/bash", "-c"]

RUN set -eux; \
    apt-get update ; \
    apt-get install -y \
      ca-certificates \
      coreutils \
      curl \
      libcap2-bin  \
      netcat-openbsd ; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/* ; \
    RELEASE_URL="https://github.com/${REPOSITORY_OWNER}/releases/download/${APP_VERSION}/smtprelay-${APP_VERSION}-${TARGETPLATFORM/\//-}.tar.gz" ; \
    RELEASE_MD5_URL="https://github.com/${REPOSITORY_OWNER}/releases/download/${APP_VERSION}/smtprelay-${APP_VERSION}-${TARGETPLATFORM/\//-}.tar.gz.md5" ; \
    curl  --fail --silent --location --output  /tmp/smtprelay.tar.gz "${RELEASE_URL}" ; \
    curl  --fail  --silent --location --output  /tmp/smtprelay.tar.gz.md5  "${RELEASE_MD5_URL}" ; \
    echo "$(cat /tmp/smtprelay.tar.gz.md5) /tmp/smtprelay.tar.gz" | md5sum -c ; \
    tar -xvf /tmp/smtprelay.tar.gz -C / ; \
    setcap 'cap_net_bind_service=+ep' /smtprelay

FROM --platform=$BUILDPLATFORM debian:bullseye-slim

RUN set -eux; \
    apt-get update ; \
    apt-get install -y \
      ca-certificates \
      netcat-openbsd ; \
    apt-get clean ; \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /LICENSE /LICENSE
COPY --from=build /smtprelay /smtprelay

ENTRYPOINT ["/smtprelay"]
USER "1000:1000"

HEALTHCHECK  \
    CMD echo -e "HELO hello\nQUIT" | nc -w 5 localhost 25 || exit 1

CMD ["--help"]

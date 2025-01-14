# :: Util
  FROM alpine AS util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone -b stable https://github.com/11notes/docker-util.git;

# :: Build / ente
  FROM golang:1.23.4-alpine3.21 AS ente
  ENV BUILD_DIR=/go/ente/server

  RUN set -ex; \
    apk add --update --no-cache \
      gcc \
      musl-dev \
      git \
      build-base \
      pkgconfig \
      libsodium-dev; \
    git clone https://github.com/ente-io/ente.git;

  RUN set -ex; \
    cd ${BUILD_DIR}; \
    mkdir -p /opt/ente; \
    go build -o /opt/ente/museum cmd/museum/main.go; \
    mv ${BUILD_DIR}/configurations /opt/ente; \
    mv ${BUILD_DIR}/migrations /opt/ente; \
    mv ${BUILD_DIR}/mail-templates /opt/ente;

# :: Header
  FROM 11notes/alpine:stable

  # :: arguments
    ARG TARGETARCH
    ARG APP_IMAGE
    ARG APP_NAME
    ARG APP_VERSION
    ARG APP_ROOT

  # :: environment
    ENV APP_IMAGE=${APP_IMAGE}
    ENV APP_NAME=${APP_NAME}
    ENV APP_VERSION=${APP_VERSION}
    ENV APP_ROOT=${APP_ROOT}

    ENV POSTGRES_HOST="postgres"
    ENV POSTGRES_PORT=5432
    ENV POSTGRES_DATABASE="postgres"
    ENV POSTGRES_USER="postgres"
    
    ENV GIN_MODE=release
    ENV ENTE_CONFIG_FILE="/ente/etc/config.yaml"

  # :: multi-stage
    COPY --from=util /docker-util/src /usr/local/bin
    COPY --from=ente /opt/ente/ /opt/ente

# :: Run
  USER root

  # :: prepare image
    RUN set -ex; \
      mkdir -p ${APP_ROOT}/etc;

  # :: install application
    RUN set -ex; \
      apk add --update --no-cache \
        libsodium-dev; \
      rm /opt/ente/configurations/local.yaml; \
      ln -s /ente/etc/config.yaml /opt/ente/configurations/local.yaml;

  # :: copy filesystem changes and set correct permissions
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin; \
      chown -R 1000:1000 \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD curl -X GET -kILs --fail http://localhost:8080/ping || exit 1

# :: Start
  USER docker
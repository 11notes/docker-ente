# :: QEMU
FROM multiarch/qemu-user-static:x86_64-aarch64 as qemu

# :: Util
  FROM alpine as util

  RUN set -ex; \
    apk add --no-cache \
      git; \
    git clone -b stable https://github.com/11notes/docker-util.git;

# :: Build
  FROM --platform=linux/arm64 golang:1.23.4-alpine3.21 as build
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  ENV BUILD_DIR=/go/ente/server

  USER root

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
  FROM --platform=linux/arm64 11notes/alpine:stable
  COPY --from=qemu /usr/bin/qemu-aarch64-static /usr/bin
  COPY --from=util /docker-util/src /usr/local/bin
  COPY --from=build /opt/ente/ /opt/ente
  ENV APP_VERSION=4.2.3
  ENV APP_NAME="ente"
  ENV APP_ROOT=/ente
  ENV POSTGRES_HOST="postgres"
  ENV POSTGRES_PORT=5432
  ENV POSTGRES_DATABASE="postgres"
  ENV POSTGRES_USER="postgres"
  ENV GIN_MODE=release
  ENV ENTE_CONFIG_FILE="/ente/etc/config.yaml"

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

  # :: copy root filesystem changes and add execution rights to init scripts
    COPY ./rootfs /
    RUN set -ex; \
      chmod +x -R /usr/local/bin

  # :: change home path for existing user and set correct permission
    RUN set -ex; \
      usermod -d ${APP_ROOT} docker; \
      chown -R 1000:1000 \
        ${APP_ROOT};

# :: Volumes
  VOLUME ["${APP_ROOT}/etc"]

# :: Monitor
  HEALTHCHECK --interval=5s --timeout=2s CMD curl -X GET -kILs --fail http://localhost:8080/ping || exit 1

# :: Start
  USER docker
# ╔═════════════════════════════════════════════════════╗
# ║                       SETUP                         ║
# ╚═════════════════════════════════════════════════════╝
# GLOBAL
  ARG APP_UID= \
      APP_GID= \
      APP_GO_VERSION=0.0

# :: FOREIGN IMAGES
  FROM 11notes/distroless AS distroless
  FROM 11notes/distroless:localhealth AS distroless-localhealth
  FROM 11notes/util AS util

# ╔═════════════════════════════════════════════════════╗
# ║                       BUILD                         ║
# ╚═════════════════════════════════════════════════════╝
# :: ENTE (SERVER)
  FROM 11notes/go:${APP_GO_VERSION} AS build
  COPY --from=util / /
  ARG APP_VERSION_BUILD \
      BUILD_ROOT=/go/ente/server \
      BUILD_BIN=/museum

  RUN set -ex; \
    eleven git slice ente-io/ente.git ${APP_VERSION_BUILD} server;

  # fix no logs on health check
  COPY ./build/go/ente /go/ente

  RUN set -ex; \
    # fix configuration path
    cd ${BUILD_ROOT}; \
    sed -i 's|viper.SetConfigFile("configurations/" + environment + ".yaml")|viper.SetConfigFile("/ente/etc/default.yml")|' ./pkg/utils/config/config.go;

  RUN set -ex; \
    cd ${BUILD_ROOT}; \
    eleven go build ${BUILD_BIN} ./cmd/museum/main.go;

  RUN set -ex; \
    eleven distroless ${BUILD_BIN};

  RUN set -ex; \
    mkdir -p /distroless/opt/ente; \
    mv /distroless/usr/local/bin/${BUILD_BIN} /distroless/opt/ente; \
    mv ${BUILD_ROOT}/configurations /distroless/opt/ente; \
    mv ${BUILD_ROOT}/migrations /distroless/opt/ente; \
    mv ${BUILD_ROOT}/mail-templates /distroless/opt/ente; \
    mv ${BUILD_ROOT}/web-templates /distroless/opt/ente; 

# :: ENTRYPOINT
  FROM 11notes/go:${APP_GO_VERSION} AS entrypoint
  COPY ./build /

  RUN set -ex; \
    cd /go/entrypoint; \
    eleven go build entrypoint main.go; \
    eleven distroless entrypoint;


# :: FILE SYSTEM
  FROM alpine AS file-system
  COPY --from=util / /
  ARG APP_ROOT

  RUN set -ex; \
    eleven mkdir /distroless${APP_ROOT}/{etc};


# ╔═════════════════════════════════════════════════════╗
# ║                       IMAGE                         ║
# ╚═════════════════════════════════════════════════════╝
# :: HEADER
  FROM scratch

  # :: default arguments
    ARG TARGETPLATFORM \
        TARGETOS \
        TARGETARCH \
        TARGETVARIANT \
        APP_IMAGE \
        APP_NAME \
        APP_VERSION \
        APP_ROOT \
        APP_UID \
        APP_GID \
        APP_NO_CACHE

  # :: default environment
    ENV APP_IMAGE=${APP_IMAGE} \
        APP_NAME=${APP_NAME} \
        APP_VERSION=${APP_VERSION} \
        APP_ROOT=${APP_ROOT}

  # :: app specific environment
    ENV GIN_MODE="release" \
        MINIO_ACCESS_KEY="admin" \
        MINIO_BUCKET="ente" \
        POSTGRES_HOST="postgres" \
        POSTGRES_PORT=5432 \
        POSTGRES_DATABASE="postgres" \
        POSTGRES_USER="postgres"

  # :: multi-stage
    COPY --from=distroless / /
    COPY --from=distroless-localhealth / /
    COPY --from=build /distroless/ /
    COPY --from=entrypoint /distroless/ /
    COPY --from=file-system --chown=${APP_UID}:${APP_GID} /distroless/ /
    COPY --chown=${APP_UID}:${APP_GID} ./rootfs/ /

# :: PERSISTENT DATA
  VOLUME ["${APP_ROOT}/etc"]

# :: MONITORING
  HEALTHCHECK --interval=5s --timeout=2s --start-period=5s \
    CMD ["/usr/local/bin/localhealth", "-I", "http://127.0.0.1:8080/ping"]

# :: EXECUTE
  USER ${APP_UID}:${APP_GID}
  ENTRYPOINT ["/usr/local/bin/entrypoint"]
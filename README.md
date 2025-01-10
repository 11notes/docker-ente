![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ Alpine - ente
[<img src="https://img.shields.io/badge/github-source-blue?logo=github">](https://github.com/11notes/docker-ente/tree/4.2.3) ![size](https://img.shields.io/docker/image-size/11notes/ente/4.2.3?color=0eb305) ![version](https://img.shields.io/docker/v/11notes/ente/4.2.3?color=eb7a09) ![pulls](https://img.shields.io/docker/pulls/11notes/ente?color=2b75d6)

# SYNOPSIS
**What can I do with this?** Run the ente server for your authenticator or photos app, easy and secure. You can use the compose to start your own server, the image will create all the needed keys and hashes or you can simply provide your own variables or config.yaml, whatever you prefer. For registration you can use the OTT option to avoid having to setup an SMTP server. Simply add your domain “@domain.com” to the ```${OTT_DOMAIN}``` and set the static PIN via ```${OTT_PIN}``` so every account can verify with that PIN.

# VOLUMES
* **/ente/etc** - Directory of config.yaml

# CONFIG (EXAMPLE)
/ente/.default/config.yaml
```yaml
db:
  host: "${POSTGRES_HOST}"
  port: "${POSTGRES_PORT}"
  name: "${POSTGRES_DATABASE}"
  user: "${POSTGRES_USER}"
  password: "${POSTGRES_PASSWORD}"
  sslmode: disable
s3:
  are_local_buckets: true
  minio:
    key: "${MINIO_ACCESS_KEY}"
    secret: "${MINIO_SECRET_KEY}"
    endpoint: "minio:3200"
    bucket: "default"
log-file: ""
http:
apps:
  public-albums:
  cast:
  accounts:
  family:
key:
  encryption: "${KEY_ENCRYPTION}"
  hash: "${KEY_HASH}"
jwt:
  secret: "${JWT_SECRET}"
smtp:
  host: "${SMTP_HOST}"
  port: "${SMTP_PORT}"
  username: "${SMTP_USER}"
  password: "${SMTP_PASSWORD}"
  email: "${SMTP_EMAIL}"
transmail:
  key:
apple:
  shared-secret:
stripe:
  us:
    key:
    webhook-secret:
  in:
    key:
    webhook-secret:
  whitelisted-redirect-urls: []
  path:
    success: "?status=success&session_id={CHECKOUT_SESSION_ID}"
    cancel: "?status=fail&reason=canceled"
webauthn:
  rpid: localhost
  rporigins:
    - "http://localhost:3001"
discord:
  bot:
    cha-ching:
      token:
      channel:
    mona-lisa:
      token:
      channel:
zoho:
  client-id:
  client-secret:
  refresh-token:
  list-key:
  topic-ids:
listmonk:
  server-url:
  username:
  password:
  list-ids:
internal:
  silent: false
  health-check-url:
  admins: []
  admin:
  disable-registration: false
  hardcoded-ott:
    local-domain-suffix: "${OTT_DOMAIN}"
    local-domain-value: ${OTT_PIN}
replication:
  enabled: false
  worker-url:
  worker-count: 6
  tmp-storage: tmp/replication
jobs:
  cron:
    skip: false
  remove-unreported-objects:
    worker-count: 1
  clear-orphan-objects:
    enabled: false
    prefix: ""
```

# COMPOSE
```yaml
name: "ente"
services:
  ente:
    image: "11notes/ente:4.2.3"
    container_name: "ente"
    depends_on:
      postgres:
        condition: "service_healthy"
        restart: true
    environment:
      TZ: "Europe/Zurich"
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
      OTT_DOMAIN: "@domain.com"
      OTT_PIN: 123456
    volumes:
      - "etc:/ente/etc"
    ports:
      - "8080:8080/tcp"
    networks:
      frontend:
      backend:
    restart: "always"

  postgres:
    image: "11notes/postgres:16"
    container_name: "ente.postgres"
    environment:
      TZ: "Europe/Zurich"
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - "postgres.etc:/postgres/etc"
      - "postgres.var:/postgres/var"
      - "postgres.backup:/postgres/backup"
    networks:
      backend:
    restart: "always"

  minio:
    image: "minio/minio"
    container_name: "ente.minio"
    environment:
      TZ: "Europe/Zurich"
      MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
      MINIO_ROOT_USER: "root"
      MINIO_ROOT_PASSWORD: "minio1234"
    command: 
      - "server"
      - "/data"
      - "--console-address"
      - ":9001"
    volumes:
      - "minio.etc:/root/.minio"
      - "minio.var:/data"
    networks:
      backend:
    restart: "always"

  mc:
    image: "minio/mc"
    container_name: "ente.mc"
    depends_on:
      - "minio"
    environment:
      TZ: "Europe/Zurich"
      MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
      MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
    entrypoint: >
      /bin/sh -c "
      /usr/bin/mc config host add ente http://minio:9000 ${MINIO_ACCESS_KEY} ${MINIO_SECRET_KEY};
      /usr/bin/mc mb --ignore-existing ente/default;
      exit 0;"
    volumes:
      - "mc.etc:/root/.mc"
    networks:
      backend:
volumes:
  etc:
  postgres.etc:
  postgres.var:
  postgres.backup:
  minio.etc:
  minio.var:
  mc.etc:
networks:
  frontend:
  backend:
    internal: true
```

# DEFAULT SETTINGS
# DEFAULT SETTINGS
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user docker |
| `uid` | 1000 | user id 1000 |
| `gid` | 1000 | group id 1000 |
| `home` | /ente | home directory of user docker |

# ENVIRONMENT
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Show debug information | |
| `POSTGRES_HOST` | postgres host | postgres |
| `POSTGRES_PORT` | postgres port | 5432 |
| `POSTGRES_DATABASE` | postgres database | postgres |
| `POSTGRES_USER` | postgres user | postgres |
| `POSTGRES_PASSWORD` | postgres password | |
| `MINIO_ACCESS_KEY` | minio access key | |
| `MINIO_SECRET_KEY` | minio secret key | |
| `KEY_ENCRYPTION` | ente encryption key | dynamically generated |
| `KEY_HASH` | ente encryption hash | dynamically generated |
| `JWT_SECRET` | ente jwt secret | dynamically generated |
| `SMTP_HOST` | smtp server | |
| `SMTP_PORT` | smtp server port | |
| `SMTP_USER` | smtp server authentication user | |
| `SMTP_PASSWORD` | smtp server authentication password | |
| `SMTP_EMAIL` | smtp email address | |
| `OTT_DOMAIN` | domain used for static OTT PIN for all accounts ending in this domain | |
| `OTT_PIN` | static OTT PIN for all accounts registering | |

# SOURCE
* [11notes/ente:4.2.3](https://github.com/11notes/docker-ente/tree/4.2.3)

# PARENT IMAGE
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH
* [ente](https://github.com/ente-io/ente/)
* [alpine](https://alpinelinux.org)

# TIPS
* Use a reverse proxy like Traefik, Nginx to terminate TLS with a valid certificate
* Use Let’s Encrypt certificates to protect your SSL endpoints

# ElevenNotes<sup>™️</sup>
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [RELEASE.md](https://github.com/11notes/docker-ente/blob/4.2.3/RELEASE.md) for breaking changes. You can find all my repositories on [github](https://github.com/11notes).
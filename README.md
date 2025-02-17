![Banner](https://github.com/11notes/defaults/blob/main/static/img/banner.png?raw=true)

# 🏔️ ente on Alpine
[<img src="https://img.shields.io/badge/github-source-blue?logo=github&color=040308">](https://github.com/11notes/docker-ente)![size](https://img.shields.io/docker/image-size/11notes/ente/717dc09?color=0eb305)![version](https://img.shields.io/docker/v/11notes/ente/717dc09?color=eb7a09)![pulls](https://img.shields.io/docker/pulls/11notes/ente?color=2b75d6)[<img src="https://img.shields.io/github/issues/11notes/docker-ente?color=7842f5">](https://github.com/11notes/docker-ente/issues)

**Run ente backend server on Alpine for your photos or authenticator app**

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [717dc09](https://hub.docker.com/r/11notes/ente/tags?name=717dc09)
* [latest](https://hub.docker.com/r/11notes/ente/tags?name=latest)
* [717dc09-unraid](https://hub.docker.com/r/11notes/ente/tags?name=717dc09-unraid)
* [latest-unraid](https://hub.docker.com/r/11notes/ente/tags?name=latest-unraid)


# SYNOPSIS 📖
**What can I do with this?** Run the ente server for your authenticator or photos app, easy and secure. You can use the compose to start your own server, the image will create all the needed keys and hashes or you can simply provide your own variables or config.yaml, whatever you prefer. For registration you can use the OTT option to avoid having to setup an SMTP server. Simply add your domain “@domain.com” to the ```${OTT_DOMAIN}``` and set the static PIN via ```${OTT_PIN}``` so every account can verify with that PIN.

![Ente Auth](https://github.com/11notes/docker-ente/blob/master/img/auth.png?raw=true)

# Patched CVEs 🦟
Unlike other popular image providers, this image contains individual CVE fixes to create a clean container image even if the developers of the original app simply forgot to do that. Why not add a PR with these fixes? Well, many developers ignore PR for CVE fixes and don’t run any code security scanners against their repos. Some simply don’t care.

| ID | Severity | Object | Fix | Source |
| --- | --- | --- | --- | --- |
| CVE-2024-45337 | critical | golang.org/x/crypto | v0.31.0 | [Github](https://github.com/advisories/GHSA-v778-237x-gjrc) |
| CVE-2024-45338 | high | golang.org/x/net | v0.33.0 | [Github](https://github.com/advisories/GHSA-w32m-9786-jp63) |
| CVE-2024-24786 | medium | google.golang.org/protobuf | v1.33.0 | [Github](https://github.com/advisories/GHSA-8r3f-844c-mc37) |



# COMPOSE ✂️
```yaml
name: "ente"
services:
  ente:
    image: "11notes/ente:717dc09"
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

# DEFAULT CONFIG 📑
/.default/config.yaml
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

# UNRAID VERSION 🟠
This image supports unraid by default. Simply add **-unraid** to any tag and the image will run as 99:100 instead of 1000:1000 causing no issues on unraid. Enjoy.


# DEFAULT SETTINGS 🗃️
| Parameter | Value | Description |
| --- | --- | --- |
| `user` | docker | user name |
| `uid` | 1000 | [user identifier](https://en.wikipedia.org/wiki/User_identifier) |
| `gid` | 1000 | [group identifier](https://en.wikipedia.org/wiki/Group_identifier) |
| `home` | /ente | home directory of user docker |

# ENVIRONMENT 📝
| Parameter | Value | Default |
| --- | --- | --- |
| `TZ` | [Time Zone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) | |
| `DEBUG` | Will activate debug option for container image and app (if available) | |
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

# SOURCE 💾
* [11notes/ente](https://github.com/11notes/docker-ente)

# PARENT IMAGE 🏛️
* [11notes/alpine:stable](https://hub.docker.com/r/11notes/alpine)

# BUILT WITH 🧰
* [ente](https://github.com/ente-io/ente/tree/main/server)
* [alpine](https://alpinelinux.org)

# GENERAL TIPS 📌
* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

    
# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-ente/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-ente/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-ente/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).
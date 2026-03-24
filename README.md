![banner](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/banner/README.png)

# ENTE
![size](https://img.shields.io/badge/image_size-24MB-green?color=%2338ad2d)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![pulls](https://img.shields.io/docker/pulls/11notes/ente?color=2b75d6)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)[<img src="https://img.shields.io/github/issues/11notes/docker-ente?color=7842f5">](https://github.com/11notes/docker-ente/issues)![5px](https://raw.githubusercontent.com/11notes/static/refs/heads/master/img/markdown/transparent5x2px.png)![swiss_made](https://img.shields.io/badge/Swiss_Made-FFFFFF?labelColor=FF0000&logo=data:image/svg%2bxml;base64,PHN2ZyB2ZXJzaW9uPSIxIiB3aWR0aD0iNTEyIiBoZWlnaHQ9IjUxMiIgdmlld0JveD0iMCAwIDMyIDMyIiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogIDxyZWN0IHdpZHRoPSIzMiIgaGVpZ2h0PSIzMiIgZmlsbD0idHJhbnNwYXJlbnQiLz4KICA8cGF0aCBkPSJtMTMgNmg2djdoN3Y2aC03djdoLTZ2LTdoLTd2LTZoN3oiIGZpbGw9IiNmZmYiLz4KPC9zdmc+)

run Ente rootless and distroless

# INTRODUCTION 📢

[Ente](https://github.com/ente-io/ente) (created by [ente-io](https://github.com/ente-io)) is a service that provides a fully open source, end-to-end encrypted platform for you to store your data in the cloud without needing to trust the service provider. On top of this platform, we have built three apps so far: Ente Photos (an alternative to Apple and Google Photos), Ente Locker (a safe space for your most important documents and credentials), and Ente Auth (a 2FA alternative to the deprecated Authy).

![ENTEAUTH](https://github.com/11notes/docker-ente/blob/master/img/EnteAuth.png?raw=true)

# SYNOPSIS 📖
**What can I do with this?** This image will run Ente [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md), for maximum security and performance. For all info's about the config file please read the [documentation]( https://github.com/ente-io/ente/blob/main/server/configurations/local.yaml). Works with Photos, Auth and Locker.

# UNIQUE VALUE PROPOSITION 💶
**Why should I run this image and not the other image(s) that already exist?** Good question! Because ...

> [!IMPORTANT]
>* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
>* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
>* ... this image is auto updated to the latest version via CI/CD
>* ... this image has a health check
>* ... this image runs read-only
>* ... this image is automatically scanned for CVEs before and after publishing
>* ... this image is created via a secure and pinned CI/CD process
>* ... this image is very small
>* ... this image supports [inline configs](https://github.com/11notes/RTFM/blob/master/linux/container/image/11notes/inline-config.md)

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

# COMPARISON 🏁
Below you find a comparison between this image and the most used or original one.

| **image** | **size on disk** | **init default as** | **[distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)** | supported architectures
| ---: | ---: | :---: | :---: | :---: |
| 11notes/ente | 24MB | 1000:1000 | ✅ | amd64, arm64 |
| ente-io/server | 53MB | 0:0 | ❌ | amd64, arm64 |

# DEFAULT CONFIG 📑
```yaml
file ./rootfs/prometheus/etc/default.yml not found!
```

# VOLUMES 📁
* **/ente/etc** - Directory of your config

# COMPOSE ✂️
```yaml
name: "ente"

x-lockdown: &lockdown
  # prevents write access to the image itself
  read_only: true
  # prevents any process within the container to gain more privileges
  security_opt:
    - "no-new-privileges=true"

services:
  server:
    depends_on:
      postgres:
        condition: "service_healthy"
        restart: true
      minio:
        condition: "service_healthy"
        restart: true
      mc:
        condition: service_completed_successfully
    image: "11notes/ente:2026.03.23"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
      POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"
      MINIO_ROOT_PASSWORD: "${MINIO_ROOT_PASSWORD}"
    volumes:
      - "server.etc:/ente/etc"
    ports:
      - "3000:8080/tcp"
    networks:
      frontend:
      backend:
    restart: "always"

  postgres:
    # for more information about this image checkout:
    # https://github.com/11notes/docker-postgres
    image: "11notes/postgres:18"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
      POSTGRES_PASSWORD: "${POSTGRES_PASSWORD}"
    networks:
      backend:
    volumes:
      - "postgres.etc:/postgres/etc"
      - "postgres.var:/postgres/var"
      - "postgres.backup:/postgres/backup"
    tmpfs:
      - "/postgres/run:uid=1000,gid=1000"
      - "/postgres/log:uid=1000,gid=1000"
    restart: "always"

  minio:
    # for more information about this image checkout:
    # https://github.com/11notes/docker-minio
    image: "11notes/minio:2025.10.15"
    hostname: "minio"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
      MINIO_ROOT_PASSWORD: "${MINIO_ROOT_PASSWORD}"
    command: "/mnt"
    ports:
      - "3000:9001/tcp"
      - "9000:9000/tcp"
    volumes:
      - "minio.var:/mnt"
    networks:
      backend:
    restart: "always"

  mc:
    # for more information about this image checkout:
    # https://github.com/11notes/docker-mc
    depends_on:
      minio:
        condition: "service_healthy"
        restart: true
    image: "11notes/mc:2025.08.13"
    <<: *lockdown
    environment:
      TZ: "Europe/Zurich"
      MC_MINIO_URL: "https://minio:9000"
      MC_MINIO_ROOT_PASSWORD: "${MINIO_ROOT_PASSWORD}"
      MC_INSECURE: true
    command:
      - mb --ignore-existing minio/ente
    volumes:
      - "mc.etc:/mc/etc"
    networks:
      backend:
    restart: "no"

volumes:
  server.etc:
  postgres.etc:
  postgres.var:
  postgres.backup:
  minio.var:
  mc.etc:

networks:
  frontend:
  backend:
    internal: true
```
To find out how you can change the default UID/GID of this container image, consult the [RTFM](https://github.com/11notes/RTFM/blob/main/linux/container/image/11notes/how-to.changeUIDGID.md#change-uidgid-the-correct-way).

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
| `ENTE_CONFIG` *(optional)* | Will overwrite the default config with the value of this variable if set ([inline config](https://github.com/11notes/RTFM/blob/master/linux/container/image/11notes/inline-config.md)) | |

# MAIN TAGS 🏷️
These are the main tags for the image. There is also a tag for each commit and its shorthand sha256 value.

* [2026.03.23](https://hub.docker.com/r/11notes/ente/tags?name=2026.03.23)
* [2026.03.23-unraid](https://hub.docker.com/r/11notes/ente/tags?name=2026.03.23-unraid)
* [2026.03.23-nobody](https://hub.docker.com/r/11notes/ente/tags?name=2026.03.23-nobody)

### There is no latest tag, what am I supposed to do about updates?
It is my opinion that the ```:latest``` tag is a bad habbit and should not be used at all. Many developers introduce **breaking changes** in new releases. This would messed up everything for people who use ```:latest```. If you don’t want to change the tag to the latest [semver](https://semver.org/), simply use the short versions of [semver](https://semver.org/). Instead of using ```:2026.03.23``` you can use ```:2026``` or ```:2026.03```. Since on each new version these tags are updated to the latest version of the software, using them is identical to using ```:latest``` but at least fixed to a major or minor version. Which in theory should not introduce breaking changes.

If you still insist on having the bleeding edge release of this app, simply use the ```:rolling``` tag, but be warned! You will get the latest version of the app instantly, regardless of breaking changes or security issues or what so ever. You do this at your own risk!

# REGISTRIES ☁️
```
docker pull 11notes/ente:2026.03.23
docker pull ghcr.io/11notes/ente:2026.03.23
docker pull quay.io/11notes/ente:2026.03.23
```

# UNRAID VERSION 🟠
This image supports unraid by default. Simply add **-unraid** to any tag and the image will run as 99:100 instead of 1000:1000.

# NOBODY VERSION 👻
This image supports nobody by default. Simply add **-nobody** to any tag and the image will run as 65534:65534 instead of 1000:1000.

# SOURCE 💾
* [11notes/ente](https://github.com/11notes/docker-ente)

# PARENT IMAGE 🏛️
> [!IMPORTANT]
>This image is not based on another image but uses [scratch](https://hub.docker.com/_/scratch) as the starting layer.
>The image consists of the following distroless layers that were added:
>* [11notes/distroless](https://github.com/11notes/docker-distroless/blob/master/arch.dockerfile) - contains users, timezones and Root CA certificates, nothing else
>* [11notes/distroless:localhealth](https://github.com/11notes/docker-distroless/blob/master/localhealth.dockerfile) - app to execute HTTP requests only on 127.0.0.1

# BUILT WITH 🧰
* [ente](https://github.com/ente-io/ente)

# GENERAL TIPS 📌
> [!TIP]
>* Use a reverse proxy like Traefik, Nginx, HAproxy to terminate TLS and to protect your endpoints
>* Use Let’s Encrypt DNS-01 challenge to obtain valid SSL certificates for your services

# ElevenNotes™️
This image is provided to you at your own risk. Always make backups before updating an image to a different version. Check the [releases](https://github.com/11notes/docker-ente/releases) for breaking changes. If you have any problems with using this image simply raise an [issue](https://github.com/11notes/docker-ente/issues), thanks. If you have a question or inputs please create a new [discussion](https://github.com/11notes/docker-ente/discussions) instead of an issue. You can find all my other repositories on [github](https://github.com/11notes?tab=repositories).

*created 24.03.2026, 01:45:43 (CET)*
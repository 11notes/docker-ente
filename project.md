${{ image: EnteAuth.png }}

${{ content_synopsis }} This image will run Ente [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) and [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md), for maximum security and performance. For all info's about the config file please read the [documentation]( https://github.com/ente-io/ente/blob/main/server/configurations/local.yaml). Works with Photos, Auth and Locker.

${{ content_uvp }} Good question! Because ...

${{ github:> [!IMPORTANT] }}
${{ github:> }}* ... this image runs [rootless](https://github.com/11notes/RTFM/blob/main/linux/container/image/rootless.md) as 1000:1000
${{ github:> }}* ... this image has no shell since it is [distroless](https://github.com/11notes/RTFM/blob/main/linux/container/image/distroless.md)
${{ github:> }}* ... this image is auto updated to the latest version via CI/CD (semver based on commit date of /server path, check [cron.yml](https://github.com/11notes/docker-ente/blob/master/.github/workflows/cron.yml) for more info)
${{ github:> }}* ... this image has a health check
${{ github:> }}* ... this image runs read-only
${{ github:> }}* ... this image is automatically scanned for CVEs before and after publishing
${{ github:> }}* ... this image is created via a secure and pinned CI/CD process
${{ github:> }}* ... this image is very small
${{ github:> }}* ... this image supports [inline configs](https://github.com/11notes/RTFM/blob/master/linux/container/image/11notes/inline-config.md)

If you value security, simplicity and optimizations to the extreme, then this image might be for you.

${{ content_comparison }}

${{ title_config }}
```yaml
${{ include: ./rootfs/ente/etc/default.yml }}
```

${{ title_volumes }}
* **${{ json_root }}/etc** - Directory of your config

${{ content_compose }}

${{ content_defaults }}

${{ content_environment }}
| `ENTE_CONFIG` *(optional)* | Will overwrite the default config with the value of this variable if set ([inline config](https://github.com/11notes/RTFM/blob/master/linux/container/image/11notes/inline-config.md)) | |

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}
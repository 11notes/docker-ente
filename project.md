${{ image: EnteAuth.png }}

${{ content_synopsis }} Run the ente server for your authenticator or photos app, easy and secure. You can use the compose to start your own server, the image will create all the needed keys and hashes or you can simply provide your own variables or config.yaml, whatever you prefer. For registration you can use the OTT option to avoid having to setup an SMTP server. Simply add your domain “@domain.com” to the ```${OTT_DOMAIN}``` and set the static PIN via ```${OTT_PIN}``` so every account can verify with that PIN.

${{ content_compose }}

${{ title_config }}
${{ json_root }}/.default/config.yaml
```yaml
${{ include: /rootfs/ente/.default/config.yaml }}
```

${{ content_defaults }}

${{ content_environment }}
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

${{ content_source }}

${{ content_parent }}

${{ content_built }}

${{ content_tips }}
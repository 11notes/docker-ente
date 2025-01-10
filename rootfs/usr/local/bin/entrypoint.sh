#!/bin/ash
  if [ -z "${1}" ]; then
    if [ ! -z "${ENTE_CONFIG_FILE}" ]; then
      elevenLogJSON info "setting default config"
      cp ${APP_ROOT}/.default/config.yaml ${ENTE_CONFIG_FILE}

      # set postgres
      sed -i 's@${POSTGRES_HOST}@'${POSTGRES_HOST}'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${POSTGRES_PORT}@'${POSTGRES_PORT}'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${POSTGRES_DATABASE}@'${POSTGRES_DATABASE}'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${POSTGRES_USER}@'${POSTGRES_USER}'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${POSTGRES_PASSWORD}@'${POSTGRES_PASSWORD}'@' ${ENTE_CONFIG_FILE}

      # set minio
      sed -i 's@${MINIO_ACCESS_KEY}@'${MINIO_ACCESS_KEY}'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${MINIO_SECRET_KEY}@'${MINIO_SECRET_KEY}'@' ${ENTE_CONFIG_FILE}

      # set smtp
      sed -i 's@${SMTP_HOST}@'${SMTP_HOST}'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${SMTP_PORT}@'${SMTP_PORT}'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${SMTP_USER}@'${SMTP_USER}'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${SMTP_PASSWORD}@'${SMTP_PASSWORD}'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${SMTP_EMAIL}@'${SMTP_EMAIL}'@' ${ENTE_CONFIG_FILE}

      if [ ! -z "${OTT_DOMAIN}" ]; then
        sed -i 's@${OTT_DOMAIN}@'${OTT_DOMAIN}'@' ${ENTE_CONFIG_FILE}
        sed -i 's@${OTT_PIN}@'${OTT_PIN}'@' ${ENTE_CONFIG_FILE}
      else
        sed -i 's@hardcoded-ott:@#hardcoded-ott:@' ${ENTE_CONFIG_FILE}
        sed -i 's@local-domain-suffix:@#local-domain-suffix:@' ${ENTE_CONFIG_FILE}
        sed -i 's@local-domain-value:@#local-domain-value:@' ${ENTE_CONFIG_FILE}
      fi

      # set secrets
      sed -i 's@${KEY_ENCRYPTION}@'$(elevenCreateRandomString 31 | base64)'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${KEY_HASH}@'$(elevenCreateRandomString 31 | base64)'@' ${ENTE_CONFIG_FILE}
      sed -i 's@${JWT_SECRET}@'$(elevenCreateRandomString 31 | base64)'@' ${ENTE_CONFIG_FILE}
    fi

    elevenDockerImageStart
    cd /opt/ente
    set -- "/opt/ente/museum"
  fi

  exec "$@"
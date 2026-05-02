#!/bin/sh
set -e

CONFIG_DIR="/config/searxng"
SETTINGS_FILE="${CONFIG_DIR}/settings.yml"

mkdir -p "${CONFIG_DIR}"

# Read secret_key from Supervisor's options.json using Python
SECRET_KEY=$(python3 -c "import json; print(json.load(open('/data/options.json')).get('secret_key', ''))")

if [ -z "${SECRET_KEY}" ]; then
  SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
  echo "WARNING: No secret_key configured. Generated a temporary secret key."
  echo "WARNING: For stable sessions, set secret_key in the add-on configuration."
fi

cat > "${SETTINGS_FILE}" <<EOF
use_default_settings: true

search:
  formats:
    - html
    - json

server:
  bind_address: "0.0.0.0"
  port: 8080
  secret_key: "${SECRET_KEY}"
  limiter: false
  image_proxy: true
EOF

export SEARXNG_SETTINGS_PATH="${SETTINGS_FILE}"

echo "INFO: Starting SearXNG..."
exec /usr/local/searxng/dockerfiles/docker-entrypoint.sh

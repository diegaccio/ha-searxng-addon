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

# Use Python to properly merge settings (use_default_settings has bugs with list overrides)
python3 <<PYEOF
import yaml
import os

# Load SearXNG default settings
settings = yaml.safe_load(open('/usr/local/searxng/searx/settings.yml'))

# Override specific settings
settings['search']['formats'] = ['html', 'json']
settings['server']['bind_address'] = '0.0.0.0'
settings['server']['port'] = 8080
settings['server']['secret_key'] = '${SECRET_KEY}'
settings['server']['limiter'] = False
settings['server']['image_proxy'] = True

# Write merged settings
with open('${SETTINGS_FILE}', 'w') as f:
    yaml.dump(settings, f, default_flow_style=False, sort_keys=False)

print("INFO: Generated settings.yml with formats:", settings['search']['formats'])
PYEOF

export SEARXNG_SETTINGS_PATH="${SETTINGS_FILE}"

echo "INFO: Starting SearXNG..."
exec /usr/local/searxng/dockerfiles/docker-entrypoint.sh

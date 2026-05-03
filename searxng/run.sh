#!/bin/sh
set -e

# Read secret_key from Supervisor's options.json using Python
SECRET_KEY=$(python3 -c "import json; print(json.load(open('/data/options.json')).get('secret_key', ''))")

if [ -z "${SECRET_KEY}" ]; then
  SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
  echo "WARNING: No secret_key configured. Generated a temporary secret key."
  echo "WARNING: For stable sessions, set secret_key in the add-on configuration."
fi

# Use Python to properly merge settings and write to the path SearXNG expects
python3 <<PYEOF
import yaml
import os

# Ensure /etc/searxng exists (SearXNG's expected settings path)
os.makedirs('/etc/searxng', exist_ok=True)

# Load SearXNG default settings
settings = yaml.safe_load(open('/usr/local/searxng/searx/settings.yml'))

# Override specific settings
settings['search']['formats'] = ['html', 'json']
settings['server']['bind_address'] = '0.0.0.0'
settings['server']['port'] = 8080
settings['server']['secret_key'] = '${SECRET_KEY}'
settings['server']['limiter'] = False
settings['server']['image_proxy'] = True

# Write merged settings to the path SearXNG actually checks
with open('/etc/searxng/settings.yml', 'w') as f:
    yaml.dump(settings, f, default_flow_style=False, sort_keys=False)

print("INFO: Generated /etc/searxng/settings.yml with formats:", settings['search']['formats'])
PYEOF

echo "INFO: Starting SearXNG..."
exec /usr/local/searxng/dockerfiles/docker-entrypoint.sh

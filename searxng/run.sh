#!/bin/sh
set -e

# Read secret_key from Supervisor's options.json using Python
SECRET_KEY=$(python3 -c "import json; print(json.load(open('/data/options.json')).get('secret_key', ''))")

if [ -z "${SECRET_KEY}" ]; then
  SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
  echo "WARNING: No secret_key configured. Generated a temporary secret key."
  echo "WARNING: For stable sessions, set secret_key in the add-on configuration."
fi

# Determine the settings path (use SearXNG's env var if available, fallback to default)
SETTINGS_PATH="${__SEARXNG_SETTINGS_PATH:-/etc/searxng/settings.yml}"
CONFIG_DIR="$(dirname "$SETTINGS_PATH")"

# Create config directory
mkdir -p "$CONFIG_DIR"

# Copy default settings and customize
cp /usr/local/searxng/searx/settings.yml "$SETTINGS_PATH"

# Add json to formats using sed
sed -i 's/    - html/    - html\n    - json/' "$SETTINGS_PATH"

# Update server settings using sed
sed -i 's/bind_address: "127.0.0.1"/bind_address: "0.0.0.0"/' "$SETTINGS_PATH"
sed -i 's/port: 8888/port: 8080/' "$SETTINGS_PATH"
sed -i "s/secret_key: \"ultrasecretkey\"/secret_key: \"${SECRET_KEY}\"/" "$SETTINGS_PATH"
sed -i 's/limiter: true/limiter: false/' "$SETTINGS_PATH"
sed -i 's/image_proxy: false/image_proxy: true/' "$SETTINGS_PATH"

echo "INFO: Created settings.yml with json format enabled at $SETTINGS_PATH"
grep -A 3 "formats:" "$SETTINGS_PATH"

# Now run the base image entrypoint, which will see our file and skip template creation
exec /usr/local/searxng/entrypoint.sh

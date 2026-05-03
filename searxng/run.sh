#!/bin/sh
set -e

# Read secret_key from Supervisor's options.json using Python
SECRET_KEY=$(python3 -c "import json; print(json.load(open('/data/options.json')).get('secret_key', ''))")

if [ -z "${SECRET_KEY}" ]; then
  SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
  echo "WARNING: No secret_key configured. Generated a temporary secret key."
  echo "WARNING: For stable sessions, set secret_key in the add-on configuration."
fi

# Create settings directory and copy default settings
mkdir -p /etc/searxng
cp /usr/local/searxng/searx/settings.yml /etc/searxng/settings.yml

# Add json to formats using sed
sed -i 's/    - html/    - html\n    - json/' /etc/searxng/settings.yml

# Update server settings using sed
sed -i 's/bind_address: "127.0.0.1"/bind_address: "0.0.0.0"/' /etc/searxng/settings.yml
sed -i 's/port: 8888/port: 8080/' /etc/searxng/settings.yml
sed -i "s/secret_key: \"ultrasecretkey\"/secret_key: \"${SECRET_KEY}\"/" /etc/searxng/settings.yml
sed -i 's/limiter: true/limiter: false/' /etc/searxng/settings.yml
sed -i 's/image_proxy: false/image_proxy: true/' /etc/searxng/settings.yml

echo "INFO: Created settings.yml with json format enabled"
grep -A 3 "formats:" /etc/searxng/settings.yml

# Now run the base image entrypoint, which will see our file and skip template creation
exec /usr/local/searxng/dockerfiles/docker-entrypoint.sh

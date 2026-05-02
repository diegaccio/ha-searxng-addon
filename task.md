# Task: Create `ha-searxng-addon` GitHub Repository

## Goal

Create a public GitHub repository named:

```text
ha-searxng-addon
```

The repository must provide a Home Assistant OS add-on that runs SearXNG using the official SearXNG Docker image.

The add-on is intended to be used as a private LAN web search provider for OpenClaw.

---

## Context

The target environment is:

```text
Home Assistant OS
```

Not Ubuntu, not a generic Docker host.

Because Home Assistant OS does not expose normal Docker management to the user, the correct approach is to create a Home Assistant add-on repository.

The add-on should be installable from Home Assistant by adding the GitHub repository URL in:

```text
Settings → Add-ons → Add-on Store → ⋮ → Repositories
```

---

## Repository name

```text
ha-searxng-addon
```

---

## Required repository structure

Create this structure:

```text
ha-searxng-addon/
├── repository.yaml
├── README.md
├── LICENSE
└── searxng/
    ├── config.yaml
    ├── Dockerfile
    ├── run.sh
    └── README.md
```

Optional future files:

```text
searxng/icon.png
searxng/logo.png
searxng/translations/en.yaml
```

---

## Root `repository.yaml`

Create:

```yaml
name: "SearXNG Home Assistant Add-on"
url: "https://github.com/YOUR_USERNAME/ha-searxng-addon"
maintainer: "YOUR_NAME"
```

Replace `YOUR_USERNAME` and `YOUR_NAME`.

---

## Add-on `searxng/config.yaml`

Create:

```yaml
name: "SearXNG"
slug: "searxng"
description: "Private SearXNG metasearch engine for OpenClaw"
version: "1.0.0"
url: "https://github.com/YOUR_USERNAME/ha-searxng-addon"
startup: services
boot: auto
init: false

arch:
  - amd64
  - aarch64

ports:
  8080/tcp: 8888

ports_description:
  8080/tcp: "SearXNG web interface"

webui: "http://[HOST]:[PORT:8080]"

map:
  - addon_config:rw

options:
  secret_key: ""

schema:
  secret_key: "str?"
```

Notes:

- Internal container port is `8080`.
- Home Assistant host port is `8888`.
- After installation, the UI should be reachable at:

```text
http://homeassistant.local:8888
```

or:

```text
http://HOME_ASSISTANT_IP:8888
```

---

## Add-on `searxng/Dockerfile`

Create:

```Dockerfile
ARG BUILD_VERSION
ARG BUILD_ARCH

FROM docker.io/searxng/searxng:latest

LABEL   io.hass.name="SearXNG"   io.hass.description="Private SearXNG metasearch engine for OpenClaw"   io.hass.version="${BUILD_VERSION}"   io.hass.type="addon"   io.hass.arch="${BUILD_ARCH}"

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
```

---

## Add-on `searxng/run.sh`

Create:

```bash
#!/usr/bin/with-contenv bashio
set -e

CONFIG_DIR="/config/searxng"
SETTINGS_FILE="${CONFIG_DIR}/settings.yml"

mkdir -p "${CONFIG_DIR}"

SECRET_KEY="$(bashio::config 'secret_key')"

if [ -z "${SECRET_KEY}" ]; then
  SECRET_KEY="$(openssl rand -hex 32)"
  bashio::log.warning "No secret_key configured. Generated a temporary secret key."
  bashio::log.warning "For stable sessions, set secret_key in the add-on configuration."
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

bashio::log.info "Starting SearXNG..."
exec /usr/local/searxng/dockerfiles/docker-entrypoint.sh
```

Important:

- JSON output must be enabled because OpenClaw needs it.
- `limiter: false` is intentional because this first version does not include Valkey/Redis.
- This is designed for private LAN use.
- In a future version, Valkey could be added for rate limiting.

---

## Root `README.md`

Create a concise README:

```md
# SearXNG Home Assistant Add-on

This repository provides a Home Assistant add-on for running SearXNG on Home Assistant OS.

It is intended for private LAN usage and for integrations such as OpenClaw web search.

## Add-on included

- SearXNG

## Installation

1. Open Home Assistant.
2. Go to Settings → Add-ons → Add-on Store.
3. Click the three-dot menu → Repositories.
4. Add this repository:

   ```text
   https://github.com/YOUR_USERNAME/ha-searxng-addon
   ```

5. Install the SearXNG add-on.
6. Start the add-on.

## Usage

After installation, open:

```text
http://homeassistant.local:8888
```

or:

```text
http://HOME_ASSISTANT_IP:8888
```

## OpenClaw integration

Configure OpenClaw to use SearXNG with:

```yaml
searxng:
  baseUrl: http://homeassistant.local:8888
```

or:

```yaml
searxng:
  baseUrl: http://HOME_ASSISTANT_IP:8888
```

## Notes

This add-on uses the official SearXNG Docker image.

The first version runs SearXNG as a single container without Valkey/Redis.

Because there is no Valkey container in this add-on, the SearXNG limiter is disabled.

This is suitable for private LAN use.
```

Replace `YOUR_USERNAME`.

---

## Add-on `searxng/README.md`

Create:

```md
# SearXNG Add-on

Run SearXNG as a Home Assistant add-on.

## Configuration

```yaml
secret_key: ""
```

If `secret_key` is empty, the add-on generates a temporary key at startup.

For stable sessions, configure a persistent secret key.

You can generate one with:

```bash
openssl rand -hex 32
```

## SearXNG settings

The add-on automatically creates a `settings.yml` with:

```yaml
use_default_settings: true

search:
  formats:
    - html
    - json

server:
  bind_address: "0.0.0.0"
  port: 8080
  limiter: false
  image_proxy: true
```

JSON output is enabled for OpenClaw compatibility.

## OpenClaw

Use this base URL:

```yaml
searxng:
  baseUrl: http://homeassistant.local:8888
```
```

---

## LICENSE

Use MIT license unless specified otherwise.

---

## Git commands

After creating the files:

```bash
git init
git add .
git commit -m "Initial SearXNG Home Assistant add-on"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/ha-searxng-addon.git
git push -u origin main
```

---

## Home Assistant installation test

After pushing to GitHub:

1. Open Home Assistant.
2. Go to Settings → Add-ons → Add-on Store.
3. Click ⋮ → Repositories.
4. Add:

```text
https://github.com/YOUR_USERNAME/ha-searxng-addon
```

5. Install the SearXNG add-on.
6. Start it.
7. Open:

```text
http://homeassistant.local:8888
```

8. Test JSON output:

```text
http://homeassistant.local:8888/search?q=test&format=json
```

Expected result:

- The normal web UI should load.
- The JSON endpoint should return JSON search results.

---

## Future improvements

Possible later enhancements:

- Add Valkey/Redis support for rate limiting.
- Add more SearXNG options to the Home Assistant add-on configuration.
- Add icon and logo.
- Add GitHub Actions validation.
- Pin the SearXNG Docker image instead of using `latest`.
- Add HTTPS support through Nginx Proxy Manager or another reverse proxy.
- Add documentation for OpenClaw HTTPS/LAN access.

---

## Important design decisions

This repository intentionally adapts the official SearXNG Docker installation to Home Assistant OS.

The official SearXNG Docker Compose setup usually includes:

- SearXNG
- Valkey/Redis

For this first Home Assistant add-on version, only the SearXNG container is used.

Reason:

- Home Assistant add-ons are single-container by default.
- This is simpler and easier to maintain.
- The intended use case is private LAN search for OpenClaw.
- The limiter is disabled to avoid requiring Valkey.

---

## Definition of done

The task is complete when:

- The repository is named `ha-searxng-addon`.
- The repository contains a valid Home Assistant add-on structure.
- Home Assistant can add the repository as an add-on repository.
- The SearXNG add-on appears in the Add-on Store.
- The add-on builds and starts.
- The SearXNG web UI is reachable on port `8888`.
- JSON search works with `format=json`.
- OpenClaw can use the SearXNG `baseUrl`.

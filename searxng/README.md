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

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
   https://github.com/diegaccio/ha-searxng-addon
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

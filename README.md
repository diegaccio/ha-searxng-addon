# SearXNG Home Assistant Add-on

Run a **free, privacy-friendly search engine** on your Home Assistant OS device.

This add-on installs [SearXNG](https://github.com/searxng/searxng), a metasearch engine that respects your privacy and does not track you. It is perfect for integrating **free web search** into your smart home via [OpenClaw](https://github.com/OpenClaw).

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

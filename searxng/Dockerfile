ARG BUILD_VERSION
ARG BUILD_ARCH

FROM docker.io/searxng/searxng:2026.5.2-cd75013c9

LABEL   io.hass.name="SearXNG"   io.hass.description="Private SearXNG metasearch engine for OpenClaw"   io.hass.version="${BUILD_VERSION}"   io.hass.type="addon"   io.hass.arch="${BUILD_ARCH}"

COPY run.sh /run.sh
RUN chmod a+x /run.sh

# Override the base image entrypoint so our script runs first
ENTRYPOINT ["/run.sh"]

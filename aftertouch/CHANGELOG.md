# Changelog

## 0.118.0 — 2026-07-26

### Initial release

- Wraps AfterTouch `soundtouch-service` v0.118.0 as a Home Assistant add-on
- Supports `aarch64` (Home Assistant Green / Raspberry Pi 4/5) and `amd64`
- Uses `host_network` for automatic mDNS/UPnP device discovery
- All service configuration exposed as add-on options (ports, SERVER_URL,
  DNS discovery, logging, Stockholm frontend path, etc.)
- Persistent data stored in the add-on `/data` volume (included in HA backups)
- Web UI accessible directly from the HA sidebar via Ingress link or port 8000
- Health watchdog on `GET /health`

### Upstream release highlights (from gesellix/Bose-SoundTouch v0.118.0)

See <https://github.com/gesellix/Bose-SoundTouch/releases/tag/v0.118.0> for
the full upstream changelog.

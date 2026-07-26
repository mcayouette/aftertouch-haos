# AfterTouch — Bose SoundTouch Service

**AfterTouch** is a local replacement for the Bose SoundTouch cloud services,
which were shut down on **May 6, 2026**. This add-on runs
[`soundtouch-service`](https://github.com/gesellix/Bose-SoundTouch) v0.118.0
directly on your Home Assistant Green (or any Home Assistant OS device), giving
your Bose SoundTouch speakers full local control — no Bose cloud required.

> **Disclaimer**: This is an independent open-source project and is not
> affiliated with, endorsed by, or otherwise connected to Bose Corporation.

---

## What it restores

- **Presets** — store and recall up to 6 presets per speaker
- **Spotify & Amazon Music** — service authentication via local OAuth
- **TuneIn & RadioBrowser** — internet radio browsing and playback
- **Multiroom stereo pairing** — zone/group management across speakers
- **Device management web UI** — browser-based setup at `http://<your-ha>:8000`

---

## Quick start

1. Install this add-on and start it.
2. Open the **AfterTouch** panel in your Home Assistant sidebar (or navigate to
   `http://homeassistant.local:8000`).
3. Wait for your SoundTouch speakers to appear in the **Device Dashboard** (they
   are discovered automatically via mDNS/UPnP because the add-on uses
   `host_network: true`).
4. Click **Migrate** next to each speaker to redirect it from the defunct Bose
   cloud to this local service.
5. Done — your speakers work again.

---

## Configuration options

| Option | Default | Description |
|---|---|---|
| `server_url` | *(auto)* | Public HTTP URL of this service. Defaults to `http://<hostname>:8000`. Set this to the stable hostname/IP your speakers can reach. |
| `https_server_url` | *(auto)* | Public HTTPS URL. Derived from `server_url` if not set. Required for DNS/DHCP migration. |
| `data_dir` | `/data` | Persistent data directory (presets, device configs, interaction logs). **Do not change** unless you know what you are doing. |
| `http_port` | `8000` | HTTP port. Change only if 8000 is occupied. Update `ports` accordingly. |
| `https_port` | `8443` | HTTPS port. |
| `bind_addr` | *(all interfaces)* | Interface to bind to, e.g. `0.0.0.0`. Rarely needed. |
| `enable_dns_discovery` | `false` | Enable built-in DNS server. Required for DNS/DHCP redirect migration (the most robust method). Binds to UDP 53 — enable the `53/udp` port mapping first. |
| `dns_upstream` | `8.8.8.8` | Upstream DNS server for non-Bose queries when DNS discovery is enabled. |
| `dns_bind_addr` | `:53` | Address/port for the DNS server. |
| `discovery_interval` | `5m` | How often to scan for new devices. |
| `discovery_disabled` | `false` | Set to `true` to disable automatic device scanning. |
| `log_proxy_body` | `false` | Log full request/response bodies (development only). |
| `redact_proxy_logs` | `true` | Redact tokens and credentials from recorded `.http` files. |
| `record_interactions` | `true` | Save all device interactions as replay-able `.http` files. |
| `stockholm_dir` | *(disabled)* | Path to the Stockholm frontend files (optional Bose app UI). See below. |
| `marge_auth_token` | *(empty)* | Pre-seed the Marge auth token to skip the first login screen. |
| `marge_account_id` | *(empty)* | Pre-seed the account ID for device discovery filtering. |

---

## Migrating your speakers

The add-on supports three migration methods, each accessible from the web UI:

### XML redirect (recommended for most users)
Requires SSH access to the speaker (enable it once via a USB stick — see
[Device Initial Setup](https://gesellix.github.io/Bose-SoundTouch/docs/guides/DEVICE-INITIAL-SETUP/)).
The service uploads a `SoundTouchSdkPrivateCfg.xml` that points all cloud URLs
at the local service.

### Telnet redirect
SSH-less method via the speaker's port-17000 diagnostic shell. Works on most
models without USB stick setup.

### DNS/DHCP redirect (most robust)
Enable `enable_dns_discovery: true` and expose port `53/udp`. The service acts
as a DNS server that intercepts all `*.bose.com` hostnames and resolves them to
itself. Survives reboots and factory resets.

---

## Stockholm frontend (optional)

The Stockholm UI is the original Bose SoundTouch app interface, patched to work
locally. The files are **not** bundled here — you must obtain them from
[krahl/soundcork-stockholm-app](https://github.com/krahl/soundcork-stockholm-app)
and build them yourself (see the AfterTouch docs for the full walkthrough).

Once you have the `/stockholm/` directory, mount it into the add-on container
(e.g. via the `/share` volume) and set `stockholm_dir` to the mount path.

---

## Persistent data

All data is stored in the add-on's `/data` volume and is included in
Home Assistant backups automatically:

```
/data/
├── accounts/default/devices/<DEVICE_ID>/   # per-device configs & backups
├── accounts/default/Presets.xml            # synced presets
├── accounts/default/Recents.xml            # playback history
├── interactions/                           # recorded .http traffic logs
├── dns/discoveries.json                    # DNS discovery log
└── stats/                                  # usage & error statistics
```

---

## Home Assistant integration

Once your speakers are migrated you can control them directly from Home
Assistant using the built-in **Bose SoundTouch** integration (Settings →
Integrations → Add integration → Bose SoundTouch). The speakers are now
self-contained on your LAN, so no cloud token is required.

For more advanced automation, the `soundtouch-cli` tool (available separately
from the same release) can be called from HA shell scripts or `command_line`
entities.

---

## Troubleshooting

- **Speaker not discovered**: Check that your HA instance and the speaker are
  on the same network segment. The add-on uses host networking for mDNS/UPnP.
  You can also add a device manually from the web UI.
- **Migration fails**: Confirm SSH is enabled on the speaker (USB stick trick)
  or try the telnet method instead.
- **Settings not taking effect**: Changes made via the web UI `Settings` tab are
  stored in `/data/settings.json` and take precedence over add-on options.
  Edit or delete that file if you need to reset to option values.
- **DNS not binding**: Port 53/UDP requires the port mapping to be enabled in
  the add-on network settings.

Full documentation: <https://gesellix.github.io/Bose-SoundTouch/docs/guides/SOUNDTOUCH-SERVICE/>

# AfterTouch — Home Assistant Add-on

[![Release](https://img.shields.io/badge/version-0.118.1-blue)](https://github.com/gesellix/Bose-SoundTouch/releases/tag/v0.118.1)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Home Assistant add-on that runs
[**AfterTouch `soundtouch-service`**](https://github.com/gesellix/Bose-SoundTouch)
v0.118.1 — a local replacement for the Bose SoundTouch cloud, which was shut
down on May 6, 2026.

## Features

- 🏠 Replaces the Bose cloud entirely — runs on your LAN, no internet required
- 🔧 Web UI for device discovery, migration, and management at port 8000
- 🎵 Restores Spotify, Amazon Music, TuneIn, and RadioBrowser
- 💾 Syncs presets and recent playback across all speakers
- 🔒 Built-in HTTPS with auto-generated CA for DNS redirect migration
- 📊 Records all device traffic as replay-able `.http` files for debugging

## Installation

1. Add this repository to your Home Assistant add-on store:
   **Settings → Add-ons → Add-on store → ⋮ → Repositories**
   ```
   https://github.com/<your-username>/ha-aftertouch
   ```
2. Install **AfterTouch — Bose SoundTouch Service**.
3. Start the add-on and open the web UI.

## Documentation

See [DOCS.md](aftertouch/DOCS.md) for full configuration reference and
migration walkthrough.

## Upstream project

- Source: <https://github.com/gesellix/Bose-SoundTouch>
- Docs: <https://gesellix.github.io/Bose-SoundTouch/>

> **Disclaimer**: Independent project. Not affiliated with Bose Corporation.

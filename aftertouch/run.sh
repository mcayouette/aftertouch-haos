#!/usr/bin/env bashio
# AfterTouch soundtouch-service — Home Assistant add-on run script
# shellcheck shell=bash
set -e

# ── Read options from /data/options.json via bashio ──────────────────────────

DATA_DIR="$(bashio::config 'data_dir')"
HTTP_PORT="$(bashio::config 'http_port')"
HTTPS_PORT="$(bashio::config 'https_port')"

# Optional / may be empty — read raw value regardless of has_value
SERVER_URL="$(bashio::config 'server_url' '')"
HTTPS_SERVER_URL="$(bashio::config 'https_server_url' '')"

BIND_ADDR=""
if bashio::config.has_value 'bind_addr'; then
    BIND_ADDR="$(bashio::config 'bind_addr')"
fi

ENABLE_DNS_DISCOVERY="$(bashio::config 'enable_dns_discovery')"
DNS_UPSTREAM="$(bashio::config 'dns_upstream')"
DNS_BIND_ADDR="$(bashio::config 'dns_bind_addr')"
DISCOVERY_INTERVAL="$(bashio::config 'discovery_interval')"
DISCOVERY_DISABLED="$(bashio::config 'discovery_disabled')"
LOG_PROXY_BODY="$(bashio::config 'log_proxy_body')"
REDACT_PROXY_LOGS="$(bashio::config 'redact_proxy_logs')"
RECORD_INTERACTIONS="$(bashio::config 'record_interactions')"

STOCKHOLM_DIR=""
if bashio::config.has_value 'stockholm_dir'; then
    STOCKHOLM_DIR="$(bashio::config 'stockholm_dir')"
fi

MARGE_AUTH_TOKEN=""
if bashio::config.has_value 'marge_auth_token'; then
    MARGE_AUTH_TOKEN="$(bashio::config 'marge_auth_token')"
fi

MARGE_ACCOUNT_ID=""
if bashio::config.has_value 'marge_account_id'; then
    MARGE_ACCOUNT_ID="$(bashio::config 'marge_account_id')"
fi

# ── Ensure data directory exists ──────────────────────────────────────────────
mkdir -p "${DATA_DIR}"

# ── Build environment for soundtouch-service ─────────────────────────────────
export PORT="${HTTP_PORT}"
export HTTPS_PORT="${HTTPS_PORT}"
export DATA_DIR="${DATA_DIR}"
export ENABLE_DNS_DISCOVERY="${ENABLE_DNS_DISCOVERY}"
export DNS_UPSTREAM="${DNS_UPSTREAM}"
export DNS_BIND_ADDR="${DNS_BIND_ADDR}"
export DISCOVERY_INTERVAL="${DISCOVERY_INTERVAL}"
export DISCOVERY_DISABLED="${DISCOVERY_DISABLED}"
export LOG_PROXY_BODY="${LOG_PROXY_BODY}"
export REDACT_PROXY_LOGS="${REDACT_PROXY_LOGS}"
export RECORD_INTERACTIONS="${RECORD_INTERACTIONS}"

[ -n "${SERVER_URL}" ]        && export SERVER_URL
[ -n "${HTTPS_SERVER_URL}" ]  && export HTTPS_SERVER_URL
[ -n "${BIND_ADDR}" ]         && export BIND_ADDR
[ -n "${STOCKHOLM_DIR}" ]     && export STOCKHOLM_DIR
[ -n "${MARGE_AUTH_TOKEN}" ]  && export MARGE_AUTH_TOKEN
[ -n "${MARGE_ACCOUNT_ID}" ]  && export MARGE_ACCOUNT_ID

# ── SERVER_URL / HTTPS_SERVER_URL precedence ──────────────────────────────────
# The AfterTouch web UI saves settings to DATA_DIR/settings.json, which the
# service reads at startup with higher priority than env vars. To avoid
# clobbering UI-saved settings on every restart, we only export SERVER_URL
# when the user has set a non-default value in the add-on options.
#
# On first boot (no settings.json yet) we seed homeassistant.local so the
# service starts with the correct LAN hostname rather than the internal
# Docker container name.
DEFAULT_SERVER_URL="http://homeassistant.local:${PORT}"
DEFAULT_HTTPS_SERVER_URL="https://homeassistant.local:${HTTPS_PORT}"
SETTINGS_FILE="${DATA_DIR}/settings.json"

if [ -n "${SERVER_URL}" ] && [ "${SERVER_URL}" != "${DEFAULT_SERVER_URL}" ]; then
    # User explicitly set a custom URL — always honour it
    export SERVER_URL
    export HTTPS_SERVER_URL="${HTTPS_SERVER_URL:-${DEFAULT_HTTPS_SERVER_URL}}"
elif [ ! -f "${SETTINGS_FILE}" ]; then
    # First boot — seed the default so the service doesn't use its internal hostname
    export SERVER_URL="${DEFAULT_SERVER_URL}"
    export HTTPS_SERVER_URL="${DEFAULT_HTTPS_SERVER_URL}"
    bashio::log.info "First boot — seeding SERVER_URL: ${SERVER_URL}"
else
    # settings.json exists — let it take precedence, don't export SERVER_URL
    bashio::log.info "settings.json found — SERVER_URL managed by AfterTouch UI"
fi

# ── Log startup info ──────────────────────────────────────────────────────────
bashio::log.info "Starting AfterTouch soundtouch-service v0.118.0"
bashio::log.info "  HTTP  : ${SERVER_URL}"
bashio::log.info "  HTTPS : ${HTTPS_SERVER_URL}"
bashio::log.info "  Data  : ${DATA_DIR}"
bashio::log.info "  DNS discovery: ${ENABLE_DNS_DISCOVERY}"

# ── Start the service (replaces this shell — PID 1 style) ────────────────────
exec /usr/local/bin/soundtouch-service

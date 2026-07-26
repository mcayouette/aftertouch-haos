#!/usr/bin/env bashio
# AfterTouch soundtouch-service — Home Assistant add-on run script
# shellcheck shell=bash
set -e

# ── Read options — prefer bashio, fall back to jq on /data/options.json ──────
OPTIONS_FILE="/data/options.json"

get_option() {
    local key="$1"
    local default="${2:-}"
    if bashio::api.supervisor GET /addons/self/options/config 2>/dev/null | grep -q "${key}" 2>/dev/null; then
        bashio::config "${key}" "${default}" 2>/dev/null || echo "${default}"
    elif [ -f "${OPTIONS_FILE}" ]; then
        python3 -c "import json,sys; d=json.load(open('${OPTIONS_FILE}')); print(d.get('${key}','${default}'))" 2>/dev/null || echo "${default}"
    else
        echo "${default}"
    fi
}

DATA_DIR="$(bashio::config 'data_dir' '/data' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('data_dir','/data'))" 2>/dev/null || echo '/data')"
HTTP_PORT="$(bashio::config 'http_port' '8000' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('http_port','8000'))" 2>/dev/null || echo '8000')"
HTTPS_PORT="$(bashio::config 'https_port' '8443' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('https_port','8443'))" 2>/dev/null || echo '8443')"
SERVER_URL="$(bashio::config 'server_url' '' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('server_url',''))" 2>/dev/null || echo '')"
HTTPS_SERVER_URL="$(bashio::config 'https_server_url' '' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('https_server_url',''))" 2>/dev/null || echo '')"
BIND_ADDR="$(bashio::config 'bind_addr' '' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('bind_addr',''))" 2>/dev/null || echo '')"
ENABLE_DNS_DISCOVERY="$(bashio::config 'enable_dns_discovery' 'false' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(str(d.get('enable_dns_discovery',False)).lower())" 2>/dev/null || echo 'false')"
DNS_UPSTREAM="$(bashio::config 'dns_upstream' '8.8.8.8' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('dns_upstream','8.8.8.8'))" 2>/dev/null || echo '8.8.8.8')"
DNS_BIND_ADDR="$(bashio::config 'dns_bind_addr' ':53' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('dns_bind_addr',':53'))" 2>/dev/null || echo ':53')"
DISCOVERY_INTERVAL="$(bashio::config 'discovery_interval' '5m' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('discovery_interval','5m'))" 2>/dev/null || echo '5m')"
DISCOVERY_DISABLED="$(bashio::config 'discovery_disabled' 'false' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(str(d.get('discovery_disabled',False)).lower())" 2>/dev/null || echo 'false')"
LOG_PROXY_BODY="$(bashio::config 'log_proxy_body' 'false' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(str(d.get('log_proxy_body',False)).lower())" 2>/dev/null || echo 'false')"
REDACT_PROXY_LOGS="$(bashio::config 'redact_proxy_logs' 'true' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(str(d.get('redact_proxy_logs',True)).lower())" 2>/dev/null || echo 'true')"
RECORD_INTERACTIONS="$(bashio::config 'record_interactions' 'true' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(str(d.get('record_interactions',True)).lower())" 2>/dev/null || echo 'true')"
STOCKHOLM_DIR="$(bashio::config 'stockholm_dir' '' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('stockholm_dir',''))" 2>/dev/null || echo '')"
MARGE_AUTH_TOKEN="$(bashio::config 'marge_auth_token' '' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('marge_auth_token',''))" 2>/dev/null || echo '')"
MARGE_ACCOUNT_ID="$(bashio::config 'marge_account_id' '' 2>/dev/null || python3 -c "import json; d=json.load(open('${OPTIONS_FILE}')); print(d.get('marge_account_id',''))" 2>/dev/null || echo '')"

# ── Ensure data directory exists ──────────────────────────────────────────────
mkdir -p "${DATA_DIR}"

# ── Rescue settings.json if it was written outside DATA_DIR ───────────────────
# If a previous run wrote settings.json somewhere other than DATA_DIR, migrate it.
for CANDIDATE in /app/data/settings.json ./data/settings.json /settings.json; do
    if [ -f "${CANDIDATE}" ] && [ "${CANDIDATE}" != "${DATA_DIR}/settings.json" ]; then
        bashio::log.warning "Found settings.json at ${CANDIDATE} — moving to ${DATA_DIR}/settings.json"
        mv "${CANDIDATE}" "${DATA_DIR}/settings.json"
        break
    fi
done

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

[ -n "${BIND_ADDR}" ]         && export BIND_ADDR
[ -n "${STOCKHOLM_DIR}" ]     && export STOCKHOLM_DIR
[ -n "${MARGE_AUTH_TOKEN}" ]  && export MARGE_AUTH_TOKEN
[ -n "${MARGE_ACCOUNT_ID}" ]  && export MARGE_ACCOUNT_ID

# ── SERVER_URL / HTTPS_SERVER_URL ─────────────────────────────────────────────
# Always export a LAN-reachable URL so the service never falls back to the
# internal Docker container hostname (e.g. 96e6f0a4-aftertouch).
# If the user has saved a custom URL via the AfterTouch web UI, settings.json
# takes highest precedence and will override this env var at runtime.
if [ -n "${SERVER_URL}" ]; then
    export SERVER_URL
else
    export SERVER_URL="http://homeassistant.local:${PORT}"
fi

if [ -n "${HTTPS_SERVER_URL}" ]; then
    export HTTPS_SERVER_URL
else
    export HTTPS_SERVER_URL="https://homeassistant.local:${HTTPS_PORT}"
fi

# ── Log startup info ──────────────────────────────────────────────────────────
bashio::log.info "Starting AfterTouch soundtouch-service v0.118.0"
bashio::log.info "  HTTP  : ${SERVER_URL}"
bashio::log.info "  HTTPS : ${HTTPS_SERVER_URL}"
bashio::log.info "  Data  : ${DATA_DIR}"
bashio::log.info "  DNS discovery: ${ENABLE_DNS_DISCOVERY}"

# ── Start the service (replaces this shell — PID 1 style) ────────────────────
exec /usr/local/bin/soundtouch-service

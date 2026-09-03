#!/usr/bin/env bash
# Deterministic qBittorrent WebUI config (idempotent): credentials, categories,
# syno autorun hook, UPnP off, host-header validation off.
# Runs on genome against 127.0.0.1:8081. QB_USER/QB_PASS come from the agenix env,
# and are also patched into qBittorrent.conf pre-start by qbittorrent-creds.py,
# so logging in with QB_PASS should always succeed.
# QB_LOGIN_PASS=<temp> remains as a fallback for bootstrapping a profile that
# was created outside this flow.
set -euo pipefail

QB_HOST=http://127.0.0.1:8081
QB_USER=${QB_USER:-admin}
COOKIE=$(mktemp)
trap 'rm -f "$COOKIE"' EXIT

login() {
  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" -c "$COOKIE" -d "username=$1&password=$2" "$QB_HOST/api/v2/auth/login")
  [[ "$code" =~ ^(200|204)$ ]]
}

if ! login "$QB_USER" "${QB_PASS:-}"; then
  if [[ -n "${QB_LOGIN_PASS:-}" ]] && login "$QB_USER" "$QB_LOGIN_PASS"; then
    echo "logged in with temp password"
  else
    echo "ERROR: cannot log in. Get the temp password with:"
    echo "  journalctl -u qbittorrent | grep -i password"
    exit 1
  fi
fi

api() { curl -fsS -b "$COOKIE" "$@"; }

if [[ -n "${QB_PASS:-}" ]]; then
  api --data-urlencode "json={\"web_ui_username\":\"$QB_USER\",\"web_ui_password\":\"$QB_PASS\"}" \
      "$QB_HOST/api/v2/app/setPreferences" >/dev/null
  echo "credentials set ($QB_USER)"
fi

add_category() {
  api --data-urlencode "category=$1" --data-urlencode "savePath=$2" \
      "$QB_HOST/api/v2/torrents/createCategory" >/dev/null || true
  echo "category: $1 -> $2"
}
add_category movies      /media/jellyfin/movies
add_category shows       /media/jellyfin/shows
add_category syno-movies /media/jellyfin/syno/movies
add_category syno-tv     /media/jellyfin/syno/tv

api --data-urlencode 'json={"autorun_enabled":true,"autorun_program":"/run/current-system/sw/bin/torrent-done.sh %I %D %N %L %F","upnp":false,"listen_port":51413,"web_ui_host_header_validation_enabled":false}' \
    "$QB_HOST/api/v2/app/setPreferences" >/dev/null
echo "hook installed; UPnP off; port 51413; host-header validation off"

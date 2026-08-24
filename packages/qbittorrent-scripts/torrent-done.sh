#!/usr/bin/env bash
# qBittorrent autorun hook: upload syno-staged torrents to the Synology, then
# delete the torrent only after a successful upload.
# Args: %I hash  %D save-path(enc)  %N name(enc)  %L category  %F content-path(enc)
set -uo pipefail

urldecode() { printf '%b' "${1//%/\\x}"; }
log()       { echo "[$(date '+%F %T')] $*" >> "$LOG"; }

HASH="$1"
SAVE_PATH="$(urldecode "$2")"
NAME="$(urldecode "$3")"
CATEGORY="$4"
CONTENT="$(urldecode "$5")"

LOG=/var/lib/qBittorrent/qBittorrent/torrent-done.log
SYNO_ROOT=/media/jellyfin/syno
QB_HOST=http://127.0.0.1:8081

SYNOLOGY_USER=raspberry-pi
SYNOLOGY_HOST=100.86.179.75
SYNOLOGY_PORT=2222
SYNO_REMOTE_ROOT=/volume1/media/jellyfin
SSH_KEY=/var/lib/qBittorrent/ssh/id_ed25519
SSH_KNOWN_HOSTS=/var/lib/qBittorrent/ssh/known_hosts

DELETE_AFTER_SECONDS=${DELETE_AFTER_SECONDS:-3600}
RSYNC_RETRIES=${RSYNC_RETRIES:-12}
RSYNC_RETRY_BASE_SECONDS=30

case "$SAVE_PATH" in
  "$SYNO_ROOT"|"$SYNO_ROOT"/*) ;;
  *) log "skip: category=$CATEGORY"; exit 0 ;;
esac

REL="${SAVE_PATH#"$SYNO_ROOT"/}"
DEST="$SYNOLOGY_USER@$SYNOLOGY_HOST:$SYNO_REMOTE_ROOT/$REL/"

rsync_cmd() {
  rsync -a -e "ssh -p $SYNOLOGY_PORT -i $SSH_KEY -o UserKnownHostsFile=$SSH_KNOWN_HOSTS -o BatchMode=yes" "$CONTENT" "$DEST"
}

log "upload: $CONTENT -> $DEST"
attempt=0
while ! rsync_cmd >>"$LOG" 2>&1; do
  attempt=$((attempt + 1))
  if (( attempt > RSYNC_RETRIES )); then
    log "FAILED after $RSYNC_RETRIES attempts — torrent kept"
    exit 1
  fi
  wait_seconds=$(( RSYNC_RETRY_BASE_SECONDS * attempt ))
  log "attempt $attempt failed; retry in ${wait_seconds}s"
  sleep "$wait_seconds"
done

log "uploaded; deleting torrent $HASH in ${DELETE_AFTER_SECONDS}s"
sleep "$DELETE_AFTER_SECONDS"

COOKIE=$(mktemp)
trap 'rm -f "$COOKIE"' EXIT
if curl -fsS -c "$COOKIE" -d "username=${QB_USER:-admin}&password=$QB_PASS" "$QB_HOST/api/v2/auth/login" >/dev/null 2>&1 \
   && curl -fsS -b "$COOKIE" --data "hashes=$HASH&deleteFiles=true" "$QB_HOST/api/v2/torrents/delete" >>"$LOG" 2>&1; then
  log "torrent $HASH removed"
else
  log "WARNING: delete failed for $HASH — remove manually"
fi

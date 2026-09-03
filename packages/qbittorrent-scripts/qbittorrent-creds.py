#!/usr/bin/env python3
"""Patch WebUI credentials into qBittorrent.conf from QB_USER/QB_PASS.

Runs as an ExecStartPre of qbittorrent.service (after the nixpkgs module has
installed its store-rendered qBittorrent.conf), so the WebUI credentials always
come from the agenix EnvironmentFile (hosts/genome/qbittorrent.env.age). No
password hash is ever committed to the repo or baked into the nix store, and
the credentials survive service restarts (the module reinstalls its store conf
on every start, wiping API-set credentials).
"""
import base64
import hashlib
import os
import sys

CONF = os.environ.get(
    "QBT_CONF", "/var/lib/qBittorrent/qBittorrent/config/qBittorrent.conf"
)
USER = os.environ.get("QB_USER") or "admin"
PASS = os.environ.get("QB_PASS") or ""

if not PASS:
    print(
        "qbittorrent-creds: QB_PASS unset; leaving qBittorrent's temporary-password flow",
        file=sys.stderr,
    )
    sys.exit(0)

# qBittorrent format: PBKDF2-HMAC-SHA512, 100000 iterations, 16-byte salt,
# 64-byte key, rendered as @ByteArray(base64(salt):base64(key)).
salt = os.urandom(16)
dk = hashlib.pbkdf2_hmac("sha512", PASS.encode(), salt, 100000, 64)
pbf = "@ByteArray(%s:%s)" % (
    base64.b64encode(salt).decode(),
    base64.b64encode(dk).decode(),
)

with open(CONF, "a") as f:
    # QSettings merges repeated [Preferences] sections with earlier ones.
    _ = f.write(f"[Preferences]\nWebUI\\Username={USER}\nWebUI\\Password_PBKDF2={pbf}\n")

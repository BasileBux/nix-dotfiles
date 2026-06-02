#!/usr/bin/env bash

start_action() {
    echo "[*] Turning ON tailscale exit node at 100.86.179.75..."
    sudo tailscale set --exit-node=100.86.179.75
    
}

stop_action() {
    echo -e "\n[*] Turning OFF tailscale exit node at 100.86.179.75..."
    sudo tailscale set --exit-node=
    
    exit 0
}

# Trap Ctrl+C (SIGINT) to ensure the stop_action always runs
trap stop_action SIGINT

start_action

echo "Press 'q' or Ctrl+C to stop."
while true; do
    read -rsn1 key
    if [[ "$key" == "q" ]]; then
        stop_action
    fi
done

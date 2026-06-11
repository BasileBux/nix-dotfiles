#!/usr/bin/env bash

# To get a picker for exit nodes, run the script with any argument

start_action() {
    vpn_ip=$1
    echo "[*] Turning ON tailscale exit node at $vpn_ip..."
    sudo tailscale set --exit-node="$vpn_ip"
    
}

stop_action() {
    echo -e "\n[*] Turning OFF tailscale exit node at $vpn_ip..."
    sudo tailscale set --exit-node=
    
    exit 0
}

vpn_ip="100.86.179.75"
if [[ -n "$1" ]]; then
  vpn_ip=$(tailscale exit-node list | grep -vE '^\s*#|^\s*IP\b|^\s*$' | jq -R -nc '
  [inputs | capture("^\\s*(?<IP>\\S+)\\s+(?<HOSTNAME>\\S+)\\s+(?<COUNTRY>.*?)\\s{2,}(?<CITY>.*?)\\s{2,}(?<STATUS>\\S+)\\s*$")]
  ' | jq -r '.[] | if .COUNTRY == "-" or .CITY == "-" then "\(.IP)\t\(.HOSTNAME)" else "\(.IP)\t\(.COUNTRY) - \(.CITY)" end' | column -t -s $'\t' | fzf | awk '{print $1}')
  
  if [[ -z "$vpn_ip" ]]; then
    echo "Error: No exit node selected or command failed." >&2
    exit 1
  fi
fi

# Trap Ctrl+C (SIGINT) to ensure the stop_action always runs
trap stop_action SIGINT

start_action "$vpn_ip"

echo "Press 'q' or Ctrl+C to stop."
while true; do
    read -rsn1 key
    if [[ "$key" == "q" ]]; then
        stop_action
    fi
done

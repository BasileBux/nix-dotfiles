#!/usr/bin/env bash

# Get the volume of the Master channel
volume=$(amixer get Master | grep -o -E '[0-9]+%' | head -n 1 | sed 's/%//')

# Check the status of the Master channel
if amixer get Master | grep -q '$$on$$'; then
  status="Off"
  status_color="\e[31m" # Red
else
  status="On"
  status_color="\e[32m" # Green
fi

# Print the output
echo "Volume: ${volume}%"
echo -e "Status: ${status_color}${status}\e[0m"


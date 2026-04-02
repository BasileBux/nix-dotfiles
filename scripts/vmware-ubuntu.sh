#!/usr/bin/env bash

MODE="$1"
VMX="$2"
DEFAULT_USER="$3"
PASSWORD="$4"
IP="$5"
shift 5

USER="$DEFAULT_USER"

ACTION="$1"
shift

if [ "$MODE" = "user" ] && [[ "$ACTION" =~ ^(ssh|scp)$ ]]; then
  USER="$1"
  shift
fi

case "$ACTION" in
  start) 
    vmrun -T ws -gu $DEFAULT_USER -gp $PASSWORD start "$VMX" nogui 
    ;;
  stop)  
    vmrun -T ws -gu $DEFAULT_USER -gp $PASSWORD stop "$VMX" hard 
    ;;
  ssh)   
    kitten ssh "$USER@$IP" 
    ;;
  scp)   
    SOURCES=("${@:1:$#-1}")
    DEST="${!#}"
    scp -r "${SOURCES[@]}" "$USER@$IP:$DEST" 
    ;;
  *)     
    echo "Usage: <alias> {start|stop|ssh [user]|scp [user] src... dest}" 
    ;;
esac

#!/usr/bin/env bash

VMX="/home/basileb/vmware/Ubuntu_PIN_SOS_SLB_CSI_2025/Ubuntu_PIN_SOS_SLB_CSI_2025.vmx"

case "$1" in
  start) vmrun -T ws -gu sos -gp motdepasse start "$VMX" nogui ;;
  stop)  vmrun -T ws -gu sos -gp motdepasse stop "$VMX" hard ;;
  ssh)   shift; kitten ssh "$1"@192.168.223.128 ;;
  scp)   shift; scp -r "${@:2}" "$1"@192.168.223.128:"${@:3}" ;;
  *)     echo "Usage: $0 {start|stop|ssh user|scp user src... dest}" ;;
esac

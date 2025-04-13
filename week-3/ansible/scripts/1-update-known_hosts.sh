#!/bin/bash
# 1-update-known_hosts.sh
# This script reads the given inventory file, extracts all ansible_host IP addresses,
# removes any existing SSH key for each host, and then adds the current key using ssh-keyscan.
#
# Usage: bash 1-update-known_hosts.sh /absolute/path/to/inventory_file

if [ -z "$1" ]; then
  echo "Usage: $0 /path/to/inventory_file"
  exit 1
fi

INVENTORY_FILE="$1"

if [ ! -f "$INVENTORY_FILE" ]; then
  echo "Inventory file $INVENTORY_FILE not found!"
  exit 1
fi

echo "Scanning inventory file ($INVENTORY_FILE) for IP addresses..."
IPS=$(grep -Eo 'ansible_host=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' "$INVENTORY_FILE" | cut -d '=' -f2 | sort -u)

if [ -z "$IPS" ]; then
  echo "No IP addresses found in $INVENTORY_FILE."
  exit 0
fi

echo "Found the following IP addresses:"
echo "$IPS"

for ip in $IPS; do
  echo "Removing existing host key for $ip..."
  ssh-keygen -R "$ip" >/dev/null 2>&1
  echo "Scanning $ip..."
  ssh-keyscan -H "$ip" >> ~/.ssh/known_hosts 2>/dev/null
done

echo "All hosts have been updated in your known_hosts file."

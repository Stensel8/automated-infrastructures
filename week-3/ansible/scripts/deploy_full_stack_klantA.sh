#!/bin/bash
# =====================================================
# Full Infrastructure Deployment Script for klantA
# Unified inventory for both test & prod
# Copies AWS credentials and SSH keys from Windows to WSL
# Ensures files are in Unix format via dos2unix
# Author: Stensel8
# =====================================================

set -euo pipefail

# ------------------------
# 1) Install 3 main Dependencies
# ------------------------
curl -fsSL https://raw.githubusercontent.com/Stensel8/basic-scripts/refs/heads/main/docker_installer.sh | sudo bash
curl -fsSL https://raw.githubusercontent.com/Stensel8/basic-scripts/refs/heads/main/ansible_installer.sh | sudo bash
curl -fsSL https://raw.githubusercontent.com/Stensel8/basic-scripts/refs/heads/main/terraform_installer.sh | sudo bash

# Ensure jq is installed
if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found, installing jq..."
  sudo apt-get update && sudo apt-get install -y jq
fi

# Ensure dos2unix is installed
if ! command -v dos2unix >/dev/null 2>&1; then
  echo "dos2unix not found, installing dos2unix..."
  sudo apt-get update && sudo apt-get install -y dos2unix
fi

# ------------------------
# 2) Global Config
# ------------------------
PROJECT_ROOT="$HOME/automated-infrastructures"
ANSIBLE_DIR="$PROJECT_ROOT/week-3/ansible"

# Inventory template file with placeholders
INVENTORY_TEMPLATE="$ANSIBLE_DIR/inventories/inventory_template_with_vars.ini"
# Unified inventory output file
INVENTORY_OUTPUT="$ANSIBLE_DIR/inventories/KlantA.ini"

ANSIBLE_USER="ec2-user"
SSH_KEY_PATH="~/.ssh/awskey"  # Will be overwritten if the WSL copy is available
PYTHON_INTERPRETER="/usr/bin/python3"

OUTPUT_JSON="$PROJECT_ROOT/temp/tf_output.json"
mkdir -p "$(dirname "$OUTPUT_JSON")"

# Variables to hold extracted IP addresses
declare TEST_IP=""
declare WEB1_IP=""
declare WEB2_IP=""
declare LB_IP=""

# Environments to process
ENVIRONMENTS=("test" "prod")

# ------------------------
# 3) Deploy each environment
# ------------------------
for ENV in "${ENVIRONMENTS[@]}"; do
  echo "========================================"
  echo "Deploying environment: $ENV"
  echo "========================================"

  TERRAFORM_DIR="$PROJECT_ROOT/week-2/klantA/$ENV"
  echo "Navigating to Terraform directory: $TERRAFORM_DIR"
  cd "$TERRAFORM_DIR"

  echo "Running Terraform init..."
  terraform init -upgrade

  echo "Fixing execute permissions on Terraform providers..."
  find .terraform -type f -name "terraform-provider-*" -exec chmod +x {} \;

  read -p "Do you want to force destroy existing Terraform infrastructure for $ENV? (y/N): " DESTROY_ANSWER
  if [[ "$DESTROY_ANSWER" =~ ^[Yy]$ ]]; then
    echo "Force destroying $ENV infrastructure..."
    terraform destroy -auto-approve || { echo "Terraform destroy failed for $ENV. Exiting."; exit 1; }
    rm -f "$OUTPUT_JSON"
    echo "Destroyed existing $ENV infrastructure."
  fi

  echo "Re-initializing Terraform..."
  terraform init -upgrade
  echo "Fixing execute permissions on Terraform providers again..."
  find .terraform -type f -name "terraform-provider-*" -exec chmod +x {} \;

  if terraform state list | grep -q aws_instance; then
    echo "EC2 instances already exist in Terraform state for $ENV. Skipping apply."
    if [[ ! -f "$OUTPUT_JSON" ]]; then
      echo "ERROR: No existing output file found. Cannot continue."
      exit 1
    fi
  else
    echo ""
    echo "Detecting your operating system for $ENV..."
    if grep -qi microsoft /proc/version 2>/dev/null; then
      PLATFORM="WSL"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
      PLATFORM="Linux"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
      PLATFORM="Windows"
    else
      PLATFORM="Unknown"
    fi

    if [[ "$PLATFORM" == "WSL" ]]; then
      WIN_AWS_DIR="/mnt/c/Users/$USER/.aws"
      LINUX_AWS_DIR="$HOME/.aws"
      if [[ -d "$WIN_AWS_DIR" ]]; then
        echo "Copying AWS credentials from Windows user to WSL..."
        rm -rf "$LINUX_AWS_DIR"
        cp -r "$WIN_AWS_DIR" "$LINUX_AWS_DIR"
        echo "Credentials copied to $LINUX_AWS_DIR"
      else
        echo "WARNING: No .aws folder found at $WIN_AWS_DIR. Terraform may fail without valid AWS credentials."
      fi

      WIN_SSH_DIR="/mnt/c/Users/$USER/.ssh"
      if [[ -f "$WIN_SSH_DIR/awskey" ]]; then
        echo "Copying private key (awskey) from Windows .ssh to WSL..."
        mkdir -p "$HOME/.ssh"
        cp "$WIN_SSH_DIR/awskey" "$HOME/.ssh/awskey"
        chmod 600 "$HOME/.ssh/awskey"
        SSH_KEY_PATH="$HOME/.ssh/awskey"
      else
        echo "WARNING: No private key found at $WIN_SSH_DIR/awskey"
      fi

      if [[ -f "$WIN_SSH_DIR/awskey.pub" ]]; then
        echo "Copying public key (awskey.pub) from Windows .ssh to WSL..."
        mkdir -p "$HOME/.ssh"
        cp "$WIN_SSH_DIR/awskey.pub" "$HOME/.ssh/awskey.pub"
        chmod 644 "$HOME/.ssh/awskey.pub"
      else
        echo "WARNING: No public key found at $WIN_SSH_DIR/awskey.pub"
      fi
    fi

    case "$PLATFORM" in
      "WSL") DEFAULT_PUBKEY_PATH="/mnt/c/Users/$USER/.ssh/awskey.pub" ;;
      "Linux") DEFAULT_PUBKEY_PATH="$HOME/.ssh/awskey.pub" ;;
      "Windows") DEFAULT_PUBKEY_PATH="C:/Users/$USER/.ssh/awskey.pub" ;;
      *) DEFAULT_PUBKEY_PATH="$HOME/.ssh/awskey.pub" ;;
    esac

    echo "Detected platform: $PLATFORM"
    echo "Suggested public key path: $DEFAULT_PUBKEY_PATH"
    read -p "Enter path to public key [Press Enter to accept default]: " USER_PUBKEY_PATH
    PUBLIC_KEY_PATH="${USER_PUBKEY_PATH:-$DEFAULT_PUBKEY_PATH}"
    if [[ ! -f "$PUBLIC_KEY_PATH" ]]; then
      echo "ERROR: File does not exist at: $PUBLIC_KEY_PATH"
      exit 1
    fi
    echo "Using public key path: $PUBLIC_KEY_PATH"
    echo "public_key_path = \"$PUBLIC_KEY_PATH\"" > ./public_key_override.auto.tfvars

    echo "Running Terraform apply for $ENV..."
    terraform apply -auto-approve

    echo "Exporting Terraform outputs to $OUTPUT_JSON..."
    terraform output -json > "$OUTPUT_JSON"
  fi

  echo "Extracting IP addresses from $OUTPUT_JSON for $ENV"
  if [[ "$ENV" == "test" ]]; then
    TEST_IP="$(jq -r '.server_public_ips.value[0]' "$OUTPUT_JSON")"
    echo "Test server IP: $TEST_IP"
  else
    WEB1_IP="$(jq -r '.server_public_ips.value[0]' "$OUTPUT_JSON")"
    WEB2_IP="$(jq -r '.server_public_ips.value[1]' "$OUTPUT_JSON")"
    LB_IP="$(jq -r '.server_public_ips.value[2]' "$OUTPUT_JSON")"
    echo "Prod server IPs:"
    echo "  WEB1_IP = $WEB1_IP"
    echo "  WEB2_IP = $WEB2_IP"
    echo "  LB_IP   = $LB_IP"
  fi

  echo "Deployment for environment '$ENV' completed."
  echo "========================================"
  echo ""
done

# ------------------------
# 4) Generate a unified inventory for both test & prod
# ------------------------
echo "Generating unified Ansible inventory: $INVENTORY_OUTPUT"
cp "$INVENTORY_TEMPLATE" "$INVENTORY_OUTPUT"
sed -i "s|{{TEST_IP}}|$TEST_IP|g" "$INVENTORY_OUTPUT"
sed -i "s|{{WEB1_IP}}|$WEB1_IP|g" "$INVENTORY_OUTPUT"
sed -i "s|{{WEB2_IP}}|$WEB2_IP|g" "$INVENTORY_OUTPUT"
sed -i "s|{{LB_IP}}|$LB_IP|g" "$INVENTORY_OUTPUT"
sed -i "s|{{ANSIBLE_USER}}|$ANSIBLE_USER|g" "$INVENTORY_OUTPUT"
sed -i "s|{{SSH_KEY_PATH}}|$SSH_KEY_PATH|g" "$INVENTORY_OUTPUT"
sed -i "s|{{PYTHON_INTERPRETER}}|$PYTHON_INTERPRETER|g" "$INVENTORY_OUTPUT"

echo "Converting unified inventory file to Unix format..."
dos2unix "$INVENTORY_OUTPUT"

# ------------------------
# 5) Update known_hosts before running Ansible
# ------------------------
echo "Updating known_hosts file..."
if [ -f "$ANSIBLE_DIR/scripts/1-update-known_hosts.sh" ]; then
  bash "$ANSIBLE_DIR/scripts/1-update-known_hosts.sh" "$INVENTORY_OUTPUT"
else
  echo "Warning: update_known_hosts script not found. Skipping known_hosts update."
fi

# ------------------------
# 6) Wait for instances to be fully ready
# ------------------------
echo "Waiting for 10 seconds to ensure all instances are ready..."
for i in {10..1}; do
  echo "Waiting for ${i}s..."
  sleep 1
done

# ------------------------
# 7) Run Ansible playbooks using the unified inventory
# ------------------------
echo "Deploying Ansible playbooks using the unified inventory ($INVENTORY_OUTPUT)..."
cd "$ANSIBLE_DIR/playbooks"
ansible-playbook -i ../inventories/KlantA.ini 1-install-docker.yml
ansible-playbook -i ../inventories/KlantA.ini 2-install-wordpress.yml
ansible-playbook -i ../inventories/KlantA.ini 3-install-loadbalancer.yml

echo "All environments deployed and Ansible tasks completed successfully!"

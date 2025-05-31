#!/bin/bash

# install_packages.sh - Install packages on RHEL-based systems
source .env

# Check the OS is CentOS, RHEL or Fedora
if [ ! -f /etc/redhat-release ]; then
    echo "This script is intended for CentOS, RHEL, or Fedora systems only."
    exit 1
fi

# List your packages here
PACKAGES=(
    nano
    wget
    htop
    net-tools
    fail2ban
    ufw
    
)

# //// Example - Add the Netbird repository

# # Netbird is a secure, open-source VPN solution.
# # This section installs Netbird and sets it up with a setup key.

# //// Make sure to set the setupkey for Netbird in the .env file

# # Example .env file content:
# # setupkey=your_setup_key_here

# Load environment variables from .env file

if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo ".env file not found. Please create a .env file with the required variables."
    exit 1
fi

echo "Install ca-certificats, curl, gnupg, add netbird sources..."
sudo dnf update
sudo dnf install ca-certificates curl gnupg -y

echo "Adding netbird repository..."
curl -fsSL https://pkgs.netbird.io/install.sh | sh

# Check if setupkey is set in the .env file 
if [ -z "$setupkey" ]; then
    echo "Error: setupkey is not set in the .env file."
    exit 1
fi

echo "Install netbird... "
sudo dnf update
sudo dnf install netbird -y


echo "Run netbird and setup setupkey..."
netbird up --setup-key ${setupkey}

# Enable netbird service
echo "Enable netbird service..."
sudo systemctl enable netbird
echo "Starting netbird service..."
sudo systemctl start netbird

echo "Netbird installation and setup complete."

#
echo "Updating package list..."
sudo dnf update

echo "Installing packages: ${PACKAGES[*]}"
sudo dnf install -y "${PACKAGES[@]}"

echo "All packages installed."
echo "Installation script completed successfully."

# Clean up unused packages
echo "Cleaning up ..."
sudo dnf autoremove -y
echo "Cleanup complete."
echo "Installation of custom base packages completed successfully."

# echo "Cleaning up package cache..."
# sudo dnf clean all
# echo "Package cache cleaned."

echo "You can now use the installed packages."
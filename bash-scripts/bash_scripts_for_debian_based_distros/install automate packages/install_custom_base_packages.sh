#!/bin/bash

# install_packages.sh - Install packages on Debian-based systems


# Check if the OS is Debian-based
if [ ! -f /etc/debian_version ]; then
    echo "This script is intended for Debian-based systems only."
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

# # Make sure to set the setupkey for Netbird in the .env file

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
sudo apt update
sudo apt install ca-certificates curl gnupg -y

echo "Adding netbird repository..."
curl -fsSL https://pkgs.netbird.io/install.sh | sh

echo "Install netbird... "
sudo apt update
sudo apt install netbird -y


echo "Run netbird and setup setupkey..."
netbird up --setup-key ${setupkey}

echo "Enable netbird service..."
sudo systemctl enable netbird
echo "Starting netbird service..."
sudo systemctl start netbird

echo "Netbird installation and setup complete."

echo "Updating package list..."
sudo apt update

echo "Installing packages: ${PACKAGES[*]}"
sudo apt install -y "${PACKAGES[@]}"

echo "All packages installed."

# echo "Cleaning up package cache..."
# sudo apt clean    
# echo "Package cache cleaned."

# Clean up unused packages
echo "Cleaning up ..."
sudo apt autoremove -y
echo "Cleanup complete."
echo "Installation of custom base packages completed successfully."
echo "You can now use the installed packages."
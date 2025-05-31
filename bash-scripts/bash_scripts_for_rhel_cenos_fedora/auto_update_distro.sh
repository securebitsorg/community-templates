#! bin/bash

# auto_update_distro.sh - Automatically update the system on RHEL-based systems

# Check if the OS is RHEL-based
if [ ! -f /etc/redhat-release ]; then
    echo "This script is intended for RHEL-based systems only."
    exit 1
fi

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use 'sudo' or switch to the root user."
    exit 1
fi
# Check if the system is already up to date
if sudo dnf check-update | grep -q 'No packages marked for update'; then
    echo "The system is already up to date."
    exit 0
fi
# Check if the system is running a supported version
if ! grep -qE 'CentOS Linux release 7|CentOS Linux release 8|Fedora release' /etc/redhat-release; then
    echo "This script is intended for CentOS 7, CentOS 8, or Fedora systems only."
    exit 1
fi
# Check if the system has enough disk space
if ! df -h / | awk 'NR==2 {exit ($5+0 > 90)}'; then
    echo "Insufficient disk space. Please free up some space before running this script."
    exit 1
fi
# Check if the system has enough memory
if ! free -m | awk 'NR==2 {exit ($2 < 1024)}'; then
    echo "Insufficient memory. Please ensure the system has at least 1GB of RAM before running this script."
    exit 1
fi
# Check if the system has a stable network connection
if ! ping -c 1 google.com &> /dev/null; then
    echo "No stable network connection. Please check your network settings."
    exit 1
fi
# Check if the system has the necessary permissions to run the script
if [ ! -w /var/log ]; then
    echo "Insufficient permissions to write to /var/log. Please run this script as root or with sudo."
    exit 1
fi

# Clean the package cache
echo "Cleaning the package cache..."
sudo dnf clean all
if [ $? -ne 0 ]; then
    echo "Failed to clean the package cache. Please check your system configuration."
    exit 1
fi

# Update the system
echo "Updating the system..."
sudo dnf update -y
if [ $? -ne 0 ]; then
    echo "Failed to update the system. Please check your network connection or repository configuration."
    exit 1
fi
# Upgrade the system
echo "Upgrading the system..."
sudo dnf upgrade -y
if [ $? -ne 0 ]; then
    echo "Failed to upgrade the system. Please check your network connection or repository configuration."
    exit 1
fi
# Clean up old packages
echo "Cleaning up old packages..."
sudo dnf autoremove -y
if [ $? -ne 0 ]; then
    echo "Failed to clean up old packages. Please check your system configuration."
    exit 1
fi

# Display the current system status
echo "System update and upgrade completed successfully."

# Reboot the system if necessary
if [ -f /var/run/reboot-required ]; then
    echo "Rebooting the system..."
    sudo reboot
else
    echo "No reboot is required."
fi

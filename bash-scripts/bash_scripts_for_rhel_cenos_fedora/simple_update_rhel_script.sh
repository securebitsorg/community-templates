#!/bin/bash


# Version: 1.0



# Hinweis:

# Dieses Script ist für RHEL-basierte Systeme gedacht.

# Es aktualisiert das System und entfernt nicht mehr benötigte Pakete.

# Es überprüft, ob ein Neustart des Systems erforderlich ist und startet es gegebenenfalls SOFORT neu.

# Es ist wichtig, dass das Script als root ausgeführt wird.



# Anwendung:

# sudo chmod +x simple_update_RHEL_script.sh

# sudo ./simple_update_RHEL_script.sh



# Info:

# This script is intended for RHEL-based systems.

# It updates the system and removes unused packages.

# It checks if a system restart is required and restarts the system if necessary.

# It is important that the script is run as root.



# Using:

# sudo chmod +x simple_update_RHEL_script.sh

# sudo ./simple_update_RHEL_script.sh







# Automatisches Update-Script für RHEL-basierte Systeme / Automatic update script for RHEL-based systems



echo "================================================================="

echo "     Automatisches System-Update / Automatic system update"

echo "        (RHEL/Fedora/CentOS)"

echo "================================================================="



# Prüfen, ob root-Rechte vorhanden sind / Check if root privileges are present

if [ "$EUID" -ne 0 ]; then

  echo "Bitte führen Sie dieses Script als root aus (sudo) / Please run this script as root (sudo)."

  exit 1

fi



# Prüfen, ob apt verfügbar ist / Check if apt is available

if ! command -v dnf >/dev/null 2>&1; then

  echo "Kein 'dnf'-Paketmanager gefunden. Dieses Script funktioniert nur auf RHEL-basierten Systemen / No 'dnf' package manager found. This script only works on RHEL-based systems."

  exit 2

fi



# Paketquellen aktualisieren / Update package sources

echo "Aktualisiere Paketquellen und Installation von Updates/ Update package sources and update packges"

dnf update -y



# Nicht mehr benötigte Pakete entfernen / Remove unused packages

echo "Entferne nicht mehr benötigte Pakete / Remove unused packages"

dnf autoremove -y



# Paketdatenbank bereinigen / Clean up cached package data

echo "Bereinige zwischengespeicherte Paketdaten / Clean up cached package data"

dnf clean all



echo "================================================================="

echo "      System-Update abgeschlossen / System update completed"

echo "================================================================="



# Überprüfen ob ein Neustart des Systems erforderlich ist / Check if a system restart is required

if [ -f /var/run/reboot-required ]; then

  echo "Ein Neustart des Systems ist erforderlich. Das System wird jetzt neu gestartet / A system restart is required. The system will now restart."

  reboot

fi



# Ende des Scripts / End of script

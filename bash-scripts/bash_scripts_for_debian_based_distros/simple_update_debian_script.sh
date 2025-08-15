#!/bin/bash

# Hinweis:
# Dieses Script ist für Debian-basierte Systeme gedacht.
# Es aktualisiert das System und entfernt nicht mehr benötigte Pakete.
# Es überprüft, ob ein Neustart des Systems erforderlich ist und startet es gegebenenfalls SOFORT neu.
# Es ist wichtig, dass das Script als root ausgeführt wird.

# Anwendung:
# sudo chmod +x simple_update_debian_script.sh
# sudo ./simple_update_debian_script.sh

# Info:
# This script is intended for Debian-based systems.
# It updates the system and removes unused packages.
# It checks if a system restart is required and restarts the system if necessary.
# It is important that the script is run as root.

# Using:
# sudo chmod +x simple_update_debian_script.sh
# sudo ./simple_update_debian_script.sh



# Automatisches Update-Script für Debian-basierte Systeme / Automatic update script for Debian-based systems

echo "================================================================="
echo "     Automatisches System-Update / Automatic system update"
echo "        (Debian/Ubuntu/Mint)"
echo "================================================================="

# Prüfen, ob root-Rechte vorhanden sind / Check if root privileges are present
if [ "$EUID" -ne 0 ]; then
  echo "Bitte führen Sie dieses Script als root aus (sudo) / Please run this script as root (sudo)."
  exit 1
fi

# Prüfen, ob apt verfügbar ist / Check if apt is available
if ! command -v apt >/dev/null 2>&1; then
  echo "Kein 'apt'-Paketmanager gefunden. Dieses Script funktioniert nur auf Debian-basierten Systemen / No 'apt' package manager found. This script only works on Debian-based systems."
  exit 2
fi

# Paketquellen aktualisieren / Update package sources
echo "Aktualisiere Paketquellen / Update package sources"
apt update -y

# Upgrades installieren / Install available updates
echo "Installiere verfügbare Updates / Install available updates"
apt upgrade -y

# Optionale Komplett-Aktualisierung (inklusiver Entfernungen/Neuinstallationen) / Optional full upgrade (including removals/reinstallations)
echo "Führe vollständige Aktualisierung durch / Run full upgrade"
apt full-upgrade -y

# Nicht mehr benötigte Pakete entfernen / Remove unused packages
echo "Entferne nicht mehr benötigte Pakete / Remove unused packages"
apt autoremove -y


# Paketdatenbank bereinigen / Clean up cached package data
echo "Bereinige zwischengespeicherte Paketdaten / Clean up cached package data"
apt clean

echo "================================================================="
echo "      System-Update abgeschlossen / System update completed"
echo "================================================================="

# Überprüfen ob ein Neustart des Systems erforderlich ist / Check if a system restart is required
if [ -f /var/run/reboot-required ]; then
  echo "Ein Neustart des Systems ist erforderlich. Das System wird jetzt neu gestartet / A system restart is required. The system will now restart."
  reboot
fi

# Ende des Scripts / End of script

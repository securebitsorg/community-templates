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

# Automatisieren:
# Sie können dieses Script in regelmäßigen Abständen mit einem Cron-Job ausführen, um Ihr System automatisch auf dem neuesten Stand zu halten. Zum Beispiel könnten Sie es einmal pro Woche ausführen lassen.
# Öffnen Sie die Crontab mit dem Befehl: sudo crontab -e
# Fügen Sie die folgende Zeile hinzu, um das Script jeden Sonntag um 3 Uhr morgens auszuführen:

# 0 3 * * 0 /pfad/zu/simple_update_rhel_script.sh 

# Info:

# This script is intended for RHEL-based systems.

# It updates the system and removes unused packages.

# It checks if a system restart is required and restarts the system if necessary.

# It is important that the script is run as root.



# Using:

# sudo chmod +x simple_update_RHEL_script.sh

# sudo ./simple_update_RHEL_script.sh

# Automating:
# You can set up a cron job to run this script at regular intervals to keep your system up to date. For example, you could run it once a week.
# Open the crontab with the command: sudo crontab -e
# Add the following line to run the script every Sunday at 3 AM: 

# 0 3 * * 0 /path/to/simple_update_rhel_script.sh





# Automatisches Update-Script für RHEL-basierte Systeme / Automatic update script for RHEL-based systems



echo "================================================================="

echo "     Automatisches System-Update / Automatic system update       "

echo "        (RHEL/Fedora/CentOS)                                     "

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

echo "      System-Update abgeschlossen / System update completed      "
echo "              [$(date '+%Y-%m-%d %H:%M:%S')] Script beendet      "
echo "================================================================="



# Überprüfen ob ein Neustart des Systems erforderlich ist / Check if a system restart is required

if [ -f /var/run/reboot-required ]; then

  echo "Ein Neustart des Systems ist erforderlich. Das System wird jetzt neu gestartet / A system restart is required. The system will now restart."

  reboot

fi



# Ende des Scripts / End of script

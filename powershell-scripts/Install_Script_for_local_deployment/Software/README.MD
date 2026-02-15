# Powershell-Script für die Installation von MSI-Pakete
Ein Script für die automatische Installation von MSI-Paketen die sich zum Beispiel auf einen USB-Stick befinden. Also das perfekte Script für einen "Turnschuh-Administrator" ;-)

## Was macht dieses Powershell-Script?

Wenn zum Beispiel kein automatisches Deployment via GPO, Tools, etc. möglich ist, kann dieses Script zum Beispiel auf einem USB-Installations-Stick genutzt werden.

## Vorbereitung
### Ordnerstruktur auf dem USB-Stick
```sh
USB-STICK (Laufwerk)
└── Software
    ├── starten.bat       
    ├── install.ps1       
    ├── netbird.env    
    ├── firefox.msi       
    ├── chrome.msi
    └── netbird.msi
```
1. Erstellen eines Ordners '**Software**' auf dem USB-Stick.
2. In diesem Ordner kopieren wir die **msi-Pakete** hinein, die via Script installierte werden sollen. In diesem Beispiel '**netbird, firefox, chrome**'.
3. Das Powershell-Script für die Installation selbst, sowie eine die **BAT-Datei 'starten.bat**' mit dem das Powershell-Script '**install_msi_packages_from_usb_stick.ps1**'
4. Sollten irgendwelche Secrets genutzt werden, so können diese in einer '.env' als Variable hineingeschrieben werden und dann mit dem Variablennamen im Powershell-Script aufgerufewn werden.
**Beispiel:**

`SETUP_KEY=abskdfodjkdfgjdklfgjdsfgjkldlkfgjd`

wird dann im Script mit 'SETUP_KEY' aufgerufen.

### Anwenden

Um das Script auszuführen und damit den Installationsprozess der MSI-Pakete zu starten, wir einfach mit einem Rechtsklick auf die Datei **'starten.bat'**, '**Als Administrator ausführen**' ausgeführt.
Dann öffnet sich ein Terminalfenster und hier sehrt ihr dann, wie der Installationsprozess durchgeführt wird.

# PowerShell Script for Installing MSI Packages

A script for the automated installation of MSI packages located, for example, on a USB drive. This makes it ideal for a “sneaker administrator” scenario.

## What does this PowerShell script do?

If automated deployment via GPO, management tools, or similar methods is not possible, this script can be used from a USB installation drive.

### Preparation
Folder structure on the USB drive

```sh
USB-DRIVE
└── Software
    ├── starten.bat       
    ├── install.ps1       
    ├── netbird.env    
    ├── firefox.msi       
    ├── chrome.msi
    └── netbird.msi
```
1. Create a folder named Software on the USB drive.

2. Copy the MSI packages that should be installed via the script into this folder. In this example: netbird, firefox, chrome.

3. Add the PowerShell installation script as well as the BAT file starten.bat, which launches the PowerShell script install_msi_packages_from_usb_stick.ps1.

4. If any secrets are required, they can be stored as variables in a .env file and referenced in the PowerShell script using the variable name.

**Example**:
`
SETUP_KEY=abskdfodjkdfgjdklfgjdsfgjkldlkfgjd`

This can then be accessed in the script using 'SETUP_KEY'.

### Usage

To execute the script and start the MSI installation process, simply right-click on the file '**starten.bat**' and select '**Run as administrator**'.

A terminal window will open, displaying the progress of the installation process.
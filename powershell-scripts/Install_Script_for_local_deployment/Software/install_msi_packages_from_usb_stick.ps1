<#
.SYNOPSIS
    USB-Deploy-Tool:
    1. Prüft Admin-Rechte.
    2. Installiert/Updated MSI-Pakete.
    3. Zeigt Fortschrittsbalken & Restzeit an.
    4. Gibt am Ende eine Zusammenfassung aus.

    USB Deployment Tool:
    1. Checks for admin rights.
    2. Installs/updates MSI packages.
    3. Shows progress bar & remaining time.
    4. Provides a summary at the end.
#>

# --- 1. INITIALISIERUNG / Initialization ---

# Admin-Check
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "ACHTUNG: Bitte Rechtsklick auf die Datei -> 'Mit PowerShell ausführen' (Admin)."
    Start-Sleep -Seconds 5
    Exit
}

$quellenPfad = $PSScriptRoot
$logPfad = "$quellenPfad\InstallLogs"

# Log-Verzeichnis / Log directory
if (!(Test-Path $logPfad)) { New-Item -ItemType Directory -Force -Path $logPfad | Out-Null }

# Bericht-Liste initialisieren / Initialize report list
$report = @()

# --- 2. NETBIRD CONFIG LADEN / LOAD NETBIRD CONFIG ---
$envDatei = "$quellenPfad\netbird.env"
$netbirdConfig = @{}
if (Test-Path $envDatei) {
    Write-Host "Konfiguration: netbird.env gefunden." -ForegroundColor Cyan
    Get-Content $envDatei | Where-Object { $_ -match '=' } | ForEach-Object {
        $key, $value = $_.Split('=', 2)
        $netbirdConfig[$key.Trim()] = $value.Trim()
    }
}

# --- 3. HILFSFUNKTIONEN / Helper Functions ---

function Get-MsiInternalName {
    param([string]$MsiPath)
    try {
        $windowsInstaller = New-Object -ComObject WindowsInstaller.Installer
        $database = $windowsInstaller.OpenDatabase($MsiPath, 0)
        $view = $database.OpenView("SELECT Value FROM Property WHERE Property = 'ProductName'")
        $view.Execute()
        $record = $view.Fetch()
        if ($record) { return $record.StringData(1) }
        return $null
    }
    catch { return $null }
    finally { [System.Runtime.Interopservices.Marshal]::ReleaseComObject($windowsInstaller) | Out-Null }
}

function Get-InstalledApp {
    param([string]$Name)
    $pfade = @("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*")
    return Get-ItemProperty $pfade | Where-Object { $_.DisplayName -eq $Name } | Select-Object DisplayName, DisplayVersion, PSChildName -First 1
}

function Format-TimeSpanString {
    param([double]$Seconds)
    $ts = [TimeSpan]::FromSeconds($Seconds)
    return "{0:D2}:{1:D2}" -f [int]$ts.TotalMinutes, $ts.Seconds
}

# --- 4. HAUPTPROGRAMM / Main-Program ---

$msiPakete = Get-ChildItem -Path $quellenPfad -Filter *.msi
if ($msiPakete.Count -eq 0) { Write-Host "Keine .msi Dateien gefunden."; Pause; Exit }

$totalPakete = $msiPakete.Count
$aktuellerIndex = 0
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

Write-Host "--------------------------------------------------------"
Write-Host "Gefunden: $totalPakete Pakete. Start..." -ForegroundColor Cyan
Write-Host "--------------------------------------------------------"

foreach ($paket in $msiPakete) {
    $aktuellerIndex++
    $typ = "Neuinstallation" # Standardwert / Default type
    
    # Zeitberechnung / Time calculation
    $verstrichen = $stopwatch.Elapsed.TotalSeconds
    $zeitText = "Laufzeit: $(Format-TimeSpanString $verstrichen)"
    if ($aktuellerIndex -gt 1) {
        $avgProPaket = $verstrichen / ($aktuellerIndex - 1)
        $restSekunden = $avgProPaket * ($totalPakete - ($aktuellerIndex - 1))
        $zeitText += " | Rest ca.: $(Format-TimeSpanString $restSekunden)"
    } else {
        $zeitText += " | Rest ca.: Berechne..."
    }
    $prozent = ($aktuellerIndex / $totalPakete) * 100
    
    # A) Namen ermitteln / Get internal name
    $internerName = Get-MsiInternalName -MsiPath $paket.FullName
    if ([string]::IsNullOrWhiteSpace($internerName)) { $internerName = $paket.Name }

    Write-Progress -Activity "Installation ($aktuellerIndex/$totalPakete)" -Status "Prüfe: $internerName" -CurrentOperation $zeitText -PercentComplete $prozent
    Write-Host "`n[$aktuellerIndex/$totalPakete] $internerName" -ForegroundColor White
    
    # B) Prüfen auf Alt-Version / Check for old version
    $alteVersion = Get-InstalledApp -Name $internerName
    
    if ($alteVersion) {
        $typ = "Update"
        Write-Host "  -> Clean Install (Entferne Alt-Version)..." -ForegroundColor Yellow
        Write-Progress -Activity "Installation ($aktuellerIndex/$totalPakete)" -Status "Deinstalliere Alt-Version..." -CurrentOperation $zeitText -PercentComplete $prozent
        
        $guid = $alteVersion.PSChildName
        $logUninstall = "$logPfad\$($paket.Name)_uninstall.log"
        Start-Process -FilePath "msiexec.exe" -ArgumentList "/x `"$guid`" /qn /norestart /L*v `"$logUninstall`"" -Wait
    }

    # C) Installation / Installation
    Write-Host "  -> Installiere..." -NoNewline
    $verstrichen = $stopwatch.Elapsed.TotalSeconds
    $zeitText = "Laufzeit: $(Format-TimeSpanString $verstrichen)"
    Write-Progress -Activity "Installation ($aktuellerIndex/$totalPakete)" -Status "Installiere $internerName..." -CurrentOperation $zeitText -PercentComplete $prozent

    $logInstall = "$logPfad\$($paket.Name)_install.log"
    $installArgs = "/i `"$($paket.FullName)`" /qn /norestart /L*v `"$logInstall`""
    if ($paket.Name -match "netbird" -and $netbirdConfig.Count -gt 0) {
        if ($netbirdConfig["NB_INSTALL_KEY"]) { $installArgs += " NB_INSTALL_KEY=`"$($netbirdConfig['NB_INSTALL_KEY'])`"" }
        if ($netbirdConfig["NB_MANAGEMENT_URL"]) { $installArgs += " NB_MANAGEMENT_URL=`"$($netbirdConfig['NB_MANAGEMENT_URL'])`"" }
    }

    $ergebnisStatus = "FEHLER"
    try {
        $procInst = Start-Process -FilePath "msiexec.exe" -ArgumentList $installArgs -Wait -PassThru
        
        if ($procInst.ExitCode -eq 0) {
            Write-Host " [OK]" -ForegroundColor Green
            $ergebnisStatus = "OK"
        } elseif ($procInst.ExitCode -eq 3010) {
            Write-Host " [NEUSTART]" -ForegroundColor Yellow
            $ergebnisStatus = "OK (Reboot)"
        } else {
            Write-Host " [FEHLER]" -ForegroundColor Red
            $ergebnisStatus = "FEHLER ($($procInst.ExitCode))"
        }
    }
    catch { 
        Write-Error "Fehler: $_" 
        $ergebnisStatus = "EXCEPTION"
    }

    # Ergebnis zum Bericht hinzufügen / Add result to report
    $report += [PSCustomObject]@{
        Software = $internerName
        Aktion   = $typ
        Status   = $ergebnisStatus
    }
}

$stopwatch.Stop()
Write-Progress -Activity "Installation" -Completed

# --- 5. ZUSAMMENFASSUNG / Summary ---
Write-Host "`n--------------------------------------------------------"
Write-Host "ZUSAMMENFASSUNG" -ForegroundColor Cyan
Write-Host "--------------------------------------------------------"

# Tabelle ausgeben / Table output
$report | Format-Table -AutoSize

Write-Host "Gesamtdauer: $(Format-TimeSpanString $stopwatch.Elapsed.TotalSeconds) Minuten."
Write-Host "Logs liegen unter: $logPfad"
Pause
#########################################################################
# Fichier: gestion.ps1
# Description: Script de validation (via powershell).
# Auteur: John Doe <john.doe@example.com>
# Date de création: 2025-01-08
# Dernière modification: 2025-01-08 01:58:56
#########################################################################
# Nombre de lignes: 82
#########################################################################
# Liste des éléments:
# Fonction: Write-Log (pas de description)
# Fonction: Write-NpmLog (pas de description)
# Fonction: Write-WidthLog (pas de description)
# Fonction: Check-FileWidth (pas de description)
# Fonction: Invoke-Scripts (pas de description)
# Variable: $scriptsToExecute = @(
#########################################################################
# Dépendances:
# Commande externe: powershell
#########################################################################
function Write-Log {
    param (
        [string]$message
    )
    $logFile = "install.log"
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logFile -Value "[$timestamp] $message"
}

function Write-NpmLog {
    param (
        [string]$message
    )
    $logFile = "npm.log"
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logFile -Value "[$timestamp] $message"
}

function Write-WidthLog {
    param (
        [string]$message
    )
    $logFile = "witdh_files.log"
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logFile -Value "[$timestamp] $message"
}

function Check-FileWidth {
    param (
        [string]$filePath
    )
    $lineCount = (Get-Content $filePath).Count
    if ($lineCount -gt 200) {
        Write-WidthLog "File $filePath exceeds 200 lines: $lineCount lines"
    }
}

function Invoke-Scripts {
    param (
        [string[]]$scripts
    )

    foreach ($script in $scripts) {
        Check-FileWidth -filePath ${script}
        try {
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File ${script}" -Wait
            Write-Log "Executed: ${script}"
        } catch {
            Write-Log "Error executing ${script}: $_"
            Write-NpmLog "NPM Error: $_"
        }
    }
}

# Example usage
$scriptsToExecute = @(
    'script1.ps1',
    'script2.ps1',
    'script3.ps1'
)

Invoke-Scripts -scripts $scriptsToExecute

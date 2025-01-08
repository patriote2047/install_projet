#########################################################################
# Module: file_logger.ps1
# Description: Fonctions de base pour l'écriture des logs
# Date: 2025-01-08
# Version: 1.0
#########################################################################

# Configuration globale des logs (importée depuis logs_files.ps1)
# $script:LogConfig

function Write-LogMessage {
    <#
    .SYNOPSIS
        Interface principale pour écrire des logs
    .DESCRIPTION
        Gère l'écriture des logs avec rotation automatique et limitation des lignes
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = $script:LogConfig.DefaultLogLevel,
        
        [Parameter(Mandatory = $false)]
        [string]$Module = "General"
    )
    
    $logFile = Join-Path -Path $script:LogConfig.LogsFolder -ChildPath "$Module.log"
    
    # Initialiser le fichier si nécessaire
    if ($script:LogConfig.LogHeaders.ContainsKey($Module)) {
        Initialize-LogFile -LogType $Module -FilePath $logFile
    }
    elseif (-not (Test-Path $logFile)) {
        Set-Content -Path $logFile -Value ""
    }
    
    # Vérifier le nombre de lignes
    if (Test-Path $logFile) {
        $content = Get-Content $logFile
        $header = if ($script:LogConfig.LogHeaders.ContainsKey($Module)) {
            $content | Select-Object -First 7
        } else { @() }
        
        $logs = $content | Select-Object -Skip ($header.Count + 1)  # +1 pour la ligne vide
        
        if ($logs.Count -ge $script:LogConfig.MaxLines) {
            Start-LogRotation -LogFile $logFile -Module $Module
            $content = $header
            $logs = @()
        }
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    $newContent = @()
    if ($header) {
        $newContent += $header
        $newContent += ""
    }
    
    # Toujours écrire les logs du plus récent au plus ancien
    $newContent += $logMessage
    if ($logs) {
        $newContent += $logs | Sort-Object -Descending { 
            if ($_ -match '^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]') {
                [datetime]::ParseExact($matches[1], 'yyyy-MM-dd HH:mm:ss', $null)
            }
        }
    }
    
    Set-Content -Path $logFile -Value $newContent -Force
}

function Write-HeaderCheckLog {
    <#
    .SYNOPSIS
        Écrit un message dans le fichier header_check.log
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = $script:LogConfig.DefaultLogLevel,
        
        [Parameter(Mandatory = $false)]
        [string]$FileName
    )
    
    $fullMessage = if ($FileName) {
        "[$FileName] $Message"
    } else {
        $Message
    }
    
    Write-LogMessage -Message $fullMessage -Level $Level -Module "HeaderCheck"
}

function Write-WidthFilesLog {
    <#
    .SYNOPSIS
        Écrit un message dans le fichier de log des largeurs de fichiers
    .DESCRIPTION
        Enregistre les informations sur la largeur des lignes dans les fichiers
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        
        [Parameter(Mandatory = $true)]
        [int]$LineWidth,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = "Info"
    )
    
    $logMessage = "$Message (Fichier: $FileName, Largeur: $LineWidth)"
    Write-LogMessage -Message $logMessage -Level $Level -Module "WidthFiles"
}

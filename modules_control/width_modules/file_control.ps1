#########################################################################
# Module: file_control.ps1
# Description: Fonctions de contrôle et de gestion des fichiers
# Date: 2025-01-08
# Version: 1.0
#########################################################################

function Initialize-LogFile {
    <#
    .SYNOPSIS
        Initialise un fichier de log avec son en-tête
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogType,
        
        [Parameter(Mandatory = $true)]
        [string]$FilePath
    )
    
    if (-not (Test-Path $FilePath)) {
        $header = @"
#########################################################################
# Fichier: $($script:LogConfig.LogHeaders[$LogType].Name)
# Description: $($script:LogConfig.LogHeaders[$LogType].Description)
# Date de création: $(Get-Date -Format "yyyy-MM-dd")
# Limite de lignes: $($script:LogConfig.LogHeaders[$LogType].LineLimit)
#########################################################################

"@
        Set-Content -Path $FilePath -Value $header
    }
}

function Test-LogSystem {
    <#
    .SYNOPSIS
        Vérifie le bon fonctionnement du système de logging
    #>
    param()
    
    try {
        Write-LogMessage -Message "Test du système de logging" -Level "Info" -Module "System"
        Remove-OldLogs
        return $true
    }
    catch {
        Write-Error "Erreur lors du test du système de logging: $_"
        return $false
    }
}

function Remove-OldLogs {
    <#
    .SYNOPSIS
        Supprime les logs plus anciens que MaxLogAge
    #>
    param()
    
    $archivePath = Join-Path -Path $script:LogConfig.LogsFolder -ChildPath "archives"
    $cutoffDate = (Get-Date).AddDays(-$script:LogConfig.MaxLogAge)
    
    Get-ChildItem -Path $archivePath -File | Where-Object {
        $_.LastWriteTime -lt $cutoffDate
    } | Remove-Item -Force
}

function Test-FileLineCount {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter(Mandatory = $false)]
        [switch]$AutoSplit
    )

    $lineCount = (Get-Content $FilePath).Count
    $maxLines = 200
    
    Write-Verbose "Analyse du fichier : $FilePath"
    Write-Verbose "Nombre de lignes : $lineCount"
    
    if ($lineCount -gt $maxLines) {
        Write-Warning "Dépassement détecté dans $FilePath."
        Write-Warning "Lancement du script de division..."
        
        if ($AutoSplit) {
            Split-FileIntoModules -FilePath $FilePath
        }
        return $false
    }
    
    return $true
}

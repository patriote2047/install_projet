#########################################################################
# Module: logs_files_part2
# Description: Partie 2 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

function Write-LogMessage {
    <#
    .SYNOPSIS
        Interface principale pour Ã©crire des logs
    .DESCRIPTION
        GÃ¨re l'Ã©criture des logs avec rotation automatique et limitation des lignes
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
    
    # Initialiser le fichier si nÃ©cessaire
    if ($script:LogConfig.LogHeaders.ContainsKey($Module)) {
        Initialize-LogFile -LogType $Module -FilePath $logFile
    }
    elseif (-not (Test-Path $logFile)) {
        Set-Content -Path $logFile -Value ""
    }
    
    # VÃ©rifier le nombre de lignes (en excluant l'en-tÃªte)
    if (Test-Path $logFile) {
        $content = Get-Content $logFile
        $header = if ($script:LogConfig.LogHeaders.ContainsKey($Module)) {
            $content | Select-Object -First 7
        } else { @() }
        
        $logs = $content | Select-Object -Skip ($header.Count)
        
        if ($logs.Count -ge $script:LogConfig.MaxLines) {
            Start-LogRotation -LogFile $logFile -Module $Module
            $content = $header
            $logs = @()
        }
    }
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    if ($script:LogConfig.ShowNewestFirst) {
        $newContent = @()
        if ($header) {
            $newContent += $header
            $newContent += ""
        }
        $newContent += $logMessage
        if ($logs) {
            $newContent += $logs
        }
        
        Set-Content -Path $logFile -Value $newContent
    } else {
        if ($header) {
            Set-Content -Path $logFile -Value $header
            Add-Content -Path $logFile -Value ""
        }
        Add-Content -Path $logFile -Value $logMessage
        if ($logs) {
            Add-Content -Path $logFile -Value $logs
        }
    }
}



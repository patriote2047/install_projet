#########################################################################
# Module: logs_files_part8
# Description: Partie 8 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

function Get-LastLogs {
    <#
    .SYNOPSIS
        RÃ©cupÃ¨re les derniers logs d'un module
    .DESCRIPTION
        Affiche les derniers logs avec possibilitÃ© de filtrer par niveau
    #>
    param(
        [Parameter(Mandatory = $false)]
        [string]$Module = "General",
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level,
        
        [Parameter(Mandatory = $false)]
        [int]$Count = 10
    )
    
    $logFile = Join-Path -Path $script:LogConfig.LogsFolder -ChildPath "$Module.log"
    if (-not (Test-Path $logFile)) {
        Write-Warning "Aucun fichier de log trouvÃ© pour le module $Module"
        return @()
    }
    
    $content = Get-Content $logFile
    $header = if ($script:LogConfig.LogHeaders.ContainsKey($Module)) {
        $content | Select-Object -First 7
    } else { @() }
    
    $logs = $content | Select-Object -Skip ($header.Count + 1)  # +1 pour la ligne vide aprÃ¨s l'en-tÃªte
    
    if ($Level) {
        $logs = $logs | Where-Object { $_ -match "\[$Level\]" }
    }
    
    if ($script:LogConfig.ShowNewestFirst) {
        $logs = $logs | Select-Object -First $Count
    } else {
        $logs = $logs | Select-Object -Last $Count
    }
    
    return $logs
}



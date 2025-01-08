#########################################################################
# Module: logs_files_part9
# Description: Partie 9 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

function Get-HeaderCheckLogs {
    <#
    .SYNOPSIS
        RÃ©cupÃ¨re les logs de vÃ©rification des en-tÃªtes
    #>
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level,
        
        [Parameter(Mandatory = $false)]
        [string]$FileName,
        
        [Parameter(Mandatory = $false)]
        [int]$Count = 10
    )
    
    $logs = Get-LastLogs -Module "HeaderCheck" -Level $Level -Count ([int]::MaxValue)
    
    if ($FileName) {
        $logs = $logs | Where-Object { $_ -match "\[$FileName\]" }
    }
    
    return $logs | Select-Object -First $Count
}



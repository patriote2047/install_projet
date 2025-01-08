#########################################################################
# Module: logs_files_part7
# Description: Partie 7 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

function Search-Logs {
    <#
    .SYNOPSIS
        Recherche dans les fichiers de log
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchPattern,
        
        [Parameter(Mandatory = $false)]
        [string]$Module,
        
        [Parameter(Mandatory = $false)]
        [DateTime]$StartDate,
        
        [Parameter(Mandatory = $false)]
        [DateTime]$EndDate
    )
    
    $searchPath = if ($Module) {
        Join-Path -Path $script:LogConfig.LogsFolder -ChildPath "$Module.log"
    } else {
        Join-Path -Path $script:LogConfig.LogsFolder -ChildPath "*.log"
    }
    
    $results = Get-Content -Path $searchPath | Where-Object {
        $line = $_
        $matchesPattern = $line -match $SearchPattern
        $matchesDate = $true
        
        if ($StartDate -or $EndDate) {
            if ($line -match '\[([\d-]+ [\d:]+)\]') {
                $logDate = [DateTime]::ParseExact($matches[1], "yyyy-MM-dd HH:mm:ss", $null)
                $matchesDate = (-not $StartDate -or $logDate -ge $StartDate) -and (-not $EndDate -or $logDate -le $EndDate)
            }
        }
        
        $matchesPattern -and $matchesDate
    }
    
    return $results
}



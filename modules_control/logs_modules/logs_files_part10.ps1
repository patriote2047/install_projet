#########################################################################
# Module: logs_files_part10
# Description: Partie 10 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

function Get-WidthFilesLogs {
    <#
    .SYNOPSIS
        RÃ©cupÃ¨re les logs de vÃ©rification de la largeur des fichiers
    #>
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level,
        
        [Parameter(Mandatory = $false)]
        [string]$FileName,
        
        [Parameter(Mandatory = $false)]
        [int]$MinWidth,
        
        [Parameter(Mandatory = $false)]
        [int]$MaxWidth,
        
        [Parameter(Mandatory = $false)]
        [int]$Count = 10
    )
    
    $logs = Get-LastLogs -Module "WidthFiles" -Level $Level -Count ([int]::MaxValue)
    
    if ($FileName) {
        $logs = $logs | Where-Object { $_ -match "\[$FileName\]" }
    }
    
    if ($MinWidth -or $MaxWidth) {
        $logs = $logs | Where-Object {
            if ($_ -match "Largeur: (\d+)") {
                $width = [int]$matches[1]
                $meetsMin = (-not $MinWidth) -or ($width -ge $MinWidth)
                $meetsMax = (-not $MaxWidth) -or ($width -le $MaxWidth)
                $meetsMin -and $meetsMax
            }
            else { $false }
        }
    }
    
    return $logs | Select-Object -First $Count
}



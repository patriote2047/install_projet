#########################################################################
# Module: logs_files_part1
# Description: Partie 1 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

function Initialize-LogFile {
    <#
    .SYNOPSIS
        Initialise un fichier de log avec son en-tÃªte
    #>
    param(
        [string]$LogType,
        [string]$FilePath
    )
    
    if (-not (Test-Path $FilePath)) {
        $header = @"
#########################################################################
# Fichier: $($script:LogConfig.LogHeaders[$LogType].Name)
# Description: $($script:LogConfig.LogHeaders[$LogType].Description)
# Date de crÃ©ation: $(Get-Date -Format "yyyy-MM-dd")
# Limite de lignes: $($script:LogConfig.LogHeaders[$LogType].LineLimit)
#########################################################################

"@
        Set-Content -Path $FilePath -Value $header
    }
}



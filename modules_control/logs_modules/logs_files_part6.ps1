#########################################################################
# Module: logs_files_part6
# Description: Partie 6 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

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



#########################################################################
# Module: logs_files_part11
# Description: Partie 11 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

function Test-LogSystem {
    <#
    .SYNOPSIS
        VÃ©rifie le bon fonctionnement du systÃ¨me de logging
    #>
    param()
    
    try {
        Write-LogMessage -Message "Test du systÃ¨me de logging" -Level "Info" -Module "System"
        Remove-OldLogs
        return $true
    }
    catch {
        Write-Error "Erreur lors du test du systÃ¨me de logging: $_"
        return $false
    }
}



#########################################################################
# Module: logs_files_part5
# Description: Partie 5 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

function Start-LogRotation {
    <#
    .SYNOPSIS
        Réinitialise un fichier de log quand il atteint sa limite
    .DESCRIPTION
        Cette fonction efface le contenu du fichier de log tout en conservant son en-tête,
        sans créer d'archive.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogFile,
        
        [Parameter(Mandatory = $true)]
        [string]$Module
    )
    
    # Vider le fichier de log original tout en conservant l'en-tête
    if ($script:LogConfig.LogHeaders.ContainsKey($Module)) {
        Set-Content -Path $LogFile -Value $script:LogConfig.LogHeaders[$Module]
    } else {
        Set-Content -Path $LogFile -Value ""
    }
    
    # Ajouter un message de réinitialisation directement (sans passer par Write-LogMessage)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$timestamp] [Info] Le fichier de log a été réinitialisé"
}

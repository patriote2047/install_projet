#########################################################################
# Module: logs_files_part4
# Description: Partie 4 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

function Write-WidthFilesLog {
    <#
    .SYNOPSIS
        Ã‰crit un message dans le fichier width_files.log
    .DESCRIPTION
        Fonction spÃ©cialisÃ©e pour les logs de vÃ©rification de la largeur des fichiers
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = $script:LogConfig.DefaultLogLevel,
        
        [Parameter(Mandatory = $false)]
        [string]$FileName,
        
        [Parameter(Mandatory = $false)]
        [int]$LineWidth
    )
    
    $fullMessage = if ($FileName -and $LineWidth) {
        "[$FileName] Largeur: $LineWidth - $Message"
    } elseif ($FileName) {
        "[$FileName] $Message"
    } else {
        $Message
    }
    
    Write-LogMessage -Message $fullMessage -Level $Level -Module "WidthFiles"
}



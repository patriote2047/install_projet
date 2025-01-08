#########################################################################
# Module: logs_files_part3
# Description: Partie 3 du fichier original
# Date: 2025-01-08 14:09:17
#########################################################################

function Write-HeaderCheckLog {
    <#
    .SYNOPSIS
        Ã‰crit un message dans le fichier header_check.log
    .DESCRIPTION
        Fonction spÃ©cialisÃ©e pour les logs de vÃ©rification des en-tÃªtes
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level = $script:LogConfig.DefaultLogLevel,
        
        [Parameter(Mandatory = $false)]
        [string]$FileName
    )
    
    $fullMessage = if ($FileName) {
        "[$FileName] $Message"
    } else {
        $Message
    }
    
    Write-LogMessage -Message $fullMessage -Level $Level -Module "HeaderCheck"
}



#########################################################################
# Fichier: encodage_control.psm1
# Description: Module principal de controle et gestion des encodages de fichiers
# Auteur: Fred
# Date de creation: 2025-01-08
# Derniere modification: 2025-01-08 14:34:00
#########################################################################

# Module de contrôle d'encodage
# Ce module vérifie et corrige l'encodage des fichiers

# Import des dépendances
Import-Module "$PSScriptRoot\logs_files.psm1"
Import-Module "$PSScriptRoot\modules_control\encoding_modules\Test-FileEncoding.psm1"
Import-Module "$PSScriptRoot\modules_control\encoding_modules\Convert-FileEncoding.psm1"
Import-Module "$PSScriptRoot\modules_control\encoding_modules\Add-EncodingControl.psm1"

function Start-EncodingControl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$DirectoryPath,
        
        [Parameter(Mandatory = $false)]
        [string]$TargetEncoding = 'UTF8',
        
        [Parameter(Mandatory = $false)]
        [string[]]$Include = @('*.ps1', '*.psm1', '*.psd1', '*.txt')
    )

    try {
        Write-LogMessage "=== Démarrage du contrôle d'encodage ===" -Level Info -Module "Encoding"
        
        # Vérifier que le répertoire existe
        if (-not (Test-Path $DirectoryPath)) {
            throw "Le répertoire n'existe pas : $DirectoryPath"
        }

        # Récupérer tous les fichiers correspondant aux critères
        $files = Get-ChildItem -Path $DirectoryPath -Include $Include -Recurse
        
        foreach ($file in $files) {
            Write-LogMessage "`nTest du fichier : $($file.FullName)" -Level Info -Module "Encoding"
            
            # Vérifier l'encodage initial
            $initialEncoding = Test-FileEncoding -Path $file.FullName
            Write-LogMessage "Encodage initial : $initialEncoding" -Level Info -Module "Encoding"
            
            if ($initialEncoding -ne $TargetEncoding) {
                Write-LogMessage "Conversion nécessaire vers $TargetEncoding" -Level Info -Module "Encoding"
                $result = Convert-FileEncoding -Path $file.FullName -TargetEncoding $TargetEncoding
                
                if ($result) {
                    $newEncoding = Test-FileEncoding -Path $file.FullName
                    Write-LogMessage "Contrôle d'encodage réussi" -Level Success -Module "Encoding"
                    Write-LogMessage "Nouvel encodage : $newEncoding" -Level Info -Module "Encoding"
                }
                else {
                    Write-ErrorLog $_ -Module "Encoding"
                }
            }
            else {
                Write-LogMessage "L'encodage est déjà correct ($TargetEncoding)" -Level Success -Module "Encoding"
            }

        }
        
        Write-EncodingLog "`n=== Fin du contrôle d'encodage ===" -Level Info
        return $true
    }
    catch {
        Write-EncodingLog "Erreur lors du contrôle d'encodage : $_" -Level Error
        Write-ErrorLog $_
    }
}

# Exporter les fonctions
Export-ModuleMember -Function Start-EncodingControl

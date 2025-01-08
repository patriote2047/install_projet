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
$modulePath = $PSScriptRoot
Import-Module "$modulePath\modules_control\encoding_modules\Write-EncodingLog.psm1"
Import-Module "$modulePath\modules_control\encoding_modules\Test-FileEncoding.psm1"
Import-Module "$modulePath\modules_control\encoding_modules\Convert-FileEncoding.psm1"
Import-Module "$modulePath\modules_control\encoding_modules\Add-EncodingControl.psm1"

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
        Write-EncodingLog "=== Démarrage du contrôle d'encodage ===" -Level Info
        
        # Vérifier que le répertoire existe
        if (-not (Test-Path $DirectoryPath)) {
            throw "Le répertoire n'existe pas : $DirectoryPath"
        }
        
        # Récupérer tous les fichiers correspondant aux critères
        $files = Get-ChildItem -Path $DirectoryPath -Include $Include -Recurse
        
        foreach ($file in $files) {
            Write-EncodingLog "`nTest du fichier : $($file.FullName)" -Level Info
            
            # Vérifier l'encodage initial
            $initialEncoding = Test-FileEncoding -Path $file.FullName
            Write-EncodingLog "Encodage initial : $initialEncoding" -Level Info
            
            if ($initialEncoding -ne $TargetEncoding) {
                Write-EncodingLog "Conversion nécessaire vers $TargetEncoding" -Level Info
                $result = Convert-FileEncoding -Path $file.FullName -TargetEncoding $TargetEncoding
                
                if ($result) {
                    $newEncoding = Test-FileEncoding -Path $file.FullName
                    Write-EncodingLog "Contrôle d'encodage réussi" -Level Success
                    Write-EncodingLog "Nouvel encodage : $newEncoding" -Level Info
                }
                else {
                    Write-EncodingLog "Échec du contrôle d'encodage" -Level Error
                }
            }
            else {
                Write-EncodingLog "L'encodage est déjà correct ($TargetEncoding)" -Level Success
            }
        }
        
        Write-EncodingLog "`n=== Fin du contrôle d'encodage ===" -Level Info
        return $true
    }
    catch {
        Write-EncodingLog "Erreur lors du contrôle d'encodage : $_" -Level Error
        return $false
    }
}

# Exporter les fonctions
Export-ModuleMember -Function Start-EncodingControl

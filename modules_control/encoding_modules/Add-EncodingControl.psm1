# Import des dépendances
$modulePath = Split-Path $PSScriptRoot -Parent
Import-Module "$modulePath\encoding_modules\Write-EncodingLog.psm1"
Import-Module "$modulePath\encoding_modules\Test-FileEncoding.psm1"
Import-Module "$modulePath\encoding_modules\Convert-FileEncoding.psm1"

function Add-EncodingControl {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ModuleName,
        
        [Parameter(Mandatory = $true)]
        [scriptblock]$Function,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('UTF8', 'UTF8BOM', 'UTF16LE', 'UTF16BE', 'ASCII')]
        [string]$TargetEncoding = 'UTF8'
    )

    try {
        # Créer une nouvelle fonction qui ajoute le contrôle d'encodage
        $wrappedFunction = {
            param($Path)
            
            # Vérifier l'encodage avant l'exécution
            $initialEncoding = Test-FileEncoding -Path $Path
            Write-EncodingLog "[$ModuleName] Encodage initial de $Path : $initialEncoding" -Level Info
            
            if ($initialEncoding -ne $TargetEncoding) {
                Write-EncodingLog "[$ModuleName] Conversion de l'encodage de $Path de $initialEncoding vers $TargetEncoding" -Level Info
                $result = Convert-FileEncoding -Path $Path -TargetEncoding $TargetEncoding
                if (-not $result) {
                    throw "Échec de la conversion de l'encodage pour $Path"
                }
            }
            
            # Exécuter la fonction originale
            Write-EncodingLog "[$ModuleName] Exécution de la fonction sur $Path" -Level Debug
            & $Function $Path
            
            # Vérifier l'encodage après l'exécution
            $finalEncoding = Test-FileEncoding -Path $Path
            Write-EncodingLog "[$ModuleName] Encodage final de $Path : $finalEncoding" -Level Info
            
            if ($finalEncoding -ne $TargetEncoding) {
                Write-EncodingLog "[$ModuleName] L'encodage a été modifié pendant l'exécution de la fonction. Restauration..." -Level Warning
                $result = Convert-FileEncoding -Path $Path -TargetEncoding $TargetEncoding
                if (-not $result) {
                    throw "Échec de la restauration de l'encodage pour $Path"
                }
            }
        }
        
        return $wrappedFunction
    }
    catch {
        Write-EncodingLog "[$ModuleName] Erreur lors de l'ajout du contrôle d'encodage : $_" -Level Error
        return $null
    }
}

Export-ModuleMember -Function Add-EncodingControl

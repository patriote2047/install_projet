# Import des dépendances
$modulePath = Split-Path $PSScriptRoot -Parent
Import-Module "$modulePath\encoding_modules\Write-EncodingLog.psm1"

function Test-FileEncoding {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    try {
        # Vérifier que le fichier existe
        if (-not (Test-Path $Path)) {
            throw "Le fichier n'existe pas : $Path"
        }

        # Lire les premiers octets du fichier
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        
        # Vérifier les marqueurs BOM
        if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            Write-EncodingLog "BOM UTF-8 détecté" -Level Debug
            return 'UTF8BOM'
        }
        elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
            Write-EncodingLog "BOM UTF-16 BE détecté" -Level Debug
            return 'UTF16BE'
        }
        elseif ($bytes.Length -ge 2 -and $bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
            Write-EncodingLog "BOM UTF-16 LE détecté" -Level Debug
            return 'UTF16LE'
        }

        # Vérifier si c'est de l'UTF-16 LE sans BOM (motif caractéristique : octet nul tous les 2 octets)
        if ($bytes.Length -ge 4) {
            $isUtf16Le = $true
            for ($i = 0; $i -lt [Math]::Min($bytes.Length, 100); $i += 2) {
                if ($bytes[$i + 1] -ne 0) {
                    $isUtf16Le = $false
                    break
                }
            }
            if ($isUtf16Le) {
                Write-EncodingLog "UTF-16 LE sans BOM détecté (motif caractéristique)" -Level Debug
                return 'UTF16LE'
            }
        }

        # Vérifier si c'est de l'ASCII (tous les octets < 128)
        $isAscii = $true
        foreach ($byte in $bytes) {
            if ($byte -gt 127) {
                $isAscii = $false
                break
            }
        }
        
        if ($isAscii) {
            Write-EncodingLog "ASCII détecté (tous les octets < 128)" -Level Debug
            return 'ASCII'
        }

        # Par défaut, considérer comme UTF8 sans BOM
        Write-EncodingLog "UTF-8 sans BOM détecté (par défaut)" -Level Debug
        return 'UTF8'
    }
    catch {
        Write-EncodingLog "Erreur lors de la détection de l'encodage : $_" -Level Error
        return $null
    }
}

Export-ModuleMember -Function Test-FileEncoding

# Import des dépendances
$modulePath = Split-Path $PSScriptRoot -Parent
Import-Module "$modulePath\encoding_modules\Write-EncodingLog.psm1"
Import-Module "$modulePath\encoding_modules\Test-FileEncoding.psm1"

function Convert-FileEncoding {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Path,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet('UTF8', 'UTF8BOM', 'UTF16LE', 'UTF16BE', 'ASCII')]
        [string]$TargetEncoding = 'UTF8'
    )

    try {
        # Vérifier que le fichier existe
        if (-not (Test-Path $Path)) {
            throw "Le fichier n'existe pas : $Path"
        }

        # Détecter l'encodage actuel
        $currentEncoding = Test-FileEncoding -Path $Path
        if ($null -eq $currentEncoding) {
            throw "Impossible de détecter l'encodage actuel"
        }

        # Si l'encodage est déjà correct, pas besoin de conversion
        if ($currentEncoding -eq $TargetEncoding) {
            Write-EncodingLog "Le fichier est déjà en $TargetEncoding" -Level Info
            return $true
        }

        Write-EncodingLog "Conversion de $Path de $currentEncoding vers $TargetEncoding" -Level Info

        # Lire le contenu du fichier avec l'encodage source
        $bytes = [System.IO.File]::ReadAllBytes($Path)
        $content = $null

        # Détecter et décoder le contenu selon l'encodage source
        switch ($currentEncoding) {
            'UTF8' { 
                $content = [System.Text.Encoding]::UTF8.GetString($bytes)
            }
            'UTF8BOM' {
                # Ignorer les 3 premiers octets (BOM)
                if ($bytes.Length -gt 3) {
                    $content = [System.Text.Encoding]::UTF8.GetString($bytes, 3, $bytes.Length - 3)
                }
            }
            'UTF16LE' {
                $content = [System.Text.Encoding]::Unicode.GetString($bytes)
            }
            'UTF16BE' {
                $content = [System.Text.Encoding]::BigEndianUnicode.GetString($bytes)
            }
            'ASCII' {
                $content = [System.Text.Encoding]::ASCII.GetString($bytes)
            }
        }

        if ($null -eq $content) {
            throw "Erreur lors de la lecture du contenu"
        }

        # Créer un fichier temporaire
        $tempFile = "$Path.tmp"
        
        # Convertir et écrire le contenu avec le nouvel encodage
        switch ($TargetEncoding) {
            'UTF8' {
                [System.IO.File]::WriteAllText($tempFile, $content, [System.Text.UTF8Encoding]::new($false))
            }
            'UTF8BOM' {
                [System.IO.File]::WriteAllText($tempFile, $content, [System.Text.UTF8Encoding]::new($true))
            }
            'UTF16LE' {
                [System.IO.File]::WriteAllText($tempFile, $content, [System.Text.UnicodeEncoding]::new($false, $false))
            }
            'UTF16BE' {
                [System.IO.File]::WriteAllText($tempFile, $content, [System.Text.UnicodeEncoding]::new($true, $false))
            }
            'ASCII' {
                # Vérifier si la conversion en ASCII est possible
                $asciiBytes = [System.Text.Encoding]::ASCII.GetBytes($content)
                $backToString = [System.Text.Encoding]::ASCII.GetString($asciiBytes)
                if ($backToString -ne $content) {
                    Write-EncodingLog "ATTENTION: La conversion en ASCII entraînera une perte de caractères" -Level Warning
                }
                [System.IO.File]::WriteAllText($tempFile, $content, [System.Text.ASCIIEncoding]::new())
            }
        }
        
        # Vérifier que le fichier temporaire a été créé
        if (-not (Test-Path $tempFile)) {
            throw "Erreur lors de la création du fichier temporaire"
        }

        # Remplacer le fichier original
        Move-Item -Path $tempFile -Destination $Path -Force

        # Vérifier le nouvel encodage
        $finalEncoding = Test-FileEncoding -Path $Path
        if ($finalEncoding -ne $TargetEncoding) {
            throw "La conversion a échoué. Encodage attendu: $TargetEncoding, obtenu: $finalEncoding"
        }

        Write-EncodingLog "Conversion réussie de $Path vers $TargetEncoding" -Level Info
        return $true
    }
    catch {
        Write-EncodingLog "Erreur lors de la conversion de l'encodage : $_" -Level Error
        if (Test-Path $tempFile) {
            Remove-Item -Path $tempFile -Force
        }
        return $false
    }
}

Export-ModuleMember -Function Convert-FileEncoding

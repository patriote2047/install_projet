#########################################################################
# Fichier: test_encodage_control.ps1
# Description: Tests unitaires pour le module de controle d'encodage
# Auteur: Fred
# Date de creation: 2025-01-08
# Derniere modification: 2025-01-08 14:40:04
#########################################################################

# Module de test pour l'encodage
# Configuration de la console pour l'Unicode
$Host.UI.RawUI.WindowTitle = "Test Encodage - Unicode"
try {
    # Changer la police de la console en Lucida Console qui supporte mieux l'Unicode
    $consoleFontInfo = [System.Management.Automation.Host.Size]::new(0, 16) # Taille de la police
    $Host.UI.RawUI.FontSize = $consoleFontInfo
    $Host.UI.RawUI.FontFamily = "Lucida Console"
} catch {
    Write-Host "ATTENTION: Impossible de changer la police de la console. Les caractères spéciaux pourraient ne pas s'afficher correctement." -ForegroundColor Yellow
}

# Configuration de l'encodage de la console
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new()
[Console]::InputEncoding = [System.Text.UTF8Encoding]::new()
$PSDefaultParameterValues['*:Encoding'] = 'utf8'
chcp 65001 | Out-Null

# Import des modules
Import-Module "$PSScriptRoot\..\..\encodage_control.psm1" -Force
Import-Module "$PSScriptRoot\..\..\modules_control\encoding_modules\Test-FileEncoding.psm1" -Force
Import-Module "$PSScriptRoot\..\..\modules_control\encoding_modules\Convert-FileEncoding.psm1" -Force
Import-Module "$PSScriptRoot\..\..\modules_control\encoding_modules\Add-EncodingControl.psm1" -Force

# Fonction pour écrire du texte avec des caractères Unicode
function Write-UnicodeText {
    param (
        [string]$Text
    )
    Write-Host $Text
}

# Créer un dossier de test
$testDir = "$PSScriptRoot\test_files"
if (-not (Test-Path $testDir)) {
    New-Item -ItemType Directory -Path $testDir | Out-Null
}

Write-UnicodeText "`nTest 1: Detection d'encodage"

# Test avec différents encodages
$testFiles = @{
    'utf8.txt' = @{
        'encoding' = 'UTF8'
        'content' = "Test de contenu avec caractères spéciaux : éèêëàâäôöüûç"
    }
    'utf8bom.txt' = @{
        'encoding' = 'UTF8BOM'
        'content' = "Test de contenu avec caractères spéciaux : éèêëàâäôöüûç"
    }
    'utf16le.txt' = @{
        'encoding' = 'UTF16LE'
        'content' = "Test de contenu avec caractères spéciaux : éèêëàâäôöüûç"
    }
    'ascii.txt' = @{
        'encoding' = 'ASCII'
        'content' = "Test de contenu avec caracteres speciaux"  # Sans caractères spéciaux pour ASCII
    }
}

foreach ($file in $testFiles.GetEnumerator()) {
    $filePath = Join-Path $testDir $file.Key
    $encoding = $file.Value.encoding
    $content = $file.Value.content
    
    Write-UnicodeText "`nTest du fichier $($file.Key)"
    Write-UnicodeText "Creation du fichier $($file.Key) avec encodage $encoding"
    Write-UnicodeText "Contenu: $content"
    Write-UnicodeText "Longueur du contenu: $($content.Length) caractères"
    
    # Créer le fichier avec l'encodage spécifié
    switch ($encoding) {
        'UTF8' {
            [System.IO.File]::WriteAllText($filePath, $content, [System.Text.UTF8Encoding]::new($false))
        }
        'UTF8BOM' {
            [System.IO.File]::WriteAllText($filePath, $content, [System.Text.UTF8Encoding]::new($true))
        }
        'UTF16LE' {
            [System.IO.File]::WriteAllText($filePath, $content, [System.Text.UnicodeEncoding]::new())
        }
        'ASCII' {
            [System.IO.File]::WriteAllText($filePath, $content, [System.Text.ASCIIEncoding]::new())
        }
    }
    
    # Afficher les informations sur le fichier
    $fileInfo = Get-Item $filePath
    Write-UnicodeText "Taille du fichier: $($fileInfo.Length) octets"
    
    # Lire les premiers octets
    $firstBytes = [System.IO.File]::ReadAllBytes($filePath)[0..20]
    Write-UnicodeText "Premiers octets: $($firstBytes -join ',')"
    
    # Lire le contenu pour vérification
    $verifyContent = [System.IO.File]::ReadAllText($filePath)
    Write-UnicodeText "Lecture de vérification: $verifyContent"
    
    # Détecter l'encodage
    Write-UnicodeText "Encodage attendu: $encoding"
    $detectedEncoding = Test-FileEncoding -Path $filePath
    Write-UnicodeText "Encodage detecte: $detectedEncoding"
    
    if ($detectedEncoding -ne $encoding) {
        Write-UnicodeText "ECHEC: $($file.Key) detecte comme $detectedEncoding au lieu de $encoding"
    }
    else {
        Write-UnicodeText "SUCCES: $($file.Key) correctement detecte comme $encoding"
    }
}

Write-UnicodeText "`nTest 2: Conversion d'encodage"

# Test de conversion d'encodage
$testFile = Join-Path $testDir "to_convert.txt"
$content = "Test de contenu avec caractères spéciaux : éèêëàâäôöüûç"

Write-UnicodeText "Creation du fichier to_convert.txt avec encodage UTF16LE"
Write-UnicodeText "Contenu: $content"
Write-UnicodeText "Longueur du contenu: $($content.Length) caractères"

# Créer le fichier en UTF16LE
[System.IO.File]::WriteAllText($testFile, $content, [System.Text.UnicodeEncoding]::new())

# Afficher les informations sur le fichier
$fileInfo = Get-Item $testFile
Write-UnicodeText "Taille du fichier: $($fileInfo.Length) octets"

# Lire les premiers octets
$firstBytes = [System.IO.File]::ReadAllBytes($testFile)[0..20]
Write-UnicodeText "Premiers octets: $($firstBytes -join ',')"

# Lire le contenu pour vérification
$verifyContent = [System.IO.File]::ReadAllText($testFile)
Write-UnicodeText "Lecture de vérification: $verifyContent"

# Détecter l'encodage initial
$initialEncoding = Test-FileEncoding -Path $testFile
Write-UnicodeText "`nEncodage initial: $initialEncoding"

# Lire le contenu avant conversion
$contentBefore = [System.IO.File]::ReadAllText($testFile)
$bytesBefore = [System.IO.File]::ReadAllBytes($testFile)[0..20]
Write-UnicodeText "Lecture du contenu avant conversion:"
Write-UnicodeText "Premiers octets avant: $($bytesBefore -join ',')"
Write-UnicodeText "Contenu avant: $contentBefore"

# Convertir en UTF8
$result = Convert-FileEncoding -Path $testFile -TargetEncoding "UTF8"
Write-UnicodeText "Resultat de la conversion: $result"

# Lire le contenu après conversion
$contentAfter = [System.IO.File]::ReadAllText($testFile)
$bytesAfter = [System.IO.File]::ReadAllBytes($testFile)[0..20]
Write-UnicodeText "Lecture du contenu après conversion:"
Write-UnicodeText "Premiers octets après: $($bytesAfter -join ',')"
Write-UnicodeText "Contenu après: $contentAfter"

# Vérifier l'encodage final
$newEncoding = Test-FileEncoding -Path $testFile
Write-UnicodeText "Nouvel encodage: $newEncoding"

if ($newEncoding -ne "UTF8") {
    Write-UnicodeText "ECHEC: La conversion n'a pas fonctionne correctement"
}
else {
    Write-UnicodeText "SUCCES: La conversion a fonctionne correctement"
}

Write-UnicodeText "`nTest 3: Controle d'encodage sur un repertoire"
Start-EncodingControl -DirectoryPath $testDir

Write-UnicodeText "`n=== Test de l'intégration avec d'autres modules ==="

# Test de l'intégration avec d'autres modules
$files = Get-ChildItem -Path $testDir -Filter "*.txt"
foreach ($file in $files) {
    Write-UnicodeText "`nTest de la fonction avec contrôle d'encodage sur : $($file.FullName)"
    
    # Créer une fonction de test
    $testFunction = {
        param($Path)
        [System.IO.File]::ReadAllText($Path) | Out-Null
    }
    
    # Ajouter le contrôle d'encodage
    $wrappedFunction = Add-EncodingControl -ModuleName "TestModule" -Function $testFunction -TargetEncoding "UTF8"
    
    # Exécuter la fonction
    & $wrappedFunction $file.FullName
}

# Nettoyage
Remove-Item -Path $testDir -Recurse -Force

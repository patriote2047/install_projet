#########################################################################
# Fichier: en_tete_generator.ps1
# Description: Script de gestion de données et validation.
# Auteur: John Doe <john.doe@example.com>
# Date de création: 2025-01-08
# Dernière modification: 2025-01-08 01:58:56
#########################################################################
# Nombre de lignes: 384
#########################################################################
# Liste des éléments:
# Fonction: Write-HeaderLog (pas de description)
# Fonction: Get-PackageJsonAuthor (pas de description)
# Fonction: Get-FileDescription (pas de description)
# Fonction: Get-FileElements (pas de description)
# Fonction: Get-FileDependencies (pas de description)
# Fonction: Update-Header (pas de description)
# Fonction: Start-HeaderCheck (pas de description)
# Variable: $defaultHeaderTemplate = @"
#########################################################################
# Dépendances:

#########################################################################
function Write-HeaderLog {
    param (
        [string]$message
    )
    $logFile = "header_check.log"
    $maxLines = 50
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $newLine = "[$timestamp] $message"
    
    if (-not (Test-Path $logFile)) {
        $newLine | Set-Content -Path $logFile
        return
    }
    
    $existingLines = @(Get-Content $logFile -TotalCount ($maxLines - 1))
    $newContent = @($newLine) + $existingLines
    $newContent | Set-Content -Path $logFile
}

function Get-PackageJsonAuthor {
    param (
        [string]$scriptPath
    )
    
    $defaultAuthor = "Généré automatiquement"
    $packageJsonPath = Join-Path (Split-Path $scriptPath -Parent) "package.json"
    
    if (Test-Path $packageJsonPath) {
        try {
            $packageJson = Get-Content $packageJsonPath -Raw | ConvertFrom-Json
            if ($packageJson.author) {
                return $packageJson.author
            }
        }
        catch {
            Write-HeaderLog "Erreur lors de la lecture de package.json: $_"
        }
    }
    
    return $defaultAuthor
}

function Get-FileDescription {
    param (
        [string]$filePath,
        [array]$elements,
        [array]$dependencies
    )
    
    $functionTypes = @{
        'Init' = @('Initialize', 'Setup', 'Config', 'Install')
        'Data' = @('Data', 'Get', 'Set', 'Update', 'Convert')
        'Test' = @('Test', 'Validate', 'Check', 'Verify')
        'Clean' = @('Clean', 'Remove', 'Delete', 'Uninstall')
    }
    
    # Compter les fonctions par type
    $functionCounts = @()
    $mainFunctions = $elements | Where-Object { $_ -match "^# Fonction: (\w+[-]?\w+)" }
    
    foreach ($func in $mainFunctions) {
        foreach ($type in $functionTypes.Keys) {
            $patterns = $functionTypes[$type] -join '|'
            if ($func -match $patterns) {
                $functionCounts += $type
            }
        }
    }
    
    # Construire la description
    $description = "Script de "
    
    # Ajouter les types de fonctions trouvées
    $functionParts = @()
    if ($functionCounts -contains 'Init') { $functionParts += "configuration" }
    if ($functionCounts -contains 'Data') { $functionParts += "gestion de données" }
    if ($functionCounts -contains 'Test') { $functionParts += "validation" }
    if ($functionParts.Count -gt 0) {
        $description += $functionParts -join ' et '
    }
    
    # Ajouter les modules principaux
    $modules = @($dependencies | Where-Object { $_ -match "Module requis: (.+)" } | ForEach-Object { $matches[1] })
    if ($modules) {
        $modulesList = $modules -join ' et '
        $description += " utilisant $modulesList"
    }
    
    # Ajouter les commandes externes principales
    $commands = @($dependencies | Where-Object { $_ -match "Commande externe: (.+)" } | ForEach-Object { $matches[1] })
    if ($commands) {
        $commandsList = $commands -join ' et '
        $description += " (via $commandsList)"
    }
    
    $description += "."
    return $description
}

function Get-FileElements {
    param (
        [string]$filePath
    )
    $mainFunctions = @()
    $subFunctions = @()
    $variables = @()
    $content = Get-Content $filePath
    $inFunction = $false
    $currentMainFunction = $null
    $inDescription = $false
    $currentDescription = @()
    $descriptionBuffer = [ordered]@{}
    $inComment = $false
    $currentFunctionName = $null
    
    # Premier passage : collecter toutes les descriptions
    for ($i = 0; $i -lt $content.Count; $i++) {
        $line = $content[$i]
        
        # Détection des fonctions
        if ($line -match '^function\s+(\w+[-]?\w+)\s*{') {
            $currentFunctionName = $matches[1]
            continue
        }
        
        # Début d'un bloc de commentaire
        if ($line -match '^\s*<#') {
            $inComment = $true
            $currentDescription = @()
            continue
        }
        
        # Dans un bloc de commentaire
        if ($inComment) {
            # Fin du bloc de commentaire
            if ($line -match '^\s*#>') {
                $inComment = $false
                if ($currentDescription.Count -gt 0 -and $null -ne $currentFunctionName) {
                    $descriptionBuffer[$currentFunctionName] = $currentDescription
                }
            }
            # Ligne de description
            elseif ($line -match '^\s*\.(DESCRIPTION|SYNOPSIS)') {
                $inDescription = $true
            }
            # Autre type de commentaire
            elseif ($line -match '^\s*\.') {
                $inDescription = $false
            }
            # Contenu de la description
            elseif ($inDescription) {
                $desc = $line.Trim()
                if ($desc) {
                    $currentDescription += $desc
                }
            }
        }
    }
    
    # Deuxième passage : traiter les fonctions et variables
    for ($lineNumber = 0; $lineNumber -lt $content.Count; $lineNumber++) {
        $line = $content[$lineNumber]
        
        # Détection des fonctions principales
        if ($line -match "^function\s+(\w+[-]?\w+)\s*{") {
            $functionName = $matches[1]
            $inFunction = $true
            $currentMainFunction = $functionName
            
            # Récupérer la description sauvegardée
            $description = $descriptionBuffer[$functionName]
            if ($description) {
                $mainFunctions += "# Fonction: $functionName"
                $mainFunctions += $description | ForEach-Object { "#   $_" }
            } else {
                $mainFunctions += "# Fonction: $functionName (pas de description)"
            }
        }
        # Détection des sous-fonctions
        elseif ($inFunction -and $line -match "^\s+function\s+(\w+[-]?\w+)\s*{") {
            $functionName = $matches[1]
            
            # Récupérer la description sauvegardée
            $description = $descriptionBuffer[$functionName]
            if ($description) {
                $subFunctions += "# Sous-fonction de $currentMainFunction`: $functionName"
                $subFunctions += $description | ForEach-Object { "#   $_" }
            } else {
                $subFunctions += "# Sous-fonction de $currentMainFunction`: $functionName (pas de description)"
            }
        }
        # Détection des variables importantes
        elseif ($line -match '^\$(?:SCRIPT:)?(\w+)\s*=') {
            $variables += "# Variable: $($line.Trim())"
        }
        # Fin de fonction
        elseif ($line -match '^}') {
            $inFunction = $false
            $currentMainFunction = $null
        }
    }
    
    # Combiner tous les éléments dans l'ordre souhaité
    $elements = @()
    if ($mainFunctions) {
        $elements += $mainFunctions
    }
    if ($subFunctions) {
        $elements += $subFunctions
    }
    if ($variables) {
        $elements += $variables
    }
    
    return $elements
}

function Get-FileDependencies {
    param (
        [string]$filePath
    )
    $dependencies = @()
    $content = Get-Content $filePath

    # Détection des modules using
    $content | Where-Object { $_ -match '^using\s+module\s+(.+)$' } | ForEach-Object {
        $dependencies += "# Module requis: $($matches[1].Trim())"
    }

    # Détection des modules importés
    $content | Where-Object { $_ -match '^Import-Module\s+(.+)$' } | ForEach-Object {
        $dependencies += "# Module requis: $($matches[1].Trim())"
    }

    # Détection des fichiers requis
    $content | Where-Object { $_ -match '\.\s+[''"]?([^''"\s]+\.ps1)[''"]?' } | ForEach-Object {
        $dependencies += "# Fichier requis: .\$($matches[1])"
    }

    # Détection des appels à des commandes externes (exclure npm et pnpm)
    $content | Where-Object { $_ -match '(?:Start-Process|&)\s+([^-\s]+)' -and $matches[1] -notin @('npm', 'pnpm') } | ForEach-Object {
        $dependencies += "# Commande externe: $($matches[1])"
    }

    return $dependencies | Sort-Object -Unique
}

function Update-Header {
    param (
        [string]$filePath
    )

    Write-HeaderLog "=== Début de la vérification pour $filePath ==="

    # Vérifier si le fichier existe
    if (-not (Test-Path $filePath)) {
        Write-HeaderLog "Le fichier $filePath n'existe pas"
        return
    }

    # Extraire le contenu sans l'en-tête
    $content = Get-Content $filePath
    $codeContent = @()
    $inHeader = $true

    foreach ($line in $content) {
        if (-not $line.StartsWith('#') -and -not [string]::IsNullOrWhiteSpace($line)) {
            $inHeader = $false
        }
        if (-not $inHeader) {
            $codeContent += $line
        }
    }

    # Analyser le fichier
    $elements = Get-FileElements -filePath $filePath
    $dependencies = Get-FileDependencies -filePath $filePath

    # Générer la description et récupérer l'auteur
    $description = Get-FileDescription -filePath $filePath -elements $elements -dependencies $dependencies
    $author = Get-PackageJsonAuthor -scriptPath $filePath

    # Créer l'en-tête temporaire
    $tempHeader = $defaultHeaderTemplate -f `
        (Split-Path $filePath -Leaf), `
        $description, `
        $author, `
        (Get-Date -Format "yyyy-MM-dd"), `
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), `
        0, `
        ($elements -join "`n"), `
        ($dependencies -join "`n")

    # Sauvegarder le contenu temporaire
    $tempContent = @($tempHeader.Split("`n")) + $codeContent
    $tempContent | Set-Content -Path $filePath -Force

    # Compter le nombre total de lignes
    $lineCount = (Get-Content $filePath).Count
    Write-HeaderLog ">>> Nombre total de lignes : $lineCount"

    # Créer l'en-tête finale avec le bon nombre de lignes
    $finalHeader = $defaultHeaderTemplate -f `
        (Split-Path $filePath -Leaf), `
        $description, `
        $author, `
        (Get-Date -Format "yyyy-MM-dd"), `
        (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), `
        $lineCount, `
        ($elements -join "`n"), `
        ($dependencies -join "`n")

    # Sauvegarder le contenu final
    $finalContent = @($finalHeader.Split("`n")) + $codeContent
    $finalContent | Set-Content -Path $filePath -Force

    Write-HeaderLog "En-tête mise à jour pour $filePath"
    Write-HeaderLog "=== Fin de la vérification pour $filePath ==="
}

# Modèle d'en-tête sans lignes vides
$defaultHeaderTemplate = @"
#########################################################################
# Fichier: {0}
# Description: {1}
# Auteur: {2}
# Date de création: {3}
# Dernière modification: {4}
#########################################################################
# Nombre de lignes: {5}
#########################################################################
# Liste des éléments:
{6}
#########################################################################
# Dépendances:
{7}
#########################################################################
"@

# Fonction principale pour scanner un dossier
function Start-HeaderCheck {
    param (
        [string]$folderPath = "."
    )

    Write-HeaderLog "Début du scan du dossier : $folderPath"

    # Récupérer tous les fichiers .ps1 et .psm1
    $files = Get-ChildItem -Path $folderPath -Recurse -Include "*.ps1","*.psm1"

    foreach ($file in $files) {
        Write-HeaderLog "Traitement du fichier : $($file.FullName)"
        Update-Header -filePath $file.FullName
    }

    Write-HeaderLog "Scan terminé"
}

# Si le script est exécuté directement
if ($MyInvocation.InvocationName -ne '.') {
    Start-HeaderCheck
}

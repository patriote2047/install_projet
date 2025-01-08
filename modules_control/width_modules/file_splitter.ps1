#########################################################################
# Module: file_splitter.ps1
# Description: Fonctions de rotation et d'archivage des logs
# Date: 2025-01-08
# Version: 1.0
#########################################################################

function Split-FileIntoModules {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        
        [Parameter(Mandatory = $false)]
        [string]$ModulesDir = "modules",
        
        [Parameter(Mandatory = $false)]
        [int]$MaxLinesPerFile = 50
    )
    
    # Créer le dossier modules
    $modulesPath = [System.IO.Path]::GetFullPath((Join-Path (Split-Path $FilePath) $ModulesDir))
    if (Test-Path $modulesPath) {
        Remove-Item -Path $modulesPath\* -Recurse -Force
    }
    else {
        New-Item -Path $modulesPath -ItemType Directory -Force | Out-Null
    }
    Write-Verbose "Dossier créé : $modulesPath"
    
    # Lire et analyser le fichier
    $content = Get-Content $FilePath -Raw
    $functions = Get-PowerShellFunctions -Content $content
    Write-Verbose "Analyse terminée : $($functions.Count) fonctions trouvées"
    
    # Initialiser les variables
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)
    $currentFileNumber = 1
    $currentLineCount = 0
    $currentFunctions = @()
    $moduleFiles = @{}
    
    # Parcourir les fonctions dans l'ordre
    foreach ($function in $functions) {
        # Si l'ajout de cette fonction dépasse la limite
        if (($currentLineCount + $function.LineCount) -gt $MaxLinesPerFile -and $currentFunctions.Count -gt 0) {
            # Créer un nouveau fichier avec les fonctions actuelles
            $moduleFile = Join-Path $modulesPath "${baseName}_part$currentFileNumber.ps1"
            $moduleContent = @"
#########################################################################
# Module: ${baseName}_part$currentFileNumber
# Description: Partie $currentFileNumber du fichier original
# Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
#########################################################################

$($currentFunctions | ForEach-Object { ($_.Content -join "`n") + "`n`n" })
"@
            $moduleContent | Out-File -FilePath $moduleFile -Encoding UTF8 -Force
            $moduleFiles["Part$currentFileNumber"] = $moduleFile
            Write-Verbose "Module créé : $moduleFile ($currentLineCount lignes)"
            
            # Réinitialiser pour le prochain fichier
            $currentFileNumber++
            $currentLineCount = $function.LineCount
            $currentFunctions = @($function)
        }
        else {
            # Ajouter la fonction au fichier actuel
            $currentLineCount += $function.LineCount
            $currentFunctions += $function
        }
    }
    
    # Créer le dernier fichier s'il reste des fonctions
    if ($currentFunctions.Count -gt 0) {
        $moduleFile = Join-Path $modulesPath "${baseName}_part$currentFileNumber.ps1"
        $moduleContent = @"
#########################################################################
# Module: ${baseName}_part$currentFileNumber
# Description: Partie $currentFileNumber du fichier original
# Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
#########################################################################

$($currentFunctions | ForEach-Object { ($_.Content -join "`n") + "`n`n" })
"@
        $moduleContent | Out-File -FilePath $moduleFile -Encoding UTF8 -Force
        $moduleFiles["Part$currentFileNumber"] = $moduleFile
        Write-Verbose "Module créé : $moduleFile ($currentLineCount lignes)"
    }
    
    # Créer le fichier principal
    $mainContent = @"
#########################################################################
# Fichier: $baseName.ps1
# Description: Fichier principal
# Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
#########################################################################

# Importer les modules
$(($moduleFiles.Values | ForEach-Object { ". ./$ModulesDir/$([System.IO.Path]::GetFileName($_))" }) -join "`n")

# Point d'entrée
$($functions | ForEach-Object { $_.Name } | Out-String)
"@
    
    # Sauvegarder l'ancien fichier et créer le nouveau
    Copy-Item -Path $FilePath -Destination "$FilePath.old" -Force
    $mainContent | Out-File -FilePath $FilePath -Encoding UTF8 -Force
    Write-Verbose "Fichier principal créé : $FilePath"
    
    return $moduleFiles
}

function Start-LogRotation {
    <#
    .SYNOPSIS
        Effectue la rotation d'un fichier de log
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$LogFile,
        
        [Parameter(Mandatory = $true)]
        [string]$Module
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $archivePath = Join-Path -Path $script:LogConfig.LogsFolder -ChildPath "archives"
    $archiveFile = Join-Path -Path $archivePath -ChildPath "${Module}_${timestamp}.log"
    $archiveZip = "$archiveFile.zip"
    
    # S'assurer que le nom du fichier est unique
    $counter = 1
    while (Test-Path $archiveZip) {
        $archiveFile = Join-Path -Path $archivePath -ChildPath "${Module}_${timestamp}_$counter.log"
        $archiveZip = "$archiveFile.zip"
        $counter++
    }
    
    # Déplacer le fichier actuel vers les archives
    Copy-Item -Path $LogFile -Destination $archiveFile
    
    # Compresser si activé
    if ($script:LogConfig.CompressionEnabled) {
        Compress-Archive -Path $archiveFile -DestinationPath $archiveZip -Force
        Remove-Item -Path $archiveFile
    }
    
    # Vider le fichier de log original tout en conservant l'en-tête
    if ($script:LogConfig.LogHeaders.ContainsKey($Module)) {
        Initialize-LogFile -LogType $Module -FilePath $LogFile
    } else {
        Set-Content -Path $LogFile -Value ""
    }
}

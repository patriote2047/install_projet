#########################################################################
# Module: width_files_control
# Description: Module de contrôle de la largeur des fichiers
# Date: 2025-01-08
# Version: 1.0
#########################################################################

# Importer les modules nécessaires
. $PSScriptRoot\modules_control\width_modules\file_analyzer.ps1
. $PSScriptRoot\modules_control\width_modules\file_splitter.ps1
. $PSScriptRoot\modules_control\width_modules\file_logger.ps1
. $PSScriptRoot\logs_files.ps1

# Définir le module
New-Module -Name "WidthFilesControl" -ScriptBlock {
    function Test-FileLineCount {
        param(
            [Parameter(Mandatory = $true)]
            [string]$FilePath,
            
            [Parameter(Mandatory = $false)]
            [int]$MaxLines = 50,
            
            [Parameter(Mandatory = $false)]
            [switch]$AutoSplit
        )
        
        Write-LogMessage "========== ANALYSE DE FICHIER ==========" -Level Info -Module "WidthFiles"
        Write-LogMessage "Fichier analysé : $FilePath" -Level Info -Module "WidthFiles"
        Write-LogMessage "Date : $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -Level Info -Module "WidthFiles"
        Write-LogMessage "=======================================" -Level Info -Module "WidthFiles"
        
        # Vérifier si le fichier existe
        if (-not (Test-Path $FilePath)) {
            Write-LogMessage "ERREUR : Le fichier $FilePath n'existe pas." -Level Error -Module "WidthFiles"
            Write-LogMessage "=======================================" -Level Info -Module "WidthFiles"
            return $false
        }
        
        # Compter les lignes
        $lineCount = (Get-Content $FilePath).Count
        Write-LogMessage "Nombre de lignes trouvées : $lineCount" -Level Info -Module "WidthFiles"
        Write-LogMessage "Limite configurée : $MaxLines lignes" -Level Info -Module "WidthFiles"
        
        # Vérifier le dépassement
        if ($lineCount -gt $MaxLines) {
            Write-LogMessage "ATTENTION : Dépassement détecté !" -Level Warning -Module "WidthFiles"
            Write-LogMessage "Le fichier dépasse de $($lineCount - $MaxLines) lignes" -Level Warning -Module "WidthFiles"
            
            if ($AutoSplit) {
                Write-LogMessage "DÉBUT DE LA DIVISION DU FICHIER" -Level Warning -Module "WidthFiles"
                Write-LogMessage "=======================================" -Level Info -Module "WidthFiles"
                
                try {
                    $result = Split-FileIntoModules -FilePath $FilePath -MaxLinesPerFile $MaxLines
                    
                    # Journaliser les détails de la division
                    Write-LogMessage "DIVISION RÉUSSIE !" -Level Info -Module "WidthFiles"
                    Write-LogMessage "Fichier d'origine : $FilePath" -Level Info -Module "WidthFiles"
                    Write-LogMessage "Nouveaux fichiers créés :" -Level Info -Module "WidthFiles"
                    Write-LogMessage "---------------------------------------" -Level Info -Module "WidthFiles"
                    
                    foreach ($module in $result.GetEnumerator()) {
                        $moduleLines = (Get-Content $module.Value).Count
                        Write-LogMessage "- $($module.Value)" -Level Info -Module "WidthFiles"
                        Write-LogMessage "  Nombre de lignes : $moduleLines" -Level Info -Module "WidthFiles"
                    }
                    
                    Write-LogMessage "---------------------------------------" -Level Info -Module "WidthFiles"
                    Write-LogMessage "Sauvegarde de l'original : $FilePath.old" -Level Info -Module "WidthFiles"
                    Write-LogMessage "=======================================" -Level Info -Module "WidthFiles"
                    
                    return $result
                }
                catch {
                    Write-LogMessage "ÉCHEC DE LA DIVISION !" -Level Error -Module "WidthFiles"
                    Write-LogMessage "Erreur : $_" -Level Error -Module "WidthFiles"
                    Write-LogMessage "=======================================" -Level Info -Module "WidthFiles"
                    return $false
                }
            }
            else {
                Write-LogMessage "Division automatique désactivée" -Level Info -Module "WidthFiles"
                Write-LogMessage "=======================================" -Level Info -Module "WidthFiles"
                return $false
            }
        }
        
        Write-LogMessage "Le fichier respecte la limite de taille" -Level Info -Module "WidthFiles"
        Write-LogMessage "=======================================" -Level Info -Module "WidthFiles"
        return $true
    }
    
    function Watch-FileSize {
        param(
            [Parameter(Mandatory = $true)]
            [string]$DirectoryPath,
            
            [Parameter(Mandatory = $false)]
            [string]$Filter = "*.ps1",
            
            [Parameter(Mandatory = $false)]
            [int]$MaxLines = 50,
            
            [Parameter(Mandatory = $false)]
            [int]$IntervalSeconds = 30
        )
        
        Write-LogMessage "========== SURVEILLANCE DÉMARRÉE ==========" -Level Info -Module "WidthFiles"
        Write-LogMessage "Dossier surveillé : $DirectoryPath" -Level Info -Module "WidthFiles"
        Write-LogMessage "Filtre : $Filter" -Level Info -Module "WidthFiles"
        Write-LogMessage "Limite : $MaxLines lignes" -Level Info -Module "WidthFiles"
        Write-LogMessage "Intervalle : $IntervalSeconds secondes" -Level Info -Module "WidthFiles"
        Write-LogMessage "=======================================" -Level Info -Module "WidthFiles"
        
        try {
            while ($true) {
                $files = Get-ChildItem -Path $DirectoryPath -Filter $Filter -File
                foreach ($file in $files) {
                    Test-FileLineCount -FilePath $file.FullName -MaxLines $MaxLines
                }
                Start-Sleep -Seconds $IntervalSeconds
            }
        }
        catch {
            Write-LogMessage "ERREUR DE SURVEILLANCE !" -Level Error -Module "WidthFiles"
            Write-LogMessage "Erreur : $_" -Level Error -Module "WidthFiles"
            Write-LogMessage "=======================================" -Level Info -Module "WidthFiles"
        }
    }
    
    # Exporter les fonctions
    Export-ModuleMember -Function @(
        'Test-FileLineCount',
        'Watch-FileSize'
    )
} | Import-Module

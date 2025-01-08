#########################################################################
# Module: width_files_control
# Description: Module de contrôle de la largeur des fichiers
# Date: 2025-01-08
# Version: 1.0
#########################################################################

# Importer les modules nécessaires
Import-Module -Path $PSScriptRoot\modules_control\width_modules\file_analyzer.ps1
Import-Module -Path $PSScriptRoot\modules_control\width_modules\file_splitter.ps1
Import-Module -Path $PSScriptRoot\modules_control\width_modules\file_logger.ps1
Import-Module -Path $PSScriptRoot\logs_files.psm1

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
        try {
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
                        Write-ErrorLog $_
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
        catch {
            Write-ErrorLog $_
            return $false
        }
    }
    
    function Watch-FileSize {
        # ... (code existant) ...
        
        try {
            # ... (code existant) ...
        }
        catch {
            Write-ErrorLog $_
        }
        # ... (reste du code existant) ...
    }

    
    # Exporter les fonctions
    Export-ModuleMember -Function @(
        'Test-FileLineCount',
        'Watch-FileSize'
    )
} | Import-Module

                return $false
            }

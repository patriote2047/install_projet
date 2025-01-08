#########################################################################
# Module: test_logs_files
# Description: Tests du système de logs
# Date: 2025-01-08
# Version: 1.0
#########################################################################

# Définir le chemin du projet
$projectRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent

# Configuration du système de logs
$script:LogConfig = @{
    LogsFolder = Join-Path $projectRoot "logs_files"
    MaxLogSize = 1024  # KB
    LogHeaders = @{
        "General" = "LOG"
        "HeaderCheck" = "HDR"
        "WidthFiles" = "WDT"
        "TestModule" = "TST"
    }
}

# Créer le dossier de logs s'il n'existe pas
if (-not (Test-Path $script:LogConfig.LogsFolder)) {
    New-Item -ItemType Directory -Path $script:LogConfig.LogsFolder -Force | Out-Null
}

# Importer les modules dans l'ordre des dépendances
# 1. Fonctions de base
. "$projectRoot\modules_control\logs_modules\logs_files_part1.ps1"  # Initialize-LogFile (base)
. "$projectRoot\modules_control\logs_modules\logs_files_part2.ps1"  # Write-LogMessage (dépend de Initialize-LogFile)

# 2. Fonctions spécialisées d'écriture
. "$projectRoot\modules_control\logs_modules\logs_files_part3.ps1"  # Write-HeaderCheckLog (dépend de Write-LogMessage)
. "$projectRoot\modules_control\logs_modules\logs_files_part4.ps1"  # Write-WidthFilesLog (dépend de Write-LogMessage)

# 3. Fonction de maintenance
. "$projectRoot\modules_control\logs_modules\logs_files_part5.ps1"  # Start-LogRotation (dépend de Write-LogMessage)

# 4. Fonctions de recherche
. "$projectRoot\modules_control\logs_modules\logs_files_part7.ps1"  # Search-Logs (dépend de Write-LogMessage)
. "$projectRoot\modules_control\logs_modules\logs_files_part8.ps1"  # Get-LastLogs (dépend de Write-LogMessage)
. "$projectRoot\modules_control\logs_modules\logs_files_part9.ps1"  # Get-HeaderCheckLogs (dépend de Write-LogMessage)
. "$projectRoot\modules_control\logs_modules\logs_files_part10.ps1" # Get-WidthFilesLogs (dépend de Write-LogMessage)

# 5. Fonction de test
. "$projectRoot\modules_control\logs_modules\logs_files_part11.ps1" # Test-LogSystem (dépend de toutes les autres fonctions)

function Test-LogsSystem {
    Write-Host "=== Test du système de logs ===" -ForegroundColor Cyan
    
    # 1. Test d'écriture de base
    Write-Host "`n1. Test d'écriture de base" -ForegroundColor Yellow
    Write-LogMessage -Message "Test message 1" -Level "Info" -Module "TestModule"
    Write-LogMessage -Message "Test message 2" -Level "Warning" -Module "TestModule"
    Write-LogMessage -Message "Test message 3" -Level "Error" -Module "TestModule"
    
    # 2. Test de la limite de lignes
    Write-Host "`n2. Test de la limite de lignes" -ForegroundColor Yellow
    Write-Host "Écriture de 60 messages..."
    1..60 | ForEach-Object {
        Write-LogMessage -Message "Message de test $_" -Level "Info" -Module "TestModule"
    }
    Write-Host "Vérification du fichier de log..."
    $logContent = Get-Content "$projectRoot\logs_files\TestModule.log"
    Write-Host "Nombre de lignes : $($logContent.Count)"
    
    # 3. Test des logs spécialisés
    Write-Host "`n3. Test des logs spécialisés" -ForegroundColor Yellow
    Write-HeaderCheckLog -Message "Test d'en-tête" -Level "Info" -FileName "test.ps1"
    Write-WidthFilesLog -Message "Test de largeur" -Level "Info" -FileName "test.ps1"
    
    # 4. Test de recherche
    Write-Host "`n4. Test de recherche" -ForegroundColor Yellow
    Write-Host "Derniers logs de TestModule :"
    Get-LastLogs -Module "TestModule" -Count 5 | ForEach-Object {
        Write-Host $_ -ForegroundColor Gray
    }
    
    Write-Host "`nDerniers logs d'en-tête :"
    Get-HeaderCheckLogs -Count 5 -Level "Info" | ForEach-Object {
        Write-Host $_ -ForegroundColor Gray
    }
    
    Write-Host "`nDerniers logs de largeur :"
    Get-WidthFilesLogs -Count 5 -Level "Info" | ForEach-Object {
        Write-Host $_ -ForegroundColor Gray
    }
    
    # 5. Test de recherche par mot-clé
    Write-Host "`n5. Test de recherche par mot-clé" -ForegroundColor Yellow
    Write-Host "Recherche du mot 'test' dans les logs :"
    Search-Logs -SearchPattern "test" -Module "TestModule" | ForEach-Object {
        Write-Host $_ -ForegroundColor Gray
    }
}

# Exécuter les tests
Clear-Host
Test-LogsSystem
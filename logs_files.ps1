#########################################################################
# Fichier: logs_files.ps1
# Description: Fichier principal
# Date: 2025-01-08 14:15:54
#########################################################################

# Importer les modules dans l'ordre des dépendances
# 1. Fonctions de base
. ./modules_control/logs_modules/logs_files_part1.ps1  # Initialize-LogFile (base)
. ./modules_control/logs_modules/logs_files_part2.ps1  # Write-LogMessage (dépend de Initialize-LogFile)

# 2. Fonctions spécialisées d'écriture
. ./modules_control/logs_modules/logs_files_part3.ps1  # Write-HeaderCheckLog (dépend de Write-LogMessage)
. ./modules_control/logs_modules/logs_files_part4.ps1  # Write-WidthFilesLog (dépend de Write-LogMessage)

# 3. Fonction de maintenance
. ./modules_control/logs_modules/logs_files_part5.ps1  # Start-LogRotation (dépend de Write-LogMessage)

# 4. Fonctions de recherche
. ./modules_control/logs_modules/logs_files_part7.ps1  # Search-Logs (dépend de Write-LogMessage)
. ./modules_control/logs_modules/logs_files_part8.ps1  # Get-LastLogs (dépend de Write-LogMessage)
. ./modules_control/logs_modules/logs_files_part9.ps1  # Get-HeaderCheckLogs (dépend de Write-LogMessage)
. ./modules_control/logs_modules/logs_files_part10.ps1 # Get-WidthFilesLogs (dépend de Write-LogMessage)

# 5. Fonction de test
. ./modules_control/logs_modules/logs_files_part11.ps1 # Test-LogSystem (dépend de toutes les autres fonctions)

# Point d'entrée - Fonctions disponibles dans l'ordre logique
# 1. Initialisation et écriture de base
Initialize-LogFile    # Initialise un fichier de log
Write-LogMessage     # Écrit un message de log général

# 2. Écriture spécialisée
Write-HeaderCheckLog # Écrit un log de vérification d'en-tête
Write-WidthFilesLog  # Écrit un log de vérification de largeur

# 3. Maintenance des logs
Start-LogRotation    # Réinitialise un fichier de log quand il atteint sa limite

# 4. Recherche et consultation
Search-Logs          # Recherche dans les logs
Get-LastLogs         # Obtient les derniers logs
Get-HeaderCheckLogs  # Obtient les logs de vérification d'en-tête
Get-WidthFilesLogs   # Obtient les logs de vérification de largeur

# 5. Test du système
Test-LogSystem       # Teste le système de logs

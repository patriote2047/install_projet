#########################################################################
# Module: file_analyzer.ps1
# Description: Fonctions d'analyse et de recherche dans les logs
# Date: 2025-01-08
# Version: 1.0
#########################################################################

function Get-LastLogs {
    <#
    .SYNOPSIS
        Récupère les derniers logs d'un module
    .DESCRIPTION
        Affiche les derniers logs avec possibilité de filtrer par niveau
    #>
    param(
        [Parameter(Mandatory = $false)]
        [string]$Module = "General",
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level,
        
        [Parameter(Mandatory = $false)]
        [int]$Count = 10
    )
    
    $logFile = Join-Path -Path $script:LogConfig.LogsFolder -ChildPath "$Module.log"
    if (-not (Test-Path $logFile)) {
        Write-Warning "Aucun fichier de log trouvé pour le module $Module"
        return @()
    }
    
    $content = Get-Content $logFile
    $header = if ($script:LogConfig.LogHeaders.ContainsKey($Module)) {
        $content | Select-Object -First 7
    } else { @() }
    
    $logs = $content | Select-Object -Skip ($header.Count + 1)  # +1 pour la ligne vide après l'en-tête
    
    if ($Level) {
        $logs = $logs | Where-Object { $_ -match "\[$Level\]" }
    }
    
    # Toujours retourner les logs du plus récent au plus ancien
    $logs = $logs | Where-Object { $_ -match '^\[\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\]' }  # Filtrer les lignes vides
    $logs = $logs | Sort-Object -Descending { 
        if ($_ -match '^\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]') {
            [datetime]::ParseExact($matches[1], 'yyyy-MM-dd HH:mm:ss', $null)
        }
    } | Select-Object -First $Count
    
    return $logs
}

function Search-Logs {
    <#
    .SYNOPSIS
        Recherche dans les fichiers de log
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$SearchPattern,
        
        [Parameter(Mandatory = $false)]
        [string]$Module,
        
        [Parameter(Mandatory = $false)]
        [DateTime]$StartDate,
        
        [Parameter(Mandatory = $false)]
        [DateTime]$EndDate
    )
    
    $searchPath = if ($Module) {
        Join-Path -Path $script:LogConfig.LogsFolder -ChildPath "$Module.log"
    } else {
        Join-Path -Path $script:LogConfig.LogsFolder -ChildPath "*.log"
    }
    
    $results = Get-Content -Path $searchPath | Where-Object {
        $line = $_
        $matchesPattern = $line -match $SearchPattern
        $matchesDate = $true
        
        if ($StartDate -or $EndDate) {
            if ($line -match '\[([\d-]+ [\d:]+)\]') {
                $logDate = [DateTime]::ParseExact($matches[1], "yyyy-MM-dd HH:mm:ss", $null)
                $matchesDate = (-not $StartDate -or $logDate -ge $StartDate) -and (-not $EndDate -or $logDate -le $EndDate)
            }
        }
        
        $matchesPattern -and $matchesDate
    }
    
    return $results
}

function Get-HeaderCheckLogs {
    <#
    .SYNOPSIS
        Récupère les logs de vérification des en-têtes
    #>
    param(
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level,
        
        [Parameter(Mandatory = $false)]
        [string]$FileName,
        
        [Parameter(Mandatory = $false)]
        [int]$Count = 10
    )
    
    $logs = Get-LastLogs -Module "HeaderCheck" -Level $Level -Count ([int]::MaxValue)
    
    if ($FileName) {
        $logs = $logs | Where-Object { $_ -match "\[$FileName\]" }
    }
    
    return $logs | Select-Object -First $Count
}

function Get-WidthFilesLogs {
    <#
    .SYNOPSIS
        Récupère les logs de largeur de fichiers
    .DESCRIPTION
        Permet de filtrer les logs par largeur minimale et niveau
    #>
    param(
        [Parameter(Mandatory = $false)]
        [int]$MinWidth = 0,
        
        [Parameter(Mandatory = $false)]
        [ValidateSet("Info", "Warning", "Error")]
        [string]$Level
    )
    
    $logs = Get-LastLogs -Module "WidthFiles" -Level $Level
    
    if ($MinWidth -gt 0) {
        $logs = $logs | Where-Object {
            if ($_ -match "Largeur: (\d+)") {
                [int]$width = $matches[1]
                $width -ge $MinWidth
            }
        }
    }
    
    return $logs
}

function Get-PowerShellFunctions {
    <#
    .SYNOPSIS
        Extrait les fonctions d'un fichier PowerShell
    .DESCRIPTION
        Analyse le contenu d'un fichier PowerShell et retourne un tableau d'objets
        contenant les informations sur chaque fonction trouvée
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content
    )
    
    $functions = @()
    $lines = $Content -split "`n"
    $inFunction = $false
    $currentFunction = @{
        Name = ""
        Content = @()
        LineCount = 0
    }
    $bracketCount = 0
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Détecter le début d'une fonction
        if ($line -match '^\s*function\s+([a-zA-Z0-9_-]+)\s*{') {
            $inFunction = $true
            $currentFunction.Name = $matches[1]
            $currentFunction.Content = @($line)
            $currentFunction.LineCount = 1
            $bracketCount = 1
            continue
        }
        
        if ($inFunction) {
            $currentFunction.Content += $line
            $currentFunction.LineCount++
            
            # Compter les accolades
            $bracketCount += ($line.ToCharArray() | Where-Object { $_ -eq '{' }).Count
            $bracketCount -= ($line.ToCharArray() | Where-Object { $_ -eq '}' }).Count
            
            # Si on trouve la dernière accolade de la fonction
            if ($bracketCount -eq 0) {
                $functions += [PSCustomObject]@{
                    Name = $currentFunction.Name
                    Content = $currentFunction.Content
                    LineCount = $currentFunction.LineCount
                }
                $inFunction = $false
                $currentFunction = @{
                    Name = ""
                    Content = @()
                    LineCount = 0
                }
            }
        }
    }
    
    return $functions
}

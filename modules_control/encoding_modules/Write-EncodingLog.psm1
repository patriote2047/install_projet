# Module de journalisation
$script:logFile = "logs_files/encoding_check.log"

function Write-EncodingLog {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $logMessage = "[$timestamp][$level] $message"
    
    $logDir = Split-Path $script:logFile -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    
    Add-Content -Path $script:logFile -Value $logMessage -Encoding UTF8
}

Export-ModuleMember -Function Write-EncodingLog

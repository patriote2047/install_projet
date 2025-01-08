@{
    ModuleVersion = '1.0'
    GUID = 'a12345b6-c789-4def-0123-456789abcdef'
    Author = 'Fred'
    Description = 'Module de contrôle d''encodage pour les fichiers'
    PowerShellVersion = '5.1'
    RootModule = 'encodage_control.psm1'
    FunctionsToExport = @(
        'Invoke-EncodingControl',
        'Test-FileEncoding',
        'Convert-FileEncoding',
        'Write-EncodingLog',
        'Add-EncodingControl'
    )
    NestedModules = @(
        'modules_control\encoding_modules\Test-FileEncoding.psm1',
        'modules_control\encoding_modules\Convert-FileEncoding.psm1',
        'modules_control\encoding_modules\Write-EncodingLog.psm1',
        'modules_control\encoding_modules\Add-EncodingControl.psm1'
    )
}

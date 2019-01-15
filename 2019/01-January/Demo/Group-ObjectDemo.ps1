param (
    [Parameter(Mandatory)]
    [String]
    $ProfileName,

    [String]
    $Region = 'eu-west-2'
)

$InformationPreference = 'Continue'
$ProgressPreference = 'SilentlyContinue'
$PSDefaultParameterValues['Import-Module:ErrorAction'] = 'Stop'

if ($IsCoreClr) {
    Import-Module -Name AWSPowerShell.NetCore
} else {
    Import-Module -Name AWSPowerShell
}

Set-AWSCredential -ProfileName $ProfileName
Set-DefaultAWSRegion -Region $Region

# Get objects with many properties
Get-RDSDBInstance

# Group by Engine type
Get-RDSDBInstance | Group-Object -Property Engine

# Group by Engine type (again)
$instanceGroups = Get-RDSDBInstance | Group-Object -Property Engine, EngineVersion
Write-Information "MySQL endpoints:"
$instanceGroups | Where-Object Name -eq 'mysql' | 
    Select-Object -ExpandProperty Group | 
        ForEach-Object {
            Write-Information $PSItem.Endpoint.Address
        }

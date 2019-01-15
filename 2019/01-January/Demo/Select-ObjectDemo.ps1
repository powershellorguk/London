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

# Select object properties - Attempt 1
Get-RDSDBInstance | 
    Select-Object -Property DBInstanceIdentifier, DBInstanceStatus, Engine, EngineVersion, AllocatedStorage, StorageType, StorageEncrypted, LicenseModel, AvailabilityZone, MultiAZ, MasterUserName, DBInstanceClass, PreferredBackupWindow, PreferredMaintenanceWindow, InstanceCreateTime

# Select object properties - Attempt 2
$selectProperties = @(
    'DBInstanceIdentifier'
    'DBInstanceStatus'
    'Engine'
    'EngineVersion'
    'AllocatedStorage'
    'StorageType'
    'StorageEncrypted'
    'LicenseModel'
    'AvailabilityZone'
    'MultiAZ'
    'MasterUserName',
    'DBInstanceClass'
    'PreferredBackupWindow'
    'PreferredMaintenanceWindow'
    'InstanceCreateTime'
)
Get-RDSDBInstance | 
    Select-Object -Property $selectProperties |
        Format-Table -AutoSize
        #Export-Csv -Path "~\Documents\AWS-RDS-MySQL-Instances.csv" -NoTypeInformation

# Select object properties - Attempt 3
$selectProperties = @(
    'DBInstanceIdentifier'
    'DBInstanceStatus'
    @{
        Name = 'Machine'
        Expression = {
            $PSItem.Engine
        }
    }
    'AllocatedStorage'
    'StorageType'
    'StorageEncrypted'
    'LicenseModel'
    'AvailabilityZone'
    'MultiAZ'
    'MasterUserName',
    'DBInstanceClass'
    'PreferredBackupWindow'
    'PreferredMaintenanceWindow'
    'InstanceCreateTime'
)
Get-RDSDBInstance | 
    Select-Object -Property $selectProperties |
        Format-Table -AutoSize
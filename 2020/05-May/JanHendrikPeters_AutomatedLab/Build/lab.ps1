[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $LabName = 'DSCValidation',

    [Parameter()]
    [ValidateSet('HyperV', 'Azure')]
    [string]
    $VirtualizationEngine = $env:Engine,

    [string]
    $Password = $env:Password
)

Set-PSFConfig -Module 'AutomatedLab' -Name DisableConnectivityCheck -Value $true -PassThru | Register-PSFConfig
Import-Module AutomatedLab

#region Configure the lab
$null = New-Item -ErrorAction SilentlyContinue -Path /AutomatedLab-VMs -ItemType Directory
New-LabDefinition -Name $LabName -DefaultVirtualizationEngine $VirtualizationEngine -VmPath /AutomatedLab-VMs

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2019 Datacenter'
    'Add-LabMachineDefinition:DomainName' = 'contoso.com'
    'Add-LabMachineDefinition:Memory' = 2gb
}
#endregion

Add-LabDomainDefinition -Name contoso.com -AdminUser JHP -AdminPassword $Password
Set-LabInstallationCredential -Username JHP -Password $Password

Add-LabMachineDefinition -Name DSCDC1 -Roles RootDC
<# Optionally add a CA to make use of encrypted passwords in your MOFs
Add-LabMachineDefinition -Name DSCCA1 -Roles CaRoot
#>

# The target machines
$vms = (Import-PowerShellDataFile -Path $PSScriptRoot\..\DSC\ConfigurationData.psd1).AllNodes.NodeName | Where-Object {$_ -ne '*'}
foreach ($vm in $vms)
{
    Add-LabMachineDefinition -Name $vm
}

Install-Lab

Send-ModuleToPSSession -Module (Get-Module -ListAvailable xWebAdministration) -Session (New-LabPSSession -Computername $vms)
exit 0

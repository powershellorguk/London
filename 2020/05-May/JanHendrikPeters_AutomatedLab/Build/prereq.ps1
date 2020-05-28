[CmdletBinding()]
param (
    [Parameter()]
    [string[]]
    $Modules = @('Az', 'PSFramework', 'newtonsoft.json', 'AutomatedLab.Common', 'Ships', 'AutomatedLab', 'xWebAdministration')
)

Write-Host 'Downloading modules'
#region Bootstrapping the module and configure basic settings
[Environment]::SetEnvironmentVariable('AUTOMATEDLAB_TELEMETRY_OPTIN', 'yes', 'Machine')
$env:AUTOMATEDLAB_TELEMETRY_OPTIN = 'yes' # or no, we are very open about what we collect.
Install-Module -Name $Modules -Force -Repository PSGallery -Scope AllUsers -AllowClobber -SkipPublisherCheck
Install-Module -Name Pester -Force -Repository PSGallery -Scope AllUsers -SkipPublisherCheck -AllowClobber -MaximumVersion 4.99.99

Write-Host "Downloading labsources"
Import-Module AutomatedLab -Verbose -Force
$null = New-LabSourcesFolder -Force -Confirm:$false -Verbose # Download additional scripts and samples if necessary

#endregion

exit 0
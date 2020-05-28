Get-Introduction
'Good evening, ladies and gentlemen :)' | Out-Voice # Install-Module VoiceCommands 

# Let's examine the pipeline first
psedit .\pipeline.yml

# I've already ran it with an intentional error. Let's have a look.
start 'https://dev.azure.com/japete/PSUGUK/_build/results?buildId=345&view=ms.vss-test-web.build-test-results-tab'

# So, now that we know what's wrong, we can fix the issue
# and while we do that, have a look at the other scripts

# Prerequisites need to come first
psedit ./Build/prereq.ps1

# Technically part of the prerequisites is the lab
psedit ./Build/lab.ps1

# Validation is important, too!
psedit ./Build/validate.ps1

# The error was part of the configuration
psedit ./Dsc/BuildConfiguration.ps1

# To fix it: New branch, commit, publish, create PR
git checkout -b fixit
git branch
git add .
git commit -m 'Everything is awesome'
git push -u --set-upstream origin/fixit
start 'https://dev.azure.com/japete/_git/PSUGUK/pullrequestcreate'

# While the PR validation is running, let's keep exploring AutomatedLab
# Installation and preparation
Install-Module AutomatedLab # or download the MSI (deb, rpm) installer for offline environments (github.com/automatedlab/automatedlab)

# Now what?
New-LabSourcesFolder -Force # Download sample scripts, custom roles, ...
$labsources # Always points to the lab sources used
Get-ChildItem $labsources/ISOs # This is where your own ISOs need to be placed
Get-LabAvailableOperatingSystem # Automatically pick up all valid OSses from your ISOs

# A simple lab
New-LabDefinition -Name SimpleYetEffective -DefaultVirtualizationEngine Azure
Add-LabMachineDefinition -Name SRV01 -OperatingSystem 'Windows Server 2019 Datacenter' -Memory 4GB
Install-Lab

# Mo' credentials, mo' problems
Invoke-LabCommand -ComputerName SRV01 -ScriptBlock {
    Get-WebSite
} -PassThru
Install-LabWindowsFeature -ComputerName SRV01 -FeatureName Web-Server -IncludeManagementTools
Invoke-LabCommand -ComputerName SRV01 -ScriptBlock {
    Get-WebSite
} -PassThru

$cims = New-LabCimSession -ComputerName (Get-LabVM)
Get-Disk -CimSession $cims
Get-DscLocalConfigurationManager -CimSession $cims

# Super simple interactions
Restart-LabVM -ComputerName SRV01 -Wait
Checkpoint-LabVM -SnapshotName BeforeMessingUp -All
Save-LabVM -Name SRV01
Start-LabVM -ComputerName SRV01 -Wait

# Works of course with deb and rpm as well
$nppUri = 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v7.8.6/npp.7.8.6.Installer.x64.exe'
$installer = Get-LabInternetFile -Uri $nppUri -Path $labsources/tools -NoDisplay -Force -PassThru
$parm = @{
    Path                = $installer.FullName
    ComputerName        = Get-LabVM
    CommandLine         = '/S'
    ExpectedReturnCodes = 0, 3010
}
Install-LabSoftwarePackage @parm
Connect-LabVM -ComputerName SRV01

# Remove when done - reference disks remain
Remove-Lab -Confirm:$false

# Adding a TFS build worker to the cloud service
# https://automatedlab.org/en/latest/Wiki/Roles/roles/
$role = Get-LabMachineRoleDefinition -Role TfsBuildWorker -Properties @{
    Organisation = 'japete'
    PAT = 'some token, generated on dev.azure.com'
    AgentPool = 'OnPrem'
}
Add-LabMachineDefinition -Role $role, HyperV
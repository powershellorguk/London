configuration BasicExample
{
    [CmdletBinding()]
    param
    ( )

    Import-DscResource -ModuleName xWebAdministration -ModuleVersion 3.1.1
    Import-DscResource -ModuleName PSDesiredStateConfiguration

    node $AllNodes.Where({$_.Role -eq 'WebServer' -and $_.Environment -eq $Environment}).NodeName
    {
        File BasicWebsiteContent
        {
            DestinationPath = 'C:\inetup\mysite\index.html'
            Contents        = @"
<html>
<head Title="We love DSC" />
<body>
<h1>We ♥ AutomatedLab and DSC - built for $Node</h1>
</body>
</html>
"@
            Ensure          = 'Present'
        }

        WindowsFeature WebServer
        {
            Name   = 'Web-Server'
            Ensure = 'Present'
        }

        xWebSite DefaultRemove
        {
            Name         = 'Default Web Site'
            DependsOn    = '[WindowsFeature]WebServer'
            PhysicalPath = 'C:\inetup\wwwroot'
            Ensure       = 'Absent'
        }

        xWebSite BasicWebSite
        {
            Name         = 'Automated Web Site'
            DependsOn    = '[File]BasicWebsiteContent','[WindowsFeature]WebServer', '[xWebSite]DefaultRemove'
            PhysicalPath = 'C:\inetup\mysite'
            State        = 'Started'
            Ensure       = 'Present'
        }
    }
}

$null = New-Item -ItemType Directory -ErrorAction SilentlyContinue -Path C:\DscMofs
Get-ChildItem -Path C:\DSCMofs\*.mof | Remove-Item -Force
BasicExample -ConfigurationData $PSScriptRoot/ConfigurationData.psd1 -OutputPath C:\DscMofs

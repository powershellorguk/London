[CmdletBinding()]
param 
(
    [Parameter()]
    [string]
    $LabName = 'DSCValidation',

    [ValidateSet('Unit','Integration')]
    [string]
    $Type
)

if ($Type -eq 'Integration')
{
    Import-Lab -Name $LabName -NoValidation -NoDisplay
}

Invoke-Pester -Script $PSScriptRoot/../tests/$Type -OutputFile $PSScriptRoot/../$Type-test-results.xml -OutputFormat NUnitXml
exit 0
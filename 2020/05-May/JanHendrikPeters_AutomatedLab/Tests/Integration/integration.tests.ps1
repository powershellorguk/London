Describe "Integration test" {
    $vms = (Import-PowerShellDataFile -Path $PSScriptRoot\..\..\DSC\ConfigurationData.psd1).AllNodes.NodeName | Where-Object {$_ -ne '*'}

    foreach ($vm in $vms)
    {
        $vm = Get-LabVm -ComputerName $vm
        $session = New-LabCimSession -ComputerName $vm

        Context 'MOF creation' {
            It "[$vm] Should have a MOF file C:\DscMofs\$($vm).mof" {
                Test-Path -Path C:\DscMofs\$($vm).mof | Should -Be $true
            }
        }

        Context 'MOF application' {
            It "[$vm] Should apply the configuration without errors" {
                {
                    Start-DscConfiguration -Path C:\DscMofs -Force -Wait -CimSession $session -ErrorAction Stop } | Should -Not -Throw
            }

            It "[$vm] Should not fail Test-DscConfiguration" {
                Test-DscConfiguration -CimSession $session -ErrorAction SilentlyContinue | Should -Be $true
            }
        }

        Context 'Configuration-specific' { # For example: Testing the functionality of a deployed API and so on
            It "[$vm] Web site should be accessible" {
                {Invoke-RestMethod -Method Get -Uri http://$($vm.FQDN) -ErrorAction Stop} | Should -Not -Throw
            }
        }
    }
}

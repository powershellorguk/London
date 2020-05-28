Describe "DSC Unit tests - e.g. is the configuration data valid?" {
    BeforeEach { $requiredKey = 'AllNodes', 'DomainName' }

    It "ConfigurationData should have been imported" {
        $confdata = Import-PowerShellDataFile -Path $PSScriptRoot\..\..\DSC\ConfigurationData.psd1 -ErrorAction SilentlyContinue
        $confdata | Should -Not -Be $null
    }

    foreach ($key in $requiredKey)
    {
        It "Should contain $key key" {
            $confdata = Import-PowerShellDataFile -Path $PSScriptRoot\..\..\DSC\ConfigurationData.psd1 -ErrorAction SilentlyContinue
            $confdata.Contains($key) | Should -Be $true
        }
    }
}
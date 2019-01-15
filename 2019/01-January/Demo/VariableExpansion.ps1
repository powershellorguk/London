# Variable expansion in strings
$path = $PSHOME

Write-Information 'Single quotes'
'PSHOME: $path'
Write-Information ''

Write-Information 'Double quotes - Variant 1a'
"PSHOME: $path"
Write-Information ''

Write-Information 'Double quotes - Variant 2a'
"PSHOME: $(Get-Date)"
Write-Information ''

Write-Information 'Double quotes - Variant 1b'
"PSHOME: $path_other text"
Write-Information ''

Write-Information 'Double quotes - Variant 3a'
"PSHOME: ${path}"
Write-Information ''

Write-Information 'Double quotes - Variant 2b'
"PSHOME: $($path)_other text"
Write-Information ''

Write-Information 'Double quotes - Variant 3b'
"PSHOME: ${path}_other text"
Write-Information ''

$root = Resolve-Path -Path "$PSScriptRoot\.."
Push-Location $root

Write-Host "Creating $env:LOCALAPPDATA\nvim"
New-Item -ItemType Junction -Path $env:LOCALAPPDATA\nvim -Target "$root\nvim" > $null

Pop-Location


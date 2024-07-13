$root = Resolve-Path -Path "$PSScriptRoot\.."
Push-Location $root

Write-Host "Removing $env:LOCALAPPDATA\nvim"
Remove-Item -Recurse -Force -Path $env:LOCALAPPDATA\nvim -ErrorAction SilentlyContinue

Write-Host "Removing $env:LOCALAPPDATA\nvim-data"
Remove-Item -Recurse -Force -Path $env:LOCALAPPDATA\nvim-data -ErrorAction SilentlyContinue

Pop-Location


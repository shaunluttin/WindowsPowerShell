
Write-Host "Loading MyScripts..."

$env:SVN_EDITOR = "vim"

Import-Module CustomPrompt
Import-Module Aliases
Import-Module SkipHistory
Import-Module PSGet
Import-Module AddToPATH

Write-Host "Done"

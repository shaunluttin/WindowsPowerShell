Write-Host "Loading MyScripts..."

$env:SVN_EDITOR = "vim"

Import-Module Aliases
Import-Module SkipHistory
Import-Module PSGet
Import-Module GetFileEncoding
Import-Module AddToPATH
Import-Module Posh-Git
Start-SshAgent
Import-Module CustomPrompt

Write-Host "Done"


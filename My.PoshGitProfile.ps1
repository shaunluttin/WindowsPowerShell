Push-Location (Split-Path -Path $MyInvocation.MyCommand.Definition -Parent)

# Load posh-git module
Import-Module 'C:\tools\poshgit\dahlbyk-posh-git-95df787\posh-git.psm1'

Enable-GitColors
Pop-Location
Start-SshAgent -Quiet

$GitPromptSettings.EnableFileStatus = $false # speed up git

git config --global color.status.changed "cyan normal bold"
git config --global color.status.untracked "cyan normal bold"
$GitPromptSettings.WorkingForegroundColor    = [ConsoleColor]::Yellow
$GitPromptSettings.UntrackedForegroundColor  = [ConsoleColor]::Yellow
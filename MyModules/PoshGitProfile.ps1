
# Load posh-git module
Import-Module posh-git

# Use colors
Enable-GitColors

# Start-SshAgent
# This commandlet is part of the posh-git module
# First, add the git SSH agent to the PATH
# to avoid "could not find ssh-agent"
$env:path += ";" + (Get-Item "Env:ProgramFiles(x86)").Value + "\Git\bin"
Start-SshAgent -Quiet

# speed up git
$GitPromptSettings.EnableFileStatus = $false

# set git colours
# git config --global color.status.changed "cyan normal bold"
# git config --global color.status.untracked "cyan normal bold"
# $GitPromptSettings.WorkingForegroundColor    = [ConsoleColor]::Yellow
# $GitPromptSettings.UntrackedForegroundColor  = [ConsoleColor]::Yellow



# Add the git SSH agent to the PATH
# This avoids the "could not find ssh-agent" message
$env:path += ";" + (Get-Item "Env:ProgramFiles(x86)").Value + "\Git\bin"

# Load posh-git example profile
. 'C:\tools\poshgit\dahlbyk-posh-git-95df787\profile.example.ps1'


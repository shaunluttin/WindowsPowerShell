
# Add the git SSH agent to the PATH to avoid "could not find ssh-agent"
$env:path += ";" + (Get-Item "Env:ProgramFiles(x86)").Value + "\Git\bin"

# Load posh-git example profile
. 'C:\tools\poshgit\dahlbyk-posh-git-95df787\profile.example.ps1'

# Load my posh-git profile using the dot-source notation
. 'C:\Users\BigFont\Documents\WindowsPowerShell\My.PoshGitProfile.ps1'

# Customize the prompt
function prompt
{
    Write-Host ("Shaun>") -nonewline -foregroundcolor White
    return " "
}

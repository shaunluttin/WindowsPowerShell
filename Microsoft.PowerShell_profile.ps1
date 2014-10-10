
# Load posh-git example profile using the dot-source notation
# . 'C:\tools\poshgit\dahlbyk-posh-git-95df787\profile.example.ps1'

# Load my posh-git profile using the dot-source notation
. 'C:\Users\BigFont\Documents\WindowsPowerShell\My.PoshGitProfile.ps1'



function prompt
{
    Write-Host ("Shaun>") -nonewline -foregroundcolor White
    return " "
}
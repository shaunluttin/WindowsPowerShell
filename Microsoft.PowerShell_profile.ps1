
Write-Host "Loading MyScripts..."

# Run

Push-Location ~\Documents\WindowsPowerShell\MyScripts

.\AddToPATH.ps1
.\Aliases.ps1
.\PoshGitProfile.ps1
.\RawUiCustomization.ps1
.\CustomPrompt.ps1

Pop-Location

# Load

Import-Module History

Write-Host "Done"
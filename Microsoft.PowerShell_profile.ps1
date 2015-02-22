
Write-Host "Loading MyModules..."

# Run these

Push-Location ~\Documents\WindowsPowerShell\MyModules

.\AddToPATH.ps1
.\Aliases.ps1
.\PoshGitProfile.ps1
.\RawUiCustomization.ps1
.\CustomPrompt.ps1

Pop-Location

# Load these

. ~\Documents\WindowsPowerShell\MyModules\NoHistory.ps1

Write-Host "Done"
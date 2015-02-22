
Write-Host "Loading MyModules..."
Push-Location ~\Documents\WindowsPowerShell\MyModules

.\AddToPATH.ps1
.\Aliases.ps1
.\PoshGitProfile.ps1
.\RawUiCustomization.ps1
.\CustomPrompt.ps1
.\NoHistory.ps1

Pop-Location
Write-Host "Done"

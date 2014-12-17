
Write-Host "Loading MyModules..."
Push-Location ~\Documents\WindowsPowerShell\MyModules

.\EmulateRun.ps1
.\My.Aliases.ps1
.\My.PoshGitProfile.ps1
.\RawUiCustomization.ps1
.\CustomPrompt.ps1

Pop-Location
Write-Host "Done"

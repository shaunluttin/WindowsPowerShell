#
# Emulate 'run' behavior with most programs
# -------------------------

function addToPath($dir)
{
  if($env:Path -notlike "*$dir*")
  {
    Write-Host "Adding to PATH: $dir";
    $env:Path += ";" + $dir;
  }
}

$regkey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths'

$appPaths = Get-ChildItem $regkey |
  Get-ItemProperty |
  ? { $_.'(default)' } |
  select -Expand '(default)' |
  Split-Path -Parent |
  % { [Environment]::ExpandEnvironmentVariables($_.TrimStart('"')) } |
  select -Unique

# add chocolaty
addToPath('C:\ProgramData\chocolatey\bin')

# add most other apps
$appPaths | %{ addToPath($_) }

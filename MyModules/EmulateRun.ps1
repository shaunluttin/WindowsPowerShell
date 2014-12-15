#
# Emulate 'run' behavior with most programs
# -------------------------

$regkey = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths'

$appPaths = Get-ChildItem $regkey |
  Get-ItemProperty |
  ? { $_.'(default)' } |
  select -Expand '(default)' |
  Split-Path -Parent |
  % { [Environment]::ExpandEnvironmentVariables($_.TrimStart('"')) } |
  select -Unique

$env:PATH = '';
$env:PATH += ';' + ($appPaths -join ';')
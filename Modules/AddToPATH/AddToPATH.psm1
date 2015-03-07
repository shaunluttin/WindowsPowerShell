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

$regkeys = @( 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths' )

$appPaths = @();

foreach($regkey in $regkeys)
{

    $appPaths += Get-ChildItem $regkey |
      Get-ItemProperty |
      Where-Object { $_.'(default)' } |
      select -Expand '(default)' |
      % { if($_) { $_.TrimStart("`"").TrimEnd("`"") }} |
      Split-Path -Parent  |
      % { [Environment]::ExpandEnvironmentVariables($_.TrimStart('"')) } |
      select -Unique
}


# add some manually
addToPath('C:\ProgramData\chocolatey\bin')
addToPath('C:\Program Files (x86)\vim\vim74')
addToPath('C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319') #include MSBuild

# add most other apps
$appPaths | % { addToPath($_) }


# Customize the prompt
function global:prompt
{
   # get the current dir
   $array = (Get-Location).Path.TrimEnd('\').Split('\');
   $currentDir = $array[$array.Length - 1];

   # add it to the prompt
   Write-Host ($currentDir + ">") -nonewline -foregroundcolor Yellow

   return " ";
}

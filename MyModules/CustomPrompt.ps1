
# Customize the prompt
function global:prompt
{
   # get the current dir
   $array = (location).Path.TrimEnd('\').Split('\');

   $currentDir = $array[$array.Length - 1];

   # add it to the prompt
   Write-Host ($currentDir + ">") -nonewline -foregroundcolor Yellow

   return " ";
}

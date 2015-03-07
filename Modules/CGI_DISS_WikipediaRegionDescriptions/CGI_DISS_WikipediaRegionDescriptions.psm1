
# Example
# Get-WikipediaRegionDesc -region "vancouver"

function Get-WikipediaRegionDesc ($region)
{

  $url = "http://en.wikipedia.org/wiki/$($region),_British_Columbia";
  $result;
  
  try
  {
  
     $result = curl $url | 
     select -expand allelements | 
     ? { $_.id -eq "mw-content-text" } | 
     select -expand innerHTML | 
     % { 
        $i = $_.IndexOf("<P>"); 
        $j = $_.IndexOf("</P>"); 
        $_.Substring($i, $j - $i) -replace '<[^>]*>'
      } 
  }
  catch 
  {
    $result = "Didn't work. Maybe " + $url + " doesn't exist.";
  }

   $dir = "C:\Users\shaun.luttin\documents\CGI_DISS_WikipediaRegionDescriptions\"
   ni -type dir $dir -force | out-null
   
   $file = $dir + $region + ".txt";
   ni -type file $file -force | out-null
   ac $file $result;
   
   
   "`n" + $result + "`n`n" + $url + "`n`n";

}

# Example
# Get-WikipediaRegionDesc -region "tradebc_community.csv"

function Get-WikipediaRegionDescFromCsvFile ($file)
{
    write-host $file;

    $index = 0;
    $timestamp = (get-date -f yyyy-MMM-dd-hhhh-mmmm);
    $source = (get-item $file).BaseName;
    $destination = "wikipedia-descriptions-$source-$timestamp.csv";

    try
    {
        Import-Csv $file |             
            Select-Object name | 
            ForEach-Object {
                Write-Host "Searching Wikipedia for" $_.name;
                Get-WikipediaRegionDesc $_.name;
            } | 
            Select-Object RegionName, Url, Description, ShortDescription |
            ForEach-Object { 
                Export-Csv -InputObject $_ -Path $destination -Append -NoTypeInformation;
                $index += 1;
            }

       Write-Host "Wrote $($index) entries to $($destination)."
    }
    catch
    {
        Write-Host $_.Exception.ToString()
    }
}


# Example
# Get-WikipediaRegionDesc -region "vancouver"

function Get-WikipediaRegionDesc ($region)
{
    $dir = "C:\Users\shaun.luttin\Documents\ProjectNotes\1415-TIBC-DISS-TA-0077\WikipediaRegions\Results\";
  
    $regex = @{};
    $regex.htmlTags = '<[^>]+>';
    $regex.footnotes = '\[\d{0,3}\]';
    $regex.firstNations = '\/[^\/]+\/\s';
    $regex.parentheses = '\([^\)]+\),?\s';
    $regex.htmlEntities = '&[^\s]*;';
  
    try
    {
        $url = Get-WikipediaUrlFromRegion $region
        $description = Get-DescriptionFromWikipediaUrl $url

        # create hash table of results
        if($description)
        {
            $results = @{
                RegionName = $region
                Url = $url
                Description = $description
                ShortDescription = $description.PadRight(380).Substring(0, 380)                
            }
        }
        else
        {
            $results = @{
                RegionName = $region
                Url = $url
                Description = "Not found in wikipedia"
                ShortDescription = "Not found in wikipedia"                
            }
        }


        # convert hash table to object
        $object = new-object psobject -Property $results
        return $object;

    }
    catch 
    {
        Write-Host $_.Exception.ToString()
    }

}

function Get-WikipediaUrlFromRegion ($region)
{
    try
    {
        $region = $region -replace " ", "_"
        if($region -match "/")
        {
            $region = $region -replace "/", "-"
            $region = "Regional_District_of_" + $region;
        }
        else
        {
            $region = $region + ",_British_Columbia";
        }
        $url = "http://en.wikipedia.org/wiki/$($region)";
    }
    catch
    {
        Write-Host $_.Exception.ToString()
    }
    
    return $url;
}

function Get-DescriptionFromWikipediaUrl ($url)
{
    $desc = "";

    try
    {
        Write-Host "`tTrying" $url;

        $desc = Invoke-WebRequest $url | 
            Select-Object -expand allelements | 
            Where-Object { $_.id -eq "mw-content-text" } | 
            Select-Object -expand innerHTML | 
            ForEach-Object {  
            
                $html = Remove-TablesFromHtml $_;            

                $i = $_.IndexOf("<P>"); 
                $j = $_.IndexOf("</P>");                
                
                $_.Substring($i, $j - $i) -replace $regex.htmlTags -replace $regex.footnotes -replace $regex.firstNations -replace $regex.parentheses -replace $regex.htmlEntities
            }   
            
        Write-Host "`tSuccess" 
    }
    catch [System.Net.WebException]
    {
        $regionalPrefix = "Regional_District_of_";
        $regionalSuffix = "_Regional_District";

        if($url -match "_British_Columbia")
        {
            $url = $url -replace ",_British_Columbia";
            $desc = Get-DescriptionFromWikipediaUrl $url;
        }
        elseif($url -notmatch $regionalPrefix)
        {
            $i = $url.LastIndexOf("/") + 1;
            $url = $url.Insert($i, $regionalPrefix);
            $desc = Get-DescriptionFromWikipediaUrl $url;
        }
        elseif($url -match $regionalPrefix)
        {
            $url = $url -replace $regionalPrefix;
            $url = $url + $regionalSuffix;
            $desc = Get-DescriptionFromWikipediaUrl $url;
        }
        else
        {
            Write-Host "`tBummer"
        }
    }
    catch
    {
        Write-Host $_.Exception.ToString()
    }

    return $desc;
}

function Remove-TablesFromHtml ($theInput)
{
    try
    {
        $html = $theInput.ToLower();

        $tagStart = "<table";
        $tagEnd = "</table>";

        $continue = $true;
        while($continue)
        {
            $start = $html.IndexOf($tagStart);
            $end = $html.IndexOf($tagEnd) + $tagEnd.Length
            $count = $end - $start;

            if($start -gt 0 -and $count -gt 0)
            {
                $html = $html.remove($start, $count);
            }
            else
            {
                $continue = $false;
            }
        }   
    }
    catch
    {
        Write-Host $_.Exception.ToString()
    }

    Write-Host $html;
    Read-Host;

    return $html;
}
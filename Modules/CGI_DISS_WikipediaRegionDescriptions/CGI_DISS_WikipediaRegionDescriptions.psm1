
# Example
# Get-WikipediaRegionDesc -region "tradebc_community.csv"

function Get-WikipediaRegionDescFromCsvFile ($file)
{
    $index = 0;
    $destination = "wikipedia-descriptions.csv";

    try
    {
        Import-Csv $file | 
            # Select-Object -first 3 |
            Select-Object name | 
            ForEach-Object { Get-WikipediaRegionDesc $_.name } | 
            ForEach-Object { 
                Export-Csv -InputObject $_ -Path $destination -append;
                Write-Host $_.RegionName "Complete";
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

        $results = @{
            RegionName = $region
            Description = $description
            ShortDescription = $description.PadRight(380).Substring(0, 380)
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
        $urlSegment = $region -replace " ", "_"
        $url = "http://en.wikipedia.org/wiki/$($urlSegment),_British_Columbia";
    }
    catch
    {
        Write-Host $_.Exception.ToString()
    }
    
    return $url;
}

function Get-DescriptionFromWikipediaUrl ($url)
{
    try
    {
        $desc = Invoke-WebRequest $url | 
            Select-Object -expand allelements | 
            Where-Object { $_.id -eq "mw-content-text" } | 
            Select-Object -expand innerHTML | 
            ForEach-Object { 
                $i = $_.IndexOf("<P>"); 
                $j = $_.IndexOf("</P>"); 
                $_.Substring($i, $j - $i) -replace $regex.htmlTags -replace $regex.footnotes -replace $regex.firstNations -replace $regex.parentheses -replace $regex.htmlEntities
            }    
    }
    catch [System.Net.WebException]
    {
        Write-Host $url " not found"
    }
    catch
    {
        Write-Host $_.Exception.ToString()
    }

    return $desc;
}
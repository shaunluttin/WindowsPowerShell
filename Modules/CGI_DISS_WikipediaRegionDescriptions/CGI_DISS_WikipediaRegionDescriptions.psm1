
# Example
# Get-WikipediaDescForRegionFromCsvFile "tradebc_community.csv"

function Get-WikipediaDescForEachRegion ($file)
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
                Get-WikipediaDescForRegion $_.name;
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
# Get-WikipediaDescForRegion -region "vancouver"

function Get-WikipediaDescForRegion ($region)
{  
    try
    {
        $url = Convert-RegionToWikipediaUrl $region
        $description = Get-WikipediaDescForUrl $url

        # create hash table
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

function Convert-RegionToWikipediaUrl ($region)
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

function Get-WikipediaDescForUrl ($url)
{
    $desc = "";

    $regex = @{};
    $regex.htmlTags = '<[^>]+>';
    $regex.footnotes = '\[\d{0,3}\]';
    $regex.firstNations = '\/[^\/]+\/\s';
    $regex.parentheses = '\([^\)]+\),?\s';
    $regex.htmlEntities = '&[^\s]*;';

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
                
                Remove-UnwantedStuffFromDesc ($_, $regex);
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
            $desc = Get-WikipediaDescForUrl $url;
        }
        elseif($url -notmatch $regionalPrefix)
        {
            $i = $url.LastIndexOf("/") + 1;
            $url = $url.Insert($i, $regionalPrefix);
            $desc = Get-WikipediaDescForUrl $url;
        }
        elseif($url -match $regionalPrefix)
        {
            $url = $url -replace $regionalPrefix;
            $url = $url + $regionalSuffix;
            $desc = Get-WikipediaDescForUrl $url;
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
    $openTag = "<TABLE";
    $closeTag = "</TABLE>";

    $RESET = -1;

    $openIndex = $RESET;
    $closeIndex = $RESET;

    $openTagCounter = 0;
    $closeTagCounter = 0;

    $index = $RESET;
    $startIndex = $RESET;
    $endIndex = $RESET;

    try
    {
        $html = $theInput;        
        $continue = $true;
        while($continue)
        {   
            $remainingOpenTags = ($html | select-string $openTag -allmatch).Matches.Count;
            $remainingCloseTags = ($html | select-string $closeTag -allmatch).Matches.Count;
            
            # get the smaller of the two indexes 
            # as starting points for the IndexOf 
            if($openIndex -le $closeIndex)
            {
                $index = $openIndex;
            }
            else
            {
                $index = $closeIndex;
            }
            
            
            # do another IndexOf
            $o = $html.IndexOf($openTag, $index + 1);
            if($o -ge 0) {
                $openIndex = $o;
            }
            
            $e = $html.IndexOf($closeTag, $index + 1);
            if($e -ge 0) {
                $closeIndex = $e;
            }
            
            # determine which one is smaller and count it
            if($openIndex -le $closeIndex)
            {
                if($openTagCounter -eq 0)
                {
                    $startIndex = $openIndex;
                }
                $openTagCounter += 1;
            }
            else
            {
                $closeTagCounter += 1;
            }  
            
            # short circuit if we have maxed out on open tags
            if($remainingOpenTags -eq $openTagCounter)
            {   
                $startIndex = $html.IndexOf($openTag);
                $closeIndex = $html.LastIndexOf($closeTag);
                                   
                $openTagCounter = $RESET;
                $closeTagCounter = $RESET;
            }
            
            # check whether we have the same number
            # of closing and opening tags
            if($openTagCounter -eq $closeTagCounter)
            {
                $endIndex = $closeIndex + $closeTag.Length;
                $count = $endIndex - $startIndex;
                
                $html = $html.Remove($startIndex, $count);
                 
                # reset - let's do it all again
                $openIndex = $RESET;
                $closeIndex = $RESET;

                $openTagCounter = 0;
                $closeTagCounter = 0;

                $index = $RESET;
                $startIndex = $RESET;
                $endIndex = $RESET;    
            }
            
            if($remainingOpenTags + $remainingCloseTags -eq 0)
            {
                $continue = $false;
            }
        }
        
        $html;
        return;
    }
    catch
    {
        Write-Host $_.Exception.ToString()
    }
}

function Remove-UnwantedStuffFromDesc ($desc, $regex)
{
    $_.Substring($i, $j - $i) -replace $regex.htmlTags -replace $regex.footnotes -replace $regex.firstNations -replace $regex.parentheses -replace $regex.htmlEntities
}
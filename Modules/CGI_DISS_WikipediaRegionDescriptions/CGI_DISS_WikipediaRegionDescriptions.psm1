

$global:SuccessfulUrls = @();


# Example
# dir .\tradebc_community.csv | % { Get-WikipediaDescriptionsFromCsvFile $_ }

function Get-WikipediaDescriptionsFromCsvFile
{
    [CmdletBinding()]
    param([Parameter(Mandatory=$True,ValueFromPipeline=$True)][System.IO.FileInfo]$file)

    $counter = 0;
    $timestamp = (get-date -f yyyy-MMM-dd-hhhh-mmmm);
    $source = $file.BaseName;
    $destination = "wikipedia-descriptions-$source-$timestamp.csv";

    try
    {
        Import-Csv $file |             
            Select-Object name, originalid | 
            ForEach-Object {
                Write-Host "Retrieving Wikipedia description for" $_.name;
                
                $dto = Get-WikipediaDescriptionForRegion $_.name;                
                $dto.OriginalId = $_.originalid;

                return $dto;

            } | 
            Select-Object OriginalId, RegionName, Url, Description, ShortDescription |
            ForEach-Object { 
                
                Export-Csv -InputObject $_ -Path $destination -Append -NoTypeInformation;
                $counter += 1;
            }

       Write-Host "Wrote $($counter) entries to $($destination)."
    }
    catch
    {
        Write-Host $_.Exception.ToString()
    }
}

# Example
# Get-WikipediaDescriptionForRegion -region "vancouver"

function Get-WikipediaDescriptionForRegion ($region)
{  
    try
    {
        $counter = 0;
        do 
        {
            $url = Convert-RegionToWikipediaUrl $region $counter            
            if($url.Length -eq 0)
            {
                break;
            }

            $webResponse = Get-WikipediaWebResponseForUrl $url;
            if($webResponse.StatusCode -eq 200)
            {
                break;
            }

            $counter += 1;
            
        } 
        while($url.Length -gt 0 -and $webResponse.StatusCode -ne 200)
        # keep trying to obtain a web response from Wikipedia
        # while we do have a url and we don't have a proper web response


        if($webResponse.StatusCode -eq 200) {
            $description = Get-DescriptionFromWebResponse $webResponse;
            $global:SuccessfulUrls += $url;
        }

        # create hash table
        if($description)
        {
            $results = @{
                OriginalId = ""
                RegionName = $region
                Url = $url
                Description = $description
                ShortDescription = $description.PadRight(380).Substring(0, 380)                
            }
        }
        else
        {
            $results = @{
                OriginalId = ""
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

# TODO Keep track of URLs that we've already tried

function Convert-RegionToWikipediaUrl ($region, $counter)
{
    $baseUrl = "http://en.wikipedia.org/wiki/";

    # wikipedia replaces spaces with underscores
    $region = $region -replace " ", "_"

    <#  Wikipedia uses several styles of URL for our target regions.
        We try several and accept whichever works first (sometimes these work because of redirects too.)
    
        ./wiki/OUR_TARGET_REGION
        ./wiki/OUR_TARGET_REGION,_British_Columbia
        ./wiki/OUR_TARGET_REGION,(district_municipality)
        ./wiki/OUR_TARGET_REGION,(city)
        ./wiki/Regional_District_of_OUR_TARGET_REGION
        ./wiki/OUR_TARGET_REGION_Regional_District
        .wiki/OUR_TARGET_REGION_Regional_Municipality

    #>

    $modifiers = [Array]::CreateInstance("string", 9);
    $modifiers[0] = ",_British_Columbia"
    $modifiers[1] = "Regional_District_of_"
    $modifiers[2] = "_Regional_District"
    $modifiers[3] = [string]::Empty
    $modifiers[4] = "_Regional_Municipality";
    $modifiers[5] = "_(district_municipality)";
    $modifiers[6] = "_(city)";

    $modifiers[7] = $modifiers[0] + $modifiers[5];
    $modifiers[8] = $modifiers[0] + $modifiers[6];

    if($counter -eq $modifiers.Length)
    {
        $url = "";
    }
    else
    {
        switch($counter)
        {
            0 {
                $url = $baseUrl + $region + $modifiers[$counter];
            }
            1 {
                $url = $baseUrl + $modifiers[$counter] + $region;
            }
            2 {
                $url = $baseUrl + $region + $modifiers[$counter];
            }
            3 {
                $url = $baseUrl + $region;
            }
            4 {
                $URL = $baseUrl + $region + $modifiers[$counter];
            }
            5 {
                $URL = $baseUrl + $region + $modifiers[$counter];
            }
            6 {
                $URL = $baseUrl + $region + $modifiers[$counter];
            }

            7 {
                $URL = $baseUrl + $region + $modifiers[$counter];
            }
            8 {
                $URL = $baseUrl + $region + $modifiers[$counter];
            }

        }
    }
    return $url;
}

function Get-WikipediaWebResponseForUrl ($url)
{
    Write-Host "`tTrying $url" -NoNewline;

    $webResponse = @{};
    try
    {       
        $webResponse = Invoke-WebRequest $url;

        # the disambiguation page means "keep going"
        $IsDisambiguation = ($webResponse.Images | where { $_.outerHtml -match "disambiguation" } | Measure-Object).Count -gt 0;
        if($IsDisambiguation)
        {
            $webResponse = @{ StatusCode = 404 }
        }

    }
    catch [System.Net.WebException]
    {
        $webResponse.StatusCode = 404;
    }
    catch
    {
        Write-Host $_.Exception.ToString()
    } 
    Write-Host " ("$webResponse.StatusCode") ";
    return $webResponse;
}

function Get-DescriptionFromWebResponse ($webResponse)
{
    $webResponse | 
        Select-Object -expand allelements | 
        Where-Object { $_.id -eq "mw-content-text" } | 
        Select-Object -expand innerHTML | 
        ForEach-Object {  
            
            $htmlWithoutTables = Remove-TablesFromHtml $_;            

            $desc = Get-DescriptionParagraphsFromHtml $htmlWithoutTables;

            Remove-UnwantedStuffFromDesc ($desc);
        }
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

function Get-DescriptionParagraphsFromHtml ($html)
{
    $desc = "";
    $openIndex = -1;
    $closeIndex = -1;

    $openTag = "<P>";
    $closeTag = "</P>";

    do {
    
        $openIndex = $html.IndexOf($openTag, $closeIndex + 1); 
        $closeIndex = $html.IndexOf($closeTag, $openIndex + 1);

        if($openIndex -ge 0 -and $closeIndex -ge 0)
        {
            $pElement = $html.Substring($openIndex, $closeIndex + $closeTag.Length - $openIndex);

            # avoid non-description paragraphs
            if($pElement -match 'id=coordinates')
            {
                continue;
            }

            $desc += $pElement;

        }
    }
    while ($desc.Length -lt 400 -and $openIndex -ge 0 -and $closeIndex -ge 0)

    return $desc;
}

function Remove-UnwantedStuffFromDesc ($desc)
{
    $regex = @{};
    $regex.htmlTags = '<[^>]+>';
    $regex.footnotes = '\[\d{0,3}\]';
    $regex.firstNations = '\/[^\/]+\/\s';
    $regex.parentheses = '\([^\)]+\),?\s';
    $regex.htmlEntities = '&[^\s]*;';

    $desc -replace $regex.htmlTags -replace $regex.footnotes -replace $regex.firstNations -replace $regex.parentheses -replace $regex.htmlEntities
}
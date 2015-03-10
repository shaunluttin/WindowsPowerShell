

function Test-RegionToWikipediaUrl ($region, $counter)
{
    $baseUrl = "http://en.wikipedia.org/wiki/";

    $modifiers = @(",_British_Columbia", "Regional_District_of_", "_Regional_District");

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
        }
    }
    return $url;
}

function Test-WikipediaWebResponseForUrl ($url)
{
    $webResponse = @{};
    try
    {       
        $webResponse = Invoke-WebRequest $url;
    }
    catch [System.Net.WebException]
    {
        $webResponse.StatusCode = 404;
    }
    catch
    {
        Write-Host $_.Exception.ToString()
    }
    return $webResponse;
}

function Test-DescriptionFromWebResponse ($webResponse)
{
    $webResponse | 
        Select-Object -expand allelements | 
        Where-Object { $_.id -eq "mw-content-text" } | 
        Select-Object -expand innerHTML | 
        ForEach-Object {  
            
            $htmlWithoutTables = Remove-TablesFromHtml $_;            

            $i = $htmlWithoutTables.IndexOf("<P>"); 
            $j = $htmlWithoutTables.IndexOf("</P>");       
                
            $desc = $htmlWithoutTables.Substring($i, $j - $i);
            Test-UnwantedStuffFromDesc ($desc);
        }
}

function Test-UnwantedStuffFromDesc ($desc)
{
    $regex = @{};
    $regex.htmlTags = '<[^>]+>';
    $regex.footnotes = '\[\d{0,3}\]';
    $regex.firstNations = '\/[^\/]+\/\s';
    $regex.parentheses = '\([^\)]+\),?\s';
    $regex.htmlEntities = '&[^\s]*;';

    $desc -replace $regex.htmlTags -replace $regex.footnotes -replace $regex.firstNations -replace $regex.parentheses -replace $regex.htmlEntities
}

function Test-Wikipedia
{
    $region = "Vancouver";
    Write-Host $region;

    $counter = 0;
    do {
        # we still have URLs to try and still lack a description
        # so keep trying to get a description

        $url = Test-RegionToWikipediaUrl $region $counter
        if($url.Length -eq 0)
        {
            break;
        }

        $webResponse = Test-WikipediaWebResponseForUrl $url;
        if($webResponse.StatusCode -eq 200)
        {
            break;
        }

        $counter += 1;
    }
    while($url.Length -gt 0 -and $response.StatusCode -eq 404)


    if($webResponse.StatusCode -eq 200) {
        $desc = Test-DescriptionFromWebResponse $webResponse;
        Write-Host $desc;
    } else {
        Write-Host "Failure";
    }
}



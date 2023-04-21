# Replace API_KEY with your Alpha Vantage API key
$apiKey = "9O5Z6EXAX29X4X8D"

# Loop until the user chooses to exit
do {
    # Prompt the user for the stock symbol
    $stockSymbol = Read-Host "Enter the stock symbol (or type 'exit' to quit):"
    if ($stockSymbol.ToLower() -eq "exit") {
        break
    }

    # Prompt the user for the number of dates to display
    $rows = Read-Host "How many dates to display?"

    # Build the URL for the API call
    $url = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY_ADJUSTED&symbol=$stockSymbol&outputsize=compact&apikey=$apiKey"

    # Make the API call and convert the JSON response to a PowerShell object
    $response = Invoke-RestMethod $url

    # Get the last 5 trading days
    $lastNDays = $response."Time Series (Daily)" | Sort-Object -Descending | Select-Object -First 5 | ForEach-Object {
        $date = $_.PSObject.Properties.Name
        $volume = $_.PSObject.Properties.Value.'6. volume'
        $close = $_.PSObject.Properties.Value.'4. close'
        $open = $_.PSObject.Properties.Value.'1. open'
        for ($i = 0; $i -lt $date.Count; $i++) {
            $change = [math]::Truncate(([float]$close[$i] - [float]$open[$i]) * 100) / 100 # Truncate to 2 decimal places
            $percentChange = [math]::Truncate(($change / [float]$open[$i]) * 10000) / 100  # Truncate to 2 decimal places
            [PSCustomObject]@{
                Date = $date[$i]
                Volume = $volume[$i]
                Open = "$" + "{0:f2}" -f [float]$open[$i]
                Close = "$" + "{0:f2}" -f [float]$close[$i]
                Change = $change
                '% Change' = "$percentChange%"
                Ticker = $stockSymbol[$i]
            }
        }
    }

    # Display the last 5 days as a table
    $lastNDays | Select-Object -First $rows | Format-Table -AutoSize

    # Prompt the user if they want to check another stock
    $continue = Read-Host "Do you want to check another stock? (Y/N)"
} while ($continue.ToLower() -eq "y")

Write-Host "Press spacebar twice to exit"

cmd /c 'pause'
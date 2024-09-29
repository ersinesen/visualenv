#
# Visualenv PowerShell demo: extract
#
# EE Sep '24

# Check if a filename argument is provided
if ($args.Count -eq 0) {
    Write-Error "No filename provided. Usage: .\extract.ps1 <filename>"
    exit
}

$filename = $args[0]

# Function to disable TLS validation for self-signed Octomim server
function Disable-TlsValidation {
    [System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }
}

# Call the function to disable TLS validation
Disable-TlsValidation

#
# Load parameters from .config file
#
$configFilePath = ".config"
$config = @{}

# Read each line from the .config file and store the key-value pairs in a hashtable
Get-Content -Path $configFilePath | ForEach-Object {
    if ($_ -match "^(.*)=(.*)$") {
        $config[$matches[1].Trim()] = $matches[2].Trim()
    }
}

# Extract necessary parameters from the hashtable
$baseUrl = $config["baseUrl"]
$baseDataUrl = $config["baseDataUrl"]
$username = $config["username"]
$password = $config["password"]
# Encode credentials for Basic Auth
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("${username}:${password}")))

#
# Get hidden data from stego image
#
Write-Output "Extracting hidden env variables using: ${filename}"
$start = [System.Diagnostics.Stopwatch]::StartNew()  # Start timer
Write-Output "Requesting URL: $baseUrl/stego/extract/text"

# Attempt to extract data from stego image
try {
    $body = @{ file = $filename } | ConvertTo-Json
    Write-Output "Request Body: $body"  # Debug output for the body

    $response = Invoke-RestMethod -Uri "$baseUrl/stego/extract/text" -Method Post `
        -Headers @{ 
            "Content-Type" = "application/json"; 
            "Authorization" = "Basic $base64AuthInfo" 
        } `
        -Body $body -Verbose

    Write-Output $response
} catch {
    Write-Error "An error occurred: $_"
}
$start.Stop()
$responseTime = $start.ElapsedMilliseconds
Write-Output $response.text
Write-Output "Response Time: $responseTime ms"

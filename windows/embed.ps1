#
# Visualenv PowerShell demo: embed env variables
#
# EE Sep '24

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

# Get shell environment variables as a string 
$ENV = Get-ChildItem Env: | ForEach-Object { "$($_.Key)=$($_.Value)" }
$ENVString = $ENV -join "`n"

#
# Create Stego Image
#
Write-Output "Creating stego image"
$requestJson = @{ text = $ENVString } | ConvertTo-Json
$start = [System.Diagnostics.Stopwatch]::StartNew()  # Start timer

# Encode credentials for Basic Auth
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("${username}:${password}")))

$response = Invoke-RestMethod -Uri "$baseUrl/stego/create/text" -Method Post `
    -Headers @{ 
        "Content-Type" = "application/json"; 
        "Authorization" = "Basic $base64AuthInfo" 
    } `
    -Body $requestJson

$filename = $response.file
$start.Stop()
$responseTime = $start.ElapsedMilliseconds
Write-Output "Response Time: $responseTime ms"

if ($response -match "error") {
    Write-Error "Error in embedding."
    exit
}

#
# Download stego image
#
Write-Output "Getting stego image ${filename}"
$response = Invoke-RestMethod -Uri "$baseDataUrl/data/stego" -Method Post `
    -Headers @{ 
        "Content-Type" = "application/json"; 
        "Authorization" = "Basic $base64AuthInfo" 
    } `
    -Body (@{ file = $filename } | ConvertTo-Json) `
    -OutFile $filename



# Load required modules
Install-Module -Name PSYaml
Import-Module PSYaml

# Read server list from JSON file
$jsonFilePath = "server_list.json"
$servers = Get-Content $jsonFilePath | ConvertFrom-Json

# Define output YAML file
$yamlOutputPath = "ilo_versions.yaml"

# Initialize output array
$iloVersions = @()

# Prompt for iLO credentials
$iloCredentials = Get-Credential -Message "Please enter your iLO credentials"

# Loop through each server
foreach ($server in $servers) {
    $iloHost = $server.iloHost
    $serverName = $server.name
    
    # Connect to iLO and get version
    try {
        $iloConnection = Connect-HPEiLO -IP $iloHost -Credential $iloCredentials -DisableCertificateAuthentication
        $iloVersion = (Get-HPEiLOFirmwareVersion -Connection $iloConnection).FirmwareVersion
    }
    catch {
        Write-Host "Error connecting to iLO on server $serverName: $_"
        continue
    }

    # Add version to output array
    $iloVersions += @{
        'ServerName' = $serverName
        'iLOVersion' = $iloVersion
    }
}

# Convert output array to YAML and save to file
$iloVersions | ConvertTo-Yaml | Set-Content $yamlOutputPath

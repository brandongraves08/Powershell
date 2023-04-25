$serversCsvFile = "servers.csv"
$outputJsonFile = "ilo_versions.json"

# Read the CSV file with the server information
$servers = Import-Csv -Path $serversCsvFile

# Import the HPiLOCmdlets module
Import-Module HPiLOCmdlets

# Prompt the user for iLO username and password
$iloUsername = Read-Host -Prompt "Enter iLO username"
$iloPassword = Read-Host -Prompt "Enter iLO password" -AsSecureString
$iloPasswordPlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($iloPassword))

# Function to get iLO version for a single server
function Get-iLOVersion {
  param($iloIPAddress, $iloUsername, $iloPassword)

  # Establish a connection to iLO
  $iloConnection = Connect-HPiLO -Server $iloIPAddress -Username $iloUsername -Password $iloPassword -DisableCertificateAuthentication

  # Get iLO version
  $iloVersion = $iloConnection.ServerInfo.iLOVersion

  # Return the iLO version
  return $iloVersion
}

# Initialize the array to store iLO version information
$iloVersions = @()

# Iterate through the servers, get their iLO versions, and store the information in the array
foreach ($server in $servers) {
  $iloVersion = Get-iLOVersion -iloIPAddress $server.address -iloUsername $iloUsername -iloPassword $iloPasswordPlainText
  $iloVersions += @{
    'address' = $server.address
    'iLOVersion' = $iloVersion
  }
}

# Write the iLO version information to the JSON file
$iloVersions | ConvertTo-Json | Set-Content -Path $outputJsonFile

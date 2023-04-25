$ipRangeStart = "192.168.1.1"
$ipRangeEnd = "192.168.1.254"
$outputJsonFile = "ilo_versions.json"
$logFile = "ilo_versions_log.txt"

# Start logging output to a log file
Start-Transcript -Path $logFile

# Import the HPEiLOCmdlets module
Import-Module HPEiLOCmdlets

# Prompt the user for iLO username and password
$iloUsername = Read-Host -Prompt "Enter iLO username"
$iloPassword = Read-Host -Prompt "Enter iLO password" -AsSecureString
$iloPasswordPlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($iloPassword))

# Function to get iLO version for a single server
function Get-iLOVersion {
  param($iloIPAddress, $iloUsername, $iloPassword)

  try {
    # Establish a connection to iLO
    $iloConnection = Connect-HPEiLO -Server $iloIPAddress -Username $iloUsername -Password $iloPassword -DisableCertificateAuthentication -ErrorAction Stop

    # Get iLO version
    $iloVersion = $iloConnection.ServerInfo.iLOVersion

    # Return the iLO version
    return $iloVersion
  } catch {
    Write-Host "Unable to connect to iLO at $iloIPAddress. Error details: $($_.Exception.Message)"
    return $null
  }
}

# Generate the list of IP addresses to check
$ipRange = [System.Net.IPAddress]::Parse($ipRangeStart)..[System.Net.IPAddress]::Parse($ipRangeEnd) | ForEach-Object { $_.GetAddressBytes() -join '.' }

# Initialize the array to store iLO version information
$iloVersions = @()

# Iterate through the IP range, get the iLO versions, and store the information in the array
foreach ($iloIPAddress in $ipRange) {
  $iloVersion = Get-iLOVersion -iloIPAddress $iloIPAddress -iloUsername $iloUsername -iloPassword $iloPasswordPlainText
  if ($iloVersion -ne $null) {
    $iloVersions += @{
      'address' = $iloIPAddress
      'iLOVersion' = $iloVersion
    }
  }
}

# Write the iLO version information to the JSON file
$iloVersions | ConvertTo-Json | Set-Content -Path $outputJsonFile

# Stop logging output to the log file
Stop-Transcript

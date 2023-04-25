$ipRangeStart = "192.168.1.1"
$ipRangeEnd = "192.168.1.254"
$outputCsvFile = "ilo_versions.csv"

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

# Function to convert IP address to a decimal number
function Convert-IPToDecimal {
  param($ipAddress)

  $octets = $ipAddress.Split('.')
  return [UInt32]($octets[0] -shl 24) + ($octets[1] -shl 16) + ($octets[2] -shl 8) + $octets[3]
}

# Function to convert a decimal number to an IP address
function Convert-DecimalToIP {
  param($decimal)

  return ('{0}.{1}.{2}.{3}' -f ($decimal -shr 24), ($decimal -shr 16 -band 0xFF), ($decimal -shr 8 -band 0xFF), ($decimal -band 0xFF))
}

# Calculate the decimal representation of the IP range
$ipStartDecimal = Convert-IPToDecimal -ipAddress $ipRangeStart
$ipEndDecimal = Convert-IPToDecimal -ipAddress $ipRangeEnd

# Initialize the array to store iLO version information
$iloVersions = @()

# Iterate through the IP range, get the iLO versions, and store the information in the array
for ($ipDecimal = $ipStartDecimal; $ipDecimal -le $ipEndDecimal; $ipDecimal++) {
  $iloIPAddress = Convert-DecimalToIP -decimal $ipDecimal
  $iloVersion = Get-iLOVersion -iloIPAddress $iloIPAddress -iloUsername $iloUsername -iloPassword $iloPasswordPlainText
  $iloVersions += [PSCustomObject]@{
    'address' = $iloIPAddress
    'iLOVersion' = $iloVersion
  }
}

# Write the iLO version information to the CSV file
$iloVersions | Export-Csv -Path $outputCsvFile -NoTypeInformation

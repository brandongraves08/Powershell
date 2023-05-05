$firmwareFilePathiLO4 = "path_to_iLO4_firmware_file"
$firmwareFilePathiLO5 = "path_to_iLO5_firmware_file"
$serversJsonFile = "servers.json"

# Read the JSON file with the server information
$servers = Get-Content -Path $serversJsonFile | ConvertFrom-Json

# Import the HPiLOCmdlets module
Import-Module HPiLOCmdlets

# Prompt the user for iLO username and password
$iloUsername = Read-Host -Prompt "Enter iLO username"
$iloPassword = Read-Host -Prompt "Enter iLO password" -AsSecureString
$iloPasswordPlainText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($iloPassword))

# Function to update iLO firmware based on detected iLO version
function Update-iLOFirmwareBasedOnVersion {
  param($iloIPAddress, $iloUsername, $iloPassword, $firmwareFilePathiLO4, $firmwareFilePathiLO5)

  # Establish a connection to iLO
  $iloConnection = Connect-HPiLO -Server $iloIPAddress -Username $iloUsername -Password $iloPassword -DisableCertificateAuthentication

  # Get iLO version
  $iloVersion = $iloConnection.ServerInfo.iLOVersion

  # Determine the iLO firmware file based on detected iLO version
  if ($iloVersion -match '^iLO 4') {
    $firmwareFilePath = $firmwareFilePathiLO4
  } elseif ($iloVersion -match '^iLO 5') {
    $firmwareFilePath = $firmwareFilePathiLO5
  } else {
    Write-Host "iLO version not supported: $($iloVersion)"
    return
  }

        # Update firmware
        Write-Host "Updating $iLOVersion firmware on server $IPAddress..."
        Update-HPEiLOFirmware -Connection $iLOConnection -Location $firmwareFilePath -Verbose

  # Display the firmware update result
  Write-Host "Update completed. Result: $($firmwareUpdateResult.Status)"
}

# Iterate through the servers and update their iLO firmware based on detected iLO version
foreach ($server in $servers) {
  Update-iLOFirmwareBasedOnVersion -iloIPAddress $server.address -iloUsername $iloUsername -iloPassword $iloPasswordPlainText -firmwareFilePathiLO4 $firmwareFilePathiLO4 -firmwareFilePathiLO5 $firmwareFilePathiLO5
}

# Read JSON file
$jsonData = Get-Content -Path $jsonFilePath | ConvertFrom-Json

# Prompt for username and password
$credential = Get-Credential -Message "Enter iLO username and password"

# Prompt for desired host group
$hostGroups = $jsonData.HostGroups | ForEach-Object { $_.GroupName }
$selectedGroup = Read-Host -Prompt "Enter the desired host group name (available groups: $($hostGroups -join ', '))"

# Find the selected host group
$group = $jsonData.HostGroups | Where-Object { $_.GroupName -eq $selectedGroup }

if ($group) {
    # Update iLO firmware for each server in the selected group
    foreach ($server in $group.Servers) {
        # Connect to iLO to get the iLO version
        $iLOConnection = Connect-HPEiLO -IP $server.IP -Credential $credential -DisableCertificateAuthentication
        $iLOVersion = (Get-HPEiLOServerInfo -Connection $iLOConnection).FirmwareVersion.ToUpper()
        Disconnect-HPEiLO -Connection $iLOConnection

        # Check if it's iLO4 or iLO5 and update the firmware
        if ($iLOVersion.Contains("ILO4")) {
            Update-ILOFirmware -IPAddress $server.IP -Credential $credential -iLOVersion "iLO4"
        } elseif ($iLOVersion.Contains("ILO5")) {
            Update-ILOFirmware -IPAddress $server.IP -Credential $credential -iLOVersion "iLO5"
        } else {
            Write-Host "Unsupported iLO version

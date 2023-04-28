#Author: Brandon Graves 

# Import HPE iLO cmdlets module
Import-Module HPEiLOCmdlets

# Define the location of your iLO firmware files and JSON file
$ilo4FirmwareFilePath = "C:\path\to\your\iLO4_firmware_file.bin"
$ilo5FirmwareFilePath = "C:\path\to\your\iLO5_firmware_file.bin"
$jsonFilePath = "C:\path\to\your\servers_list.json"

# Function to update iLO firmware on a server
function Update-ILOFirmware {
    param (
        $IPAddress,
        $Credential,
        $iLOVersion
    )

    try {
        # Connect to iLO
        $iLOConnection = Connect-HPEiLO -IP $IPAddress -Credential $Credential -DisableCertificateAuthentication

        # Select the appropriate firmware file based on the iLO version
        $firmwareFilePath = ""
        if ($iLOVersion -eq "iLO4") {
            $firmwareFilePath = $ilo4FirmwareFilePath
        } elseif ($iLOVersion -eq "iLO5") {
            $firmwareFilePath = $ilo5FirmwareFilePath
        } else {
            Write-Host "Unsupported iLO version for server $IPAddress" -ForegroundColor Yellow
            Disconnect-HPEiLO -Connection $iLOConnection
            return
        }

        # Update firmware
        Write-Host "Updating $iLOVersion firmware on server $IPAddress..."
        Update-HPEiLOFirmware -Connection $iLOConnection -Location $firmwareFilePath -Verbose

        # Disconnect iLO
        Disconnect-HPEiLO -Connection $iLOConnection
    } catch {
        Write-Host "Error updating iLO firmware on server $IPAddress $_" -ForegroundColor Red
    }
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

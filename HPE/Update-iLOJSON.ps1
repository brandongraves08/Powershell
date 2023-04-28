# Import HPE iLO cmdlets module
Import-Module HPEiLOCmdlets

# Define the location of your iLO firmware file and JSON file
$iloFirmwareFilePath = "C:\path\to\your\iLO_firmware_file.bin"
$jsonFilePath = "C:\path\to\your\servers_list.json"

# Function to update iLO firmware on a server
function Update-ILOFirmware {
    param (
        $IPAddress,
        $Credential,
        $FirmwarePath
    )

    try {
        # Connect to iLO
        $iLOConnection = Connect-HPEiLO -IP $IPAddress -Credential $Credential -DisableCertificateAuthentication

        # Update firmware
        Write-Host "Updating iLO firmware on server $IPAddress..."
        Update-HPEiLOFirmware -Connection $iLOConnection -Location $FirmwarePath -Verbose

        # Disconnect iLO
        Disconnect-HPEiLO -Connection $iLOConnection
    } catch {
        Write-Host "Error updating iLO firmware on server $IPAddress: $_" -ForegroundColor Red
    }
}

# Read server list from JSON file
$servers = Get-Content -Path $jsonFilePath | ConvertFrom-Json

# Prompt for username and password only once
$credential = Get-Credential -Message "Enter iLO username and password"

# Update iLO firmware for each server in the list
foreach ($server in $servers) {
    Update-ILOFirmware -IPAddress $server.IP -Credential $credential -FirmwarePath $iloFirmwareFilePath
}

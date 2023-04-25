# Import HPE iLO cmdlets module
Import-Module HPEiLOCmdlets

# Define the location of your iLO firmware file and CSV file
$iloFirmwareFilePath = "C:\path\to\your\iLO_firmware_file.bin"
$csvFilePath = "C:\path\to\your\servers_list.csv"

# Function to update iLO firmware on a server
function Update-ILOFirmware {
    param (
        $IPAddress,
        $Username,
        $Password,
        $FirmwarePath
    )

    try {
        # Connect to iLO
        $iLOConnection = Connect-HPEiLO -IP $IPAddress -Username $Username -Password $Password -DisableCertificateAuthentication

        # Update firmware
        Write-Host "Updating iLO firmware on server $IPAddress..."
        Update-HPEiLOFirmware -Connection $iLOConnection -Location $FirmwarePath -Verbose

        # Disconnect iLO
        Disconnect-HPEiLO -Connection $iLOConnection
    } catch {
        Write-Host "Error updating iLO firmware on server $IPAddress: $_" -ForegroundColor Red
    }
}

# Read server list from CSV file
$servers = Import-Csv -Path $csvFilePath

# Prompt for username and password
$credential = Get-Credential -Message "Enter iLO username and password"

# Update iLO firmware for each server in the list
foreach ($server in $servers) {
    Update-ILOFirmware -IPAddress $server.IP -Username $credential.UserName -Password $credential.GetNetworkCredential().Password -FirmwarePath $iloFirmwareFilePath
}

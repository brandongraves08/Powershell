# Import HPE iLO cmdlets
Import-Module HPEiLOCmdlets

# Path to the JSON file containing host information
$jsonFilePath = "path\to\your\jsonfile.json"

# Paths to the firmware files
$firmwarePathIlo4 = "path\to\your\ilo4_firmwarefile.bin"
$firmwarePathIlo5 = "path\to\your\ilo5_firmwarefile.bin"

# Read the JSON file and parse its content
$jsonContent = Get-Content -Path $jsonFilePath -Raw
$hostData = $jsonContent | ConvertFrom-Json

# Function to update iLO firmware
function Update-IloFirmware {
    param (
        [string]$ipAddress,
        [string]$username,
        [string]$password,
        [string]$firmwarePathIlo4,
        [string]$firmwarePathIlo5
    )

    try {
        # Connect to iLO
        $ilo = Connect-HPEiLO -IP $ipAddress -Username $username -Password $password

        # Get iLO version
        $iloVersion = (Get-HPEiLOServerInfo -Connection $ilo).FirmwareVersion
        
        # Determine the firmware file path based on iLO version
        if ($iloVersion -like "iLO 4*") {
            $firmwarePath = $firmwarePathIlo4
        } elseif ($iloVersion -like "iLO 5*") {
            $firmwarePath = $firmwarePathIlo5
        } else {
            Write-Warning "Unsupported iLO version for $ipAddress: $iloVersion"
            Disconnect-HPEiLO -Connection $ilo
            return
        }

        # Update iLO firmware
        Write-Host "Updating iLO firmware for $ipAddress..."
        $result = Update-HPEiLOFirmware -Connection $ilo -Location $firmwarePath -Confirm:$false

        # Check the result
        if ($result.Status -eq "success") {
            Write-Host "Successfully updated iLO firmware for $ipAddress"
        } else {
            Write-Warning "Failed to update iLO firmware for $ipAddress"
        }

        # Disconnect from iLO
        Disconnect-HPEiLO -Connection $ilo
    } catch {
        Write-Error "Error updating iLO firmware for $ipAddress: $_"
    }
}

# Iterate through hosts and update iLO firmware
foreach ($host in $hostData.hosts) {
    # Replace these with appropriate credentials for your environment
    $username = "your_username"
    $password = "your_password"
    
    Update-IloFirmware -ipAddress $host.ipAddress -username $username -password $password -firmwarePathIlo4 $firmwarePathIlo4 -firmwarePathIlo5 $firmwarePathIlo5
}

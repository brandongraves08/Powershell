Install-Module -Name HPEiLOCmdlets

Import-Module HPEiLOCmdlets

$iloIPAddress = "ilo_ip_address"
$iloUsername = "ilo_username"
$iloPassword = "ilo_password"
$firmwareFilePath = "path_to_firmware_file"

# Establish a connection to iLO
$iloConnection = Connect-HPEiLO -Server $iloIPAddress -Username $iloUsername -Password $iloPassword -DisableCertificateAuthentication

# Update the iLO firmware
Write-Host "Updating iLO firmware on $($iloIPAddress)..."
$firmwareUpdateResult = Update-HPEiLOFirmware -Connection $iloConnection -Location $firmwareFilePath -Confirm:$false

# Display the firmware update result
Write-Host "Update completed. Result: $($firmwareUpdateResult.Status)"
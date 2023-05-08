# Define variables
$iloIPsFile = "C:\path\to\ilo_ips.json"
$firmwareFilePath = "C:\path\to\firmware.bin"

# Import HPE iLO cmdlets
if (!(Get-Module -ListAvailable -Name HPEiLOCmdlets)) {
    Install-Module -Name HPEiLOCmdlets -Scope CurrentUser
}
Import-Module -Name HPEiLOCmdlets

# Read iLO IP addresses from JSON file
$iloServers = (Get-Content -Path $iloIPsFile -Raw) | ConvertFrom-Json

# Iterate through each iLO server and update firmware
foreach ($server in $iloServers.servers) {
    $iloIP = $server.ip
    $iloUsername = $server.username
    $iloPassword = $server.password

    # Connect to iLO
    $securePassword = ConvertTo-SecureString $iloPassword -AsPlainText -Force
    $iloCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $iloUsername, $securePassword
    $connection = Connect-HPEiLO -IP $iloIP -Credential $iloCreds

    # Update iLO firmware
    try {
        Write-Host "Updating iLO firmware on $($iloIP)..."
        $updateResult = Update-HPEiLOFirmware -Connection $connection -Location $firmwareFilePath -Confirm:$false
        Write-Host "Update successful. $($updateResult.Message)"
    } catch {
        Write-Host "Error updating iLO firmware: $($_.Exception.Message)"
    } finally {
        # Disconnect from iLO
        Disconnect-HPEiLO -Connection $connection
    }
}

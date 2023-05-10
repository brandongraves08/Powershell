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

# Prompt user for iLO username and password
$iloUsername = Read-Host -Prompt "Enter iLO username"
$iloPassword = Read-Host -Prompt "Enter iLO password" -AsSecureString

# Iterate through each iLO server and update firmware
foreach ($server in $iloServers.servers) {
    $iloIP = $server.ip

    # Use the provided username and password for each iLO connection
    $iloCreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $iloUsername, $iloPassword
    $connection = Connect-HPEiLO -IP $iloIP -Credential $iloCreds -DisableCertificateAuthentication -verbose

    if ($connection) {
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
    } else {
        Write-Host "Error connecting to iLO at IP $($iloIP). Please check the IP address and credentials."
    }
}
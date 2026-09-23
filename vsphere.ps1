$vCenters = (Read-Host "vCenter servers (comma-separated)") -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$servers = Import-Csv C:\temp\standard2016.csv

foreach ($vc in $vCenters) {
    Connect-VIServer -Server $vc -Credential (Get-Credential -Message "Credentials for $vc") | Out-Null
}

# VM names don't always match the AD name, so also key on the guest's hostname
$vms = @{}
foreach ($vm in Get-VM -Server $vCenters) {
    $vms[$vm.Name] = $vm
    if ($vm.Guest.HostName) { $vms[$vm.Guest.HostName.Split('.')[0]] = $vm }
}

$cores = foreach ($server in $servers) {
    $vm = $vms[$server.Name]
    [pscustomobject]@{
        Name  = $server.Name
        Cores = $vm.NumCpu
    }
}

Disconnect-VIServer -Server $vCenters -Confirm:$false

$cores | Format-Table -AutoSize

$csv = Read-Host "Save results to CSV (leave blank to skip)"
if ($csv) { $cores | Export-Csv $csv -NoTypeInformation }

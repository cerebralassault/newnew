$domains = (Read-Host "Domains to search (comma-separated)") -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }
$filter = 'OperatingSystem -like "Windows Server 2016 Standard*" -or OperatingSystem -like "Windows Server 2016 Datacenter*"'

$servers = foreach ($d in $domains) {
    $cred = Get-Credential -Message "Credentials for $d"
    try {
        Get-ADComputer -Server $d -Credential $cred -Filter $filter -Properties OperatingSystem -ErrorAction Stop |
            Select-Object @{n = 'Domain'; e = { $d } }, Name, OperatingSystem
    }
    catch {
        # keep going so one bad password doesn't kill the other domains
        Write-Warning "${d}: $_"
    }
}

$servers = $servers | Sort-Object Domain, Name
$servers | Format-Table -AutoSize

New-Item -ItemType Directory -Path C:\temp -Force | Out-Null
$servers | Export-Csv C:\temp\server2016.csv -NoTypeInformation
Write-Host "Saved to C:\temp\server2016.csv"

$domains = (Read-Host "Domains to search (comma-separated)") -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }

$servers = foreach ($d in $domains) {
    $cred = Get-Credential -Message "Credentials for $d"
    try {
        Get-ADComputer -Server $d -Credential $cred -Filter 'OperatingSystem -like "Windows Server 2016 Standard*"' -Properties OperatingSystem |
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
$servers | Export-Csv C:\temp\standard2016.csv -NoTypeInformation
Write-Host "Saved to C:\temp\standard2016.csv"

Import-Csv '\\pnimsrv3\jmjeremy\Websites to Check.csv' | ForEach-Object {
    $request = Invoke-WebRequest -URi $($_.URL) -UseDefaultCredentials | Select-Object -ExpandProperty StatusDescription
Write-Host $($_.Website) $request
}


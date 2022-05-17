#Checks website and reports if 200 status code was recieved

#CSV file has 2 columns one with website name -column called website and URL -column called URL

Import-Csv '\\pnimsrv3\jmjeremy\Websites to Check.csv' | ForEach-Object {
    $request = Invoke-WebRequest -URi $($_.URL) -UseDefaultCredentials | Select-Object -ExpandProperty StatusDescription
Write-Host $($_.Website) $request
}


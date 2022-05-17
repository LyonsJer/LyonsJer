# בודק נתיבים משרת שיתוף הקובצים מרשימה שנקבע בקובץ

$Date = Get-Date -Format "dd_MM_yy"

$Network_Drive =  Get-Content '\\pnimsrv3\jmjeremy\Network_Drives.txt' 


Foreach ($Drive in $Network_Drive){

if((Test-Path $Drive) -eq $true){
    New-Item  -Path $Drive -Name $Date -Value "$Drive" -ItemType "file" ; Write-Host "Access Compliant, File Written To $Drive." -fore green
}
else{
    Write-Host "Failed To Access $Drive." -fore red
}
}

Read-Host -Prompt "Press Enter to Delete Test Files Or CTRL+C To Exit Script"

Foreach ($Drive in $Network_Drive){
Remove-Item $Drive\$Date
}

#בודק תקינות כונן איש י
$user = $env:Username
$Path = "\\pnimsrv3\$user"

if((Test-Path $Path) -eq $true){
    New-Item  -Path $Path -Name $Date -Value "$Path" -ItemType "file" ; Write-Host "Access Compliant, File Written To $Drive." -fore green
}
else{
    Write-Host "Failed To Access $Path." -fore red
}

Read-Host -Prompt "Press Enter to Delete Test File"


Remove-Item $Path\$Date


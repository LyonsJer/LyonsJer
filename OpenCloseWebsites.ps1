# WEBSITES.TXT בודק אתרים שונים לפי שנקבע בקובץ

#Get-Content from path of file
$Websites = Get-Content '\\..\..\Websites.txt' 

ForEach($Website in $Websites){
   
$edge_procinfo = Start-Process msedge -ArgumentList "$Website" -PassThru
$edge_procid = $edge_procinfo.Id


}

Read-Host -Prompt "Press Enter to close Microsoft Edge"

TaskKill /IM msedge.exe /F


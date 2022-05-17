$obj = New-Object -ComObject Wscript.Shell

Read-Host -Prompt "To Check Saar File Sharing and Mercava Press Enter, Check that Smart card is inserted and PIN is set to 1212"

#בודק מערכת סער באקספלורר ומרכבה נוכחות באדג 
$ie_procinfo = Start-Process iexplore -ArgumentList 'https://moin.saar.gov.il/saar2500' -PassThru
$ie_procid = $ie_procinfo.Id
echo $ie_procid
Sleep 15

$obj.SendKeys("{TAB}{ENTER}")
Sleep 2
$obj.SendKeys("1212{ENTER}")

Sleep 5

$edge_procinfo = Start-Process msedge -ArgumentList "https://ofan.merkava.gov.il/Merkava" -PassThru
$edge_procid = $edge_procinfo.Id
echo $edge_procid

Sleep 15
$obj.SendKeys("{TAB}{TAB}{TAB}{ENTER}")
Sleep 2
$obj.SendKeys("1212{ENTER}")





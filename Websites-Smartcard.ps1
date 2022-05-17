#Imports object that allows for keystrokes in powershell
 # complete list of options at this website http://msdn.microsoft.com/en-us/library/office/aa202943%28v=office.10%29.aspx
 #This allows to enter preset pin code automatically
 #Keystrokes would have to be changed for each instance
 
 $obj = New-Object -ComObject Wscript.Shell

Read-Host -Prompt "To Check Websites Press Enter, Check that Smart card is inserted and PIN is set to ***"

 
$ie_procinfo = Start-Process iexplore -ArgumentList 'https://website.com' -PassThru
$ie_procid = $ie_procinfo.Id
echo $ie_procid
#sleep command is important to allow website to load before proceeding to next keystroke
Sleep 15

#Keystroke to navigate to pin code entry
$obj.SendKeys("{TAB}{ENTER}")
Sleep 2
#pincode is entered
$obj.SendKeys("****{ENTER}")






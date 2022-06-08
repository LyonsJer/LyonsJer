#Randomly Chooses Password
Add-Type -AssemblyName 'System.Web'
$minLength = 20 ## characters
$maxLength = 40 ## characters
$length = Get-Random -Minimum $minLength -Maximum $maxLength
$nonAlphaChars = 5
$password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)
$secPw = ConvertTo-SecureString -String $password -AsPlainText -Force

#Prompts Username to enter Username to Disable
$UsertoDisable = Read-Host "Please Enter Username to Disable"

#Disables User
Disable-ADAccount -Identity $UsertoDisable
#Resets Password
Set-ADAccountPassword -Identity $UsertoDisable -NewPassword $secPw -Reset

#Searches for all Outlook-Contact groups that User is a member of 
$OutlookGroups = Get-ADPrincipalGroupMembership -Identity $UsertoDisable `
    | Where-Object {$_.distinguishedName -CLike "*OU=Outlook-Contacts,OU=Jeremy,DC=Lyons,DC=Server"} `
    | Select-Object -ExpandProperty distinguishedName

#Remove User from each Outlook Contact Group
ForEach ($OutlookGroup in $OutlookGroups){
    Remove-ADPrincipalGroupMembership -Identity $UsertoDisable -MemberOf $OutlookGroup
}

#Moves User to Disabled
Get-ADUSer -Identity $UsertoDisable | Move-ADObject -TargetPath "OU=Disabled Users,OU=Jeremy,DC=Lyons,DC=Server"

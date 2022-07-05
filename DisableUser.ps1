#Randomly Chooses Password
Add-Type -AssemblyName 'System.Web'
$minLength = 20 ## characters
$maxLength = 40 ## characters
$length = Get-Random -Minimum $minLength -Maximum $maxLength
$nonAlphaChars = 5
$password = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)
$secPw = ConvertTo-SecureString -String $password -AsPlainText -Force

Import-Csv C:\UsersToDisable.csv | ForEach-Object{

#Creates Variable of User and Groups to be deleted
$User = Get-ADUser -Identity $_.UserstoDisable 

$Groups = Get-ADPrincipalGroupMembership -Identity $_.UserstoDisable `
    | Where-Object {$_.distinguishedName -CLike "*OU=Outlook-Contacts,OU=Jeremy,DC=Lyons,DC=Server"} `
    
#Combines Variables to one object for export
$list = Foreach ($Group in $Groups){
New-Object PSobject -Property @{
 User = $User
 Groups = $Group
}}
 
#Exports to CSV with Users name
$UsersName = Get-ADUser -Identity $_.UserstoDisable | Select-Object -ExpandProperty Name

$List | Export-Csv -NoTypeInformation C:\$UsersName.csv

#Disables User
Disable-ADAccount -Identity $_.UserstoDisable
#Resets Password
Set-ADAccountPassword -Identity $_.UserstoDisable -NewPassword $secPw -Reset

#Searches for all Outlook-Contact groups that User is a member of 
$OutlookGroups = $Groups | Select-Object -ExpandProperty distinguishedName 
    
#Remove User from each Outlook Contact Group
ForEach ($OutlookGroup in $OutlookGroups){
    Remove-ADPrincipalGroupMembership -Identity $_.UserstoDisable -MemberOf $OutlookGroup -Confirm:$false
}

#Moves User to Disabled
Get-ADUSer -Identity $_.UserstoDisable | Move-ADObject -TargetPath "OU=Disabled Users,OU=Jeremy,DC=Lyons,DC=Server"

}

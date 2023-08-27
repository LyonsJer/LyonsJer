#imports csv file of user info into variable
$users = import-csv 'C:\proj_newuser\users.csv'

#check if user already exists according to TZ
#enable user, fix password, update info cellphone job description and department, move user to correct OU according to place of work
#move user to OU



<#Fixes  ou for user, accepts 2 variables - username of existing user and place of work of user being created\changed.
if existing user is not in disabled ou takes OU, if in disabled  takes OU from place of work, unless in mate then asks for user input#>
Function Fix-OUforUser {
    param (
            [Parameter(Mandatory=$true)] [string]$currentuser,
            [Parameter(Mandatory=$true)] [string]$placeofwork,
            [Parameter(Mandatory=$true)] [string]$Firstname,
            [Parameter(Mandatory=$true)] [string]$lastname

)

$disabledOU = ""
$site1= ""




#pulls DistinguishedName from existing user
$OUfromUser = Get-adUser -identity $currentuser | Select-Object -expandproperty DistinguishedName

#removes common name from DistinguishedName 
$OUforuser= "OU="+($OUfromUser -split ",OU=",2)[1]

#checks if ou is not disabled
if ($OUforuser -ne $disabledOU){
        $finalOUforuser = $OUforuser
}

#if OU is disabled, check if place of work is not mate, fixes OU according to place of work
    Elseif ($placeofwork -ne "mate"){
        Switch ($placeofwork.ToLower()) {
            site1 {$finalOUforuser = $site1 }
            site2 {$finalOUforuser =  $site1 }
        
          
    }
}
#if place of work is mate, asks for userinput
        Elseif ($placeofwork -eq ""){
    #creates object for each option and the label for each object
            $ = New-Object System.Management.Automation.Host.ChoiceDescription '&OU
            $ = New-Object System.Management.Automation.Host.ChoiceDescription '&OU 
       
           

    #groups all options into array

                $options = [System.Management.Automation.Host.ChoiceDescription[]]($)
    
    #display them to user with prompt title and message
                $title = 'Choose the Organizational Unit for Active Directory'
                $message = "Since the user $Firstname $lastname you are creating works in מטה ראשי, please specify which OU to move him to:"
                $result = $host.ui.PromptForChoice($title, $message, $options, 0)
    
    #applies to each option a value of the correct OU
                         switch ($result) {
                         0 {$finalOUforuser = ""}
                         1 {$finalOUforuser = ""}
                         2 {$finalOUforuser = ""}
                        
                         }

 #write-host $finalOUforuser
}
return $finalOUforuser
#Write-Host $finalOUforuser + "it works"
}




#Function sets password, accepts 3 variables englsih first name, lastname and cellphone from which to make password script from disable user to change it into password
Function Create-Passwd  {

    param (
        [Parameter(Mandatory=$true)] [string]$englishfirstname,
        [Parameter(Mandatory=$true)] [string]$englishlastname,
        [Parameter(Mandatory=$true)] [string]$cellphone
            )

    #Variable with password string
            $passwordstring = $englishfirstname.Substring(0,1).ToUpper() + $englishlastname.Substring(0,1).ToLower() + $cellphone + "!" 
          
           $password = $passwordstring.Replace("-","")

           write-host $password

      return $password      
            

}



#fixes prefix of username according to place of work, accepts 3 vaiables place of work, english first name and last name, creates 5 options for username and checks which one is available

Function Create-username {
    Param(
         [string]$placeofwork,
         [string]$englishfirstname,
         [string]$englishlastname,
         [string]$Teudat_zehut
        )

#switch between prefix according to place of work
        Switch ($placeofwork.ToLower()) {
            site1 {$prefix =  ""}
            site2 {$prefix =  ""}
           
           

        if($placeofwork.ToLower() = ""){
        $finalusername =  "$Teudat_zehut"
        }
        else{

#creates array of 5 options for username

        $username_options = @("$prefix$($englishfirstname)" ,
                             "$prefix$($englishfirstname)$($englishlastname.Substring(0,1))",
                             "$prefix$($englishfirstname)$($englishlastname.Substring(0,2))",
                             "$prefix$($englishfirstname)$($englishlastname.Substring(0,3))",
                             "$prefix$($englishfirstname)1")
 


#write-host $username_options
#loops through array checking to find if username is unique -doesnt exist in AD

 ForEach ($username_option in $username_options) {
 
    if(-not [bool] (Get-ADUser  -Filter {SamAccountName -eq $username_option})){
    
         $finalusername = $username_option
 break
    
    }
    }
}
return $finalusername
#Write-Host $finalusername
}

<#function to create user, accepts 8 variables, 5 variables from csv  Hebrew Firstname, Hebrew last name, Department, outlook description and teudat zehut.
3 from previous functions: $finalusername from create-username, $secpass from create-password, $finalOuforuser from fix-OUforUser
In addition fixes password to must change on logo and enables user
#>
Function create-user {
            Param ( 
                [Parameter(Mandatory=$true)] [string] $HebrewFirstName,
                [Parameter(Mandatory=$true)] [string] $HebrewLastName,
                [Parameter(Mandatory=$false)] [string] $Department,
                [Parameter(Mandatory=$false)] [string] $Outlook_Description,
                [Parameter(Mandatory=$true)] [string] $Cellphone,
                [Parameter(Mandatory=$true)] [string] $teudet_zehut,
                [Parameter(Mandatory=$true)] [string] $finalusername,
                [Parameter(Mandatory=$true)] [string] $password,
                [Parameter(Mandatory=$true)] [string] $finalOUforuser
            )

                    New-ADUser -Name "$HebrewFirstName $HebrewLastName" `
                                -GivenName "$HebrewFirstName" `
                                -DisplayName "$HebrewFirstName $HebrewLastName" `
                                -Surname "$HebrewLastName" `
                               -SamAccountName "$finalusername" `
                               -UserPrincipalName $teudet_zehut"@Pnim.Lab" `
                               -Department "$Department" `
                               -Description "$Outlook_Description" `
                               -Title "$Outlook_Description" `
                               -MobilePhone "$Cellphone" `
                               -AccountPassword (ConvertTo-SecureString -String $password -AsPlainText -Force) `
                               -Path "$finalOUforuser" `
                               -ChangePasswordatLogon 1 `
                               -Enabled 1


}
<#Copy permissions from existing user to new/ user, accepts 2 variables $currentusername and $newusername

#>
Function Copy-Permissions {

        Param (
                [Parameter(Mandatory=$true)] [string] $currentusername,
               [Parameter(Mandatory=$true)] [string] $newusername
                )

            $sourceuser = $(Get-ADUser $currentusername)
            $destuser = $(get-aduser $newusername)

    Get-ADUser $sourceuser -Properties memberof | Select-Object -ExpandProperty memberof | Add-ADGroupMember -Members $destuser 

}

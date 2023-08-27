



Function Check-userexists {
    Param     (
        [Parameter(Mandatory=$true)] [string] $teudat_zehut
    )
    $userprincipalname = $teudat_zehut + "@Pnim.Lab"
    
     
         if([bool] (Get-ADUser  -Filter {UserPrincipalName -eq $userprincipalname})){
            $userexists = $true
            $existingusername = Get-ADUser -Filter "UserPrincipalName -eq '$userprincipalname'" | Select-Object -ExpandProperty SamAccountName 
            $DistinguishedName = Get-ADUser -Filter "UserPrincipalName -eq '$userprincipalname'" | Select-Object -ExpandProperty DistinguishedName
           write-host "user exists"
    }
         else{
            
            $userexists = $false
            write-host "USer doesnt exist"

    }
    return $userexists, $existingusername, $DistinguishedName
    write-host $userexists
}

Function Update-existinguser{
    Param (
        [Parameter(Mandatory=$false)] [string] $existingusername,
        [Parameter(Mandatory=$false)] [string] $HebrewFirstName,
        [Parameter(Mandatory=$false)] [string] $HebrewLastName,
        [Parameter(Mandatory=$false)] [string] $Outlook_Description,
        [Parameter(Mandatory=$false)] [string] $Department,
        [Parameter(Mandatory=$false)] [string] $cellphone, 
        [Parameter(Mandatory=$true)]  [string] $password,     
        [Parameter(Mandatory=$false)]  [string] $finalOUforuser
        
    )
     
       Set-ADUser -Identity $existingusername -DisplayName "$HebrewFirstName $HebrewLastName" `
                                        -Surname "$HebrewLastName" `
                                        -Department "$Department" `
                                        -Description "$Outlook_Description" `
                                        -Title "$Outlook_Description" `
                                        -MobilePhone "$Cellphone" `
                                        -Enabled 1 `
                                        -ChangePasswordatLogon 1 
                                         
            Rename-ADObject -Identity $DistinguishedName -NewName "$HebrewFirstName $HebrewLastName"                            

Set-ADAccountPassword -Identity $existingusername -Reset -NewPassword (ConvertTo-SecureString -String $password -AsPlainText -Force) 

Get-ADUser -Identity $existingusername | Move-ADObject -TargetPath $finalOUforuser

}

$users = import-csv 'C:\proj_newuser\users.csv'






ForEach ($user in $users){

    $userexists, $existingusername, $DistinguishedName = Check-userexists $user.Teudat_Zehut
    write-host $userexists

if($userexists){


    $userinput = Read-Host "The User $($user.English_First_Name) $($user.English_Last_Name), already exists, do you wish to update the user's info according to the data you inputted? Enter yes or no:"
    $userinput

      if ($userinput.ToLower() -eq "yes"){

      Write-Host "updating user $($user.English_First_Name) $($user.English_Last_Name)" -ForegroundColor green
      

           $password =  Create-Passwd $user.English_First_Name $user.English_Last_name $user.CellPhone

           $finalOUforuser =  Fix-OUforUser $user.user_with_same_permissions $user.Place_of_Work $user.English_First_Name $user.English_Last_name


            #pulls DistinguishedName from existing user
    $OUfromUser = Get-adUser -identity $existingusername | Select-Object -expandproperty DistinguishedName
           if($finalOUforuser -eq $OUfromUser){

            write-host "The user $($user.English_First_Name) $($user.English_Last_Name) already exists in the organizational unit you specified"

    Update-existinguser $existingusername $user.Hebrew_First_Name`
                        $user.Hebrew_Last_Name $user.Outlook_Description `
                        $user.Department $user.CellPhone `
                        $password  
                    }

            elseif($finalOUforuser -ne $OUfromUser){

             Update-existinguser $existingusername $user.Hebrew_First_Name`
                        $user.Hebrew_Last_Name $user.Outlook_Description `
                        $user.Department $user.CellPhone `
                        $password $finalOUforuser
            }

      Write-host "The user for $($user.English_First_Name) $($user.English_Last_Name) was updated successfully"
                        }

                        elseif($userinput.ToLower() -eq "no"){

                        Write-host "you have decided not to update user $($user.English_First_Name) $($user.English_Last_Name)" -ForegroundColor Red

                        continue
                        }
              
             
    }

else{


   $finalOUforuser =  Fix-OUforUser $user.user_with_same_permissions $user.Place_of_Work $user.English_First_Name $user.English_Last_name

   write-host "this is the OU $finalOUforuser"

    $password = Create-Passwd $user.English_First_Name $user.English_Last_name $user.CellPhone
  
  $finalusername = Create-username $user.Place_of_Work $user.English_First_Name $user.English_Last_name $user.Teudat_Zehut
  
  create-user $user.Hebrew_First_Name $user.Hebrew_Last_Name `
              $user.Department $user.Outlook_Description $user.CellPhone `
              $user.Teudat_Zehut $finalusername $password `
              $finalOUforuser

  Copy-Permissions $user.user_with_same_permissions $finalusername
     
     Write-host "The user for $($user.English_First_Name) $($user.English_Last_Name) was created successfully"           
    
    }
}


Import-Module ActiveDirectory

# Set the number of days since last logon
$DaysInactive = 365
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

#-------------------------------
# FIND INACTIVE COMPUTERS
#-------------------------------

# Get AD Computers that haven't logged on in xx days
$Computers = Get-ADComputer -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true -and operatingsystem -like "Windows 10*" -or operatingsystem -like "Windows 7*" } -Properties LastLogonDate | Select-Object Name, LastLogo
nDate, DistinguishedName

### Only use this if you are moving object from a particular OU and adjust Enabled property. 
#### Get-ADComputer -SearchBase "OU=Workstations,OU=Computers,OU=Server,DC=test,DC=com" -Filter { LastLogonDate -lt "06/29/2020" -and Enabled -eq $false } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName 

#-------------------------------
# REPORTING
#-------------------------------
# Export results to CSV
$a = Get-Date -Format "dd-MMM-yyyy HH-mm"
$filename = "C:\Windows\Temp\AD Cleanup\InactiveComputer " + "$a" + ".csv"

$Computers | Export-Csv -Path $filename -NoClobber

#-------------------------------
# INACTIVE COMPUTER MANAGEMENT
#-------------------------------

# Disable Inactive Computers
ForEach ($Item in $Computers){
  $DistName = $Item.DistinguishedName
  Set-ADComputer -Identity $DistName -Enabled $false 
  Get-ADComputer -Filter { DistinguishedName -eq $DistName } | Select-Object Name, Enabled
}

# Move Computer Object to Disabled Computer OU
ForEach ($Item in $Computers){
  Get-ADComputer -Identity $Item.Name | Set-ADObject -ProtectedFromAccidentalDeletion $false #### ONLY SET this if you to disable ProtectedFromAccidentalDeletion property as it wont be able to be moved to the correct OU with this option checked. Also, didn't test the DistName variable with this script
  Get-ADComputer -Identity $Item.DistinguishedName | Move-ADObject -TargetPath "OU=Terminated Computers,DC=test,DC=com"   ### Need verify which if this correct disable OU we will use. Adjust as neseccary 
  Write-Output "$($Item.Name) - Move to a disabled OU"
}

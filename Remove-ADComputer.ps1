Import-Module ActiveDirectory

# Set the number of days since last logon
$DaysInactive = 365
$InactiveDate = (Get-Date).Adddays(-($DaysInactive))

#-------------------------------
# FIND INACTIVE COMPUTERS
#-------------------------------
# Below are three options to find inactive computers. Select the one that is most appropriate for your requirements:

# Get AD Computers that haven't logged on in xx days
$Computers = Get-ADComputer -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName

# Get AD Computers that have never logged on
$Computers = Get-ADComputer -Filter { LastLogonDate -notlike "*" -and Enabled -eq $true } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName

# Automated way (includes never logged on computers)
$Computers = Search-ADAccount -AccountInactive -DateTime $InactiveDate -ComputersOnly | Select-Object Name, LastLogonDate, Enabled, DistinguishedName

$Computers = Get-ADComputer -Filter { LastLogonDate -lt $InactiveDate -and Enabled -eq $true -and operatingsystem -like "Windows 10*" -or operatingsystem -like "Windows 7*" } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName

#-------------------------------
# REPORTING
#-------------------------------
# Export results to CSV
$Computers | Export-Csv C:\Temp\InactiveComputers.csv -NoTypeInformation

#-------------------------------
# INACTIVE COMPUTER MANAGEMENT
#-------------------------------
# Below are two options to manage the inactive computers that have been found. Either disable them, or delete them. Select the option that is most appropriate for your requirements:

# Disable Inactive Computers
ForEach ($Item in $Computers){
  $DistName = $Item.DistinguishedName
  Set-ADComputer -Identity $DistName -Enabled $false
  Get-ADComputer -Filter { DistinguishedName -eq $DistName } | Select-Object Name, Enabled
}

# Move Computer Object to Disabled Computer OU
ForEach ($Item in $Computers){
  Get-ADComputer -Identity $Item.DistinguishedName -Confirm:$false | Move-ADObject -TargetPath "OU=Disabled Computers,DC=test,DC=com"   ### Need verify which if this correct disable we will use. 
  Write-Output "$($Item.Name) - Move to a disabled OU"
}


Search-ADAccount -AccountInactive -DateTime "5/26/2020" -ComputersOnly | FT Name,ObjectClass,DistinguishedName -A | measure



Get-ADComputer -Filter { LastLogonDate -lt "06/3/2020" -and Enabled -eq $true -and operatingsystem -like "Windows 10*" -or operatingsystem -like "Windows 7*" } -Properties LastLogonDate | Select-Object Name, LastLogo
nDate, DistinguishedName



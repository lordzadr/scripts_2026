Import-Module ActiveDirectory


# Get AD Computers that haven't logged on in xx days
$Computers = Get-ADComputer -Filter { Enabled -eq $true -and operatingsystem -like "Windows 10*" -or operatingsystem -like "Windows 7*" -and DistinguishedName -like "*OU=Terminated Computers*" } -Properties LastLogonDate | Select-Object Name, LastLogonDate, DistinguishedName

#-------------------------------
# REPORTING
#-------------------------------
# Export results to CSV
$Computers | Export-Csv C:\Temp\ReactivateComputers.csv -NoTypeInformation

#-------------------------------
# ACTIVE COMPUTER MANAGEMENT
#-------------------------------

# Disable Inactive Computers
ForEach ($Item in $Computers){
  $DistName = $Item.DistinguishedName
  Set-ADComputer -Identity $DistName -Enabled $true
  Get-ADComputer -Filter { DistinguishedName -eq $DistName } | Select-Object Name, Enabled
}

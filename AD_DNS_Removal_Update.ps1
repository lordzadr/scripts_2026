Import-Module activedirectory

$serverlist = Get-Content -Path C:\Desktop\test\pslist.txt
$filename = "C:\Desktop\AD_DNS_Removal.ps1-$(get-date -UFormat "%Y%m%d-%H%M%S").log"
Start-Transcript -Path $filename -IncludeInvocationHeader
foreach ($server in $serverlist) {
echo $server
if (@(nslookup $server).Count) {
  Write-Host "#########################"  
  Write-Host "DNS Resource Record exists"
  Write-Host "#########################"
  dnscmd dc01 /recorddelete test.com $server A /f
  dnscmd dc01 /recorddelete test.com $server PTR /f
 }
else {
        Write-Host "#########################"  
        Write-Host "DNS Resource Record NOT FOUND"
        Write-Host "#########################"
		
    }
foreach ($i in 0..20) {
  nslookup $server-$i
  Write-Host "#########################"  
  Write-Host " Secondary DNS Resource Record exists"
  Write-Host "#########################"
  dnscmd dc01 /recorddelete test.com $server-$i A /f
  dnscmd dc01 /recorddelete test.com $server-$i PTR /f
  }
} 
Stop-Transcript
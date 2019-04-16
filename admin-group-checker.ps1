$working = "C:\sec-audit"
$domain = Get-ADDomain -Current LocalComputer | select -ExpandProperty name
Write-Host "We're now getting list of users that are in admin or domain admin groups for domain. Make sure there are no weird human accounts in here. Less privledge the better" -ForegroundColor Red -BackgroundColor White
Get-ADGroupMember "Domain Admins" | Select name >> $working\admin-report-$domain.txt
"The above users are in the domain admin group" | out-file -append $working\admin-report-$domain.txt
Get-ADGroupMember "Administrators" | Select name >> $working\admin-report-$domain.txt
"The above users are in the administrator group" | out-file -append $working\admin-report-$domain.txt
Write-Host "Admin group report completed. Report can be found at $working\admin-report-$domain.txt" -ForegroundColor Red -BackgroundColor White

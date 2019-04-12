Write-Host "For baseline security we want to disable any end user accounts that haven't logged on in 90 days. 
This script will export a list of accounts that match that description. 
DO NOT disable accounts that are obvious builtin/service accounts for windows. When in doubt please check with customer." -ForegroundColor Red -BackgroundColor White


Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');

$working = "C:\sec-audit"
Search-ADAccount -UsersOnly -AccountInactive -TimeSpan 90 | Get-ADUser -Properties Name, sAMAccountName, givenName, sn, userAccountControl, LastLogonDate | Where {($_.userAccountControl -band 2) -eq $False} | Select Name, sAMAccountName, givenName, sn, LastLogonDate > $working\inactive-accounts.txt
Write-Host "



Report completed. You can find the results in $working\inactive-accounts.txt" -ForegroundColor Red -BackgroundColor White
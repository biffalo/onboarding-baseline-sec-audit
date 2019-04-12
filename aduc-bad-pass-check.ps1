Install-Module DSInternals -Force
#^ we probably don't need to do this since we installed the module in the 'start here' script but I'm doing it just in case#
#the variables below get all the info needed to run the last command automatically so you don't have to fill stuff out and be saddened#
#this should be obvious but this script will not run on its until the _start here script runs otherwise files will be missing#
$domain = Get-ADDomain -Current LocalComputer  | select -ExpandProperty DistinguishedName
$server = get-content env:computername
$dn = Get-ADDomain -Current LocalComputer | select -ExpandProperty name
$working = "C:\sec-audit"
$badhash = "$working\pwned-passwords-ntlm-ordered-by-count-v4.txt"
Write-Host "this part will take some time. We have 500+ million hashes to cross reference. Go grab coffee " -ForegroundColor Red -BackgroundColor White
Get-ADReplAccount -All -Server $server -NamingContext "$domain" | Test-PasswordQuality -WeakPasswordHashesFile $badhash -IncludeDisabledAccounts > $working\Aduc-Compromised-Accounts.txt
Write-Host "results have been output to $working\Aduc-Compromised-Accounts.txt - this portion of the audit is complete. GOOD JORB " -ForegroundColor Red -BackgroundColor White
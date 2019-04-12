Set-ExecutionPolicy bypass -force
Write-Host "attempting to install chocolatey and latest version of powershell if it is not already in place" -ForegroundColor Red -BackgroundColor White
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Choco install powershell -y
Write-Host "chocolatey has installed latest version of powershell if you receive errors below you may need to reboot and run again" -ForegroundColor Red -BackgroundColor White
Write-Host "installing 7zip so we can grab ntlm straight from hibp" -ForegroundColor Red -BackgroundColor White
Write-Host "we'll also install 7zip posh module so we can 7z from posh" -ForegroundColor Red -BackgroundColor White
Choco install 7zip -y
Install-Module -Name 7Zip4Powershell -Force
Write-Host "installing dsinternals - this is used for hash matching for bad passwords" -ForegroundColor Red -BackgroundColor White
Install-Module DSInternals -Force
Write-Host "creating folder C:\sec-audit to use as our working directory" -ForegroundColor Red -BackgroundColor White
New-Item -Path "c:\" -Name "sec-audit" -ItemType "directory"
$working = "C:\sec-audit"
#downloading the tools you need for security audit. This will take a while. Its about 8gb of stuff#
Write-Host "If you are not running powershell 5 and get a bunch of angry errors below you need to install latest posh version, reboot and start script again" -ForegroundColor Red -BackgroundColor White
Write-Host "downloading the tools we need for security audit. This will take a while. Its about 8gb of stuff" -ForegroundColor Red -BackgroundColor White
(New-Object System.Net.WebClient).DownloadFile('https://downloads.pwnedpasswords.com/passwords/pwned-passwords-ntlm-ordered-by-count-v4.7z',"$working\pwned-passwords-ntlm-ordered-by-count-v4.7z")
Write-Host "Downloaded zipped hash archive. Now unzipping. This will take some time." -ForegroundColor Red -BackgroundColor White
Expand-7Zip -archivefilename $working\pwned-passwords-ntlm-ordered-by-count-v4.7z -targetpath $working
Write-Host "done with big file download/extract, next ones are small" -ForegroundColor Red -BackgroundColor White
Invoke-WebRequest -Uri "https://repo.it-va.com/office-365-have-i-been-pwned-check.ps1" -OutFile "$working\office-365-have-i-been-pwned-check.ps1"
Invoke-WebRequest -Uri "https://repo.it-va.com/aduc-bad-pass-check.ps1" -OutFile "$working\aduc-bad-pass-check.ps1"
Invoke-WebRequest -Uri "https://repo.it-va.com/inactive-user-check.ps1" -OutFile "$working\inactive-user-check.ps1"
Invoke-WebRequest -Uri "https://repo.it-va.com/admin-group-checker.ps1" -OutFile "$working\admin-group-checker.ps1"
#now we need to disable IE enchanced security configuration or when we connect to msolservice is next script will get errors and make you sad#
Write-Host "Disabling IE Enhanced Sec Configuration so you can auth to office365" -ForegroundColor Red -BackgroundColor White
$AdminKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}"
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
Set-ItemProperty -Path $AdminKey -Name "IsInstalled" -Value 0
Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 0
Stop-Process -Name Explorer
Write-Host "IE Enhanced Security Configuration (ESC) has been disabled." -ForegroundColor Red -BackgroundColor White
#below line starts the office365 security audit script#
Write-Host "starting office365 pwned check. be sure to have o365 admin creds handy for this" -ForegroundColor Red -BackgroundColor White
C:\sec-audit\office-365-have-i-been-pwned-check.ps1
Write-Host "next we are going to launch script for aduc hash matching and generate a txt in $working" -ForegroundColor Red -BackgroundColor White
C:\sec-audit\aduc-bad-pass-check.ps1
Write-Host "now we are going to generate a report of inactive AD users (accounts that haven't been logged on to in 90 days or more). Results can be found in $working/inactive-accounts.txt" -ForegroundColor Red -BackgroundColor White
C:\sec-audit\inactive-user-check.ps1
Write-Host "Ok were almost home free. Now we run admin-group-checker.ps1. Results can be found in $working/admin-report-domain.txt" -ForegroundColor Red -BackgroundColor White
C:\sec-audit\admin-group-checker.ps1
Write-Host "OK YOU ARE HOME FREE - THIS CONCLUDES THE ONBOARDING SECURITY AUDIT." -ForegroundColor Red -BackgroundColor White

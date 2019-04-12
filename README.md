# onboarding-baseline-sec-audit
Collection of scripts for use in windows domain environment to minimize risk by checking admin groups/ haveibeenpwned/open ports/inactive accounts

-Login to domain controller as domain admin 

-Download the following [ps1 file](https://github.com/biffalo/onboarding-baseline-sec-audit/raw/master/_starthere_security_audit_onboarding.ps1 )

-Open powershell as admin/ nav to folder / run "Set-ExecutionPolicy bypass -force" / then run **"_starthere_security_audit_onboarding.ps1"**. This script will display progress and explanations in terminal as needed so you have an idea of what stage you're in. This script performs a good number of functions and does take some time to run. The script does the following things (this is for transparency, but you should review yourself so you **don't go running code from the interwebz you haven't vetted**).

-Installs chocolatey.

-Installs latest version of powershell via chocolatey (this may require a reboot if you run into errors later in the script).

-Installs 7zip via chocolately so we can extract a large 7z file later.

-Installs 7zip powershell module to aid in the above . You may be prompted to allow "NUget" or something. Please answer in the affirmative.

-Installs DSInternals powershell module for use later in the script.

-Creates the folder **C:\sec-audit**. This is where all of the scripts/reports and files will end up when we are done.

-Creates/Sets variable called **$working** which is C:\sec-audit so script knows where to look for things

-Downloads the following file https://downloads.pwnedpasswords.com/passwords/pwned-passwords-ntlm-ordered-by-count-v4.7z into $working . This is 500million known compromised passwords from haveibeenpwned converted to NTLM hashes that we'll compare against  AD to see if they are using known compromised passwords. This is about 9gb and a progress bar will not show. It will take some time.

-Uses 7zip to extract the above file to a txt file in $working. This will have a progress bar. Takes a while

-Downloads script **office-365-have-i-been-pwned-check.ps1** into $working.

-Downloads script **aduc-bad-pass-check.ps1** into $working.

-Downloads script **inactive-user-check.ps1** into $working.

-Downloads script **admin-group-checker.ps1** into $working.

-Disables IE Enhanced Security Configuration as it will interfere with our office365 script.

-Launches **office-365-have-i-been-pwned script**. You'll be prompted for the office365 admin creds for the client. Please enter them. The script will look at all email accounts in the customer tenancy and check them against haveibeenpwned. It will then generate a file called **BreachedAccounts.csv** and dump it in $working. It will look something like the example below. You do not need to do anything with it yet. I make my csv pretty with excel so yours might look different.

![office365example](https://github.com/biffalo/onboarding-baseline-sec-audit/raw/master/screenshots/office365-breaches.jpg)

=========================================================================

-Next the script will launch the **aduc-bad-pass-check.ps1** script from $working. This is where we xreference compromised passwords from haveibeenpwned against customer domain accounts without any data leaving their server. This will take quite some time, but does have a progress bar. This would be a good time to do some other work while you wait. Upon completion a file called **Aduc-Compromised-Accounts.txt** will be dumped in $working and will look like the example below. This will give you accounts with hashes that are in hibp, accounts with no pw, accounts with passwords that are dictionary words etc. 

![aducpwnexample](https://github.com/biffalo/onboarding-baseline-sec-audit/raw/master/screenshots/aduc-pw-pwnage.jpg)

==========================================================================

-Next the script will launch **inactive-user-check.ps1** from $working. This will search for any user that hasn't logged on in 90 days or more. It will generate at file in $working called **inactive-accounts.txt**. You should go through this list and disable any human accounts that haven't logged on in 90 days or more. Please note the "lastlogondate" field to make sure the account actually hasn't logged in for 90+ days so you can avoid disabling someone in error. DO NOT disable accounts that are obvious builtin/service accounts for windows/vendors. When in doubt, please check with customer. Example of inactive-accounts.txt below.

![inactiveexample](https://github.com/biffalo/onboarding-baseline-sec-audit/raw/master/screenshots/inactive-users.jpg)

==========================================================================

-Lastley the script will launch **admin-group-checker.ps1** from $working. This will show you any account contained in any admin group on the server (local or domain). Best practice is to not have any end users be any kind of admin on the domain because if they get/bug ransomware they will have access to everything and that can be VERY bad. Please remove end users from the admin groups. You'll want to consult with the POC for the site to explain that you're doing this and why before pulling the trigger. The script will dump **admin-group-report.txt** to $working. Example below.

![adminuserexample](https://github.com/biffalo/onboarding-baseline-sec-audit/raw/master/screenshots/admin-group.jpg)

===========================================================================

Now you'll have a solid amount of data in **$working** that will allow you to have a (hopefully) productive converstation with your client or mgr about improving security posture for your/their org.



============================================================================
**CREDITS**

*[Troy Hunt/HaveIBeenPwned](https://haveibeenpwned.com/) - This mini project would not be possible if it was not for his service. Seriously donate some dollars to this gentleman.*

*[Michael Grafnetter/DSinternals](https://www.dsinternals.com/en/about/) - DSinternals does lots of the heavy lifting as far as comparing the hibp hashes with ad hashes. Wouldn't be possible without his great work.*

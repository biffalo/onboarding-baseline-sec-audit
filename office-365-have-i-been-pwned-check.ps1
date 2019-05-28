Install-Module -Name AzureAD -force
Install-Module MSOnline -force

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Connect-MsolService

$UserAgent = “Infinity Technologies Security Audit”
$users = Get-MsolUser -all
  
foreach ($user in $users) {
        $email = $user.UserPrincipalName
        $uri = "https://haveibeenpwned.com/api/v2/breachedaccount/$email"
        $breachResult = $null
        try {
            [array]$breachResult = Invoke-RestMethod -Uri $uri -UserAgent $UserAgent -ErrorAction SilentlyContinue
        }
        catch {
            if($error[0].Exception.response.StatusCode -match "NotFound"){
                Write-Host "No Breach detected for $email" -ForegroundColor Green
            }else{
                Write-Host "$breachresult"
            }
        }
        
        if ($breachResult) {
            foreach ($breach in $breachResult) {
                $breachObject = [ordered]@{
                    Email              = $email
                    LastPasswordChange = $user.LastPasswordChangeTimestamp
                    BreachName         = $breach.Name
                    BreachTitle        = $breach.Title
                    BreachDate         = $breach.BreachDate
                    BreachDataClasses  = ($breach.DataClasses -join ", ")

                }
                $breachObject = New-Object PSobject -Property $breachObject
                $breachObject | Export-csv C:\sec-audit\BreachedAccounts.csv -NoTypeInformation -Append
                Write-Host "Breach detected for $user - $($breach.name)" -ForegroundColor Yellow
                Write-Host $breach.description -ForegroundColor DarkYellow
            }
        }
        Start-sleep -Milliseconds 2000
    }

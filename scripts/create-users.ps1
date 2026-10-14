<#
.SYNOPSIS
  Bulk-creates Active Directory users from names.txt into an OU.
.NOTES
  Run on the domain controller in PowerShell ISE as administrator.
  Lab use only. Change the password variable and never reuse it anywhere real.
#>

# ----- Edit these variables for your own use case ----- #
$PASSWORD_FOR_USERS   = "Password1"
$USER_FIRST_LAST_LIST = Get-Content .\names.txt
$OU_NAME              = "_USERS"
# ------------------------------------------------------ #

$password = ConvertTo-SecureString $PASSWORD_FOR_USERS -AsPlainText -Force
New-ADOrganizationalUnit -Name $OU_NAME -ProtectedFromAccidentalDeletion $false

foreach ($n in $USER_FIRST_LAST_LIST) {
    if ([string]::IsNullOrWhiteSpace($n)) { continue }

    $parts    = $n.Trim().Split(" ")
    $first    = $parts[0].ToLower()
    $last     = $parts[-1].ToLower()
    $username = "$($first.Substring(0,1))$($last)"

    Write-Host "Creating user: $username" -BackgroundColor Black -ForegroundColor Cyan

    New-AdUser -AccountPassword $password `
               -GivenName $first `
               -Surname $last `
               -DisplayName $username `
               -Name $username `
               -EmployeeID $username `
               -PasswordNeverExpires $true `
               -Path "ou=$OU_NAME,$(([ADSI]"").distinguishedName)" `
               -Enabled $true
}

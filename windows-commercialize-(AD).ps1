# Check if the script is run as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator."
    exit 1
}

# Import the Active Directory module
Import-Module ActiveDirectory

# Step 1: Add the user 'user2' in Active Directory with a home directory
Write-Host "Adding user 'user2' in Active Directory with home directory \\\\DOMAIN\\Users\\user2..."
New-ADUser -Name "user2" -SamAccountName "user2" -UserPrincipalName "user2@domain.com" -Path "OU=Users,DC=domain,DC=com" -AccountPassword (ConvertTo-SecureString "user21" -AsPlainText -Force) -Enabled $true -PasswordNeverExpires $true -HomeDirectory "\\\\DOMAIN\\Users\\user2" -HomeDrive "H:"
Write-Host "User 'user2' added with password 'user21'."

# Step 2: Add 'user2' to the Domain Admins group (equivalent to sudoers in a domain environment)
Write-Host "Adding 'user2' to the Domain Admins group..."
Add-ADGroupMember -Identity "Domain Admins" -Members "user2"
Write-Host "User 'user2' granted administrative privileges."

# Step 2.5: Move files from 'trainee' to 'user2'
$source = "\\DOMAIN\\Users\\trainee\*"
$destination = "\\DOMAIN\\Users\\user2\\Desktop"
Write-Host "Moving files from 'trainee' to 'user2' Desktop..."
Copy-Item -Path $source -Destination $destination -Recurse -Force
Write-Host "Changing ownership of files to 'user2'..."
(Get-Item "$destination").SetAccessControl((New-Object System.Security.AccessControl.DirectorySecurity).SetOwner((New-Object System.Security.Principal.NTAccount("DOMAIN\\user2"))))
Write-Host "Ownership and permissions updated."

# Remove the user 'trainee' if they exist in Active Directory
if (Get-ADUser -Filter { SamAccountName -eq "trainee" }) {
    Write-Host "Checking if user 'trainee' is signed in..."
    $traineeSessions = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty UserName) -match "^trainee"
    if ($traineeSessions) {
        Write-Host "Signing out user 'trainee'..."
        logoff /ID (query session | Where-Object { $_ -match "trainee" } | ForEach-Object { ($_ -split '\s+')[2] })
    }

    Write-Host "Removing user 'trainee' from Active Directory..."
    Remove-ADUser -Identity "trainee" -Confirm:$false
    Remove-Item -Path "\\DOMAIN\\Users\\trainee" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "User 'trainee' removed from Active Directory."
} else {
    Write-Host "User 'trainee' does not exist in Active Directory."
}

# Inform the user of completion
Write-Host "Script completed successfully."

# Optionally restart the system (uncomment the line below if required)
# Restart-Computer -Force

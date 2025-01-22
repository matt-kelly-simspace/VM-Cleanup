# Check if the script is run as administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "This script must be run as an administrator."
    exit 1
}

# Step 1: Add the user 'simspace' with a home directory
Write-Host "Adding user 'simspace' with home directory C:\Users\simspace..."
New-LocalUser -Name "simspace" -Description "Standard User" -Password (ConvertTo-SecureString "simspace1" -AsPlainText -Force) -PasswordNeverExpires -UserMayNotChangePassword
Write-Host "User 'simspace' added with password 'simspace1'."

# Step 2: Add 'simspace' to the Administrators group
Write-Host "Adding 'simspace' to the Administrators group..."
Add-LocalGroupMember -Group "Administrators" -Member "simspace"
Write-Host "User 'simspace' granted administrative privileges."

# Step 3: Move files from 'trainee' to 'simspace'
$source = "C:\Users\trainee\*"
$destination = "C:\Users\simspace\Desktop"
Write-Host "Moving files from 'trainee' to 'simspace' Desktop..."
Move-Item -Path $source -Destination $destination -Force
Write-Host "Changing ownership of files to 'simspace'..."
Takeown /F "$destination" /R /D Y
icacls "$destination" /grant simspace:(OI)(CI)F /T
Write-Host "Ownership and permissions updated."

# Step 4: Sign out of the 'trainee' account
Write-Host "Checking if user 'trainee' is signed in..."
$traineeSessions = (Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object -ExpandProperty UserName) -match "^trainee"
if ($traineeSessions) {
    Write-Host "Signing out user 'trainee'..."
    logoff /ID (query session | Where-Object { $_ -match "trainee" } | ForEach-Object { ($_ -split '\s+')[2] })
}

Write-Host "Script completed successfully."


# Remove the user 'trainee', after signing out.
if (Get-LocalUser | Where-Object { $_.Name -eq "trainee" }) {
    Write-Host "Removing user 'trainee'..."
    Stop-Process -Name "trainee" -Force -ErrorAction SilentlyContinue
    Remove-LocalUser -Name "trainee"
    Remove-Item -Path "C:\Users\trainee" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "User 'trainee' removed from the system."
} else {
    Write-Host "User 'trainee' does not exist."
}


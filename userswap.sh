#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Step 1: Add the user simspace with a home directory in /home/simspace
echo "Adding user simspace with home directory /home/simspace..."
useradd -m -d /home/simspace -s /bin/zsh simspace
echo "simspace:simspace1" | chpasswd
echo "User simspace added with password simspace."

# Step 2: Add simspace to the sudoers file
echo "Adding simspace to the sudoers file..."
echo "simspace ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "User simspace granted sudo privileges."

# Step 2.5: Move trainee files to simspace
directory="/home/simspace/"

echo "Moving trainee files to simspace Desktop"
mv /home/trainee/ $directory

echo "Changing ownership from trainee -> simspace
cd "$directory"
chown -R simspace:simspace *

# Define backup file paths
passwd_backup="/etc/passwd.bak"
shadow_backup="/etc/shadow.bak"

# Step 1: Back up /etc/passwd and /etc/shadow
echo "Backing up /etc/passwd and /etc/shadow..."
cp /etc/passwd "$passwd_backup"
cp /etc/shadow "$shadow_backup"
echo "Backup completed."

# Step 2: Remove TRAINEE user data from /etc/passwd
echo "Removing TRAINEE user data from /etc/passwd..."
sed -i '/^TRAINEE:/d' /etc/passwd
diff -u /etc/passwd.bak /etc/passwd | grep '^[+-]' | grep -Ev '^(---|\+\+\+)'

echo "TRAINEE entry removed from /etc/passwd."

# Step 3: Remove TRAINEE user data from /etc/shadow
echo "Removing TRAINEE user data from /etc/shadow..."
sed -i '/^TRAINEE:/d' /etc/shadow
diff -u /etc/shadow.bak /etc/shadow | grep '^[+-]' | grep -Ev '^(---|\+\+\+)'

echo "TRAINEE entry removed from /etc/shadow."

echo "Script completed successfully."

# Post: Remove backups
rm "$passwd_backup"
rm "$shadow_backup"

# REBOOT

# Step 3: Remove the user trainee if they exist
if id "trainee" &>/dev/null; then
    echo "Removing user trainee..."
    killall -u trainee
    userdel -r trainee
    echo "User trainee removed from the system."
    rm -rf /home/trainee/
    rmdir /home/trainee
else
    echo "User trainee does not exist."
fi

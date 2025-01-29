#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root."
   exit 1
fi

# Double check to make sure simspace is not already a user
if id "simspace" &>/dev/null; then
    echo "Simspace user already exists on the system..."
    exit 1
fi

# Step 1: Add the user simspace with a home directory in /home/simspace
echo "Adding user simspace with home directory /home/simspace..."
useradd -m -d /home/simspace -s /bin/zsh simspace -g simspace
echo "simspace:simspace1" | chpasswd
echo "User simspace added with password simspace."

# Step 2: Add simspace to the sudoers file
echo "Adding simspace to the sudoers file..."
echo "simspace ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
echo "User simspace granted sudo privileges."

# Step 3: Move trainee files to simspace
directory="/home/simspace/"

echo "Moving trainee files to simspace Desktop"
mv /home/trainee/ $directory

echo "Changing ownership from trainee -> simspace"
cd "$directory"
chown -R simspace:simspace *

# Define backup file paths
passwd_backup="/etc/passwd.bak"
shadow_backup="/etc/shadow.bak"

# Step 4: Back up /etc/passwd and /etc/shadow
echo "Backing up /etc/passwd and /etc/shadow..."
cp /etc/passwd "$passwd_backup"
cp /etc/shadow "$shadow_backup"
echo "Backup completed."

# Step 5: Remove TRAINEE user data from /etc/passwd
echo "Removing TRAINEE user data from /etc/passwd..."
cat /etc/passwd | grep -v "trainee" > /tmp/passwd
mv /tmp/passwd /etc/passwd

echo "TRAINEE entry removed from /etc/passwd."

# Step 6: Remove TRAINEE user data from /etc/shadow
echo "Removing TRAINEE user data from /etc/shadow..."
cat /etc/shadow | grep -v "trainee" > /tmp/shadow
mv /tmp/shadow /etc/shadow

echo "TRAINEE entry removed from /etc/shadow."
echo "Script completed successfully."

# Post: Remove backups
rm "$passwd_backup"
rm "$shadow_backup"

echo "REBOOTING THE SYSTEM"
sleep 5
reboot

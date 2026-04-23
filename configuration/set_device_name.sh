#!/bin/bash

# This script retrieves the device serial number, uses it to create a new hostname,
# and updates the system hostname configuration files to apply the new device name.

# Get the device's serial number
SERIAL_NUMBER=$(sudo dmidecode -s system-serial-number)

# Define the new device name with the serial number appended
NEW_HOSTNAME="C-$SERIAL_NUMBER"

# Change the hostname
sudo hostnamectl set-hostname $NEW_HOSTNAME

# Update /etc/hostname
echo $NEW_HOSTNAME | sudo tee /etc/hostname

# Update /etc/hosts
CURRENT_HOSTNAME=$(hostname)
sudo sed -i "s/$CURRENT_HOSTNAME/$NEW_HOSTNAME/g" /etc/hosts
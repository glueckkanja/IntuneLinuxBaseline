#!/bin/bash

# This script updates the system package lists, installs available upgrades
# for APT and Snap packages, removes no-longer-needed packages,
# and confirms that the update process has completed.

# Update the package list from Ubuntu and configured third-party repositories
apt-get update

# Upgrade Ubuntu and all installed APT packages, including packages with dependency changes
apt-get -y dist-upgrade

# Update all installed Snap packages
snap refresh

# Remove packages that are no longer required
apt-get -y autoremove

# Show the change
echo "Ubuntu, installed APT packages, and Snap packages have been updated"
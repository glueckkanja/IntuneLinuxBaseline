#!/bin/bash

# This script checks whether the firewall is enabled and, if not,
# configures secure default UFW rules and enables the firewall.

# Get the device's current firewall status
CURRENT_FIREWALL_STATUS=$(ufw status | head -n 1)

# Define the new firewall setting
NEW_FIREWALL_SETTING="Enabled"

# Check if the firewall is not already enabled
if [ "$CURRENT_FIREWALL_STATUS" != "Status: active" ]; then
    # Set the default firewall policy
    ufw default deny incoming
    ufw default allow outgoing

    # Enable the firewall
    ufw --force enable

    # Show the change
    echo "Firewall changed from Disabled to $NEW_FIREWALL_SETTING"
fi
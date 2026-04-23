#!/bin/bash

# This script configures and enforces GNOME screen lock settings by setting
# the idle timeout to 5 minutes, locking the values so users cannot change them,
# and updating the dconf database to apply the policy.

# Get the device's current idle delay setting if it exists
CURRENT_IDLE_DELAY=$(grep '^idle-delay=' /etc/dconf/db/local.d/00-screensaver 2>/dev/null | awk '{print $3}')

# Define the new idle delay setting in seconds
NEW_IDLE_DELAY="300"

# Check if the current idle delay is different from the new idle delay
if [ "$CURRENT_IDLE_DELAY" != "$NEW_IDLE_DELAY" ]; then
    # Create the dconf profile if it does not exist
    mkdir -p /etc/dconf/profile
    if [ ! -f /etc/dconf/profile/user ]; then
        cat <<EOF > /etc/dconf/profile/user
user-db:user
system-db:local
EOF
    fi

    # Create the dconf local database directories
    mkdir -p /etc/dconf/db/local.d
    mkdir -p /etc/dconf/db/local.d/locks

    # Configure the screen lock settings
    cat <<EOF > /etc/dconf/db/local.d/00-screensaver
[org/gnome/desktop/session]
idle-delay=uint32 300

[org/gnome/desktop/screensaver]
lock-delay=uint32 0
EOF

    # Lock the settings so users cannot change them
    cat <<EOF > /etc/dconf/db/local.d/locks/screensaver
/org/gnome/desktop/session/idle-delay
/org/gnome/desktop/screensaver/lock-delay
EOF

    # Update the dconf database
    dconf update

    # Show the change
    echo "Screen lock idle delay changed to 5 minutes"
fi
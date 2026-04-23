#!/bin/bash

# This script checks the current default web browser and changes it to
# Microsoft Edge if Edge is installed and not already set as the default.
# It also updates the system’s default handlers for web links and HTML files.

# Get the device's current default web browser
CURRENT_BROWSER=$(xdg-settings get default-web-browser)

# Define the Microsoft Edge browser desktop file
if [ -f /usr/share/applications/microsoft-edge.desktop ]; then
    NEW_BROWSER="microsoft-edge.desktop"
elif [ -f /usr/share/applications/com.microsoft.Edge.desktop ] || [ -f /var/lib/flatpak/exports/share/applications/com.microsoft.Edge.desktop ]; then
    NEW_BROWSER="com.microsoft.Edge.desktop"
else
    echo "Microsoft Edge desktop entry was not found."
    exit 1
fi

# Check if the current default browser is different from Microsoft Edge
if [ "$CURRENT_BROWSER" != "$NEW_BROWSER" ]; then
    # Change the default web browser
    xdg-settings set default-web-browser "$NEW_BROWSER"

    # Update the default handlers for web links and HTML files
    xdg-mime default "$NEW_BROWSER" x-scheme-handler/http
    xdg-mime default "$NEW_BROWSER" x-scheme-handler/https
    xdg-mime default "$NEW_BROWSER" text/html
    xdg-mime default "$NEW_BROWSER" application/xhtml+xml

    # Show the change
    echo "Default browser changed from $CURRENT_BROWSER to $NEW_BROWSER"
fi
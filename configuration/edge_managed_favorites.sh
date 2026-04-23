#!/bin/bash

# this configures a managed favorites list with predefined websites in Microsoft Edge.

# Define the Edge policy directory
EDGE_POLICY_DIR="/etc/opt/edge/policies/managed"

# Define the Edge managed favorites policy file
EDGE_POLICY_FILE="$EDGE_POLICY_DIR/managed_favorites.json"

# Create the Edge policy directory if it does not exist
mkdir -p "$EDGE_POLICY_DIR"

# Create the new managed favorites policy
cat <<EOF | tee "$EDGE_POLICY_FILE" > /dev/null
{
  "ManagedFavorites": [
    {
      "toplevel_name": "Managed favorites"
    },
    {
      "name": "Google",
      "url": "https://www.google.com"
    },
    {
      "name": "Office Portal",
      "url": "https://www.portal.office.com"
    },
    {
      "name": "Contoso",
      "url": "https://www.contoso.com"
    }
  ],
  "FavoritesBarEnabled": true
}
EOF

# Show the change
echo "Managed favorites have been configured for Microsoft Edge"
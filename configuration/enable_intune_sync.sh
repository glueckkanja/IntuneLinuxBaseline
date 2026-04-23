#!/bin/bash

# This script creates an executable helper script to run the Microsoft Intune agent
# and schedules it as a cron job to run automatically every x hours.

# Define the path for the Intune agent runner script
INTUNE_RUNNER_SCRIPT_PATH="/usr/local/bin/run_intune_agent.sh"

# Create the runner script
cat << 'EOF' > $INTUNE_RUNNER_SCRIPT_PATH
#!/bin/bash

# Run the Intune agent
/opt/microsoft/intune/bin/intune-agent
EOF

# Make the script executable
chmod +x $INTUNE_RUNNER_SCRIPT_PATH

# Define the cron line (every 4 hours, every day)
CRON_LINE="0 */1 * * * $INTUNE_RUNNER_SCRIPT_PATH"

# Schedule the cron job, ignoring duplicates (ensures only one identical entry exists)
(crontab -l 2>/dev/null | grep -Fv "$CRON_LINE"; echo "$CRON_LINE") | crontab -
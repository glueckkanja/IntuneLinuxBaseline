#!/bin/sh
# Intune custom compliance discovery script for Ubuntu 24.04 LTS
# Checks whether APT package upgrades were installed in the last 28 days.
# Output must be valid JSON and match the setting name used in the rules file.

set -u

SETTING_NAME="UpdatesInstalledInLast4Weeks"
DAYS=28
LAST_UPGRADE_EPOCH=0
THRESHOLD_EPOCH=$(date -d "$DAYS days ago" +%s 2>/dev/null || echo 0)

emit_history_logs() {
    found_any=0
    for file in /var/log/apt/history.log*; do
        [ -e "$file" ] || continue
        found_any=1
        case "$file" in
            *.gz)
                gzip -cd -- "$file" 2>/dev/null || true
                ;;
            *)
                cat -- "$file" 2>/dev/null || true
                ;;
        esac
        printf '\n'
    done

    # Return success even if no history logs exist; the script will then mark
    # the device as noncompliant because no qualifying update transaction exists.
    [ "$found_any" -eq 1 ] || true
}

parse_upgrade_dates() {
    emit_history_logs | awk '
        BEGIN {
            start = ""
            has_upgrade = 0
        }
        /^Start-Date:/ {
            if (start != "" && has_upgrade == 1) {
                print start
            }
            line = $0
            sub(/^Start-Date:[[:space:]]*/, "", line)
            gsub(/[[:space:]]+/, " ", line)
            start = line
            has_upgrade = 0
            next
        }
        /^Upgrade:[[:space:]]/ {
            line = $0
            sub(/^Upgrade:[[:space:]]*/, "", line)
            if (line != "") {
                has_upgrade = 1
            }
            next
        }
        END {
            if (start != "" && has_upgrade == 1) {
                print start
            }
        }
    '
}

while IFS= read -r upgrade_date; do
    [ -n "$upgrade_date" ] || continue
    upgrade_epoch=$(date -d "$upgrade_date" +%s 2>/dev/null || echo 0)
    if [ "$upgrade_epoch" -gt "$LAST_UPGRADE_EPOCH" ]; then
        LAST_UPGRADE_EPOCH=$upgrade_epoch
    fi
done <<EOF_DATES
$(parse_upgrade_dates)
EOF_DATES

if [ "$LAST_UPGRADE_EPOCH" -ge "$THRESHOLD_EPOCH" ] 2>/dev/null; then
    printf '{"%s":true}\n' "$SETTING_NAME"
else
    printf '{"%s":false}\n' "$SETTING_NAME"
fi
#!/bin/bash

# Intune Linux custom compliance discovery scripts run in user context,
# so avoid sudo or checks that require elevation.

UFW_ENABLED=false
UFW_BIN="/usr/sbin/ufw"

# Fall back to PATH if ufw isn't in /usr/sbin
if [ ! -x "$UFW_BIN" ]; then
    UFW_BIN="$(command -v ufw 2>/dev/null || true)"
fi

# Prefer the ufw CLI because it reports the firewall state directly.
if [ -n "$UFW_BIN" ] && [ -x "$UFW_BIN" ]; then
    UFW_STATUS="$($UFW_BIN status 2>/dev/null | head -n 1)"

    if [ "$UFW_STATUS" = "Status: active" ]; then
        UFW_ENABLED=true
    fi
fi

# Fallback: if ufw status wasn't available, check the persisted config.
if [ "$UFW_ENABLED" = false ] && [ -r /etc/ufw/ufw.conf ]; then
    if grep -Eq '^ENABLED=yes$' /etc/ufw/ufw.conf; then
        UFW_ENABLED=true
    fi
fi

# Intune expects single-line JSON whose property names match SettingName values.
printf '{"UfwEnabled":%s}\n' "$UFW_ENABLED"
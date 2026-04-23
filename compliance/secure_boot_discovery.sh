#!/bin/bash

# Intune Linux custom compliance discovery scripts should avoid interactive prompts.
# Prefer mokutil because Ubuntu documents it as the standard way to show Secure Boot state.

SECURE_BOOT_ENABLED=false
MOKUTIL_BIN="/usr/bin/mokutil"
EFI_SECUREBOOT_VAR="/sys/firmware/efi/efivars/SecureBoot-8be4df61-93ca-11d2-aa0d-00e098032b8c"

# Fall back to PATH if mokutil isn't in /usr/bin
if [ ! -x "$MOKUTIL_BIN" ]; then
    MOKUTIL_BIN="$(command -v mokutil 2>/dev/null || true)"
fi

# If the device didn't boot in UEFI mode, Secure Boot can't be enabled.
if [ -d /sys/firmware/efi ]; then
    # Prefer mokutil because it returns a straightforward Secure Boot state string.
    if [ -n "$MOKUTIL_BIN" ] && [ -x "$MOKUTIL_BIN" ]; then
        SB_STATE="$($MOKUTIL_BIN --sb-state 2>/dev/null | tr '[:upper:]' '[:lower:]')"

        if printf '%s' "$SB_STATE" | grep -q 'secureboot enabled'; then
            SECURE_BOOT_ENABLED=true
        fi
    fi

    # Fallback: read the UEFI SecureBoot variable directly when it is readable.
    # The first 4 bytes are EFI attributes and the 5th byte is the value: 1 = enabled, 0 = disabled.
    if [ "$SECURE_BOOT_ENABLED" = false ] && [ -r "$EFI_SECUREBOOT_VAR" ]; then
        SB_VALUE="$(od -An -t u1 -j 4 -N 1 "$EFI_SECUREBOOT_VAR" 2>/dev/null | tr -d '[:space:]')"

        if [ "$SB_VALUE" = "1" ]; then
            SECURE_BOOT_ENABLED=true
        fi
    fi
fi

# Intune expects single-line JSON whose property names match SettingName values.
printf '{"SecureBootEnabled":%s}\n' "$SECURE_BOOT_ENABLED"
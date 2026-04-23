# Ubuntu Autoinstall — Intune Enrollment Guide

## Overview

This `autoinstall` YAML is an **unattended Ubuntu installation configuration** that provisions a hardened, Microsoft Intune-ready Ubuntu desktop with minimal manual steps. When you provide the raw URL of the file while installing Ubuntu in the advanced installtion section, Ubuntu reads it automatically and performs the entire setup — including disk encryption, package installation, firewall rules, and Intune tooling — without requiring user interaction during the install itself.

After the first login, the user is guided through one final step: replacing the temporary LUKS disk encryption password with a personal one.

---

## What the Configuration Does

### 1. Base System Setup

- Creates an **empty default user** (the first user is created interactively or via Intune enrollment later)
- SSH server is **not installed**
- Disk is encrypted using **LUKS via LVM** with a temporary password (`ubuntu`) that must be changed on first login
- Only **security updates** are enabled automatically
- The system **reboots** automatically after installation completes

### 2. Packages Installed

The following APT packages are installed during setup:

| Package | Purpose |
|---|---|
| `curl`, `wget` | File downloads and scripting |
| `git` | Version control |
| `gpg` | GPG key handling (required for Microsoft repos) |
| `zenity` | GUI dialog boxes (used for the LUKS password prompt) |
| `auditd` + `audispd-plugins` | Linux audit framework for compliance logging |

The following **Snap packages** are also installed:

| Snap | Notes |
|---|---|
| `code` (VS Code) | Classic confinement |
| `postman` | API testing tool |
| `powershell` | Classic confinement |
| `sublime-text` | Classic confinement |

### 3. LUKS First-Boot Password Change

Because an autoinstall must use a known temporary encryption password (`ubuntu`) to set up LUKS, a **two-script system** forces the user to replace it on their very first GUI login:

- **`luks-change-password-ui.sh`** — runs as the logged-in user, shows `zenity` dialogs asking for a new password (minimum 7 characters, confirmation required). The user **cannot skip or close** this dialog.
- **`luks-change-password-root.sh`** — called via `sudo` (NOPASSWD, restricted to this script only), performs the actual `cryptsetup luksChangeKey` operation using the temporary password as the old key.
- A **marker file** (`/var/lib/luks-firstboot`) is created during install and deleted on success — if the change fails, the dialog reappears on the next login.
- An **autostart desktop entry** (`/etc/xdg/autostart/luks-change-password.desktop`) triggers the UI script 5 seconds after any user logs into the desktop for the first time.

### 4. System Hardening

**Firewall (ufw)**
- Installed and enabled
- Default policy: deny all incoming, allow all outgoing

**SSH hardening** (applied even though the SSH server is not installed, as a defence-in-depth measure if it is ever added):
- Password authentication disabled
- Root login disabled
- X11 forwarding disabled
- Agent forwarding disabled
- Maximum 3 authentication attempts

**Audit rules (`auditd`)** log the following events for Intune/compliance purposes:
- Login and authentication attempts (`/var/log/faillog`, `lastlog`, `tallylog`)
- Sudo usage and `sudoers` changes
- User and group management (`/etc/passwd`, `/etc/group`, `/etc/shadow`)
- System startup scripts (`init.d`, `systemd`)
- Network configuration changes (`/etc/hosts`, `/etc/network/`)

### 5. Microsoft Tooling (Intune, Edge, Defender)

The Microsoft APT repository and signing key are added, then the following packages are installed:

| Package | Purpose |
|---|---|
| `intune-portal` | Microsoft Intune Company Portal for Linux |
| `microsoft-edge-stable` | Microsoft Edge browser |
| `mdatp` | Microsoft Defender for Endpoint |

After a successful LUKS password change, the **Intune Company Portal is automatically launched** so the user can immediately begin device enrollment.

### 6. Bloatware Removal

The following packages are removed to reduce attack surface and storage use:

- `libreoffice*`
- `remmina*` (remote desktop client)
- `transmission*` (torrent client)

### 7. Telemetry and Setup Wizard Suppression

- Ubuntu telemetry report is sent as `no` (opt-out)
- GNOME Initial Setup wizard is suppressed system-wide via `/etc/gnome-initial-setup/vendor.conf` (skips language, keyboard, privacy, software, parental-controls, and Ubuntu Pro pages)
- Ubuntu Pro background notifications and `apt_news` are disabled

---

## How to Use This Configuration


### Step 1 — Review and Customise the YAML

Before use, check the following settings and adjust as needed:

**Storage password (critical)**

The temporary LUKS password is hardcoded in the root script:

```bash
printf '%s' "ubuntu" | cryptsetup luksChangeKey "$DEVICE" ...
```

This value must match the `password` field in the `storage` section:

```yaml
storage:
  layout:
    name: lvm
    password: ubuntu   # Must match the luksChangeKey call above
```

If you change one, change the other. The password is only used during install and is immediately replaced by the user on first login.

**Optional: Locale, keyboard, timezone**

These lines are commented out in the config. Uncomment and set them if you want a non-default locale:

```yaml
# keyboard:
#   layout: de
# locale: en_US
# timezone: Europe/Berlin
```

**Password minimum length**

The minimum LUKS password length is set to 7 characters in `luks-change-password-ui.sh`. Change this line to enforce a stronger policy:

```bash
if [ ${#NEW_PASS} -lt 7 ]; then
```

### Step 2 — Place the File on the Installation Medium


**Via a local HTTP server or hosted on Azure storage or publicly via Github**

Host the file on a location reachable during setup and pass the URL in the advanced installation section of Ubuntu's installation.


### Step 3 — Install

The installation runs fully unattended — do not interact with it
The machine reboots automatically when finished

> The installation will take several minutes depending on hardware and network speed, as it downloads Microsoft packages and Snap packages during the process. Ensure the machine has internet access.

### Step 4 — First Login and LUKS Password Setup

1. At the user account setup screen, create username and password and login to the device
2. Within 5 seconds of reaching the desktop, the **Disk Encryption Setup** dialog appears automatically
3. The user must:
   - Read the information screen and click OK
   - Enter a new encryption password (minimum 7 characters)
   - Confirm the password
4. On success, the dialog closes and the **Intune Company Portal opens automatically**
5. The user completes Intune device enrollment in the Company Portal

> If the password change fails (e.g. wrong temporary password due to a config mismatch), the dialog will reappear on the next login. The marker file `/var/lib/luks-firstboot` controls this — it is deleted only on success.

### Step 5 — Complete Intune Enrollment

Follow your organisation's standard Intune enrollment steps in the Company Portal. Once enrolled, the device is managed and policies are applied automatically.

---

## Security Notes

- The temporary LUKS password (`ubuntu`) is **only used during the install phase** and is immediately replaced. It is not a long-term credential.
- The `NOPASSWD` sudo rule is **scoped exclusively** to `/usr/local/bin/luks-change-password-root.sh` and grants no other elevated access.
- `auditd` rules are active from the first boot and cover all key compliance event categories expected by Intune and common security baselines.

---

## Have fun!
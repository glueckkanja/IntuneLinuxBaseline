<div align="center">

<img src="pictures/banner.png" alt="Intune X Linux" width="800">

# IntuneLinuxBaseline

**Manage. Secure. Empower.**

A baseline for managing Linux devices with Microsoft Intune.

</div>

## Table of Contents
- [Overview](#overview)
- [What's Included](#whats-included)
- [Supported Distributions](#supported-distributions)
- [Getting Started](#getting-started)
- [Basic concept](#basic-concept)
- [Enrollment](#enrollment)
- [Compliance](#compliance)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)

## Overview
The IntuneLinuxBaseline is a collection of security and compliance configurations for Linux devices managed through Microsoft Intune. It provides policy definitions, custom compliance scripts, and configuration scripts that help organisations establish a consistent, secure Linux endpoint posture without starting from scratch.

Mainly aimed at Ubuntu but working with other supported distributions, this baseline gives you a solid, opinionated starting point that you can adapt to your environment.

## What's Included
| Category | Description |
|---|---|
| **Enrollment** | an autoinstall enrollment experience for a faster and standarized setup |
| **Compliance** | policy definitions covering OS, password, encryption, and firewall checks ...etc. |
| **Configuration** | configuration scripts for common Linux hardening settings and customization |

## Supported Distributions
- Ubuntu 24.04 LTS and 26.04 LTS
- Red Hat Enterprise Linux 9/10 (some adjustments might be needed)

## Getting Started

This baseline is modular, you can adopt all of it or just the parts you need. The sections below go into detail on each component; this is the recommended order to put them in place. Do the Intune setup first so the policies and scripts are ready before any device enrolls.

### 1. Check the prerequisites
Before you start, make sure the basics are in place:
- The user has an **Intune license**
- **Users may join devices to Microsoft Entra** is enabled for the users who will enroll
- If you use a Conditional Access policy that requires compliant devices, **exclude Microsoft Intune and Microsoft Intune Enrollment** so the first enrollment isn't blocked
- The device runs a **supported OS** (see [Supported Distributions](#supported-distributions))

### 2. Deploy the compliance policies
In the Intune admin center, upload the discovery scripts and their matching rules files from [compliance/](compliance/), then create the custom compliance policies. Tie these to Conditional Access so only compliant devices reach company resources. See the [Compliance](#compliance) section for what each policy checks.

### 3. Deploy the configuration scripts
Upload the Bash scripts from [configuration/](configuration/) as platform scripts and assign them to your devices. These apply the hardening and convenience settings and re-apply them on every run, so the device stays in the desired state. See the [Configuration](#configuration) section for what each script does.

### 4. Prepare and install the OS
Use the autoinstall file in [enrollment/](enrollment/) to flash and install the device in a standardized way. This handles disk encryption, base packages, the Microsoft apps and more before the user ever reaches the desktop. See the [Enrollment](#enrollment) section for the full walkthrough.

### 5. Enroll the device into Intune
After installation the Intune Portal app launches automatically. The user signs in and registers the device. Because the policies and scripts are already in place, the device picks them up and starts converging to the baseline right after enrollment. See the [Enrollment](#enrollment) section for the sign-in steps.

## Basic concept
there are basic things that need to exist when talking about modern managing devices from any platform, which are:

- A scalable and user driven enrollment with minimal effort
- A set of security policies to reduce exposed weaknesses
- A compliance status of the device that only allow access through conditional access if device is compliant
- Some settings that make the work experience more convenient
- Some basic device information in Intune

## Enrollment
### OS preparation
Intune offers no native method to prepare devices before the user signs in. there is no Autopilot such as for Windows. No sync to external MDM such as for Apple Business and no method to customize the installation. It's expected that a user goes through a manual installation process before reaching their desktop and go through the enrollment into Intune.

For that we utilized the native Ubuntu "Automated Installation" Feature and added some additional features for it for a smooth installation process.

The feature allows using a YAML file to achieve the following requirements:

 initialize a user account
- Uses LVM layout with full-disk LUKS encryption and set a temporary password
- install basic packages
- install basic Snap packages
- run security updates
- Disable telemetry
- Removes LibreOffice, Remmina, and Transmission
- installs needed Microsoft Packages. (Microsoft Edge and Intune Portal App)
- prompt user to change the encryption password after the first sign-in

Check the YAML file and documentation and use with caution ->

### Enrollment to Intune

before the user can enroll their devices to Intune you need to check the following things:
- Licensing: The user has an Intune license
- Entra-Join: make sure the Entra setting "Users may join devices to Microsoft Entra" is set to all or the users that needs to enroll are allowed.
- Conditional Access: If you're using a Conditional Access policy that only allows compliant devices then you need to exclude these resources :
	- Microsoft Intune 
	- Microsoft Intune Enrollment
	otherwise you will not be able to enroll devices as those are not compliant before the enrollment and there is no bypassing mechanism for the enrollment such as for Windows devices
- Operating System: Use a supported OS version. At the i'm writing this it's:
	- Ubuntu 24.04 LTS or Ubuntu 26.04 LTS
	- Red Hat Enterprise Linux (RHEL) 9 or 10

### Installation Process
1. Flash Ubuntu on an external USB Stick and boot your device from it.

2. On the first screen choose the system language you want to use

3. On the next screen choose your accessibility settings or just skip and choose "Next"

4. Choose you keyboard layout and choose "Next"

5. connect your device to a network connection that can access the internet

![Network Connection](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/04_internet_connection.png)

6. Choose "Install Ubuntu" and choose "Next"

![Install Ubuntu](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/05_install_or_try.png)



7. Choose "Automated with autoinstall file"

![Autoinstall](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/06_installation_type.png)

8. import the autoinstall YAML file by using the RAW file URL from Github or the URL to your locally hosted file

![YAML File](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/07_autoinstall_url.png)

9. After reviewing the imported data choose "install"

![Imported Data](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/09_review_autoinstall.png)

10. the installation of Ubuntu and all changes defined in the YAML file will happen in the background. This Process takes 15 -20 minutes. After that the device will reboot.

11. After the instalation has completed and the device has rebooted you need to type the temporary encryption password. in this case "ubuntu". Don't worry this will be changed in a later step.

![Encryption](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/12_disk_passphrase_entry.png)

12. Afterwards you will be greeted with a welcome screen. please create a username and choose a temporary device name. The device name will be changed in a later step.

![user account](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/14_user_setup.png)

13. Choose a password for your device

![Password](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/15_set_password.png)

14. choose the later personalization settings as needed to reach to the desktop.

15. Afterwards you will recieve a Disk Encryption Popup. Please choose a permanent encryption password and confirm it. Note that the password will be needed at each device boot.

![Encryption Popup](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/22_disk_encryption_setup.png)

![encryption pass](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/23_set_encryption_password.png)

![Encryption confirm](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/24_confirm_encryption_password.png)

![Encryption success](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/25_encryption_password_set.png)

16. after this the Intune App will start automatically. the user needs to sign in and enroll their device to Intune

![Intune start](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/26_intune_agent.png)

![sign in](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/27_microsoft_signin.png)

![MS password](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/28_microsoft_password.png)

![register](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/29_device_registration.png)

![Begin](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/30_intune_setup_access.png)

![Enroll](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/31_intune_org_permissions.png)

type the device password as this is needed for some policies that run in root context to take effect.

![root permissions](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/32_auth_required.png)

17. your device is now enrolled to Intune and compliant and can access company data using Microsoft Edge.

![compliant device](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/pictures/33_device_compliant.png)

## Compliance
Compliance policies in Intune are used to define the rules and settings a device must meet to be considered "compliant".

Intune evaluates each device against these rules and reports its compliance state, which can then be used with Conditional Access in Entra ID to allow or block access to company resources based on whether the device is compliant.

As Intune doesn't provide much built in policies for Linux, we will mainly be using custom compliance policies.

Custom compliance for Linux in Intune lets you evaluate device settings that aren't covered by Intune's built-in compliance rules. It consists of two parts that work together:

- A discovery script (Bash) – runs on the Linux device, collects the settings you want to check and returns the results as a JSON object.

- A JSON rules file – uploaded in the Intune admin center, defining the expected values, operators and remediation messages shown to the user if a rule fails.

Intune runs the script on the device, compares the returned JSON against the rules file, and marks the device compliant or non-compliant. The result feeds into Conditional Access just like built-in compliance settings.

for Linux we check for the following settings:

| Policy | Description | Discovery script | Rules file |
|----------|----------|----------|----------|
| Linux - Default - Defender Health | verifies that Microsoft Defender is installed, running and have a healthy state | [Defender_health_discovery.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/compliance/defender_health_discovery.sh)  | [defender_health_rule.json](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/compliance/defender_health_rule.json)  |
| Linux - Default - Firewall | verifies that UFW is enabled and all inbound traffic is not allowed  | [firewall_enabled_discovery.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/compliance/firewall_enabled_discovery.sh)  | [firewall_enabled_rule.json](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/compliance/firewall_enabled_rule.json)  |
| Linux - Default - Secure Boot  | verifies that secure boot is enabled  | [secure_boot_discovery.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/compliance/secure_boot_discovery.sh)  | [secure_boot_rule.json](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/compliance/secure_boot_rule.json)  |
| Linux - Default - Package Updates  | verifies that the package updates has been installed in the last 28 Days | [update_check_discovery.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/compliance/update_check_discovery.sh) | [update_check_rule.json](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/compliance/update_check_rule.json)  |
| Linux - Default - Encryption  | verifies that the device's system disk is encrypted using LUKS  | built-in policy  | built-in policy  |
| Linux - Default - Allowed Distributions  | verifies that only supported Distributions are installed on the targeted devices | built-in policy  | built-in policy  |
| Linux - Default - Password  | verifies that passwords fulfilling certain criterias are used for the local account on the device | built-in policy  | built-in policy  |


## Configuration
Where compliance policies only report whether a device meets the rules, configuration is what actually applies the settings to the device. This is where we harden the system and add the convenience tweaks that make the device ready to use.

Intune offers no settings catalog or configuration profiles for Linux the way it does for Windows, macOS, iOS or Android. The only mechanism Intune provides to push settings to a Linux device is custom scripts, called platform scripts (also called custom scripts/shell scripts in the admin center). For that reason every configuration in this baseline is delivered as a Bash script.

A platform script in Intune is a Bash script that:

- runs in an execution context you choose when creating the policy, either User or Root

- runs on a recurring schedule defined in Intune, which makes the configuration self-healing. if a setting drifts or a user reverts it, the next run puts it back

- reports a basic success or failure state back to Intune based on the script's exit code

Because the scripts run repeatedly, they are written to be idempotent. Each one checks the current state first and only makes a change when the device isn't already in the desired state, so re-runs are safe and don't produce noise.

for Linux we apply the following configurations:

| Configuration | Description | Script |
|----------|----------|----------|
| Disable Telemetry | opts out of ubuntu-report, disables Whoopsie crash and metrics reporting, and stops the whoopsie service | [disable_telemetry.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/configuration/disable_telemetry.sh) |
| Default Browser | sets Microsoft Edge as the default web browser and registers it as the handler for http, https and HTML files | [edge_default_browser.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/configuration/edge_default_browser.sh) |
| Managed Favorites | deploys a managed favorites list with predefined websites and enables the favorites bar in Microsoft Edge | [edge_managed_favorites.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/configuration/edge_managed_favorites.sh) |
| Enable Firewall | sets secure default UFW rules (deny incoming, allow outgoing) and enables the firewall | [enable_firewall.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/configuration/enable_firewall.sh) |
| Intune Sync | creates a helper script for the Intune agent and schedules it as a cron job so the device checks in regularly | [enable_intune_sync.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/configuration/enable_intune_sync.sh) |
| Package Updates | updates the package lists, installs available APT and Snap upgrades, and removes packages that are no longer needed | [package_updates.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/configuration/package_updates.sh) |
| Screen Lock | enforces a 5 minute idle screen lock through dconf and locks the values so users cannot change them | [screen_lock_idle.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/configuration/screen_lock_idle.sh) |
| Device Name | builds a hostname from the device serial number and applies it across the system hostname files | [set_device_name.sh](https://github.com/glueckkanja/IntuneLinuxBaseline/blob/main/configuration/set_device_name.sh) |





## Contributing
Contributions are what make this project useful for the whole community. All skill levels are welcome!

Ways to contribute:

- Report a bug: Open an issue with details and reproduction steps
- Submit a fix or new policy: Fork, branch, and open a pull request
- Improve documentation: Even small docs fixes are appreciated

## Disclaimer

These baselines are provided as-is and represent community recommendations. They are not official Microsoft guidance. Always review and test policies in a non-production environment before deploying to your organisation. The maintainers are not responsible for any unintended impacts to your environment.


<div align="center">

<img src="pictures/banner.png" alt="Intune X Linux" width="800">

# IntuneLinuxBaseline

**Manage. Secure. Empower.**

A baseline for managing Linux devices with Microsoft Intune.

[![License: MIT](https://img.shields.io/github/license/glueckkanja/IntuneLinuxBaseline)](LICENSE)
[![Last Commit](https://img.shields.io/github/last-commit/glueckkanja/IntuneLinuxBaseline)](https://github.com/glueckkanja/IntuneLinuxBaseline/commits)
[![Issues](https://img.shields.io/github/issues/glueckkanja/IntuneLinuxBaseline)](https://github.com/glueckkanja/IntuneLinuxBaseline/issues)

</div>

## Table of Contents
- [Overview](#overview)
- [What's Included](#whats-included)
- [Supported Distributions](#supported-distributions)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Basic concept](#basic-concept)
- [Enrollment](#enrollment)
- [Compliance](#compliance)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)
- [License](#license)

## Overview
The IntuneLinuxBaseline is a collection of security and compliance configurations for Linux devices managed through Microsoft Intune. It provides policy definitions, custom compliance scripts, and configuration scripts that help organisations establish a consistent, secure Linux endpoint posture without starting from scratch.

Mainly aimed at Ubuntu but working with other supported distributions, this baseline gives you a solid, opinionated starting point that you can adapt to your environment.

## What's Included
| Category | Description |
|---|---|
| **Enrollment** | An autoinstall enrollment experience for a faster, standardized setup |
| **Compliance** | Policy definitions covering OS, password, encryption, firewall checks, and more |
| **Configuration** | Configuration scripts for common Linux hardening settings and customization |

## Supported Distributions
- Ubuntu 24.04 LTS and 26.04 LTS
- Red Hat Enterprise Linux 9/10 (some adjustments might be needed)

## Prerequisites
Before you start, make sure the basics are in place:
- The user has an **Intune license**
- **Users may join devices to Microsoft Entra** is enabled for the users who will enroll
- If you use a Conditional Access policy that requires compliant devices, **exclude Microsoft Intune and Microsoft Intune Enrollment** so the first enrollment isn't blocked
- The device runs a **supported OS** (see [Supported Distributions](#supported-distributions))

## Getting Started

This baseline is modular — you can adopt all of it or just the parts you need. The sections below go into detail on each component; this is the recommended order to put them in place. Do the Intune setup first so the policies and scripts are ready before any device enrolls.

### 1. Check the prerequisites
Make sure everything in the [Prerequisites](#prerequisites) section is in place before you begin.

### 2. Deploy the compliance policies
In the Intune admin center, upload the discovery scripts and their matching rules files from [compliance/](compliance/), then create the custom compliance policies. Tie these to Conditional Access so only compliant devices reach company resources. See the [Compliance](#compliance) section for what each policy checks.

### 3. Deploy the configuration scripts
Upload the Bash scripts from [configuration/](configuration/) as platform scripts and assign them to your devices. These apply the hardening and convenience settings and re-apply them on every run, so the device stays in the desired state. See the [Configuration](#configuration) section for what each script does.

### 4. Prepare and install the OS
Use the autoinstall file in [enrollment/](enrollment/) to flash and install the device in a standardized way. This handles disk encryption, base packages, the Microsoft apps and more before the user ever reaches the desktop. See the [Enrollment](#enrollment) section for the full walkthrough.

### 5. Enroll the device into Intune
After installation the Intune Portal app launches automatically. The user signs in and registers the device. Because the policies and scripts are already in place, the device picks them up and starts converging to the baseline right after enrollment. See the [Enrollment](#enrollment) section for the sign-in steps.

## Basic concept
There are some basic things that need to exist when managing modern devices on any platform:

- A scalable, user-driven enrollment with minimal effort
- A set of security policies to reduce exposed weaknesses
- A compliance status for the device that only allows access through Conditional Access if the device is compliant
- Some settings that make the work experience more convenient
- Some basic device information in Intune

## Enrollment
### OS preparation
Intune offers no native method to prepare devices before the user signs in. There is no Autopilot as there is for Windows, no sync to an external MDM as there is for Apple Business, and no method to customize the installation. A user is expected to go through a manual installation process before reaching their desktop and enrolling into Intune.

For that we use the native Ubuntu "Automated Installation" feature and added some extra steps to it for a smooth installation process.

The feature allows using a YAML file to achieve the following requirements:

- Initializes a user account
- Uses an LVM layout with full-disk LUKS encryption and sets a temporary password
- Installs basic packages
- Installs basic Snap packages
- Runs security updates
- Disables telemetry
- Removes LibreOffice, Remmina, and Transmission
- Installs the needed Microsoft packages (Microsoft Edge and the Intune Portal app)
- Prompts the user to change the encryption password after the first sign-in

➡️ Check the YAML file in [enrollment/](enrollment/).



### Installation Process
The full step-by-step installation and enrollment walkthrough, with screenshots, is available here:

➡️ [Installation Process walkthrough](enrollment/enrollment_docs.md)

## Compliance
Compliance policies in Intune are used to define the rules and settings a device must meet to be considered "compliant".

Intune evaluates each device against these rules and reports its compliance state, which can then be used with Conditional Access in Entra ID to allow or block access to company resources based on whether the device is compliant.

As Intune doesn't provide many built-in policies for Linux, we will mainly be using custom compliance policies.

Custom compliance for Linux in Intune lets you evaluate device settings that aren't covered by Intune's built-in compliance rules. It consists of two parts that work together:

- A discovery script (Bash) – runs on the Linux device, collects the settings you want to check and returns the results as a JSON object.

- A JSON rules file – uploaded in the Intune admin center, defining the expected values, operators and remediation messages shown to the user if a rule fails.

Intune runs the script on the device, compares the returned JSON against the rules file, and marks the device compliant or non-compliant. The result feeds into Conditional Access just like built-in compliance settings.

For Linux we check the following settings:

| Policy | Description | Discovery script | Rules file |
|----------|----------|----------|----------|
| Linux - Default - Defender Health | verifies that Microsoft Defender is installed, running, and in a healthy state | [defender_health_discovery.sh](compliance/defender_health_discovery.sh)  | [defender_health_rule.json](compliance/defender_health_rule.json)  |
| Linux - Default - Firewall | verifies that UFW is enabled and all inbound traffic is not allowed  | [firewall_enabled_discovery.sh](compliance/firewall_enabled_discovery.sh)  | [firewall_enabled_rule.json](compliance/firewall_enabled_rule.json)  |
| Linux - Default - Secure Boot  | verifies that secure boot is enabled  | [secure_boot_discovery.sh](compliance/secure_boot_discovery.sh)  | [secure_boot_rule.json](compliance/secure_boot_rule.json)  |
| Linux - Default - Package Updates  | verifies that package updates have been installed in the last 28 days | [update_check_discovery.sh](compliance/update_check_discovery.sh) | [update_check_rule.json](compliance/update_check_rule.json)  |
| Linux - Default - Encryption  | verifies that the device's system disk is encrypted using LUKS  | built-in policy  | built-in policy  |
| Linux - Default - Allowed Distributions  | verifies that only supported distributions are installed on the targeted devices | built-in policy  | built-in policy  |
| Linux - Default - Password  | verifies that passwords meeting certain criteria are used for the local account on the device | built-in policy  | built-in policy  |


## Configuration
Where compliance policies only report whether a device meets the rules, configuration is what actually applies the settings to the device. This is where we harden the system and add the convenience tweaks that make the device ready to use.

Intune offers no settings catalog or configuration profiles for Linux the way it does for Windows, macOS, iOS or Android. The only mechanism Intune provides to push settings to a Linux device is custom scripts, called platform scripts (also called custom scripts/shell scripts in the admin center). For that reason every configuration in this baseline is delivered as a Bash script.

A platform script in Intune is a Bash script that:

- runs in an execution context you choose when creating the policy, either User or Root

- runs on a recurring schedule defined in Intune, which makes the configuration self-healing. If a setting drifts or a user reverts it, the next run puts it back

- reports a basic success or failure state back to Intune based on the script's exit code

Because the scripts run repeatedly, they are written to be idempotent. Each one checks the current state first and only makes a change when the device isn't already in the desired state, so re-runs are safe and don't produce noise.

For Linux we apply the following configurations:

| Configuration | Description | Script |
|----------|----------|----------|
| Disable Telemetry | opts out of ubuntu-report, disables Whoopsie crash and metrics reporting, and stops the whoopsie service | [disable_telemetry.sh](configuration/disable_telemetry.sh) |
| Default Browser | sets Microsoft Edge as the default web browser and registers it as the handler for http, https and HTML files | [edge_default_browser.sh](configuration/edge_default_browser.sh) |
| Managed Favorites | deploys a managed favorites list with predefined websites and enables the favorites bar in Microsoft Edge | [edge_managed_favorites.sh](configuration/edge_managed_favorites.sh) |
| Enable Firewall | sets secure default UFW rules (deny incoming, allow outgoing) and enables the firewall | [enable_firewall.sh](configuration/enable_firewall.sh) |
| Intune Sync | creates a helper script for the Intune agent and schedules it as a cron job so the device checks in regularly | [enable_intune_sync.sh](configuration/enable_intune_sync.sh) |
| Package Updates | updates the package lists, installs available APT and Snap upgrades, and removes packages that are no longer needed | [package_updates.sh](configuration/package_updates.sh) |
| Screen Lock | enforces a 5 minute idle screen lock through dconf and locks the values so users cannot change them | [screen_lock_idle.sh](configuration/screen_lock_idle.sh) |
| Device Name | builds a hostname from the device serial number and applies it across the system hostname files | [set_device_name.sh](configuration/set_device_name.sh) |





## Contributing
Contributions are what make this project useful for the whole community. All skill levels are welcome!

Ways to contribute:

- Report a bug: Open an issue with details and reproduction steps
- Submit a fix or new policy: Fork, branch, and open a pull request
- Improve documentation: Even small docs fixes are appreciated

## Disclaimer

These baselines are provided as-is and represent community recommendations. They are not official Microsoft guidance. Always review and test policies in a non-production environment before deploying to your organisation. The maintainers are not responsible for any unintended impacts to your environment.

## License

This project is licensed under the MIT License.

➡️ See the [LICENSE](LICENSE) file for details.


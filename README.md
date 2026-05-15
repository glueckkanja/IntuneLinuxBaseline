# IntuneLinuxBaseline
A baseline for managing Linux devices with Microsoft Intune.

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

![Encryption success](https://raw.githubusercontent.com/glueckkanja/IntuneLinuxBaseline/refs/heads/main/pictures/25_encryption_password_set.png)

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

## Contributing
Contributions are what make this project useful for the whole community. All skill levels are welcome!

Ways to contribute:

- Report a bug: Open an issue with details and reproduction steps
- Submit a fix or new policy: Fork, branch, and open a pull request
- Improve documentation: Even small docs fixes are appreciated

## Disclaimer

These baselines are provided as-is and represent community recommendations. They are not official Microsoft guidance. Always review and test policies in a non-production environment before deploying to your organisation. The maintainers are not responsible for any unintended impacts to your environment.


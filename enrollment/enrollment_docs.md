# Installation Process

This is the step-by-step installation and enrollment walkthrough for preparing a Linux device with the IntuneLinuxBaseline. For the overview and the rest of the baseline, see the [main README](../README.md).

1. Flash Ubuntu onto an external USB stick and boot your device from it.

2. On the first screen, choose the system language you want to use.

3. On the next screen, choose your accessibility settings, or just skip and choose "Next".

4. Choose your keyboard layout and choose "Next".

5. Connect your device to a network connection that can access the internet.

![Network Connection](../pictures/04_internet_connection.png)

6. Choose "Install Ubuntu" and choose "Next".

![Install Ubuntu](../pictures/05_install_or_try.png)

7. Choose "Automated with autoinstall file".

![Autoinstall](../pictures/06_installation_type.png)

8. Import the autoinstall YAML file by using the raw file URL from GitHub or the URL to your locally hosted file.

![YAML File](../pictures/07_autoinstall_url.png)

9. After reviewing the imported data, choose "Install".

![Imported Data](../pictures/09_review_autoinstall.png)

10. The installation of Ubuntu and all changes defined in the YAML file happen in the background. This process takes 15–20 minutes. After that, the device will reboot.

11. After the installation has completed and the device has rebooted, you need to type the temporary encryption password — in this case "ubuntu". Don't worry, this will be changed in a later step.

![Encryption](../pictures/12_disk_passphrase_entry.png)

12. Afterwards you will be greeted with a welcome screen. Please create a username and choose a temporary device name. The device name will be changed in a later step.

![user account](../pictures/14_user_setup.png)

13. Choose a password for your device.

![Password](../pictures/15_set_password.png)

14. Choose the remaining personalization settings as needed to reach the desktop.

15. Afterwards you will receive a Disk Encryption popup. Please choose a permanent encryption password and confirm it. Note that the password will be needed at each device boot.

![Encryption Popup](../pictures/22_disk_encryption_setup.png)

![encryption pass](../pictures/23_set_encryption_password.png)

![Encryption confirm](../pictures/24_confirm_encryption_password.png)

![Encryption success](../pictures/25_encryption_password_set.png)

16. After this, the Intune app will start automatically. The user needs to sign in and enroll their device in Intune.

![Intune start](../pictures/26_intune_agent.png)

![sign in](../pictures/27_microsoft_signin.png)

![MS password](../pictures/28_microsoft_password.png)

![register](../pictures/29_device_registration.png)

![Begin](../pictures/30_intune_setup_access.png)

![Enroll](../pictures/31_intune_org_permissions.png)

Type the device password, as this is needed for some policies that run in root context to take effect.

![root permissions](../pictures/32_auth_required.png)

17. Your device is now enrolled in Intune and compliant, and can access company data using Microsoft Edge.

![compliant device](../pictures/33_device_compliant.png)

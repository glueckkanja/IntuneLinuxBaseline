# 🐧  IntuneLinuxBaseline

> A baseline for managing Linux devices with Microsoft Intune.

## 📖 Overview
 
The **IntuneLinuxBaseline** is a collection of security and compliance configurations for Linux devices managed through **Microsoft Intune**. It provides policy definitions, custom compliance scripts, and configuration scripts that help organisations establish a consistent, secure Linux endpoint posture without starting from scratch.

Mainly aimed at Ubuntu but working with other supported distributions, this baseline gives you a solid, opinionated starting point that you can adapt to your environment.

---

## What's Included
 
| Category | Description |
|---|---|
| **Enrollment** | an autoinstall enrollment experience for a faster and standarized setup |
| **Compliance** | policy definitions covering OS, password, encryption, and firewall checks ...etc. |
| **Configuration** | configuration scripts for common Linux hardening settings and customization |
| **Documentation** | Per-policy notes explaining intent, impact, and recommended remediation steps |

---
 
## Supported Distributions
 
- Ubuntu 22.04 LTS and 24.04 LTS
- Red Hat Enterprise Linux 9/10 (not tested)

other distributions might work but are not officially supported by Microsoft
 
---

### Prerequisites
 
- An active Microsoft tenant with Intune in place
- Linux devices to enroll to Intune
- Intune licenses

## Getting Started

### 1. Review the the policies and the documentation
### 2. Download the scripts
### 3. Adjust the scripts according to your needs
### 4. Deploy the settings via Intune

## Contributing
 
Contributions are what make this project useful for the whole community. All skill levels are welcome!
 
**Ways to contribute:**
 
- **Report a bug** — Open an with details and reproduction steps
- **Submit a fix or new policy** — Fork, branch, and open a pull request
- **Improve documentation** — Even small docs fixes are appreciated

## ⚠️ Disclaimer
 
These baselines are provided **as-is** and represent community recommendations. They are not official Microsoft guidance. Always review and test policies in a non-production environment before deploying to your organisation. The maintainers are not responsible for any unintended impacts to your environment.

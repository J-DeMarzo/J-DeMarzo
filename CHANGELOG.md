# Changelog

All notable changes to the **DeMarzo Home Lab** infrastructure will be documented in this file.

##  2026-03-20

### Added
- **Ansible Infrastructure-as-Code (IaC):** Established a modular directory structure for configuration management (`playbooks/`, `inventory/`, `group_vars/`).
- **Universal Bootstrap:** Developed `bootstrap.yml` to automate OS updates, core utility installation (vim, git, tmux), and QEMU Guest Agent deployment across the fleet.
- **Project Monorepo:** Transitioned infrastructure files into a unified Git repository at the `J-DeMarzo/` root for better version control and visibility.
- **Custom MOTD:** Implemented automated "DeMarzo Home Lab" banners across all nodes for consistent session identification.

### Fixed
- **SSH Latency:** Resolved a persistent 25-second connection hang by automating `UseDNS no` and `GSSAPIAuthentication no` configurations across all nodes.
- **LXC Restrictions:** Implemented conditional logic and error handling in Ansible to bypass hostname and service management limitations on Proxmox LXC containers (DNS1, DNS2, PBS).
- **Directory Structure:** Refactored the repository to move `.terraform.lock.hcl` into the appropriate `terraform/` subdirectory, ensuring tool-specific isolation.

### Changed
- **Architecture Documentation:** Updated `README.md` to formally define the hardware relationship between the **"ThePack"** compute cluster and the **"Lucky"** standalone storage/backup node.

---

<h1 align="center">Welcome, I’m John DeMarzo</h1>
<h3 align="center">Veteran | Aspiring System Administrator | Cybersecurity Professional</h3>

<p align="center">
  <img src="https://img.shields.io/badge/CompTIA-A%2B-red?style=for-the-badge">
  <img src="https://img.shields.io/badge/CompTIA-Network%2B-blue?style=for-the-badge">
  <img src="https://img.shields.io/badge/CompTIA-Security%2B-yellow?style=for-the-badge">
  <img src="https://img.shields.io/badge/Google-Cybersecurity-green?style=for-the-badge">
</p>

---

## 🔧 About Me

I’m a U.S. Army & fire service veteran transitioning into IT with a focus on **system administration, automation, Windows/Linux environments, and security operations**.

- 🔭 Currently building: **Infrastructure-as-Code (Ansible)**, **AD Lab**, **Monitoring Stack**
- 🎓 Completing my **Bachelor of Business in Cybersecurity (UTSA)**
- 🌐 Based in New Braunfels, TX
- 📚 Lifelong learner focused on infrastructure, cloud, and security

---

## 🤖 Automation Engine (Ansible)

The entire lab is managed as **Infrastructure-as-Code (IaC)**. I utilize a modular Ansible framework to ensure consistency, security, and rapid deployment across the cluster.

- **Modular Inventory:** Organized into logical groups (`thepack`, `infra_services`, `managed_vms`) with inherited variables for global scaling.
- **Universal Bootstrap:** A custom `bootstrap.yml` playbook that automates:
  - OS updates and core tool deployment (`vim`, `tmux`, `git`, `htop`).
  - **SSH Hardening & Optimization:** Eliminated connection latency by disabling `UseDNS` and `GSSAPIAuthentication`.
  - **Intelligent Identity:** Automated hostname and `/etc/hosts` configuration with fail-safe logic for LXC container restrictions.
- **Service Resilience:** Automated deployment of QEMU Guest Agents to ensure Proxmox-level visibility and graceful shutdowns.

---

## 🖥️ Home Lab Hardware

| Device Name | CPU | RAM | Notes |
|-------------|--------------|-------|-------|
| **Lucas** | Intel i7 i8550u | 32GB | Primary compute node (Proxmox) |
| **Angel** | Intel i7 i8550u  | 18GB | Windows VM workloads (Proxmox) |
| **BooBoo** | Intel i7 i8550u | 18GB | Monitoring / logging stack (Proxmox) |
| **Lucky** | Intel N100 | 18GB | PBS / Filestore (Bosgame E1) |

---

## 🧰 Tech Stack

**Operating Systems:** Linux (Debian, Ubuntu, Rocky), Windows Server 2019/2022  

**Automation & IaC:** Ansible, Terraform, Bash, PowerShell  

**Networking:** Technitium DNS, VLAN Segmentation, Omada SDN, Wireshark  

**Security & Monitoring:** Hardening, Audit Frameworks, Sysmon, ELK, Wazuh  

---

## 🌐 Proxmox Lab Architecture

### 1. Service Map & Management

| Service | Hostname | IP | Management | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Primary DNS** | `dns1` | `10.12.5.5` | **Ansible** | Technitium (LXC) |
| **Secondary DNS**| `dns2` | `10.12.5.6` | **Ansible** | Technitium (LXC) |
| **Backup Server**| `pbs` | `10.12.5.15` | **Ansible** | Proxmox Backup Server |
| **Ops Station** | `ops` | `10.12.5.20` | **Ansible** | Control Plane Node |

---

## 🚧 2026 Roadmap

- [x] **Phase 1: Foundation Automation** (Inventory setup, SSH optimization, and node bootstrapping).
- [ ] **Phase 2: DNS Automation** (Automate Technitium DNS record creation via API for new VMs).
- [ ] **Phase 3: Docker Orchestration** (Automated deployment of Docker/Portainer hosts).
- [ ] **Phase 4: Security Hardening** (Implement Ansible Vault for secret management and automated UFW rules).

---

## 🤝 Let’s Connect

Feel free to reach out — I’m always open to collaboration, mentorship, and learning opportunities.

---

### **Next Step for your Diary**
Would you like me to generate a matching `CHANGELOG.md` entry for today so you can document the exact technical hurdles you overcame (like the 25-second SSH hang and LXC hostname issues)?

# John DeMarzo
### Veteran | Network & Security Operations | Cybersecurity Professional

[![CompTIA A+](https://img.shields.io/badge/CompTIA-A%2B-red?style=for-the-badge)](https://www.comptia.org/)
[![CompTIA Network+](https://img.shields.io/badge/CompTIA-Network%2B-blue?style=for-the-badge)](https://www.comptia.org/)
[![CompTIA Security+](https://img.shields.io/badge/CompTIA-Security%2B-yellow?style=for-the-badge)](https://www.comptia.org/)
[![Google Cybersecurity](https://img.shields.io/badge/Google-Cybersecurity-green?style=for-the-badge)](https://grow.google/certificates/cybersecurity/)

---

## About Me

U.S. Army veteran (13B) and fire service professional transitioning into **network and security operations**. I hold four industry certifications and am completing my **BBA in Cybersecurity at UTSA (August 2026)**. My homelab is my proving ground — I design, break, and rebuild production-grade infrastructure to develop real operational skills.

- 🎯 Targeting: **NOC Technician / SOC Analyst** roles (available May 2026)
- 📍 New Braunfels, TX (open to remote)
- 🎓 BBA Cybersecurity, UTSA — August 2026

---

## Homelab Infrastructure

A 3-node Proxmox cluster (Asus Chromebox 3) plus a standalone Proxmox node, all on a 7-VLAN segmented network managed as Infrastructure-as-Code.

### Network Stack
| Device | Role |
|--------|------|
| TP-Link OC200 | Omada SDN Controller |
| TP-Link ER605 | Gateway / Firewall |
| TP-Link SG2008P | PoE Switch |
| TP-Link EAP610 | Wireless AP |

### VLAN Architecture
| VLAN | Subnet | Purpose |
|------|--------|---------|
| 5 | 10.12.5.0/24 | Management |
| 10 | 10.12.10.0/24 | Internal |
| 20 | 10.12.20.0/24 | IoT |
| 30 | 10.12.30.0/24 | Internal Services |
| 35 | 10.12.35.0/24 | DMZ |
| 40 | 10.12.40.0/24 | Lab |
| 45 | 10.12.45.0/24 | Isolated Lab |

### Compute Nodes

**Proxmox Cluster — Asus Chromebox 3 (CN65)**
| Node | Specs | Role |
|------|-------|------|
| Lucas | i7-8550U / 32GB / 1TB NVMe | Primary compute |
| Angel | i7-8550U / 32GB / 500GB NVMe | VM workloads |
| BooBoo | i7-8550U / 32GB / 500GB NVMe | Monitoring stack |

**Standalone Node — Bosgame E1**
| Node | Specs | Role |
|------|-------|------|
| Lucky | N100 / 16GB / 500GB NVMe + 2×6TB ZFS Mirror | Proxmox Backup Server + Admin Ops VM (`ops` 10.12.5.20) |

**Desktop**
| Node | Specs | Role |
|------|-------|------|
| WinDesk | N150 / 16GB / 1TB NVMe | Desktop (Windows/Ubuntu dual) |

---

## Automation & Monitoring

**Infrastructure-as-Code (Ansible)**
- Modular inventory structure for scalable group-based management
- Bootstrap playbook: OS hardening, SSH optimization, hostname automation
- QEMU Guest Agent deployment for Proxmox visibility

**Monitoring Stack**
- Grafana dashboards for node and network health
- Technitium DNS (redundant: `dns1` 10.12.5.5 / `dns2` 10.12.5.6)

---

## Tech Stack

**OS:** Debian, Ubuntu, Rocky Linux, Windows Server 2019/2022  
**Automation:** Ansible, Bash, PowerShell  
**Networking:** Omada SDN, VLAN segmentation, Technitium DNS, Wireshark  
**Monitoring:** Grafana, Proxmox Backup Server  
**Security Tools:** Sysmon, Wazuh, ELK (in progress)  
**Virtualization:** Proxmox VE, LXC

---

## 2026 Roadmap

- [x] Phase 1 — Cluster bootstrap & Ansible IaC
- [x] Phase 2 — DNS redundancy & Grafana monitoring
- [ ] Phase 3 — Wazuh SIEM deployment & alert tuning
- [ ] Phase 4 — ELK log aggregation across VLANs
- [ ] Phase 5 — Ansible Vault + UFW hardening automation
- [ ] Phase 6 — Detection rule documentation & runbooks

---

## Connect

Open to NOC/SOC opportunities in the San Antonio / New Braunfels area or remote.  
Feel free to reach out for collaboration or mentorship.

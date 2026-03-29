# John DeMarzo
### Veteran | Infrastructure Security | Detection Engineering | Wazuh · Splunk · Ansible · Proxmox

[![CompTIA A+](https://img.shields.io/badge/CompTIA-A%2B-red?style=for-the-badge)](https://www.comptia.org/)
[![CompTIA Network+](https://img.shields.io/badge/CompTIA-Network%2B-blue?style=for-the-badge)](https://www.comptia.org/)
[![CompTIA Security+](https://img.shields.io/badge/CompTIA-Security%2B-yellow?style=for-the-badge)](https://www.comptia.org/)
[![Google Cybersecurity](https://img.shields.io/badge/Google-Cybersecurity-green?style=for-the-badge)](https://grow.google/certificates/cybersecurity/)

---

## About Me

U.S. Army veteran (13B) and fire service professional transitioning into IT with a focus on system administration, automation, Windows/Linux environments. I hold four industry certifications and am completing my BBA in Cybersecurity at UTSA (August 2026). My homelab is my proving ground — I design, break, and rebuild production-grade infrastructure to develop real operational skills.

- 🎯 Targeting: Systems Security Administrator / IT Security Analyst / SOC Analyst (available May 2026)
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
| Lucky | N100 / 16GB / 500GB NVMe + 2×6TB ZFS Mirror | Proxmox Backup Server + Control Plane VM (`ops` 10.12.5.20) — Ansible, Terraform, Git |

**Desktop**
| Node | Specs | Role |
|------|-------|------|
| WinDesk | N150 / 16GB / 1TB NVMe | Desktop (Windows/Ubuntu dual) |

---

## Automation & Monitoring

**Infrastructure-as-Code (Ansible, Terraform, Git)**
- Dedicated control plane VM (`ops` 10.12.5.20) — single source of truth for all automation and version control
- Modular inventory structure for scalable group-based management
- Bootstrap playbook: OS hardening, SSH optimization, hostname automation
- QEMU Guest Agent deployment for Proxmox visibility

**Monitoring Stack**
- Grafana dashboards for node and network health
- Technitium DNS (redundant: `dns1` 10.12.5.5 / `dns2` 10.12.5.6)

---

## Tech Stack
**Security & Monitoring:** Wazuh, ELK, Splunk, Sysmon, Hardening, Audit Frameworks
**Automation & IaC:** Ansible, Terraform, Bash, PowerShell  
**Networking:** VLAN Segmentation, Omada SDN, Technitium DNS, Wireshark
**Operating Systems:** Linux (Debian, Ubuntu, Rocky), Windows 11, 10, XP Pro, Server 2019/2022  
**Virtualization:** Proxmox VE, LXC

---

## 2026 Roadmap

- [x] * Phase 1 — Cluster Bootstrap, Ansible IaC & DNS Redundancy
          (Inventory, SSH hardening, QEMU agents, Technitium DNS)

- [x] * Phase 2 — Security Monitoring Foundation
          (Wazuh SIEM/XDR deployment, Sysmon integration, 
          alert tuning, detection rule documentation)

- [ ] * Phase 3 — Splunk Integration & Detection Engineering
          (Splunk deployment, SPL query writing, brute force 
          detection lab, ATT&CK-mapped detection runbooks)

- [ ] * Phase 4 — Microsoft Security Stack
          (Azure free tier, Microsoft Sentinel, KQL queries, 
          Defender for Endpoint integration)

- [ ] * Phase 5 — ELK Log Aggregation & Correlation
          (Cross-VLAN log collection, Elasticsearch indexing, 
          Kibana dashboards, Logstash pipelines)

- [ ] * Phase 6 — Security Automation & Scripting
          (Python IOC enrichment, threat intel feed aggregator, 
          automated alerting via API, Ansible Vault secrets mgmt)

- [ ] * Phase 7 — Infrastructure Hardening & Compliance
          (UFW automation, CIS benchmarking, audit framework 
          implementation, vulnerability scanning with OpenVAS)

- [ ] * Phase 8 — Threat Intelligence Platform
          (OpenCTI deployment, MISP integration, threat actor 
          profiling, ATT&CK Navigator mapping)

- [ ] * Phase 9 — Cloud Security Engineering
          (AZ-500 alignment, cloud workload protection, 
          identity & access management, Zero Trust architecture)

- [ ] * Phase 10 — Advanced Detection & Red/Blue Integration
          (Atomic Red Team simulation, purple team exercises, 
          PCAP threat hunting, full incident response runbooks)

---

## Connect

Open to NOC/SOC opportunities in the San Antonio / New Braunfels area or remote.  
Feel free to reach out for collaboration or mentorship.

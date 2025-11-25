<!-- HEADER -->
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

- 🔭 Currently building: **AD Lab**, **Linux Automation Toolkit**, **Monitoring Stack**
- 🎓 Completing my **Bachelor of Business (UTSA)**
- 🌐 Based in New Braunfels, TX
- 📚 Lifelong learner focused on infrastructure, cloud, and security

---

## 🖥️ Home Lab Hardware

| Device Name | CPU | Ram | Notes |
|-------------|--------------|-------|-------|
| **Lucas** | Intel i7 i8550u | 32Gb | Primary compute node |
| **Primey** | Intel i7 i8550u  | 32Gb | Linux & services testing |
| **Angel** | Intel i7 i8550u  |  18Gb | Windows VM workloads |
| **BooBoo** | Intel i7 i8550u | 18Gb | Monitoring / logging stack |
| **Lucky** | Intel N100 | 16Gb | Filestore / PBS |


---

## 🧰 Tech Stack

**Operating Systems:**  
Linux (Ubuntu, Debian, Rocky), Windows Server 2019/2022  

**Automation & Scripting:**  
Bash, PowerShell, Python  

**Networking:**  
DNS, DHCP, VLANs, routing, Wireshark  

**Security & Monitoring:**  
Hardening, audit frameworks, Sysmon, ELK, Wazuh  

**Infrastructure:**  
VMs, snapshots, backups, virtualization, container basics  

---

## 🚧 Active Projects (with repos)

### 🔹 [Linux Sysadmin Toolkit](#)  
Automation scripts, backups, log rotation, permission auditing.

### 🔹 [Windows AD Lab](#)  
Domain controller, Group Policy Objects, PowerShell automation.

### 🔹 [Security Hardening Guide](#)  
Baseline hardening for Linux/Windows, firewalls, auditing.

### 🔹 [Monitoring Lab](#)  
ELK/Wazuh stack, log forwarding, Sysmon pipelines.

### 🔹 [Dotfiles](#)  
My environment configurations: shell, editor, aliases, functions.

---

## 🌐 Network / Lab Diagram (Placeholder)

## Proxmox Lab Architecture

### 1. Hardware Overview

#### 1.1 Proxmox Cluster – “The Pack”

All four cluster nodes are **Asus Chromebox 3 (CN65)** units with coreboot/MrChromebox firmware.

| Node    | Model            | CPU           | Cores/Threads | RAM   | Storage        | Role                        |
|--------:|------------------|---------------|---------------|-------|----------------|-----------------------------|
| Lucas   | Asus CN65        | i7-8550U      | 4c / 8t       | 32 GB | NVMe (local)   | Primary infra               |
| Maximus | Asus CN65        | i7-8550U      | 4c / 8t       | 32 GB | NVMe (local)   | Security / SIEM / lab core  |
| BooBoo  | Asus CN65        | i7-8550U      | 4c / 8t       | 18 GB | NVMe (local)   | Secondary infra / endpoints |
| Angel   | Asus CN65        | i7-8550U      | 4c / 8t       | 18 GB | NVMe (local)   | Utility / overflow          |

Common characteristics:

- Hardware virtualization and VT-d enabled  
- AES-NI available (for VPN/crypto)  
- Single 1 GbE NIC per node (VLAN trunk to core switch)  
- Proxmox installed to local NVMe on all nodes  

#### 1.2 Storage & Backup Node – “Lucky” + DAS

| Node  | Model       | CPU       | RAM   | Storage                                                                 | Role                                       |
|------:|-------------|-----------|-------|-------------------------------------------------------------------------|--------------------------------------------|
| Lucky | Bosgame E1  | Intel N100| 18 GB | NVMe (system + fast tier) + Cenmate 2-Bay USB 3.0 DAS (2 × 6TB HDD RAID1) | PBS, NFS/SMB file services, bulk storage   |

DAS details:

- **Enclosure:** Cenmate 2-bay USB 3.0 DAS  
- **Drives:** 2 × 6TB HDD configured as **RAID-1 mirror** (via Proxmox)  
- **Purpose:**  
  - PBS bulk (long-retention) datastore  
  - Low-IO NFS/SMB shares  
  - Media / archival / general “cold” storage  

Lucky is not part of the Proxmox cluster. It provides:

- **Proxmox Backup Server (PBS)** for all nodes  
- **Tiered storage**: fast NVMe + mirrored HDD DAS  
- **NFS/SMB** for ISOs, templates, archives, and bulk data  

---

### 2. Logical Design

#### 2.1 Node Roles

- **Lucas** – Core infrastructure (DNS, AD/DC, reverse proxy, monitoring, Home Assistant)  
- **Maximus** – Security stack (Wazuh/SIEM, Kali, key Windows endpoints)  
- **BooBoo** – Redundant infra (Pi-hole 2, AD/DC 2) + extra lab endpoints  
- **Angel** – Utility services (MQTT, Node-RED, NVR, jumpbox, overflow workloads)  
- **Lucky** – Proxmox Backup Server, NFS/SMB, fast NVMe tier + mirrored DAS bulk tier  

#### 2.2 Storage Strategy (Tiered)

**On “The Pack” (CN65 nodes):**

- **Local NVMe** on each node:
  - Primary storage for performance-sensitive VMs/CTs  
  - Fast snapshots and PBS backups  
  - No shared block storage (no Ceph)  

**On Lucky (tiered):**

- **NVMe – “fast-store” PBS datastore:**
  - Short/medium retention  
  - High-change VMs (AD, DNS, SIEM, Kali, Windows endpoints)  
  - Quick restore candidates  

- **DAS RAID1 – “bulk-store” PBS datastore + NFS/SMB:**
  - Long-term retention (mirrored 6TB HDDs)  
  - Less frequently restored VMs and CTs  
  - Archival snapshots, media, NVR recordings, and lab file shares  
  - Lower IOPS but high capacity and redundancy  

There is no distributed block storage (e.g., Ceph). Availability is handled at the **service level** (multiple DNS/DC nodes) and through **PBS backups** across fast and bulk tiers.

---

### 3. Service Layout

#### 3.1 Service Table

The table below summarizes the planned / deployed services and where they run.

| Service / VM/CT       | Type  | Node    | vCPU | RAM       | Disk (approx)          | Notes                                   |
|-----------------------|-------|---------|------|-----------|------------------------|-----------------------------------------|
| `ct-pihole-1`         | LXC   | Lucas   | 1    | 0.5–1 GB  | 8–16 GB (NVMe)         | Primary DNS / ad-blocking               |
| `ct-unbound`          | LXC   | Lucas   | 1    | 0.5 GB    | 4–8 GB (NVMe)          | Recursive DNS backend                    |
| `vm-ad1`              | VM    | Lucas   | 2–4  | 4–8 GB    | 60–80 GB (NVMe)        | Primary AD/DC or Samba AD               |
| `ct-reverse-proxy`    | LXC   | Lucas   | 2    | 2 GB      | 16–32 GB (NVMe)        | Traefik / Nginx Proxy Manager           |
| `ct-homeassistant`    | LXC   | Lucas   | 2    | 4 GB      | 32 GB (NVMe)           | Home automation                         |
| `ct-monitoring`       | LXC   | Lucas   | 2    | 4 GB      | 32–64 GB (NVMe)        | Grafana + Loki / metrics & logs         |
| `ct-uptime-kuma`      | LXC   | Lucas   | 1    | 0.5–1 GB  | 8–16 GB (NVMe)         | Service uptime checks                   |
| `vm-wazuh-mgr`        | VM    | Maximus | 4–6  | 8–16 GB   | 200–300 GB (NVMe)      | Core SIEM / Wazuh stack                 |
| `vm-es-single`        | VM    | Maximus | 4–6  | 12–16 GB  | 300+ GB (NVMe)         | Optional dedicated Elastic node         |
| `vm-kali-main`        | VM    | Maximus | 4    | 8 GB      | 80–100 GB (NVMe)       | Primary attack box                      |
| `vm-win10-lab1`       | VM    | Maximus | 2–4  | 4–8 GB    | 80–100 GB (NVMe)       | Lab endpoint (blue team)                |
| `ct-tools`            | LXC   | Maximus | 2    | 2–4 GB    | 32 GB (NVMe)           | Tooling container                       |
| `ct-pihole-2`         | LXC   | BooBoo  | 1    | 0.5–1 GB  | 8–16 GB (NVMe)         | Secondary DNS                           |
| `vm-ad2`              | VM    | BooBoo  | 2–4  | 4–8 GB    | 60–80 GB (NVMe)        | Secondary AD/DC                         |
| `vm-win10-lab2`       | VM    | BooBoo  | 2–4  | 4–8 GB    | 80–100 GB (NVMe)       | Second lab endpoint                     |
| `ct-syslog`           | LXC   | BooBoo  | 2    | 4 GB      | 64–100 GB (NVMe)       | Syslog aggregation                      |
| `ct-mqtt`             | LXC   | Angel   | 1    | 0.5 GB    | 4–8 GB (NVMe)          | MQTT broker                             |
| `ct-nodered`          | LXC   | Angel   | 1–2  | 1–2 GB    | 8–16 GB (NVMe)         | Automation/flows                        |
| `vm-nvr`              | VM    | Angel   | 4    | 4–8 GB    | OS on NVMe, recordings on DAS (NFS/SMB) | NVR (Frigate/Shinobi)                   |
| `vm-jumpbox`          | VM    | Angel   | 2    | 4 GB      | 40–60 GB (NVMe)        | Bastion host                            |
| `pbs-fast-store`      | PBS   | Lucky   | N/A  | N/A       | NVMe                   | Fast-tier PBS datastore                 |
| `pbs-bulk-store`      | PBS   | Lucky   | N/A  | N/A       | DAS RAID1 (2 × 6TB)    | Bulk/long-retention PBS datastore       |
| `nfs-iso` / `nfs-templates` | NFS | Lucky | N/A | N/A     | NVMe or DAS            | ISOs, templates, general storage        |
| `nfs-archive` / `nfs-media` | NFS/SMB | Lucky | N/A | N/A  | DAS RAID1              | Archives, media, low-IO bulk data       |

Resource values are starting points and may be tuned based on real-world usage.

---

### 4. Network & VLAN Overview

The environment uses VLANs to segment management, infrastructure, lab, and storage traffic. Exact VLAN IDs are specific to the physical network configuration; the logical roles are:

- **Management VLAN** – Proxmox host management, infra VMs (AD, DNS, reverse proxy, PBS access).  
- **Client / Lab VLANs** – Lab endpoints, Kali/attack boxes, test clients.  
- **Infrastructure VLAN(s)** – Internal-only services that should not be exposed directly to client networks.  
- **Storage VLAN** (optional) – Dedicated network between Proxmox nodes and Lucky for NFS/PBS traffic.

Key principles:

- Proxmox host management interfaces live only on the **Management VLAN**.  
- Client/Lab networks cannot reach Proxmox management IPs directly (enforced via firewall/ACLs).  
- Only Proxmox nodes can reach PBS and NFS/SMB services on Lucky on required ports.  
- DNS and AD are reachable from client/lab VLANs, but not vice versa beyond what is required.

---

### 5. Backup & Resilience Strategy

#### 5.1 Tiered Proxmox Backup Server (PBS) on Lucky

PBS uses two storage tiers:

- **`pbs-fast-store` (NVMe):**
  - Short- to medium-term retention  
  - High-frequency backups for critical and frequently changing VMs/CTs  
  - Example retention:
    - 7 daily  
    - 4 weekly  
    - 1–2 monthly  

- **`pbs-bulk-store` (DAS RAID1, 2 × 6TB HDD):**
  - Long-term retention and archival  
  - Lower-frequency backups or synced copies from `pbs-fast-store`  
  - Example retention:
    - 12 weekly  
    - 6 monthly  
    - 1 yearly  

Typical policy:

- Critical infra and SIEM:
  - Back up to `pbs-fast-store` daily  
  - Periodic sync or additional backups to `pbs-bulk-store` for long-term history  

- Lab endpoints / scratch:
  - Back up less frequently  
  - Retain mainly on `pbs-bulk-store` if needed at all  

PBS verification and prune jobs are configured per datastore to enforce retention and health checks.

#### 5.2 Service-Level Redundancy

- Two Pi-hole instances (`ct-pihole-1` on Lucas, `ct-pihole-2` on BooBoo)  
- Two AD/DCs (`vm-ad1` on Lucas, `vm-ad2` on BooBoo)  
- SIEM and monitoring components distributed primarily on Maximus, with logs sent from other nodes  

Resilience is achieved by:

- Running redundant services on **different nodes**  
- Using **tiered PBS backups** (fast NVMe + mirrored DAS)  
- Treating most lab workloads as **rebuildable from templates** when needed  

There is no live VM HA; restoration and redundancy are intentional and documented.

---

### 6. Node Affinity & Tags

Proxmox node tags and VM/CT affinity are used to keep services on appropriate hardware:

- Nodes:
  - `Lucas` → tag: `infra`  
  - `Maximus` → tag: `siem`  
  - `BooBoo` → tag: `infra-secondary`  
  - `Angel` → tag: `utility`  

- VMs/CTs:
  - Core infra (AD, DNS, reverse proxy, Home Assistant, monitoring) prefer nodes tagged `infra`.  
  - Security stack (Wazuh, Elastic, main Kali) prefers nodes tagged `siem`.  
  - Utility services (MQTT, NVR, Node-RED, jumpbox) prefer the `utility` node.  

If a node fails, services can be:

- Started elsewhere where compatible  
- Restored from PBS (fast or bulk tiers)  
- Rebuilt from templates kept on Lucky’s NFS shares  

---

### 7. Implementation Order (High-Level)

1. Configure Proxmox networking and VLAN trunks on all CN65 nodes.  
2. Configure RAID1 on the DAS attached to Lucky and mount it as a Proxmox storage backend.  
3. Install and configure **PBS** on Lucky:
   - Create `pbs-fast-store` on NVMe  
   - Create `pbs-bulk-store` on DAS RAID1  
4. Add NFS/SMB exports from Lucky (`nfs-iso`, `nfs-templates`, `nfs-archive`, `nfs-media`) and mount them on each Proxmox node.  
5. Deploy core infra on **Lucas** and **BooBoo** (Pi-hole 1/2, AD1/2, reverse proxy, Home Assistant).  
6. Deploy security stack and lab VMs on **Maximus** (Wazuh/SIEM, Kali, lab endpoints).  
7. Deploy utility/overflow services on **Angel** (MQTT, Node-RED, NVR, jumpbox).  
8. Tune CPU/RAM allocations, PBS retention policies, and firewall rules based on usage and monitoring.  

---

This document describes the current “desired state” for the Proxmox lab layout, including the tiered storage design on Lucky using NVMe plus the Cenmate 2-bay DAS in RAID1. As the environment evolves, updates should be reflected here so the GitHub repository remains the authoritative architecture and service map.


## 📈 GitHub Stats

<p align="center">
  <img height="160px" src="https://github-readme-stats.vercel.app/api?username=J-DeMarzo&show_icons=true&theme=tokyonight">
  <img height="160px" src="https://github-readme-streak-stats.herokuapp.com/?user=J-DeMarzo&theme=tokyonight">
</p>

---

## 🤝 Let’s Connect

Feel free to reach out — I’m always open to collaboration, mentorship, and learning opportunities.


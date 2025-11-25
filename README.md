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

#### 1.2 Storage & Backup Node – “Lucky”

| Node  | Model       | CPU     | RAM  | Storage                        | Role                          |
|------:|-------------|---------|------|--------------------------------|-------------------------------|
| Lucky | Bosgame E1  | Intel N100 | 18 GB | NVMe + additional SSD/HDD pool | PBS, NFS/SMB file services    |

Lucky is not part of the Proxmox cluster. It provides:

- **Proxmox Backup Server (PBS)** for all nodes
- **NFS/SMB** for ISOs, templates, and bulk storage

---

### 2. Logical Design

#### 2.1 Node Roles

- **Lucas** – Core infrastructure (DNS, AD/DC, reverse proxy, monitoring, Home Assistant)
- **Maximus** – Security stack (Wazuh/SIEM, Kali, key Windows endpoints)
- **BooBoo** – Redundant infra (Pi-hole 2, AD/DC 2) + extra lab endpoints
- **Angel** – Utility services (MQTT, Node-RED, NVR, jumpbox, overflow workloads)
- **Lucky** – Proxmox Backup Server and central file/NFS/SMB storage

#### 2.2 Storage Strategy

- **Local NVMe** (on each CN65):
  - Primary storage for performance-sensitive VMs/CTs (AD, DNS, SIEM, Windows, Kali)
  - Fast snapshots and PBS backups

- **Lucky (PBS + NFS/SMB)**:
  - PBS datastores for VM/CT backups
  - NFS exports for:
    - ISOs and install media
    - VM templates / cloud images
    - Optional low-IO lab VMs and bulk data

There is no distributed block storage (e.g., Ceph). High availability is handled at the **service level** (e.g., multiple DNS and DC instances) and via **PBS backups**, not live VM HA.

---

### 3. Service Layout

#### 3.1 Service Table

The table below summarizes the planned / deployed services and where they run.

| Service / VM/CT     | Type  | Node    | vCPU | RAM   | Disk (approx) | Notes                          |
|---------------------|-------|---------|------|-------|----------------|--------------------------------|
| `ct-pihole-1`       | LXC   | Lucas   | 1    | 0.5–1 GB | 8–16 GB     | Primary DNS / ad-blocking     |
| `ct-unbound`        | LXC   | Lucas   | 1    | 0.5 GB | 4–8 GB        | Recursive DNS backend         |
| `vm-ad1`            | VM    | Lucas   | 2–4  | 4–8 GB | 60–80 GB      | Primary AD/DC or Samba AD     |
| `ct-reverse-proxy`  | LXC   | Lucas   | 2    | 2 GB   | 16–32 GB      | Traefik / Nginx Proxy Manager |
| `ct-homeassistant`  | LXC   | Lucas   | 2    | 4 GB   | 32 GB         | Home automation               |
| `ct-monitoring`     | LXC   | Lucas   | 2    | 4 GB   | 32–64 GB      | Grafana + Loki / metrics/logs |
| `ct-uptime-kuma`    | LXC   | Lucas   | 1    | 0.5–1 GB | 8–16 GB     | Service uptime checks         |
| `vm-wazuh-mgr`      | VM    | Maximus | 4–6  | 8–16 GB | 200–300 GB    | Core SIEM / Wazuh stack       |
| `vm-es-single`      | VM    | Maximus | 4–6  | 12–16 GB | 300+ GB     | Optional dedicated Elastic    |
| `vm-kali-main`      | VM    | Maximus | 4    | 8 GB   | 80–100 GB     | Primary attack box            |
| `vm-win10-lab1`     | VM    | Maximus | 2–4  | 4–8 GB | 80–100 GB     | Lab endpoint (blue team)      |
| `ct-tools`          | LXC   | Maximus | 2    | 2–4 GB | 32 GB         | Tooling container             |
| `ct-pihole-2`       | LXC   | BooBoo  | 1    | 0.5–1 GB | 8–16 GB     | Secondary DNS                 |
| `vm-ad2`            | VM    | BooBoo  | 2–4  | 4–8 GB | 60–80 GB      | Secondary AD/DC               |
| `vm-win10-lab2`     | VM    | BooBoo  | 2–4  | 4–8 GB | 80–100 GB     | Second lab endpoint           |
| `ct-syslog`         | LXC   | BooBoo  | 2    | 4 GB   | 64–100 GB     | Syslog aggregation            |
| `ct-mqtt`           | LXC   | Angel   | 1    | 0.5 GB | 4–8 GB        | MQTT broker                   |
| `ct-nodered`        | LXC   | Angel   | 1–2  | 1–2 GB | 8–16 GB       | Automation/flows              |
| `vm-nvr`            | VM    | Angel   | 4    | 4–8 GB | N/A (records on Lucky) | NVR (Frigate/Shinobi, etc.) |
| `vm-jumpbox`        | VM    | Angel   | 2    | 4 GB   | 40–60 GB      | Bastion host                  |
| `pbs`               | Bare  | Lucky   | N/A  | N/A    | NVMe + HDD/SSD | Proxmox Backup Server         |
| `nfs-iso` / `nfs-templates` | NFS | Lucky | N/A | N/A | Exported pool | ISOs, templates, bulk storage |

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
- Only Proxmox nodes can reach PBS and NFS services on Lucky on required ports.
- DNS and AD are reachable from client/lab VLANs, but not vice versa beyond what is required.

---

### 5. Backup & Resilience Strategy

#### 5.1 Proxmox Backup Server (PBS)

All Proxmox nodes back up to PBS on Lucky. Example policy:

- **Critical infra (AD, DNS, reverse proxy, Home Assistant, Wazuh/SIEM):**
  - Schedule: daily backups (off-peak)
  - Retention: 7 daily, 4 weekly, 3 monthly

- **Lab endpoints & Kali:**
  - Schedule: every 2–3 days
  - Retention: 4 weekly, 3 monthly

- **Scratch / temporary VMs:**
  - Schedule: manual or weekly
  - Retention: minimal (e.g., 2 weekly)

PBS is configured with:

- At least one **fast datastore** on NVMe for frequent backups
- Optional **bulk datastore** on larger SSD/HDD for long-term retention

#### 5.2 Service-Level Redundancy

- Two Pi-hole instances (`ct-pihole-1` on Lucas, `ct-pihole-2` on BooBoo)
- Two AD/DCs (`vm-ad1` on Lucas, `vm-ad2` on BooBoo)
- SIEM and monitoring components distributed across Maximus and other nodes as needed

Resilience is achieved by:

- Running redundant services on **different nodes**
- Using **PBS** for VM/CT restore in case of node failure
- Treating most lab workloads as **rebuildable from templates** if necessary

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

If a node fails, services can be manually started on another node, restored from PBS, or rebuilt from templates as needed.

---

### 7. Implementation Order (High-Level)

1. Configure Proxmox networking and VLAN trunks on all CN65 nodes.
2. Add NFS exports from Lucky (ISOs, templates) and mount them on each Proxmox node.
3. Deploy core infra on **Lucas** and **BooBoo** (Pi-hole 1/2, AD1/2, reverse proxy, Home Assistant).
4. Install and configure **PBS** on Lucky; add PBS as backup target in Proxmox.
5. Deploy security stack and lab VMs on **Maximus** (Wazuh/SIEM, Kali, lab endpoints).
6. Deploy utility/overflow services on **Angel** (MQTT, Node-RED, NVR, jumpbox).
7. Tune CPU/RAM allocations, PBS retention policies, and firewall rules based on usage.

---

This document describes the current “desired state” for the Proxmox lab layout and service deployment. As the environment evolves, updates should be reflected here so the GitHub repository always shows the authoritative architecture and service map.


---

## 📈 GitHub Stats

<p align="center">
  <img height="160px" src="https://github-readme-stats.vercel.app/api?username=J-DeMarzo&show_icons=true&theme=tokyonight">
  <img height="160px" src="https://github-readme-streak-stats.herokuapp.com/?user=J-DeMarzo&theme=tokyonight">
</p>

---

## 🤝 Let’s Connect

Feel free to reach out — I’m always open to collaboration, mentorship, and learning opportunities.


# Wazuh SIEM/XDR Deployment

## Overview

Deployment of Wazuh as the primary SIEM/XDR platform in the homelab, running as an LXC
container on Proxmox. Covers installation, network placement, agent enrollment, and
connected endpoint inventory.

---

## Context

- Proxmox cluster node: BooBoo
- Container IP: 10.12.50.20 | VLAN 50
- Wazuh version: 4.14.4
- Resources: Default (community helper script defaults)
- Deployed via Proxmox VE community helper script

---

## Objective

- Deploy a production-grade SIEM/XDR platform to centralize log collection and security
  monitoring across the homelab
- Enroll all active servers and workstations as monitored agents
- Establish a foundation for future detection engineering and alerting work

---

## Approach

- Deployed Wazuh all-in-one (manager + indexer + dashboard) using the community helper
  script for Proxmox LXC
- Assigned a static IP on the dedicated security VLAN (VLAN 50)
- Enrolled agents on both Windows and Debian endpoints using version-pinned install
  commands pointing to the Wazuh manager IP

---

## Analysis

**Installation command:**
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/wazuh.sh)"
```

**Agent enrollment — Windows:**
```powershell
Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.14.4-1.msi `
  -OutFile $env:tmp\wazuh-agent
msiexec.exe /i $env:tmp\wazuh-agent /q WAZUH_MANAGER='10.12.50.20'
NET START Wazuh
```

**Agent enrollment — Debian:**
```bash
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.4-1_amd64.deb && \
  WAZUH_MANAGER='10.12.50.20' dpkg -i ./wazuh-agent_4.14.4-1_amd64.deb
systemctl daemon-reload
systemctl enable wazuh-agent
systemctl start wazuh-agent
```

**Connected agents:**

| Group        | Hostname      |
|--------------|---------------|
| Servers      | Lucas         |
| Servers      | Angel         |
| Servers      | Boo           |
| Servers      | Lucky         |
| Workstations | WinDesk       |
| Workstations | DeMarzoINSP   |

---

## Outcome

- Wazuh manager, indexer, and dashboard deployed and operational on BooBoo
- Six agents enrolled and reporting across two agent groups (Servers, Workstations)
- Centralized visibility established across the full homelab endpoint inventory

---

## Key Takeaways

- Community helper script significantly reduces deployment complexity for an all-in-one
  Wazuh stack on Proxmox LXC
- Pinning agent version to match the manager (4.14.4) is critical to avoid compatibility
  issues
- Separating agents into logical groups (Servers vs. Workstations) from the start makes
  rule scoping and alerting cleaner as the deployment matures

---

## Notes

- Dashboard credentials are local lab credentials only — not exposed externally

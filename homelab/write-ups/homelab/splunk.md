# Splunk Enterprise SIEM Deployment
### Homelab Security Operations — Phase 3

---

## Overview

This document covers the end-to-end deployment of a Splunk Enterprise SIEM on a dedicated, network-isolated VM in my homelab. The goal was to mirror enterprise security architecture: isolated network segment, firewall-enforced access control, log ingestion from multiple sources, and infrastructure-as-code integration via Ansible.

**Deployment date:** March 2026  
**Splunk version:** 10.2.2

---

## Architecture

### Network Isolation

Splunk lives on a dedicated Security VLAN (VLAN 50, `10.12.50.0/24`), completely separate from the Management, Internal, and Lab VLANs. Access is enforced at the ER605 gateway with explicit ACL rules:

| Rule | Source | Destination | Port | Action |
|------|--------|-------------|------|--------|
| Log ingestion | All VLANs | 10.12.50.10 | 9997/TCP | Allow |
| Web UI | VLAN 5 (Management) only | 10.12.50.10 | 8000/TCP | Allow |
| All other inbound | Any | VLAN 50 | Any | Deny |

This ensures Universal Forwarders on any VLAN can ship logs, but the Splunk Web UI is only reachable from the Management VLAN — matching enterprise SOC access control practices.

### VM Specifications

| Parameter | Value |
|-----------|-------|
| Hypervisor | Proxmox VE on BooBoo (i7-8550U / 32GB RAM) |
| OS | Ubuntu 22.04 Server |
| VMID | 401 |
| vCPUs | 4 |
| RAM | 8GB |
| Disk | 80GB (local-zfs, VirtIO SCSI) |
| IP | 10.12.50.10 (static, VLAN 50) |
| Hostname | splunk |

---

## Index Configuration

Rather than a single catch-all index, logs are separated by OS and data type for cleaner searching, targeted retention policies, and role-based access alignment.

| Index | Data Source | Status |
|-------|-------------|--------|
| `net_flow` | Network flow telemetry (Omada SDN / NetFlow) | ✅ Active |
| `windows_sec` | Windows Security event logs | ✅ Active |
| `windows_sys` | Windows System event logs | ✅ Active |
| `windows_app` | Windows Application event logs | ✅ Active |
| `linux_sec` | Linux auth/security logs (`/var/log/auth.log`, `secure`) | ✅ Active |
| `linux_sys` | Linux system logs (`syslog`, `messages`) | ✅ Active |
| `linux_app` | Linux application logs | ✅ Active |
| `proxmox` | Proxmox VE node logs | ✅ Active |

All indexes were created via `Settings → Indexes → New Index` in Splunk Web. Receiver on port `9997` was enabled via `Settings → Forwarding and Receiving → Configure Receiving`.

---

## Splunk Enterprise Installation

Splunk Enterprise was installed manually from the official `.deb` package. Running Splunk as root is deprecated in 10.x, so a dedicated system user was created first.

```bash
# Download
wget -O /tmp/splunk.deb \
  "https://download.splunk.com/products/splunk/releases/10.2.2/linux/splunk-10.2.2-80b90d638de6-linux-amd64.deb"

# Install
sudo dpkg -i /tmp/splunk.deb

# Create dedicated service account
sudo useradd -m -r splunk
sudo chown -R splunk:splunk /opt/splunk

# Enable boot-start under splunk user, accept license, seed admin password
sudo /opt/splunk/bin/splunk enable boot-start -user splunk \
  --accept-license --answer-yes --seed-passwd '<your_password>'

# Start
sudo systemctl start splunk
```

---

## Universal Forwarder Deployment

Universal Forwarders are deployed on all nodes with `outputs.conf` pointing to `10.12.50.10:9997`. Each node's `inputs.conf` routes logs to the appropriate index based on source type.

### Proxmox Node Forwarding

All four Proxmox nodes (Lucas, Angel, BooBoo, Lucky) are configured with Universal Forwarders shipping to the `proxmox` index. Each node's `inputs.conf` targets Proxmox-specific log paths.

### rsyslog Requirement

Ubuntu/Debian 22.04+ ships with `journald` only — `/var/log/auth.log` and `/var/log/syslog` do not exist without `rsyslog`:

```bash
sudo apt install rsyslog -y && sudo systemctl enable rsyslog --now
```

---

## Verification

### Confirm Forwarder Connectivity (on source host)

```bash
sudo /opt/splunkforwarder/bin/splunk list forward-server
```

Expected output:
```
Active forwards:
    10.12.50.10:9997
Configured but inactive forwards:
    None
```

### Confirm Data per Index

```spl
index=proxmox | head 20
index=net_flow | head 20
index=windows_sec | head 20
index=linux_sec | head 20
```

First confirmed log sources: `ops` (10.12.5.20) shipping `/var/log/syslog` and `/var/log/auth.log`. Proxmox nodes, net_flow, and Windows indexes subsequently confirmed active.

---

## Lessons Learned

| Issue | Root Cause | Resolution |
|-------|-----------|------------|
| Splunk service failed to start | Splunk 10.x refuses to run as root | Created dedicated `splunk` system user |
| No logs appearing in index | `/var/log/auth.log` did not exist | Installed `rsyslog` on Debian/Ubuntu hosts |
| RPM downloaded instead of DEB | Wrong package selected from Splunk downloads | Used `-linux-amd64.deb` URL explicitly |

---

## Next Steps

- [ ] Windows Universal Forwarder + Sysmon (SwiftOnSecurity config)
- [ ] Security dashboard — failed logins, top event IDs, auth activity over time, top source IPs
- [ ] Retention policy configuration (`maxTotalDataSizeMB`, `frozenTimePeriodInSecs`) per index
- [ ] Wazuh → Splunk forwarding pipeline for correlated alert data
- [ ] HEC (HTTP Event Collector) for app-level log ingestion
- [ ] Onboard remaining homelab VMs via bootstrap playbook

---

## Infrastructure Reference

| Component | Detail |
|-----------|--------|
| Hypervisor | Proxmox VE — BooBoo node |
| Network | TP-Link ER605 + Omada SDN |
| Automation | Ansible from `ops` (10.12.5.20) |
| Security VLAN | VLAN 50 — 10.12.50.0/24 |
| Splunk UI | http://10.12.50.10:8000 (VLAN 5 access only) |
| Log ingestion port | 9997/TCP |

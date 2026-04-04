
# Splunk Enterprise SIEM Deployment
### Homelab Security Operations — Phase 3

---

## Overview

This document covers the end-to-end deployment of a Splunk Enterprise SIEM on a dedicated, network-isolated VM in my homelab. The goal was to mirror enterprise security architecture: isolated network segment, firewall-enforced access control, log ingestion from multiple sources, and infrastructure-as-code integration via Ansible.

**Index name:** `the_kennel`  
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

### Initial Configuration

After installation, the following were configured via Splunk Web (`http://10.12.50.10:8000`):

1. **Created index `the_kennel`** — `Settings → Indexes → New Index`
2. **Enabled receiver on port 9997** — `Settings → Forwarding and Receiving → Configure Receiving → New Receiving Port → 9997`

---

## Universal Forwarder Deployment

The Universal Forwarder deployment was integrated into the infrastructure bootstrap Ansible playbook, ensuring every VM provisioned into the homelab automatically ships logs to Splunk. This mirrors enterprise endpoint onboarding practices.

### Key design decisions

- A dedicated `splunkfwd` system user owns the forwarder process (no root execution)
- `rsyslog` is installed to ensure `/var/log/auth.log` and `/var/log/syslog` exist (Ubuntu/Debian 22.04+ uses `journald` only by default)
- UFW allows outbound 9997/TCP for log forwarding

### Bootstrap playbook tasks (Section 15)

```yaml
- name: 15a. Download Splunk Universal Forwarder
  get_url:
    url: "https://download.splunk.com/products/universalforwarder/releases/10.2.2/linux/splunkforwarder-10.2.2-80b90d638de6-linux-amd64.deb"
    dest: /tmp/splunkuf.deb

- name: 15b. Install Splunk Universal Forwarder
  apt:
    deb: /tmp/splunkuf.deb

- name: 15c. Create splunkfwd user
  user:
    name: splunkfwd
    system: yes
    shell: /bin/false
    create_home: no

- name: 15d. Set ownership
  file:
    path: /opt/splunkforwarder
    owner: splunkfwd
    group: splunkfwd
    recurse: yes

- name: 15e. Configure outputs to Splunk indexer
  copy:
    content: |
      [tcpout]
      defaultGroup = homelab_indexer

      [tcpout:homelab_indexer]
      server = 10.12.50.10:9997
    dest: /opt/splunkforwarder/etc/system/local/outputs.conf
    owner: splunkfwd
    group: splunkfwd

- name: 15f. Configure Linux log inputs
  copy:
    content: |
      [monitor:///var/log/auth.log]
      index = the_kennel
      sourcetype = linux_secure

      [monitor:///var/log/syslog]
      index = the_kennel
      sourcetype = syslog
    dest: /opt/splunkforwarder/etc/system/local/inputs.conf
    owner: splunkfwd
    group: splunkfwd

- name: 15g. Enable boot-start and start UF
  command: >
    /opt/splunkforwarder/bin/splunk enable boot-start
    -user splunkfwd --accept-license --answer-yes
    --seed-passwd '<your_password>'
  args:
    creates: /etc/init.d/SplunkForwarder

- name: 15h. Allow UF outbound in UFW
  ufw:
    rule: allow
    port: '9997'
    proto: tcp
    direction: out

- name: 15i. Start Splunk UF
  systemd:
    name: SplunkForwarder
    state: started
    enabled: yes
```

### rsyslog requirement

Ubuntu/Debian 22.04+ ships with `journald` only — `/var/log/auth.log` and `/var/log/syslog` do not exist without `rsyslog`. This was added to the bootstrap playbook core packages section:

```bash
sudo apt install rsyslog -y && sudo systemctl enable rsyslog --now
```

---

## Verification

### Confirm forwarder connectivity (on source host)

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

### Confirm data in Splunk

```spl
index=the_kennel | head 20
```

First confirmed log sources: `ops` (10.12.5.20) shipping `/var/log/syslog` and `/var/log/auth.log`.

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
- [ ] Windows Security / System / Application event log ingestion
- [ ] Security dashboard — failed logins, top event IDs, auth activity over time, top source IPs
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

# Prometheus Node Exporter — Cross-VLAN Scrape Failure
### Runbook | Infrastructure Troubleshooting | Homelab IaC

---

## Incident Summary

**Symptom:** Prometheus targets on VLAN 5 (`10.12.5.x:9100`) returning `context deadline exceeded` while scraping from Prometheus on VLAN 30 (`10.12.30.10`).  
**Root Cause:** Omada ACL source IP-Port group incorrectly restricting the **source port** to 9100, blocking Prometheus's ephemeral outbound connections.  
**Resolution:** Removed port restriction from the source group; port 9100 scoped to destination only.

---

## Environment

| Component | Detail |
|-----------|--------|
| Prometheus Host | `10.12.30.10` — VLAN 30 (Internal Services) |
| Target Node | `lucky` — `10.12.5.14` — VLAN 5 (Management) |
| Exporter | `node_exporter` v1.8.2 |
| Firewall | TP-Link ER605 via Omada SDN |
| ACL Type | LAN → LAN, Stateful |

---

## Troubleshooting Steps

### 1. Verify Exporter Service Status
```bash
systemctl status node_exporter
```
**Finding:** Service in `failed` state — `exit-code 1/FAILURE`

---

### 2. Run Binary Directly to Capture Errors
```bash
/usr/local/bin/node_exporter 2>&1 | head -20
```
**Finding:** Binary ran successfully — service was failing due to port 9100 already bound by a stale process.

---

### 3. Identify and Release Port Conflict
```bash
ss -tlnp | grep 9100
kill $(ss -tlnp | grep 9100 | awk '{print $6}' | grep -oP 'pid=\K[0-9]+')
systemctl start node_exporter
```
**Finding:** Port conflict cleared — exporter started cleanly.

---

### 4. Verify Cross-VLAN Reachability
```bash
curl http://10.12.5.14:9100/metrics
```
**Finding:** Request hung — not a firewall block (UFW inactive), pointing to ACL misconfiguration.

---

### 5. Identify ACL Misconfiguration

**Incorrect Configuration:**

| Field | Value |
|-------|-------|
| Source | IP-Port Group — `10.12.30.10` + ports `8000, 9090, 9100` |
| Destination | IP Group — Any |

**Problem:** The source IP-Port group restricted the **source port** to 9100. Prometheus initiates connections using a random ephemeral port (32768–60999), not port 9100. The firewall was dropping all outbound scrape requests before they reached the target.

**Correct Mental Model:**
```
Prometheus (10.12.30.10)
  └─ Initiates connection from ephemeral port ──► 10.12.5.14:9100
  └─ Stateful rule allows return traffic automatically
```

**Fix:** Remove port restriction from source group. Port 9100 belongs on the **destination** only.

| Field | Corrected Value |
|-------|----------------|
| Source | IP Group — `10.12.30.10` (no port) |
| Destination | IP-Port Group — `10.12.5.0/24` + port `9100` |

---

## Resolution Verified

Prometheus targets page (`http://10.12.30.10:9090/targets`) confirmed all VLAN 5 nodes returned to **UP** state after ACL correction.

---

## Key Takeaways

- `context deadline exceeded` in Prometheus = exporter reachable at the IP layer but not responding in time — start with port/process issues, then move to ACL
- Stateful firewalls handle return traffic automatically — source restrictions only apply to the **initiating** connection
- Source port ≠ destination port — Prometheus scrapes **to** port 9100; it originates **from** an ephemeral port
- Always scope port restrictions to the destination in monitoring ACL rules

---

## Node Exporter Install Reference

```bash
# Download
wget https://github.com/prometheus/node_exporter/releases/download/v1.8.2/node_exporter-1.8.2.linux-amd64.tar.gz

# Install
tar xvf node_exporter-1.8.2.linux-amd64.tar.gz
cp node_exporter-1.8.2.linux-amd64/node_exporter /usr/local/bin/

# Systemd unit
cat > /etc/systemd/system/node_exporter.service << EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload && systemctl enable --now node_exporter
```

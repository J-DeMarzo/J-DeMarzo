# Storage Configuration

> Hybrid ZFS + NFS + PBS architecture centralizing all backup, ISO, and template storage onto a 6TB DAS — protecting NVMe root drives across the entire cluster from exhaustion.

---

## 🏗️ Architecture Overview

| Role | Node | Storage |
|------|------|---------|
| **Primary Storage Host** | `lucky` | 2×6TB ZFS Mirror (DAS) |
| **Backup Server** | `lucky` (CT 501) | PBS via bind mount |
| **Client Nodes** | `lucas`, `angel`, `boo` | NVMe local-zfs + NFS |

---

## 💾 ZFS Pool Layout

**Pool:** `cenmate` — ZFS Mirror on two 6TB drives attached to `lucky`

| Dataset | Purpose |
|---------|---------|
| `cenmate/backups` | Dedicated to Proxmox Backup Server |
| `cenmate/shared-isos` | Cluster-wide ISOs |
| `cenmate/templates` |  Cluster-wide CT Templates |
| `cenmate/vm-disks` | Dedicated to HA disks for migrations |
---

## 🛡️ Proxmox Backup Server — Container Bind Mount

PBS runs inside LXC CT 501 on `lucky`. Rather than consuming the container's virtual disk, a bind mount punches through the container wall for direct raw access to the ZFS dataset.

```bash
# 1. Create the dataset
zfs create cenmate/backups

# 2. Bind mount into PBS container
pct set 501 -mp0 /cenmate/backups,mp=/cenmate-das

# 3. Fix permissions for the backup user
chown -R backup:backup /cenmate-das
```

> In the PBS GUI, the Datastore path is set to `/cenmate-das`.

---

## 🌐 Shared Cluster Storage — Hybrid Method

ISOs and CT Templates are centralized on `lucky`'s ZFS pool. A hybrid approach avoids routing `lucky`'s own traffic over the network to reach its own drives.

### Client Nodes — NFS

`lucas`, `angel`, and `boo` access shared storage over NFS.

`/etc/exports` on `lucky`:
```text
/cenmate/shared-isos 10.12.5.0/24(rw,sync,no_root_squash,no_subtree_check)
```
> `no_root_squash` is required to allow remote Proxmox nodes write access.

Added in Proxmox GUI as **NFS Storage**, scoped to client nodes only.

### Host Node — Local Directory Bypass

`lucky` bypasses NFS entirely, reading the same dataset at raw ZFS speeds.

Added in Proxmox GUI as **Directory Storage** pointing to `/cenmate/shared-isos`, scoped to `lucky` only.

---

## 🔒 Root Drive Guardrails

Prevents NVMe root drives from being consumed by rogue VM installs or accidental uploads.

| Node | Restriction |
|------|-------------|
| `lucky` | Default `local` storage **disabled** |
| `lucas`, `angel`, `boo` | `local` restricted to **Import** content only — disk images and containers forced to `local-zfs` |

---

## 🛠️ Troubleshooting — Ghost NFS Mounts

If the NFS server goes offline abruptly, client nodes can lock with `Resource busy` or `File exists` errors. Run this on the affected client node to force-clear stale mounts and reset the storage daemon:

```bash
#!/bin/bash
# Force-cleans stale NFS mount points causing "File exists" GUI errors

TARGETS=("/mnt/pve/ISO" "/mnt/pve/Templates" "/mnt/pve/HA-Disk")

for DIR in "${TARGETS[@]}"; do
    if [ -d "$DIR" ]; then
        echo "Force cleaning: $DIR"
        fuser -km "$DIR" 2>/dev/null       # Kill processes locking the directory
        umount -f -l "$DIR" 2>/dev/null    # Force lazy unmount
        rm -rf "$DIR"                      # Nuke the ghost directory
    fi
done

systemctl restart pvestatd
echo "Cleanup complete. Storage daemon restarted."
```

# Proxmox Cluster

## Overview
This document describes the Proxmox virtualization environment, including cluster configuration, node roles, storage design, networking, and workload placement.

The cluster is designed to support a mix of stable infrastructure, monitoring/security workloads, and isolated lab environments. It balances reliability with flexibility by separating core services from experimental systems while maintaining backup and redundancy through an external node.

---

## Cluster Summary

The Proxmox environment is configured as an active cluster consisting of three primary nodes, with an additional standalone system providing backup and auxiliary services.

**Cluster Nodes:**
- Lucas
- Angel
- BooBoo

**Supporting Node (Non-clustered):**
- Lucky

High Availability (HA) is enabled at the cluster level, but redundancy is currently achieved primarily through workload placement and external backup rather than automated failover.

---

## Node Specifications & Roles

| Node | IP Address | Role | Hardware |
|------|------------|------|----------|
| Lucas | 10.12.5.10 | Infrastructure | 32 GB RAM, 1 TB NVMe |
| Angel | 10.12.5.12 | Lab / Cyber Range | 32 GB RAM, 500 GB NVMe (ZFS) |
| BooBoo | 10.12.5.13 | Monitoring / Workloads | 32 GB RAM, 500 GB NVMe (ZFS) |
| Lucky | 10.12.5.14 | Backup / Filestore / Utility | Intel N150, 16 GB RAM, 500 GB NVMe |

---

## Node Role Design

### Lucas - Infrastructure Node
Lucas is the primary infrastructure host and is intended to run stable, always-on services.

**Workload focus:**
- DNS (primary instance)
- core internal services
- future reverse proxy
- infrastructure support services

**Design intent:**
- runs 24/7 workloads
- prioritized for stability over experimentation
- central point for critical services

---

### Angel - Lab / Cyber Range
Angel is dedicated to lab environments and isolated experimentation.

**Planned uses:**
- cyber range scenarios
- offensive/defensive simulations
- curated security tooling (e.g., Kali environment)
- temporary or high-risk workloads

**Design intent:**
- safe space for experimentation
- prevents lab activity from impacting infrastructure
- supports hands-on security practice

---

### BooBoo - Monitoring & Workload Node
BooBoo is intended to host monitoring, security, and persistent workload VMs.

**Planned uses:**
- monitoring stack
- SIEM components
- logging infrastructure
- persistent Linux/Windows VMs (including potential VDI-style systems)

**Design intent:**
- centralize observability and security tooling
- support always-on workloads that are not core infrastructure
- act as a bridge between infrastructure and security visibility

---

### Lucky - Backup / Utility Node (Non-Clustered)
Lucky operates outside the Proxmox cluster and provides redundancy and support services.

**Current and planned roles:**
- Proxmox Backup Server (PBS)
- file storage
- administrative services
- redundant DNS instance
- secondary infrastructure support

**Design intent:**
- provides resilience outside the cluster
- avoids shared failure domains
- supports backup and recovery operations

---

## Storage Architecture

### Node Storage

- **Lucas**
  - 1 TB NVMe (local storage)

- **Angel**
  - 500 GB NVMe
  - local ZFS

- **BooBoo**
  - 500 GB NVMe
  - local ZFS

- **Lucky**
  - 500 GB NVMe
  - external storage attached via NAS

---

### Backup Storage (PBS)

Lucky hosts a mirrored ZFS storage pool backed by:
- **2 × 6 TB 7200 RPM HDDs**
- configured in **ZFS mirror**

**Backup configuration:**
- Weekly backup schedule
- Runs at **Sunday 01:00**

**Scope:**
- Currently backing up all VMs

---

### Storage Design Notes

- No shared cluster storage (e.g., Ceph) is in use
- Storage is node-local for performance and simplicity
- Backup and redundancy are handled externally via PBS on Lucky
- ZFS is used for reliability and data integrity on applicable nodes

---

## Networking Model

### Bridge Configuration

Each Proxmox node uses a single primary bridge:

- **vmbr0**

Configuration model:
- Untagged traffic → **VLAN 5 (Management)**
- VLAN tagging handled per VM using vmbr0

### VLAN Integration

VLANs are passed to VMs by tagging on the Proxmox side.

Example:
- VM on VLAN 10 → tag 10 on vmbr0
- VM on VLAN 30 → tag 30 on vmbr0

This allows:
- a single trunk connection from the switch
- flexible per-VM network assignment
- alignment with the broader VLAN segmentation design

---

## Workload Placement Strategy

The cluster uses intentional workload placement based on role and stability requirements.

### Current / Planned Distribution

| Function | Node |
|----------|------|
| DNS (Primary) | Lucas |
| DNS (Secondary) | Lucky |
| Monitoring / SIEM | BooBoo (planned) |
| Persistent Workloads / VDI | BooBoo (planned) |
| Lab / Cyber Range | Angel |
| Backup (PBS) | Lucky |

---

### Placement Philosophy

- **Infrastructure workloads** → Lucas  
- **Monitoring and persistent systems** → BooBoo  
- **Lab and experimental systems** → Angel  
- **Backup and redundancy** → Lucky  

This approach:
- reduces interference between workloads
- improves troubleshooting clarity
- mirrors real-world separation of duties

---

## High Availability (HA)

Proxmox HA is enabled at the cluster level but is not currently used for active failover.

### Current Model
- HA configured but not actively leveraged
- redundancy handled via:
  - workload separation
  - external backup (Lucky)

---

## Access Model

### Current
- Proxmox management is accessed via **VLAN 5 (Management)**
- Administrative access is performed from trusted systems only

### Planned
- VPN access will be introduced to enable secure remote administration
- VPN will likely terminate on the network edge (router) or a dedicated service

---

## Automation

Automation tooling is planned but currently paused.

### Planned Integration
- **Ansible**
  - configuration management
  - service deployment

- **Terraform**
  - infrastructure provisioning
  - VM lifecycle management

These tools will be reintroduced to:
- standardize deployments
- reduce manual configuration
- support repeatable infrastructure builds

---

## Design Decisions

### Externalized Backup
Using Lucky as a non-clustered backup node:
- reduces shared risk
- provides isolation from cluster failures
- simplifies recovery scenarios

### Role-Based Node Separation
Each node has a defined purpose:
- improves operational clarity
- reduces cross-impact of failures
- aligns with enterprise-style architecture patterns

---

## Future Enhancements

- Reverse proxy deployment (NGINX or similar)
- SIEM and centralized logging rollout on BooBoo
- VPN deployment for secure remote access
- Expansion of automation (Ansible / Terraform)
- More granular HA utilization if needed
- Improved monitoring and alerting coverage

---

## Summary

The Proxmox cluster is structured to provide a stable, segmented, and extensible virtualization platform. It combines:

- a defined cluster core (Lucas, Angel, BooBoo)
- external redundancy and backup (Lucky)
- VLAN-integrated networking
- role-based workload separation

This design supports both immediate infrastructure needs and future expansion into monitoring, security, automation, and advanced lab scenarios.

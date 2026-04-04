# Homelab | Infrastructure & Network Design

## Overview
This section documents the design, deployment, and ongoing evolution of my homelab environment. The lab is built to simulate real-world enterprise infrastructure, with a focus on networking, system administration, automation, and security.

The goal of this environment is to:
- Build practical, hands-on experience with production-like systems
- Test and validate infrastructure changes safely
- Develop repeatable deployment and troubleshooting workflows
- Support security-focused projects such as logging, monitoring, and SIEM integration

---

## Architecture Summary

The homelab is centered around a segmented network design with virtualization and centralized services.

**Core Components:**
- Proxmox virtualization cluster (multi-node)
- VLAN-based network segmentation
- Centralized DNS and internal domain management
- Layered network infrastructure using Omada ecosystem
- Dedicated management and services networks

---

## Network Design

The network is segmented using VLANs to isolate traffic and enforce security boundaries.

**Key Concepts:**
- Separation of management, client, IoT, and service networks
- Controlled inter-VLAN communication using firewall rules
- Trunked connections between switching and virtualization layers

Detailed design:
- [VLAN Design](./network/vlan-design.md)
- [Firewall Rules & ACLs](./network/firewall-rules.md)
- [Omada Configuration](./network/omada-config.md)

---

## Infrastructure

The lab infrastructure is built on Proxmox and supports virtual machines and containerized services.

**Capabilities:**
- Multi-node virtualization cluster
- Segmented networking across virtual bridges
- Centralized service hosting (DNS, future SIEM, reverse proxy)
- Planned backup and storage segmentation

Documentation:
- [Proxmox Cluster](./infrastructure/proxmox-cluster.md)
- [Storage & Backup Strategy](./infrastructure/storage-backup.md)

---

## Core Services

### DNS (Technitium)
- Dual-instance DNS deployment for redundancy
- Internal zone: `int.demarzo.dev`
- Ad-blocking and internal name resolution
- Replaced previous Pi-hole + Unbound setup

See:
- [Technitium DNS Deployment](./infrastructure/dns-technitium.md)

---

## Automation (External Repositories)

Infrastructure automation is managed separately to maintain clean version control and modularity.

- Ansible (configuration management)
- Terraform (infrastructure provisioning)

These are maintained in dedicated repositories and linked from the main portfolio.

---

## Security Approach

Security is integrated into the lab design rather than added later.

**Current Focus Areas:**
- Network segmentation and access control
- Controlled inter-VLAN traffic
- Preparation for centralized logging and SIEM ingestion
- Service isolation and least-privilege design

---

## Diagrams

Network and system diagrams are stored here:

- `/homelab/diagrams/`

These include:
- Network topology
- VLAN layout
- Service architecture

---

## Current Focus

- Stabilizing reverse proxy layer for internal services
- Preparing SIEM deployment pipeline
- Expanding infrastructure automation (Ansible / Terraform)
- Refining firewall rules and inter-VLAN policies

---

## Future Enhancements

- SIEM deployment and log aggregation
- Endpoint monitoring and alerting
- Infrastructure as Code expansion
- Automated provisioning workflows
- Advanced network security controls

---

## Notes

This homelab is continuously evolving. Documentation reflects active development and iterative improvements as new technologies and practices are implemented.

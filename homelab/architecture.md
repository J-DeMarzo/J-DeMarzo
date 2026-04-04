# Homelab Architecture

## Overview
This document provides a high-level view of the current homelab architecture, including the core infrastructure, network segmentation model, node roles, and planned expansion areas.

The environment is designed to support hands-on development in systems administration, networking, infrastructure design, automation, and security engineering. It is structured to balance day-to-day infrastructure needs with isolated lab space for testing, experimentation, and future security-focused projects.

---

## Design Goals

Kell's Kennel 2.0 is built around the following objectives:

- Maintain stable core infrastructure for administration and shared services
- Separate production-like services from testing and isolated lab workloads
- Use VLAN segmentation to improve organization and security boundaries
- Support virtualization, monitoring, logging, and SIEM integration
- Create a repeatable platform for learning and documenting real-world operational practices
- Preserve redundancy where practical for DNS, backups, and administrative services

---

## Core Infrastructure

### Network Stack
The network is built on the TP-Link Omada platform and provides centralized management, routing, switching, and wireless access.

**Core components:**
- **OC200** - Omada hardware controller
- **ER605 v2** - Router / gateway
- **SG2008P** - Managed PoE switch
- **EAP610** - Wireless access point

This stack provides the base for VLAN segmentation, centralized network management, and future policy enforcement across lab and service networks.

---

## Virtualization & Compute Layer

The compute environment is centered on multiple Proxmox hosts with role-based separation across infrastructure, lab, monitoring, and backup functions.

### Node Summary

| Node | Management IP | Primary Role | Hardware Summary |
|------|---------------|--------------|------------------|
| Lucas | 10.12.5.10 | Infrastructure | 32 GB RAM, 1 TB NVMe |
| Angel | 10.12.5.12 | Lab / Isolation | 32 GB RAM, 500 GB NVMe, local ZFS |
| BooBoo | 10.12.5.13 | Monitoring / VM workloads | 32 GB RAM, 500 GB NVMe, local ZFS |
| Lucky | 10.12.5.14 | PBS / Filestore / redundant infrastructure | Intel N150, 16 GB RAM, 500 GB NVMe |

### Role Allocation

#### Lucas - Infrastructure
Lucas serves as the primary infrastructure-oriented node. It is intended to host stable internal services and core platform components that support the rest of the environment.

Examples of suitable workloads include:
- DNS services
- reverse proxy
- management utilities
- shared internal service infrastructure

Lucas has the largest local storage footprint and is positioned as a stable base for central services.

#### Angel - Lab / Isolation
Angel is designated for lab and isolated workloads. This supports testing, experimentation, and potentially unsafe or disruptive changes without directly impacting core infrastructure.

This node is best suited for:
- temporary lab VMs
- attack/defense simulations
- test deployments
- isolated service validation

#### BooBoo - Monitoring / VM Workloads
BooBoo is intended to support monitoring-focused services and general VM workloads. This makes it a strong candidate for logging, metrics, dashboards, and security visibility tooling as the lab matures.

Network workloads include:
- monitoring platforms
- log aggregation
- SIEM preparation
- supporting VMs
  
#### Lucky - PBS / Filestore / Redundant Infrastructure
Lucky serves a utility and resilience role in the environment. It is intended to support backup, shared storage, administrative support functions, and other secondary infrastructure tasks.

Workloads include:
- Proxmox Backup Server (PBS)
- NFS file storage
- Connected 6 TB DAS
- redundant service placement where needed

---

## Network Segmentation Model

The network uses a segmented VLAN architecture based on the **10.12.\<subnet\>.0/24** pattern.

### VLAN List

| VLAN ID | Name | Subnet |
|--------:|------|--------|
| 5 | Management | 10.12.5.0/24 |
| 10 | Internal | 10.12.10.0/24 |
| 20 | IoT | 10.12.20.0/24 |
| 30 | Internal Services | 10.12.30.0/24 |
| 35 | DMZ | 10.12.35.0/24 |
| 40 | Lab | 10.12.40.0/24 |
| 45 | ISO Lab | 10.12.45.0/24 |
| 50 | Security | 10.12.50.0/24 |

### VLAN Purpose

#### VLAN 5 - Management
The management network is the administrative backbone of the environment.

- network infrastructure management interfaces
- hypervisor management interfaces
- controller access
- administrative systems

This is the primary network used for infrastructure control and device administration.

#### VLAN 10 - Internal
Trusted internal client systems and day-to-day internal network use. (home / lab separation)

#### VLAN 20 - IoT
IoT and lower-trust devices.

It exists to keep IoT traffic separated from internal and management systems and to reduce unnecessary exposure between device classes.

#### VLAN 30 - Internal Services
This network is intended for internal service hosting.

Examples include:
- vs code server
- reverse proxy
- internal application hosting
- shared utility services

This VLAN provides a cleaner separation between user/client systems and backend services.

#### VLAN 35 - DMZ
Externally exposed or semi-exposed services that require tighter control than internal services.

This segment supports:
- reverse proxy placement
- internet-facing test services
- controlled ingress paths into the environment

Traffic between DMZ and internal networks are tightly controlled via ACL and firewalls.

#### VLAN 40 - Lab
General lab experimentation and non-production test workloads.

It is used for:
- proof-of-concept deployments
- software testing
- temporary experiments
- general technical validation

#### VLAN 45 - ISO Lab
Intended for more isolated lab scenarios where additional separation is required.

It is useful for:
- higher-risk testing
- sandboxed experiments
- offensive security practice
- deliberately contained workloads

#### VLAN 50 - Security
This network is intended for security tooling and visibility-focused services.

Potential uses include:
- monitoring infrastructure
- centralized logging
- SIEM components
- security utilities and dashboards

As the lab evolves, this VLAN is expected to become more important for monitoring and detection workflows.

---

## Service Placement Strategy

The architecture uses logical placement of services based on trust level, stability requirements, and operational role.

### Current Placement Approach
- **Core infrastructure services** are intended to stay close to Lucas and the stable infrastructure layer
- **Lab and experimental workloads** belong primarily on Angel
- **Monitoring and visibility services** align with BooBoo and VLAN 50
- **Backup, file services, and redundant utility functions** align with Lucky

### Practical Benefits
- Reduces risk of test workloads interfering with infrastructure services
- Makes troubleshooting easier by separating stable and experimental systems
- Supports future documentation and project write-ups with clearer boundaries
- Creates a more realistic operational model for infrastructure and security-focused learning

---

## Security Design Principles

Security is built into the layout of the environment through segmentation, role separation, and service placement.

### Core Principles
- Separate management traffic from user and service traffic
- Keep IoT devices isolated from internal trusted systems
- Distinguish internal services from externally exposed services
- Maintain dedicated lab and isolated lab networks for testing
- Reserve a security-focused segment for logging, monitoring, and detection tooling
- Use role-based workload placement to reduce unnecessary cross-dependencies

### Expected Control Areas
As the environment continues to develop, the following control areas are expected to expand:
- inter-VLAN firewall policy refinement
- DMZ access restrictions
- logging and monitoring coverage
- service hardening
- backup validation and recovery testing

---

## Current State vs Planned Expansion

### Current State
The current architecture already establishes:
- a defined VLAN model
- role-based node placement
- centralized network management through Omada
- a Proxmox-based compute layer
- internal administrative structure around VLAN 5
- a platform suitable for stable internal services and segmented lab work

### Planned Expansion
The following areas are planned or expected to expand over time:
- reverse proxy deployment for service access and stability
- centralized logging pipeline
- SIEM-oriented service deployment
- expanded automation through Ansible and Terraform
- backup maturity using PBS on Lucky
- more formalized service placement across Internal Services, DMZ, and Security VLANs
- refinement of ACLs and traffic rules between all VLANs

---

## Operational Notes

This architecture is intentionally designed to evolve incrementally. Stable infrastructure and management functions are separated from lab and isolated environments so that testing can continue without undermining the reliability of the core platform.

The current design supports both immediate operational needs and future portfolio projects, including:
- infrastructure documentation
- automation workflows
- security monitoring projects
- segmented network testing
- production-style write-ups and incident simulations

---

## Summary

The homelab is built as a segmented, role-based environment that supports infrastructure learning, service hosting, automation, and future security engineering work. It combines a practical Omada-based network stack with Proxmox-hosted compute resources and clear functional separation across nodes and VLANs.

In its current form, the architecture provides:
- a stable management and infrastructure base
- dedicated space for lab and isolated experimentation
- a clear path toward monitoring, backup, and security tooling
- a strong foundation for continued technical growth and portfolio development

# VLAN Design

## Overview
This document defines the VLAN structure used in my homelab environment. The design is intended to separate home, management, trusted internal systems, untrusted devices, services, lab workloads, and security tooling into distinct network segments.

The overall goal is to improve organization, reduce unnecessary trust relationships, and create a cleaner foundation for administration, troubleshooting, monitoring, and future security controls.

All VLANs follow the addressing pattern:

`10.12.<vlan>.0/24`

Gateway addresses are assigned as `.1` for each subnet.

---

## Design Objectives

The VLAN model is built around a few core principles:

- Keep infrastructure management separated from normal client traffic
- Separate trusted internal systems from IoT and lower-trust devices
- Isolate internal services from user endpoints where practical
- Maintain dedicated lab space for testing and experimentation
- Preserve a fully isolated environment for higher-risk lab use
- Reserve a dedicated security segment for monitoring, logging, and SIEM-related services
- Reduce unnecessary inter-VLAN communication and allow it only where operationally required

---

## VLAN Summary

| VLAN ID | Name | Subnet | Gateway | Addressing Model | Primary Purpose |
|--------:|------|--------|---------|------------------|-----------------|
| 5 | Management | 10.12.5.0/24 | 10.12.5.1 | Static | Infrastructure and administrative management |
| 10 | Internal | 10.12.10.0/24 | 10.12.10.1 | DHCP | Trusted internal client devices |
| 20 | IoT | 10.12.20.0/24 | 10.12.20.1 | DHCP | Untrusted or lower-trust IoT devices |
| 30 | Internal Services | 10.12.30.0/24 | 10.12.30.1 | Static | Core internal services |
| 35 | DMZ | 10.12.35.0/24 | 10.12.35.1 | Static | Proxy and externally facing service layer |
| 40 | Lab | 10.12.40.0/24 | 10.12.40.1 | DHCP | General lab and testing workloads |
| 45 | ISO Lab | 10.12.45.0/24 | 10.12.45.1 | Static | Fully isolated lab environment |
| 50 | Security | 10.12.50.0/24 | 10.12.50.1 | Static | Monitoring, logging, and security tooling |

---

## VLAN Details

### VLAN 5 - Management
**Subnet:** `10.12.5.0/24`  
**Gateway:** `10.12.5.1`  
**Addressing:** Static

This VLAN is reserved for infrastructure administration and management access. It is the most trusted operational network in the environment and should only contain systems used for control, administration, and device management.

Systems on this VLAN include:
- router and switch management interfaces
  - Omada Controller   - '10.12.5.2'
- hypervisor management interfaces
  - Lucas              - `10.12.5.10`
  - Angel              - `10.12.5.12`
  - BooBoo             - `10.12.5.13`
  - Lucky              - `10.12.5.14`
  - DNS Servers
    - dns1/2           - '10.12.5.5/6'-   
- administrative workstation(s)
  - admin workstation  - `10.12.5.20`

**Design intent:**
- accessible only from approved administrative systems
- permitted to reach other VLANs for management purposes
- not used for general application or user traffic

---

### VLAN 10 - Internal
**Subnet:** `10.12.10.0/24`  
**Gateway:** `10.12.10.1`  
**Addressing:** DHCP

This is the trusted internal user/device network. It is intended for general-purpose devices that are considered part of the normal internal environment.

Typical devices:
- user workstations
- laptops
- phones and tablets that are trusted
- other day-to-day internal endpoints

Wireless mapping:
- **SSID:** `Kell's Kennel`
- **Purpose:** trusted general devices

**Design intent:**
- full internet access
- access to internal services as needed
- no direct administrative role

---

### VLAN 20 - IoT
**Subnet:** `10.12.20.0/24`  
**Gateway:** `10.12.20.1`  
**Addressing:** DHCP

This VLAN is intended for lower-trust or untrusted smart devices and appliances. These systems are separated from the trusted internal network to reduce risk and unnecessary east-west visibility.

Typical devices:
- smart home devices
- appliances
- streaming devices
- lower-trust wireless endpoints

Wireless mapping:
- **SSID:** `Kell's Kennel IoT`
- **Purpose:** untrusted IoT devices

**Design intent:**
- internet access allowed
- no access to internal or management networks
- tightly limited access to internal services only when required

---

### VLAN 30 - Internal Services
**Subnet:** `10.12.30.0/24`  
**Gateway:** `10.12.30.1`  
**Addressing:** Static

This VLAN is intended for core internal service hosting. It provides separation between user endpoints and backend infrastructure services.

Examples of appropriate services:
- reverse proxy backends
- internal web applications
- utility services
- infrastructure support services

---

### VLAN 35 - DMZ
**Subnet:** `10.12.35.0/24`  
**Gateway:** `10.12.35.1`  
**Addressing:** Static

This VLAN is reserved for proxying and externally oriented services. It is currently empty, but the intended model is to place NGINX or a similar reverse proxy in this segment to broker access to internal services while reducing unnecessary cross-VLAN exposure.

Planned uses:
- reverse proxy
- externally published service entry points
- controlled ingress layer for services that need exposure

---

### VLAN 40 - Lab
**Subnet:** `10.12.40.0/24`  
**Gateway:** `10.12.40.1`  
**Addressing:** DHCP

This VLAN is intended for general lab activity, experimentation, and proof-of-concept work. It provides flexibility for testing without mixing those workloads into the production-like internal or service networks.

Examples of use:
- temporary VMs
- new services under evaluation
- configuration testing
- general technical experiments

---

### VLAN 45 - ISO Lab
**Subnet:** `10.12.45.0/24`  
**Gateway:** `10.12.45.1`  
**Addressing:** Static

This is the fully isolated lab segment. It is reserved for workloads that should have no connectivity to the rest of the environment.

Examples of use:
- sandboxed testing
- malware-safe simulations
- offensive practice labs
- high-risk experiments
- validation of containment controls

This is the most restricted network in the environment.

---

### VLAN 50 - Security
**Subnet:** `10.12.50.0/24`  
**Gateway:** `10.12.50.1`  
**Addressing:** Static

This VLAN is reserved for security and monitoring infrastructure. It is intended to centralize telemetry, visibility, and security-focused tooling so that those systems are logically separated from ordinary clients and general service hosting.

Appropriate workloads include:
- syslog collectors
- monitoring servers
- dashboards
- SIEM components
- IDS/IPS management interfaces
- vulnerability management tools
- security administration utilities

---

## DHCP Strategy

The following VLANs use DHCP:
- VLAN 10 - Internal
- VLAN 20 - IoT
- VLAN 40 - Lab

The following VLANs are statically assigned:
- VLAN 5 - Management
- VLAN 30 - Internal Services
- VLAN 35 - DMZ
- VLAN 45 - ISO Lab
- VLAN 50 - Security

This model keeps dynamic addressing for user and flexible test networks while preserving predictable addressing for infrastructure and service-oriented segments.

---

## Wireless Mapping

| SSID | VLAN | Trust Level | Purpose |
|------|------|-------------|---------|
| Kell's Kennel | 10 | Trusted | General internal wireless devices |
| Kell's Kennel IoT | 20 | Untrusted | IoT and lower-trust wireless devices |

This mapping keeps trusted internal devices separate from IoT systems and aligns wireless access with the broader VLAN design.

---

## Trunking / Tagging Notes

Within Omada, the **PVID is the untagged VLAN** on a trunk port.

Current design note:
- trunk ports use the required tagged VLANs for downstream devices
- the untagged/native behavior follows the configured PVID in Omada
- management and infrastructure connectivity should be documented carefully to avoid accidental lockout during changes

---

## Inter-VLAN Policy Model

The environment is intended to follow a least-privilege approach. Rather than broadly allowing east-west traffic, communication between VLANs should be explicitly approved based on function.

### Recommended Access Model

#### VLAN 5 - Management
Should be allowed to access other VLANs as needed for:
- administration
- device management
- hypervisor access
- service maintenance

This should be the primary operational network for control traffic.

#### VLAN 10 - Internal
Should generally be allowed to:
- reach the internet
- access required services on VLAN 30
- access selected dashboards or tools on VLAN 50 if appropriate

Should not have unrestricted access to:
- management interfaces
- lab networks
- DMZ systems beyond intended service paths

#### VLAN 20 - IoT
Should generally be limited to:
- internet access
- DNS
- DHCP
- NTP
- specific internal services only if required

Should not have general access to:
- VLAN 5
- VLAN 10
- VLAN 30
- VLAN 50

#### VLAN 30 - Internal Services
Should accept traffic from:
- VLAN 5 for management
- VLAN 10 for approved internal service use
- VLAN 50 where monitoring or logging requires it
- VLAN 35 only for explicitly defined proxy/service paths

Should not broadly initiate access into user or IoT networks.

#### VLAN 35 - DMZ
Should be tightly restricted and only permitted to:
- accept defined ingress
- forward specific proxy requests to approved destinations in VLAN 30
- reach management only where absolutely required for administration

This VLAN should not become a transit path for broad internal access.

#### VLAN 40 - Lab
Should be allowed:
- internet access
- optionally limited access to specific internal services when needed for testing

Should not be granted broad access to management or security systems.

#### VLAN 45 - ISO Lab
Should have:
- no internet
- no inter-VLAN access

This isolation should be enforced explicitly, not assumed.

#### VLAN 50 - Security
Should be allowed carefully scoped access to:
- infrastructure and services for monitoring
- logging destinations
- dashboards and collectors
- approved telemetry ports across other VLANs

This is the one segment where cross-VLAN access is expected, but it should still be explicit and minimal.

---

## High-Level Access Pattern

| Source VLAN | Destination VLAN | Desired State |
|-------------|------------------|---------------------|
| 5 Management | All relevant VLANs | Allow as needed for administration |
| 10 Internal | 30 Internal Services | Allow required services |
| 10 Internal | 50 Security | Allow selected dashboards/tools |
| 20 IoT | Internet only + required service exceptions | Restrict |
| 30 Internal Services | 10 Internal | Limited, service-driven only |
| 35 DMZ | 30 Internal Services | Allow only defined proxy/backend paths |
| 40 Lab | Internet + limited test paths | Restrict |
| 45 ISO Lab | Any | Deny |
| 50 Security | Multiple VLANs | Allow only defined monitoring/security flows |

---

## Operational Notes

This VLAN design is intended to support both stable infrastructure and future security expansion. The segmentation model provides room for:
- monitoring rollout
- SIEM deployment
- reverse proxy architecture
- lab experimentation
- isolated testing
- tighter policy enforcement over time

As additional monitoring and security services come online, VLAN 50 should become the central home for those platforms while rule sets are refined around explicit operational need.

---

## Summary

The VLAN architecture is designed around trust separation, operational clarity, and future growth. Each segment has a defined purpose and should remain aligned with that purpose as the lab expands.

This design provides:
- a protected management backbone
- a trusted internal client network
- an isolated IoT segment
- dedicated service hosting space
- a future DMZ proxy layer
- flexible lab space
- a fully isolated sandbox
- a dedicated security and monitoring network

The result is a cleaner, more defensible, and more scalable network foundation for continued homelab development.

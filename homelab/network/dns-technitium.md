# Technitium DNS Deployment

## Overview
This project implements a dual-instance DNS architecture using Technitium DNS to replace a previous Pi-hole + Unbound setup. The goal is to provide reliable internal name resolution, ad-blocking, and centralized DNS management across multiple VLANs.

This deployment is being rebuilt using Infrastructure as Code (Terraform + Ansible) to ensure repeatability and consistency.

---

## Objective

- Replace Pi-hole with a more flexible DNS solution
- Implement redundant DNS servers
- Support internal domain resolution (`int.demarzo.dev`)
- Provide ad-blocking across multiple VLANs
- Prepare DNS for integration with future monitoring and SIEM tooling
- Automate deployment using Terraform and Ansible

---

## Environment

**Platform:**
- Proxmox virtualization

**Nodes:**
- Primary DNS: Lucas (VLAN 5)
- Secondary DNS: Lucky (redundant)

**Network:**
- Multi-VLAN environment (10.12.x.0/24)
- DNS used across:
  - Internal (VLAN 10)
  - IoT (VLAN 20)
  - Lab (VLAN 40)
  - Services (VLAN 30)

---

## Architecture / Design

- Two Technitium DNS instances deployed on separate hosts
- Internal DNS zone:
  - `int.demarzo.dev`
- DNS configured for:
  - internal name resolution
  - upstream recursive resolution
  - ad-blocking via blocklists
- Clients configured via DHCP to use DNS servers

**Design Goals:**
- eliminate single point of failure
- centralize DNS management
- support internal service discovery
- reduce external DNS dependency where possible

---

## DNS Design

### Internal Zone
- `int.demarzo.dev`

---

## Redundancy Strategy

- Primary DNS hosted on Lucas
- Secondary DNS hosted on Lucky
- Clients configured with both DNS servers
- Failure of one node does not disrupt name resolution

---

## Security Considerations

- Restrict DNS access to internal VLANs only
- Prevent DNS from being exposed externally
- Monitor DNS logs for unusual activity

---

## Results

- Stable internal DNS resolution
- Redundant DNS infrastructure
- Reduced dependency on external DNS services
- Improved control over internal naming and traffic

---

## Lessons Learned

- DNS design considerations in segmented networks
- Service placement across VLANs
- Operational challenges and fixes

---

## Future Improvements

- Automate DNS record management
- Integrate DNS logs into SIEM
- Add monitoring and alerting
- Expand internal service discovery
- Implement DNS health checks

---

## Notes

This write-up will be updated during and after the Infrastructure as Code rebuild to reflect actual implementation details, challenges, and final configuration.

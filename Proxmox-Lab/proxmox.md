# Proxmox Homelab | Virtual Infrastructure & Systems Administration Portfolio

> A production-minded homelab built to practice and document virtualization, Linux administration, DHCP & DNS services, network design, storage, automation, and observability.

## Project Goals

My primary goal was to expand my knowledge and skills in production system and network administration. I achieved this by self-hosting applications and services using a production environment I built from scratch for real users (my family and myself) to incorporate real stakeholders, data, and requirements into the project.

This repository documents an evolving Proxmox-based infrastructure environment designed around the same operational concerns found in small and mid-sized enterprise IT: service reliability, identity management, repeatable deployments, storage planning, automated backups, monitoring, and recoverable configuration.

## Skills Demonstrated

| Area | Technologies & Practices |
| --- | --- |
| Virtualization | Proxmox VE, KVM virtual machines, LXC containers, Linux and  guest administration |
| Linux administration | Ubuntu Server, Debian/Proxmox, Netplan, systemd, BIND9, DHCP, SSH, package/repository management |
| Networking | VLAN design, Linux bridges, static addressing, DHCP reservations, DNS zones, reverse DNS, DMZ planning |
| Storage | NVMe/SSD/HDD tiering, ZFS-oriented storage planning, VM/container storage, backup-oriented capacity design |
| Monitoring & logging | Grafana, SNMP/syslog collection, OpenTelemetry-oriented telemetry pipelines |
| Automation | build scripts, configuration documentation, repeatable build procedures |
| Security | Segmented networks, least-privilege permissions, firewall/DMZ planning, VPN isolation, GPU/IOMMU configuration research |
| Documentation | Markdown runbooks, configuration examples, IP address management, implementation checklists, validation commands |

## Environment Overview

The lab centers on a Proxmox VE host that runs infrastructure services and application workloads as virtual machines and LXC containers. A dedicated Ubuntu Server thin client provides foundational network services including DHCP and authoritative internal DNS, while a managed Brocade switch supports the physical network design.

```text
                    Internet / ISP Gateway
                             |
                    VLAN-aware LAN switching
                             |
          +------------------+------------------+
          |                                     |
  Ubuntu Infrastructure Node              Proxmox VE Host
  - DHCP                                 - KVM virtual machines
  - BIND9 DNS                            - LXC containers
  - Grafana                              - Storage tiers
  - Firewall / DMZ                       - Application services
```

### Core Infrastructure

- **Proxmox VE host:** KVM and LXC virtualization platform for Linux and  workloads.
- **Ubuntu Server infrastructure node:** Static network configuration, ISC DHCP, BIND9 DNS, Headscale exit node for Tailscale, and Grafana.
- **Managed switching:** Brocade ICX switch used for LAN organization, VLAN design, and out-of-band management.
- **Virtual workloads:** Nextcloud, Jellyfin, Immich, and a VDI/LXC-oriented server workload.

## Architecture Decisions

### Virtualization Strategy

I use both VMs and containers based on workload requirements:

- **KVM VMs** support Server labs, full operating-system isolation, and workloads requiring dedicated kernels or broader compatibility.
- **LXC containers** provide a lightweight option for Linux application services such as media hosting.
- **Linux bridges** connect guests to the appropriate network while preserving flexibility for future segmentation and VLAN-aware designs.
- The environment includes planning and documentation for **IOMMU/GPU passthrough** to support hardware-accelerated workloads such as media transcoding.

### Storage Design

The Proxmox host uses multiple storage tiers to balance performance, capacity, and recoverability:

| Storage tier | Intended role |
| --- | --- |
| NVMe storage | Proxmox operating system, primary VM disks, and container workloads |
| SATA SSD storage | Additional VM disks and high-I/O cache/transcoding use cases |
| HDD storage | Bulk media, mass storage, and backup-oriented capacity |

Storage planning includes ZFS pool and dataset workflows, mount-point validation, and Proxmox storage configuration management.

### Network Design

The network is documented with an address-allocation plan for workstations, infrastructure servers, virtual workloads, network appliances, printers, signage clients, and guest devices.

Key practices include:

- Reserved address ranges by device role to simplify troubleshooting and growth.
- Static addressing and DHCP reservations for infrastructure services.
- Internal DNS forward and reverse lookup planning.
- VLAN separation between lab/server workloads and DMZ-oriented workloads.
- A planned Ubuntu-based firewall/DMZ role rather than reliance on a secondary consumer router and double NAT.

## Implemented Services

### Linux Infrastructure Services

- Configured persistent static networking with **Netplan** and cloud-init network configuration controls.
- Deployed **ISC DHCP Server** for managed address leases and network-option delivery.
- Deployed **BIND9** for internal DNS zones, forwarding, caching, and reverse-lookup design.
- Documented operational commands for service status, logging, lease inspection, DNS validation, and restart procedures.
- Installed and configured **Grafana** for centralized visibility and telemetry collection.

### Virtualized Application Services

- **Nextcloud VM:** Self-hosted file collaboration and synchronization workload.
- **Jellyfin LXC:** Lightweight media-server deployment with future GPU-accelerated transcoding capability.
- **Immich VM:** Self-hosted photo-management workload.
- **VDI/PXE-focused server:** Supports deployment and endpoint-management experimentation.

## Operational Approach

This project is maintained as an infrastructure runbook—not simply a collection of screenshots or one-time builds.

- Configuration files are documented alongside their paths and expected contents.
- Changes include validation steps such as DNS zone checks, service status checks, storage mount verification, and client-side testing.
- Network assignments and device roles are recorded to improve incident response and reduce configuration drift.
- Completed lab tasks are retained as evidence of hands-on implementation and troubleshooting.
- Roadmap items remain explicitly identified so experimental ideas are not represented as completed production capabilities.

## Example Administration Tasks

### Validate DNS

```bash
sudo named-checkzone example.internal /etc/bind/example.internal
dig host.example.internal
dig -x 10.0.0.100 +short
```

### Validate Linux Services

```bash
sudo systemctl status bind9
sudo systemctl status isc-dhcp-server
sudo journalctl -u bind9
sudo tail -f /var/log/syslog
```

### Validate Proxmox Storage

```bash
zfs get mountpoint <dataset>
pvesm status
```

### Manage Active Directory with PowerShell

```powershell
New-ADUser -Name "Example User" -Enabled $true
New-ADGroup -Name "Example Group" -GroupScope Global
Add-ADGroupMember -Identity "Example Group" -Members "Example User"
```

## Roadmap

Planned work focuses on expanding reliability, security, and automation:

- [x] Create and validate ZFS pools/datasets and expose storage through Proxmox configuration.
- [x] Complete DMZ segmentation and firewall policy enforcement on the Ubuntu infrastructure node.
- [ ] Implement scheduled backups, restore testing, and documented recovery objectives.
- [ ] Build a VPN gateway/container to isolate selected outbound traffic from the Proxmox host.
- [ ] Expand Grafana dashboards and telemetry collection for network equipment, hosts, and guest workloads.
- [ ] Automate baseline Linux configuration with Ansible, including Netplan, DNS, DHCP, and SSH configuration.
- [ ] Build a small Kubernetes environment using K3s or MicroK8s on Proxmox VMs.
- [ ] Add CI/CD workflows for infrastructure documentation, configuration linting, and deployment artifacts.
- [ ] Continue security hardening through firewall policy review, guest hardening, access control, and monitoring.

## Professional Focus

This homelab is a practical demonstration of my ability to:

- Design and operate infrastructure.
- Translate requirements into documented, testable technical implementations.
- Administer identity, DNS, DHCP, storage, virtualization, endpoint deployment, and file services.
- Troubleshoot services across network, operating system, and application layers.
- Use automation and documentation to make infrastructure supportable by more than one person.
- Apply enterprise concepts in a self-directed environment while continuously improving reliability and security.

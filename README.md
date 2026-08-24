# Homelab Systems & Network Projects

A showcase repository for two hands-on homelab builds focused on virtualization, Windows domain services, Linux server administration, and network infrastructure. This repo documents a VMware-based Windows domain lab and a bare-metal Proxmox/Linux lab, with notes on systems, networking, monitoring, storage, and service design.

## Overview

This repository documents two complementary homelab environments:

- [Linux Infrastructure Lab](./Proxmox-Lab/proxmox-homelab.md): built on bare metal with Proxmox as a **Type 1 hypervisor**, Ubuntu Server on an HP t640, and a Brocade switch for network segmentation and lab connectivity.
- [Windows Domain Lab](./vmWare-Lab/Documentation/VM%20Config%20Notes.md): built on VMware Workstation as a **Type 2 hypervisor** to simulate an enterprise Windows domain environment.

Together, these projects demonstrate practical experience with virtualization, server roles, DNS, DHCP, directory services, storage, networking, and lab design.

## Projects Included

### 1. Proxmox Linux Lab

This lab was built on bare metal with Proxmox as the primary virtualization platform, running alongside Ubuntu Server on the HP t640 and a Brocade switch for network services and segmentation.

**Highlights:**

- Proxmox VE as a **Type 1 hypervisor** for VMs and containers.
- Ubuntu Server on the HP t640 providing DHCP and BIND9 DNS services.
- Brocade ICX-6430-C12 switch for lab networking and segmentation.
- Static IP planning, network scope design, and fixed allocations for lab devices.
- Proxmox storage, networking, and host configuration documentation.
- Linux service administration, including DNS forwarding, internal zones, and DHCP integration.
- Optional infrastructure services such as Grafana, Alloy, Nextcloud, and Jellyfin documented in the lab notes.

### 2. VMware Windows Domain Lab

This lab was built in VMware Workstation to practice designing and managing a closed Windows environment. It includes Active Directory, DNS, DHCP, Group Policy, file sharing, DFS, WDS, WSUS, and PowerShell-based administration tasks.

**Highlights:**

- VMware Workstation nested virtualization environment.
- Active Directory Domain Services with multiple domain controllers.
- DNS and DHCP configuration for domain clients and servers.
- Group Policy for drive mapping, permissions, and workstation management.
- DFS namespaces and replication for shared file services.
- WDS and WSUS for imaging and update management.
- PowerShell automation for AD user, group, and CSV-based provisioning tasks.

## Lab Architecture

| Project | Platform | Purpose |
| --- | --- | --- |
| Windows Domain Lab | VMware Workstation | Virtual enterprise Windows environment for AD, DNS, DHCP, GPO, DFS, WDS, WSUS, and PowerShell practice |
| Linux Infrastructure Lab | Proxmox VE + Ubuntu Server | Bare-metal virtualization and core network services for Linux administration and lab networking |

## Skills Demonstrated

- Virtualization and hypervisor administration.
- Windows Server infrastructure services.
- Active Directory and Group Policy management.
- DNS, DHCP, and network service design.
- Linux server administration and system configuration.
- Proxmox VE deployment and storage/network setup.
- Switch-based lab networking and segmentation.
- Automation and scripting with PowerShell.
- Documentation and reproducible lab design.

## Hardware and Platform Summary

### Linux Infrastructure Lab

- Proxmox host on bare metal.
- HP t640 thin client running Ubuntu Server 24.04 LTS.
- Brocade ICX-6430-C12 switch for internal lab networking.

### Windows Domain Lab

- VMware Workstation host environment.
- Windows Server virtual machines and client systems.

## Included Documentation

- Proxmox host and Linux service documentation.
- Network design and device allocation documentation.
- Windows Domain Lab notes and project tasks.

# Proxmox Virtual Environment Server

Proxmox Virtual Environment (PVE) is an open-source virtualization platform that provides a powerful, enterprise-grade toolset for building and managing both virtual machines (VMs) and Linux containers (LXC). It combines the capabilities of KVM (Kernel-based Virtual Machine) for full virtualization and LXC for lightweight, system-level virtualization.

## Key Features of Proxmox VE

1. Unified Management Interface:

    - Web-based GUI for centralized management.

    - Command-line tools and a REST API for automation and integration.

    - Built-in, mobile-friendly dashboard.

2. Virtualization and Containerization:

    - KVM for full hardware virtualization.

    - LXC for lightweight, OS-level containers with lower overhead.

    - Ability to run Linux, Windows, and BSD guests.

3. Storage Flexibility:

    - ZFS, Ceph, NFS, iSCSI, and more.

    - Built-in support for snapshots, thin provisioning, and replication.

    - Storage pools can span multiple types and tiers.

4. High Availability (HA) and Clustering:

    - Built-in clustering for distributed environments.

    - HA management for automatic failover and recovery.

    - Centralized storage with Ceph for better resilience.

5. Networking Features:

    - Software-defined networking (SDN) with support for VLANs, bridges, and bonding.

    - Built-in firewall, NAT, and VPN support.

    - Integrated virtual switches like Open vSwitch (OVS).

6. Backup and Disaster Recovery:

    - Integrated Proxmox Backup Server support.

    - Encrypted, incremental backups.

    - Scheduled snapshots and restore points.

7. Advanced Features:

    - Support for GPU passthrough and SR-IOV for high-performance workloads.

    - Cloud-init support for automating VM configuration.

    - Integration with tools like Ansible, Terraform, and SaltStack for automation.

## Proxmox Homelab Project Goals

1. Linux Fundamentals and Administration (LFCSA, RHCSA):

    - Basic VM Setup: Create CentOS, AlmaLinux, or Ubuntu VMs for learning basic Linux commands, file systems, and user management.

    - Networking Practice: Set up complex networking scenarios with VLANs, bridges, and firewalls.

    - Filesystem Management: Use ZFS for storage management and practice filesystem snapshots, quotas, and replication.

2. Virtualized Data Center and High Availability:

    - Clustering: Create a small Proxmox cluster to learn clustering, high availability, and live migration.

    - Ceph Storage: Set up a Ceph cluster for shared storage, simulating enterprise-level data redundancy.

    - HA Services: Run critical services (e.g., web servers, databases) with HA to understand failover and recovery.

3. Containerization (Docker, LXC, Podman):

    - LXC Labs: Use LXC containers for lightweight application hosting, simulating multi-tier architectures.

    - Docker Swarm or Podman: Run containers directly on Proxmox or use Docker Swarm for orchestration.

4. Kubernetes and DevOps Skills:

    - Kubernetes Cluster: Use tools like K3s or MicroK8s on VMs for a small-scale Kubernetes cluster.

    - CICD Pipelines: Integrate with GitHub Actions or GitLab CI for hands-on DevOps experience.

    - Helm and Kustomize: Use these tools for managing Kubernetes manifests.

5. Advanced Networking and Security:

    - Virtual Network Lab: Build complex, multi-VLAN networks to simulate enterprise environments.

    - Security Hardening: Practice hardening Proxmox itself as well as the VMs, including SELinux, firewalls, and IDS/IPS.

## System Information

- Hostname: rksrv-pve.rklab.lan
- IP: 192.168.1.100/24
  - Web Management Interface: <https://192.168.1.100:8006/>
- Mobo: Gigabyte B450M DS3H (bios key `del`)

## System Configuration

A clean install of Proxmox VE 9 from the official ISO will already have the standard Debian `main` and `contrib` repos configured, but it will not automatically enable `non-free-firmware` for you.

### What you will (and won’t) get by default

- After a fresh PVE 9 install, you will have the Proxmox 9 repo and Debian 13 (trixie) repos set up in `/etc/apt/sources.list.d` / `debian.sources`, typically with `main` and `contrib` components enabled.
- The `non-free-firmware` component is required for packages like `amd64-microcode` and some extra firmware; this component is not always enabled by default and may still need to be added manually.

### What you should do after a clean install

I used the [:scroll: PVE Post-Install Helper-Script]([https://](https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install&category=Proxmox+%26+Virtualization))

Verify non-free CPU firmware has been installed

```bash
apt list --installed | grep 'amd64-microcode`
```

### PCIe GPU Passthrough

Configurations to allow VMs/containers to use the GPU installed in the Proxmox host machine.

1. Config File: [IOMMU/PCIe GPU Passthrough](./Configs/pve-IOMMU_PCIe_GPU_Passthrough.md)
2. Configure in VM [VM Passthrough](./Configs/pve-IOMMU_PCIe_GPU_Passthrough.md#for-plex-or-jellyfin-in-the-vm)

### Network

#### Network Hardware

##### NIC 0: Realtek PCIe GbE (onboard, Management Interface)

- MAC: B4-2E-99-A5-1D-8F
- Proxmox Management Interface
- IP: 192.168.1.100/24
- Gateway: 192.168.1.254
- DNS Server: 192.168.1.254

##### NIC 1: Intel 82575EB GbE (PCI)

- MAC: A0-36-9F-A0-2C-06

##### NIC 2: Intel 82575EB GbE (PCI)

- MAC: A0-36-9F-A0-2C-07

## Proxmox Configuration

### Storage

:file_folder: [Storage Documentation](./Configs/pve-Storage.md)

#### Storage Configuration Task List

- Run commands or script to create pools/datasets
  - If using a script, proof-read first
  - Use scp to secure copy over ssh to rksrv-pve
  - Check permissions
  - Run & Verify Pools and Datasets
    - `zfs get mountpoint [DATASET]`
- Update storage.cfg with new configurations to expose in GUI
  - Proof-read file (compare to pve-ZFS.sh)
  - Create backup copy of existing /etc/pve/storage.cfg
  - Copy new [config](./Configs/Scripts/storage.cfg) to rksrv-pve storage.cfg file

#### Storage Hardware

| Make            | Model           | Type   | Size  | Content                    | Filesystem                 |
| --------------- | --------------- | :----: | :----:| -------------------------- | -------------------------- |
| Western Digital | WD-BLACK SN770  | NVMe   | 2 TB  | OS + VMs + LXC Containers  |  |
| Crucial         | CT1000BX500SSD1 | SSD    | 1 TB  | VM Disks + Transcode Cache |  |
| Western Digital | WD Red          | HDD    | 4 TB  | Mass Storage + Backups     |  |
| Western Digital | WD Red          | HDD    | 4 TB  | Mass Storage + Backups     |  |

## Virtual Machines

## Nextcloud VM

:magic_wand: Created using the Proxmox VE Community Helper Script

:file_folder: [Nextcloud VM Documentation](./VMs/100-nextcloud-vm/100-nextcloud-vm.md)

## Jellyfin LXC

Created using the Proxmox VE Community Helper Script for Jellyfin Media Server LXC.

:file_folder: [Jellyfin LXC Documentation](./LXC/101-jellyfin/101-jellyfin-LXC.md)

## Other Apps & Services

Run Mullvad VPN in a VM or Container

1. Create a VM or LXC container (Debian, Ubuntu, etc.)
2. Install Mullvad CLI or manually configure WireGuard
3. Route the desired traffic through the container

This is ideal for segregating VPN usage while keeping your Proxmox host clean and unaffected.

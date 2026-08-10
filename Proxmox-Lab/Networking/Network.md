# Homelab Network

## Contents

- [Homelab Network](#homelab-network)
  - [Contents](#contents)
  - [IP Scheme](#ip-scheme)
  - [Device Scope Table](#device-scope-table)
  - [DHCP Fixed Allocations/Static Leases](#dhcp-fixed-allocationsstatic-leases)
    - [Workstations](#workstations)
    - [Servers](#servers)
    - [PVE Virtual Machines / Containers](#pve-virtual-machines--containers)
    - [Network Appliances](#network-appliances)
    - [Ring System](#ring-system)
    - [Printers](#printers)
    - [Streaming / Roku Devices](#streaming--roku-devices)
    - [Other Clients](#other-clients)
  - [LAN Network Appliances](#lan-network-appliances)
    - [Switch: Brocade ICX-6430-C12](#switch-brocade-icx-6430-c12)
    - [Server: rknix-t640](#server-rknix-t640)
      - [:file\_folder: File Location: Full Documentation](#file_folder-file-location-full-documentation)
      - [Inactive Router: Linksys EA8300](#inactive-router-linksys-ea8300)
        - [Router Firmware Upgrade](#router-firmware-upgrade)

## IP Scheme

- Network: 192.168.1.0/24
- Gateway: 192.168.1.254
- IPv4 Range: 192.168.1.1 - 192.168.1.253

## Device Scope Table

This table is used to document the scopes/blocks of addresses reserved for the various types of devices in my homelab. Primarily for organization and ensuring I have enough addresses for each device type I deploy or plan to deploy.

| Network        | Network Type | Device Type                 | Device QTY | Purpose     | Device Scope                  |
| -------------- | ------------ | --------------------------- | :--------: | ----------- | ----------------------------- |
| 192.168.1.0/24 | WLAN         | Misc Personal Devices       | 59         | Personal    | 192.168.1.1 – 192.168.1.59    |
| 192.168.1.0/24 | WLAN         | Workstations                | 10         | Homelab     | 192.168.1.60 - 192.168.1.69   |
| 192.168.1.0/24 | WLAN         | Streaming / Roku Devices    | 10         | Homelab     | 192.168.1.70 - 192.168.1.79   |
| 192.168.1.0/24 | LAN          | Virtual Machine / Container | 10         | Homelab     | 192.168.1.100 – 192.168.1.120 |
| 192.168.1.0/24 | LAN          | Virtual Network Appliance   | 5          | Homelab     | 192.168.1.140 – 192.168.1.144 |
| 192.168.1.0/24 | WLAN         | Emulation Console           | 5          | Homelab     | 192.168.1.200 – 192.168.1.204 |
| 192.168.1.0/24 | WLAN         | Chromeboxes (Backline,etc)  | 5          | Homelab     | 192.168.1.205 - 192.168.1.209 |
| 192.168.1.0/24 | LAN & WLAN   | Ring System                 | 10         | Personal    | 192.168.1.210 - 192.168.1.220 |
| 192.168.1.0/24 | WLAN         | Printers                    | 10         | Personal    | 192.168.1.220 – 192.168.1.229 |
| 192.168.1.0/24 | LAN          | Physical Server             | 10         | Homelab     | 192.168.1.240 – 192.168.1.249 |
| 192.168.1.0/24 | LAN          | Physical Network Appliance  | 5          | Homelab     | 192.168.1.250 – 192.168.1.254 |
| 192.168.2.0/24 | WLAN Guest   | Misc Guest Devices          | 253        | Guest Wi-Fi | 192.168.2.1 – 192.168.2.254   |

## DHCP Fixed Allocations/Static Leases

### Workstations

| Node         | IP            | Network | NIC MAC           | NIC Name   | Device Type                 | Role                      |
| -----------  | --------------| ------- | ----------------- | -----------| --------------------------- | ------------------------- |
| rknix-nova   | 192.168.1.69  | WLAN    | bc:09:1b:05:fd:a7 | wlp0s20f3  | Lenovo ThinkPad T15 laptop  | Management laptop         |

### Servers

| Node        | IP             | Network    | NIC MAC           | NIC Name      | Device Type              | Role                     |
| ----------- | -------------- | ---------- | ----------------- | ------------- | ------------------------ | ------------------------ |
| Rksrv-pve   | 192.168.1.240  | LAN        | b4:2e:99:a5:1d:8f | NIC0 > vmbr0  | Physical Server (NIC 0)  | PVE Management           |
| Rksrv-pve   |                | LAN        | a0:36:9f:a0:2c:06 | NIC1 > vmbr1  | Physical Server          |                          |
| Rksrv-pve   | 192.168.1.242  | LAN        | a0:36:9f:a0:2c:07 | NIC2          | Physical Server (NIC2)   |                          |
| Rknix-t640  | 192.168.1.244  | LAN        | 7c:d3:0a:78:32:3f | enp1s0f0      | Physical Server          | DHCP,DNS,DMZ edge router |

### PVE Virtual Machines / Containers

| Node        | IP            | Network | NIC MAC           | NIC Name   | Device Type                 | Role                            |
| ----------- | --------------| ------- | ----------------- | -----------| --------------------------- | --------------------------------|
| nextcloud   | 192.168.1.100 | LAN     | 02:92:31:4e:8b:24 | vmbr0      | Virtual Machine / Container | rksrv-pve nextcloud (VM 100)    |
| jellyfin    | 192.168.1.101 | LAN     | bc:24:11:08:c4:aa | vmbr0      | Virtual Machine / Container | rksrv-pve jellyfin (VM 101)     |
| Rknix-arr   | 192.168.1.102 | LAN     | BC:24:11:A6:7E:6A | vmbr0      | Virtual Machine / Container | rksrv-pve *arr stack (VM 102)   |
| Immich-vm   | 192.168.1.103 | LAN     | BC:24:11:17:75:28 | enp0s18    | Virtual Machine / Container | rksrv-pve immich (VM 103)       |
| rksrv-alp   | 192.168.1.104 | LAN     | BC:24:11:B6:FC:CF | eth0       | Virtual Server              | VDI Netboot Server (VM 104)     |

### Network Appliances

| Node        | IP               | Network      | NIC MAC           | NIC Name             | Device Type                 | Role                                                                           |
| ----------- | ---------------- | ------------ | ----------------- | -------------------- | --------------------------- | ------------------------------------------------------------------------------ |
| Brocade     | 192.168.1.250    | LAN          | 60:9c:9f:38:4b:c8 | Out-Of-Band Mgmt Int | Physical Network Appliance  | Out of band management interface for console access                            |
| Brocade     |                  | LAN          |                   |                      | Physical Network Appliance  | VLAN 10 = 192.168.1.0/24 for Proxmox and lab LAN (gateway 192.168.1.1 on t640) |
| Brocade     |                  | LAN          |                   |                      | Physical Network Appliance  | VLAN 20 = DMZ subnet (e.g., 10.20.0.0/24, gateway 10.20.0.1 on t640).          |
| BGW320-505  | 192.168.1.254    | WAN & WLAN   | 40:e1:e4:29:58:71 | Fiber                | Physical Network Appliance  | WAN Gateway, Wi-Fi Router (NAT/DHCP), IP Passthrough > T640 (DMZ)              |

### Ring System

| Node                  | IP               | Network      | NIC MAC           | NIC Name             | Device Type                 | Role                                                         |
| --------------------- | ---------------- | ------------ | ----------------- | -------------------- | --------------------------- | ------------------------------------------------------------ |
| Ring-BaseStation-D199 | 192.168.1.210    | LAN          | B0:09:DA:73:D1:99 | Ethernet             | Ring System                 | Provides network and Z Wave connectivity to Ring devices     |
|

### Printers

| Node        | IP               | Network      | NIC MAC           | NIC Name             | Device Type                 | Role                                                                           |
| ----------- | ---------------- | ------------ | ----------------- | -------------------- | --------------------------- | ------------------------------------------------------------------------------ |
| Brother MFC | 192.168.1.220    | WLAN         | 00:41:0e:6d:09:db |                      | Printers                    | Monochrome laser printer                                                       |
| Brother CDW | 192.168.1.221    | WLAN         | a8:3b:76:f2:87:75 |                      | Printers                    | Color laser printer                                                            |
| Rollo       | 192.168.1.223    | WLAN         |                   |                      | Printers                    | Shipping label printer                                                         |

### Streaming / Roku Devices

| Node         | IP            | Network | NIC MAC           | NIC Name   | Device Type                 | Role                            |
| -----------  | --------------| ------- | ----------------- | -----------| --------------------------- | ------------------------------- |
| LivingRoom   | 192.168.1.70  | WLAN    | c4:98:5c:f6:21:6b |            | TCL Roku TV                 | Streaming Client                |
| RickyandKara | 192.168.1.74  | WLAN    | d0:12:55:d4:62:c5 |            | TCL Roku TV                 | Streaming Client                |

### Other Clients

| Node         | IP            | Network | NIC MAC           | NIC Name   | Device Type                 | Role                            |
| -----------  | --------------| ------- | ----------------- | -----------| --------------------------- | ------------------------------- |
| rknix-bkln   | 192.168.1.207 | WLAN    | 00:16:6f:f3:26:f4 | wlp2s0     | Acer Chromebox CXI2         | Backline Digital Signage        |
| rknix-bat    | 192.168.1.200 | WLAN    | cc:3d:82:95:27:48 | wlp2s0     | HP EliteDesk 800 G1         | Backline Digital Signage        |

## LAN Network Appliances

### Switch: Brocade ICX-6430-C12

:file_folder: [Full Documentation](./Switches/brocade/Brocade_ICX-6430-C12.md)

- Hostname: rknet-bro
- IP Address: 192.168.1.250/24
- MAC Address: 60:9C:9F:38:4B:C8
- DNS Server-Address: 192.168.1.244 (rknix-t640)
- Gateway: 192.168.1.254
- NTP Client Addresses (Server Disabled): 216.239.35.0, 216.239.35.4

### Server: rknix-t640

#### :file_folder: File Location: [Full Documentation](../Servers/t640.md)

- IP Address: 192.168.1.244/24
- DHCP
  - Scope: Not configured yet
- DNS
  - SOA FQDN: Not configured yet

#### Inactive Router: Linksys EA8300

##### Router Firmware Upgrade

I have not upgraded the router firmware and have taken it out of my LAN to avoid issues with double-NAT and to simplify routing.

Instead, I opted to create a DMZ using VLANs on the Brocade ICX-6430-C12, and firewall rules on the Ubuntu Server rknix-t640.

> Open Source Router Firmware provides a better alternative to proprietary software. Enjoy increased security, improved speed, and flexibility in network configuration. Upgrade your router with open-source firmware today and experience the benefits of a customizable network environment. Our website provides step-by-step guides and resources to help you get started. Join the growing community of users who have made the switch to open source router firmware.

[Compatible OpenWRT Release](https://openwrt.org/releases/24.10/notes-24.10.4)

- Hostname: rknet-linksy
- MAC Address: 24:f5:a2:eb:e5:44
  
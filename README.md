# Homelab: System and Network Administration Projects

## Overview
Over the past 2 years, I have been building a virtual Windows domain lab environment using VMware Workstation, ESXi, vSphere, and vCenter. The goal of this project is to learn and gain experience deploying common infrastructure and services. I also use pfSense, a free open source firewall and router to create a closed network 

## Components
- Virtualization Host: Windows 10 PC
  - System Model: B450 Tomahawk (MS-7C02)
  - Processor: AMD Ryzen 5 3600
  - RAM: 32 GB
  - Storage: 2100 GB
    - 1 TB SSD
    - 100 GB SSD
    - 1 TB NVMe SSD
  - Network Interfaces
    - Eth0: Realtek Gigabit Ethernet NIC 
    - Eth1: Intel Gigabit Ethernet NIC
    - Eth2: Intel Gigabit Ethernet NIC
- Type 2 Hypervisor: VMware Workstation 17
  - I chose to use VMware Workstation as it allows nested virtualization which was needed for the ESXi hosts.
- Network
  - 1 GB Fiber Internet
  - Wireless Router
  - pfSense (Lab Host VM)
- Virtual Machines
  - ESXi-1
  - ESXi-2
    - vSphere, vCenter
  - pfSense
  - Windows Server 2019
    - WINSRV201901
    - WINSRV201902 
  - Windows 10
  - Windows 11

## Deployed Windows Services 
- Active Directory Domain Services
  - User home folders mapped to hidden network drive
  - Logon script that maps additional network drives
  - Powershell script to import new users from .CSV file 
- Group Policy
  - Drive mapping for specific security groups
  - WMI Filters to deploy software depending on system architecture (x86/x64)
    - O365
    - Google Chrome
    - Foxit Reader
- DNS
  - Forward and Reverse Lookup Zones for internally hosted resources


### Work In Progress 
- DHCP
  - Scopes and Reservations to seperate servers and clients based on location
- WDS
  - Windows 10 and 11 image creation and deployment
- WSUS 
  - Centralized management of Windows updates

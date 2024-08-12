# VMware Workstation Virtual Machine Configuration Notes

**Table of Contents**
- [VMware Workstation Virtual Machine Configuration Notes](#vmware-workstation-virtual-machine-configuration-notes)
- [Networking](#networking)
  - [pfSense Configuration](#pfsense-configuration)
    - [Hardware](#hardware)
    - [Options](#options)
    - [Interfaces](#interfaces)
- [Servers](#servers)
  - [Server 1 Configuration](#server-1-configuration)
    - [VM Settings](#vm-settings)
      - [Hardware](#hardware-1)
      - [Options](#options-1)
      - [Local Server Properties](#local-server-properties)
    - [Network Settings](#network-settings)
        - [Ethernet0 Properties](#ethernet0-properties)
    - [Server 1 Roles and Features](#server-1-roles-and-features)
  - [Server 2 Configuration](#server-2-configuration)
    - [VM Settings](#vm-settings-1)
      - [Hardware](#hardware-2)
      - [Options](#options-2)
      - [Local Server Properties](#local-server-properties-1)
    - [Network Settings](#network-settings-1)
        - [Ethernet0 Properties](#ethernet0-properties-1)
    - [Server 2 Roles and Features](#server-2-roles-and-features)
  - [Server Roles and Features](#server-roles-and-features)
    - [AD DS](#ad-ds)
      - [Orginizational Units](#orginizational-units)
    - [Group Policy](#group-policy)
    - [File and Storage Services](#file-and-storage-services)
      - [Home Folder](#home-folder)
      - [Logon Script](#logon-script)



# Networking

## pfSense Configuration

### Hardware
- Memory: 2 GB
- Processors: 2
- Hard Disk (SCSI): 40 GB
- Network Adapter: Bridged (Automatic - Realtek PCIe GbE)
- Network Adapter 2: LAN Segment (pfSense)
- Network Adapter 3: Bridged (Automatic - Intel(R) 82575EB Gigabit Network Connection)
  
### Options
- Virtual machine name: pfSense
- Working directory: D:\Virtual Machines\pfSense
- VMware Tools features
  - Synchronize guest time with host enabled
- VMware tools updates: update manually 

### Interfaces
- WAN => em0: `10.45.1.100` (DHCP reserved on linksys router)
    - WAN Gateway: `10.45.1.1` (linksys router)
- LAN => em1: `192.168.100.254/24`
    - LAN DHCP: `192.168.100.10 - 192.168.100.20`

# Servers

> WINSRV201901 will be referred to as Server 1, WINSRV201902 will be referred to as Server 2. These are both domain controllers to provide redundancy for critical services. 

## Server 1 Configuration  

### VM Settings

#### Hardware
- Memory: 2 GB
- Processors: 2
- Hard Disk (NVMe): 60 GB
- Network Adapter: LAN Segment (pfSense)
#### Options
- Virtual machine name: Windows Server 2019 - Server 1
- Working directory: E:\Virtual Machines
- VMware Tools features
  - Synchronize guest time with host enabled
- VMware tools updates: update manually
- VMware tools installed: yes 

#### Local Server Properties
- Computer name: WINSRV201901
- Firewall: Domain/Private off; Public: on
- Remote management: Enabled
- Time zone: UTC-6 CT

### Network Settings
 
##### Ethernet0 Properties
- IPv4
  - IP address: `192.168.100.10`
  - Default gateway: `192.168.100.254`
  - Preferred DNS server: `192.168.100.254`
  - Alternate DNS server: `8.8.8.8`

### Server 1 Roles and Features
- AD DS
- DNS
- File and Storage Services
  
## Server 2 Configuration  

### VM Settings

#### Hardware
- Memory: 2 GB
- Processors: 2
- Hard Disk (NVMe): 60 GB
- Network Adapter: LAN Segment (pfSense)
#### Options
- Virtual machine name: Windows Server 2019 - Server 2
- Working directory: E:\Virtual Machines\Windows Server 2019 - Server 2
- VMware Tools features
  - Synchronize guest time with host enabled
- VMware tools updates: update manually
- VMware tools installed: yes 

#### Local Server Properties
- Computer name: WINSRV201902
- Firewall: Domain/Private off; Public: on
- Remote management: Enabled
- Time zone: UTC-6 CT

### Network Settings
 
##### Ethernet0 Properties
- IPv4
  - IP address: `192.168.100.11`
  - Default gateway: `192.168.100.254`
  - Preferred DNS server: `192.168.100.10`
  - Alternate DNS server: `192.168.100.254`

### Server 2 Roles and Features
- AD DS
  - DNS 
  - Global Catalog
  
## Server Roles and Features

### AD DS
- Domain name: rickyratliff.local
- Domain/Forest functional level: 2016

#### Orginizational Units
> User accounts imported using `Import-CSV` PowerShell cmdlet, see Import-Csv.ps1 and ADUserImportData.csv 
- 📁Administration
  - 📁Computers
    - 🖥 WIN1064CLI01
  - 📁Users
    - 👨‍💼 Kaden Ratliff
    - 🐕 Okie Ratliff
    - 👨‍💻 Ricky Ratliff
- 📁Sales
  - 📁Computers
  - 📁Users 
    - 🧚‍♀️Ava Ratliff
    - 😼 Bear Ratliff
    - 👨‍💼 Dwight Schrute
    - 👩 Kara Ratliff
    - :lock: PWD Without Complexity
    - 👨‍💼 Steven Seagal

### Group Policy

💠 rickyratliff.local
  - 🧾 Default Domain Policy
  - 🧾 Public Folder Sharing 
  
        👨‍🔧 User Configuration > Preferences > Drive Maps
        - Letter: P 
        - Location: \\WINSRV201901\Public 
        - Reconnect: Enabled
   
  - 📁Administration
     - 📁Computers
     - 📁Users
       - 🧾 Administration Drive Sharing 
  
                👨‍🔧 User Configuration > Preferences > Drive Maps
                - Letter: A 
                - Location: \\WINSRV201901\Administration$
                - Reconnect: Enabled
  - 📁Sales
     - 📁Computers
     - 📁Users 
  - 📁 Group Policy Objects
  - 📁 WMI Filters
  - 📁 Starter GPOs



### File and Storage Services

#### Home Folder
- All user accounts have their home folder connected to H:\\WINSRV201901\DomainUsers$\%USERNAME%

#### Logon Script
- Logon Script.bat saved to "C:\Windows\SYSVOL\sysvol\rickyratliff.local\scripts\script.bat"
 
        net use F: \\WINSRV201901\Files$

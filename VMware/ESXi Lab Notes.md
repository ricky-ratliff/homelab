# VMware Workstation ESXi Lab Notes

## ESXi Host Configs

### ESXi-1 Configs (Servers)
- VMware Tools Installed: No
- Storage: 200 GB
- Memory: 8 GB
- CPU: 4 vCPUs
- Network 
  - VMware Workstation Host: NAT
  - vmnic0 (Ethernet0)
    - IPv4 Configuration: 192.168.136.130 (static)
    - DNS Configuration
      - Primary DNS Server: 192.168.136.2
      - Hostname: ESXi-1
      - DNS suffixes: localdomain, arka.net

#### ESXi-1 Virtual Machines
- WINSRV2012R2DC1
  - VMware Tools Installed: Yes
  - Storage: 80 GB
  - Memory: 4 GB
  - CPU: 2 vCPUs
  - Network
    - Ethernet0
      - IPv4 Address: 192.168.136.131 (static)
      - Default Gateway: 192.168.136.2
      - Preferred DNS: 192.168.136.131
  - Roles
    - AD DS
      - Forest root domain name: arka.net
      - Forest & Domain functional level: 2012 R2
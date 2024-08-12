# HomeLab Network Notes 

## pfSense

- WAN => em0: `10.45.1.100` (DHCP reserved on linksys router)
    - WAN Gateway: `10.45.1.1` (linksys router)
- LAN => em1: `192.168.100.254/24`
    - LAN DHCP Server Range (for servers only): `192.168.100.10 - 192.168.100.20`

## Servers 

#### Server1 (WINSRV201901)

- Static IP: `192.168.100.10`
- DHCP Server Local Network Scope: `192.168.100.50 - 192.168.10.100`

#### Server2 (WINSRV201902)
   
- Static IP: `192.168.100.11`

#### ESXi-1

- Static IP: `192.168.100.16` 


## Clients 

- Windows 10 Client 01 (ADM1): `Server1 DHCP Client`
- Windows 10 x32 Client 02 (SAL1): `Server1 DHCP Client`


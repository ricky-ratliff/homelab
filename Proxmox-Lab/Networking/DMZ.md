# DMZ Config Docs

## High-Level Config Overview

Use the documentation I have provided (Homelab IP Schemes.xlsx, etc.) to give me a step by step guide to set up my DMZ using IP Passthrough to hand the public IP from the BGW320 to the t640 Ubuntu Server to make the t640 the true edge router with the Brocade providing segmentation and VLANs.

The t640 will be the true edge router by (1) putting the BGW320 in IP Passthrough to the t640, (2) making the t640 route/NAT for your internal VLANs, and (3) having the Brocade do the VLAN segmentation.

## 1. Final topology and IP Plan

Based on homelab network documentation: :file_folder: [Network.md](./Network.md)

Using existing scopes and assignments:

- Public internet
  - Terminates on BGW320, which **passes the public IP** through to t640 (IP Passthrough).[^12_3][^12_4]
- “WAN side” of t640
  - t640 `enp1s0f0` plugged into **BGW320 LAN port 1**.
- BGW320 in IP Passthrough mode, so t640 `enp1s0f0` gets the **public IP** via DHCP (no 192.168.1.x on the WAN anymore).
- Brocade ICX 6430‑C12
  - Uplink from t640 with VLAN to a Brocade switch port configured as a trunk:
    - VLAN 10 = LAN (192.168.1.0/24, your current main scope).
    - VLAN 20 = DMZ (new DMZ subnet, e.g., 10.20.0.0/24, for Headscale‑exposed or internet‑facing services).[^12_2][^12_1]
- Internal IPs (examples, aligned with your spreadsheet):[^12_6][^12_1]
  - VLAN 10 (LAN): 192.168.1.0/24
    - Gateway: **192.168.1.1** (t640 on VLAN 10)
    - Your scopes (VMs 192.168.1.100‑120, Proxmox 192.168.1.240, etc.) stay the same, just use 192.168.1.1 instead of BGW320 as gateway.
  - VLAN 20 (DMZ): 10.20.0.0/24 (you can pick any RFC1918 block not already used)
    - Gateway: **10.20.0.1** (t640 on VLAN 20)
    - DMZ services (reverse proxy, Headscale, maybe a hardened nginx, etc.).

## 2. Configure BGW320: IP Passthrough to t640

On the BGW320 (Nokia BGW320‑505):[^12_4][^12_7][^12_3]

1. Connect a laptop to BGW320 LAN and log in to the web UI (usually `192.168.1.254`).
2. Go to **Firewall > IP Passthrough**.[^12_4]
3. Set:
    - “Allocation Mode”: **Passthrough**.
    - “Passthrough Mode”: **DHCPS‑fixed** or **DHCPS‑dynamic**.
    - “Passthrough Fixed MAC Address”: select the **t640’s WAN MAC** (the NIC cabled to BGW320).
4. Save and **reboot BGW320**, then **reboot t640** or bounce its WAN interface.
5. Verify on t640 that `eth0` gets a **public IP**, gateway, and DNS from the BGW320 via DHCP.[^12_3][^12_5]

At this point the BGW320 is basically a media converter: it holds the ONT and hands one public IP to the t640; all routing/NAT is done by the t640.

## 3. Wire the Brocade and define VLANs

On the Brocade ICX 6430‑C12, using your notes and current running config as a base:[^12_2]

1. Pick a port for **t640 LAN‑side uplink** (for example `1/1/1`).
2. In Brocade CLI, define VLANs 10 and 20 if not already there:

```shell
conf t
vlan 10 name LAN by port
 tagged ethernet 1/1/1
vlan 20 name DMZ by port
 tagged ethernet 1/1/1
exit
write mem
```

1. For access ports:
    - Ports that feed LAN devices/Proxmox (rksrv‑pve at 192.168.1.240) are **untagged in VLAN 10**.[^12_6][^12_1]
    - Ports that feed DMZ devices/servers are **untagged in VLAN 20**.

Example for Proxmox on port `1/1/2` and a DMZ VM host on `1/1/3`:

```shell
conf t
interface ethernet 1/1/2
  untagged vlan 10
  spanning-tree portfast
exit
interface ethernet 1/1/3
  untagged vlan 20
  spanning-tree portfast
exit
write mem
```

## 4. Configure Ubuntu Server on t640 as edge router

Assume:

- `eth0` = WAN to BGW320 (public IP via DHCP).
- `eth1` = LAN/DMZ trunk to Brocade.
- You want:
  - `eth1.10` = 192.168.1.1/24 (LAN gateway).
  - `eth1.20` = 10.20.0.1/24 (DMZ gateway).

### 4.1 Netplan on t640

Create `/etc/netplan/01-t640.yaml`:

```yaml
network:
  version: 2
  renderer: networkd

  ethernets:
    eth0:
      dhcp4: yes      # public IP from BGW320 (IP Passthrough)
    eth1:
      dhcp4: no

  vlans:
    eth1.10:
      id: 10
      link: eth1
      addresses:
        - 192.168.1.1/24
    eth1.20:
      id: 20
      link: eth1
      addresses:
        - 10.20.0.1/24
```

Then:

```bash
sudo netplan apply
```

- All LAN devices (including Proxmox at 192.168.1.240 and your management laptop at 192.168.1.69) now use **192.168.1.1** as their default gateway.[^12_6][^12_1]
- DMZ devices use **10.20.0.1** as gateway.

### 4.2 Enable IPv4 forwarding

Edit `/etc/sysctl.conf` and ensure:

```text
net.ipv4.ip_forward=1
```

Apply:

```bash
sudo sysctl -p
```

## 5. Add NAT and basic firewall on t640 (nftables)

Install nftables:

```bash
sudo apt update
sudo apt install nftables
sudo systemctl enable --now nftables
```

Create `/etc/nftables.conf` (minimal but usable):

```nft
table inet filter {
    chain input {
        type filter hook input priority 0;
        policy drop;

        ct state established,related accept

        # Allow localhost
        iif "lo" accept

        # Allow SSH from LAN for admin
        iif "eth1.10" tcp dport 22 accept

        # Allow basic ICMP for troubleshooting
        ip protocol icmp accept

        # Allow Tailscale if running
        iif "tailscale0" accept
    }

    chain forward {
        type filter hook forward priority 0;
        policy drop;

        ct state established,related accept

        # LAN/DMZ to WAN (outbound)
        iif { "eth1.10", "eth1.20" } oif "eth0" accept

        # Optional: LAN to DMZ (e.g., for management)
        iif "eth1.10" oif "eth1.20" tcp dport { 22, 80, 443 } accept

        # Optional: DMZ to LAN – very restrictive; add only what you need
        iif "eth1.20" oif "eth1.10" tcp dport { 80, 443 } accept
    }
}

table ip nat {
    chain postrouting {
        type nat hook postrouting priority 100;
        policy accept;

        # NAT LAN and DMZ out via public WAN
        oif "eth0" ip saddr 192.168.1.0/24 masquerade
        oif "eth0" ip saddr 10.20.0.0/24 masquerade
    }
}
```

Load it:

```bash
sudo nft -f /etc/nftables.conf
```

Now:

- LAN and DMZ clients route to t640, which NATs traffic out the public IP.
- LAN ↔ DMZ flows are controlled explicitly, letting you keep DMZ tight.

## 6. Adjust LAN/DMZ clients and Proxmox

Using your IP scopes:[^12_1][^12_6]

1. On **Proxmox host** (rksrv‑pve):
    - Keep IP: **192.168.1.240** on VLAN 10 access port.
    - Change gateway to **192.168.1.1** (t640) rather than 192.168.1.254.
2. On your **management laptop** (192.168.1.69):
    - Ensure it’s on a VLAN 10 access port (on Brocade).
    - Gateway = 192.168.1.1.
3. On **other LAN devices** (printers, consoles, VMs):
    - IPs stay inside your defined ranges (e.g., 192.168.1.100–120 for VMs).
    - Gateway = 192.168.1.1.
4. On any **DMZ hosts** (for example, a reverse proxy VM for internet‑facing services):
    - Put their ports untagged in VLAN 20 on Brocade.
    - IP = 10.20.0.x/24, gateway = 10.20.0.1.

## 7. Headscale/Tailscale placement (optional but recommended)

On the t640:

- Install **Headscale** and bind its web/API on either:
  - DMZ IP 10.20.0.1, or
  - A DMZ VM IP (e.g., 10.20.0.10) behind the t640.
- Install **Tailscale** and:
  - Join your Headscale tailnet.
  - Advertise 192.168.1.0/24 and 10.20.0.0/24 as **subnet routes**.
  - Optionally enable as **exit node**.

Use nftables to control what tailnet clients can reach:

- From `tailscale0` → VLAN 10 (LAN) services (Proxmox, Nextcloud, Jellyfin, etc.).
- From `tailscale0` → VLAN 20 (DMZ) services.

Generate a t640‑specific checklist I can literally follow in order (BGW320 page, Brocade commands, then Ubuntu commands) using my exact device names and MACs from my homelab network documentation (Network.md).

### References

[^12_1]: Homelab-IP-Schemes.xlsx

[^12_2]: Brocade_ICX-6430-C12.md

[^12_3]: <https://www.devonstephens.com/how-to-enable-ip-passthrough-on-att-bgw320-505/>

[^12_4]: <https://www.att.com/support/smallbusiness/article/smb-internet/KM1188700/>

[^12_5]: <https://www.reddit.com/r/ATTFiber/comments/1l8tjsx/passthrough_mode_questions_bgw320500/>

## BGW320 WiFi Clients

I need to ensure that devices currently using Wi-Fi are still able to connect. How can I configure the BGW320 to work with my homelab DMZ and still provide a Wi-Fi network? There are options for a Public Subnet, Cascaded Router, and Guest SSID on the BGW320

You can leave the BGW320 providing Wi‑Fi while using IP Passthrough to the t640; you do not need Public Subnet or Cascaded Router for your homelab DMZ design.[^13_1][^13_2]

### What happens to Wi‑Fi in IP Passthrough

- When you enable **IP Passthrough** to the t640, the BGW320 still runs its own NAT, DHCP, and Wi‑Fi for other clients.[^13_1]
- The t640 gets the **public IP** on its WAN, while Wi‑Fi clients keep getting **192.168.1.x** addresses from the BGW’s internal DHCP pool.[^13_2][^13_1]
- This effectively gives you:
  - Path A: Internet ⇄ BGW320 ⇄ **t640 (edge router)** ⇄ Brocade ⇄ VLAN 10/20 (homelab + DMZ).
  - Path B: Internet ⇄ BGW320 ⇄ **BGW Wi‑Fi clients** on 192.168.1.0/24 (separate from your VLANs).

For your lab, that’s fine as long as you accept that BGW Wi‑Fi devices sit “outside” your t640/Brocade segmentation.

### How to configure the BGW320

1. **Keep Wi‑Fi enabled**
    - Leave the main SSID on the BGW320 as it is for your regular wireless devices.
    - Optionally enable the **Guest SSID** if you want a separate guest network; note that AT\&T’s guest isolation is imperfect (guests can still reach the router UI at 192.168.1.254).[^13_3]
2. **Enable IP Passthrough to the t640**
    - Log into BGW320 at `192.168.1.254`.
    - Go to **Firewall → IP Passthrough**.[^13_4][^13_2]
    - Set:
        - Allocation Mode: **Passthrough**.
        - Passthrough Mode: **DHCPS‑fixed**.
        - Passthrough Fixed MAC: select the **t640 WAN NIC MAC**.
    - Save, then reboot BGW320 and the t640 WAN interface.
    - Confirm t640 WAN now has the **public IP**, and your existing t640 router configuration handles LAN/DMZ via the Brocade.
3. **Leave “Public Subnet” and “Cascaded Router” OFF**
    - “Public Subnet” / “Cascaded Router” are for AT\&T‑sold static public IP blocks and are not needed for your single‑IP Passthrough setup.[^13_5][^13_6]
    - Your DMZ subnet (e.g., 10.20.0.0/24) is a **private VLAN behind t640**, not something the BGW320 should know about; routing and firewalling for DMZ stays on t640 and Brocade.[^13_7][^13_8]

### How this fits your homelab DMZ

- t640 is still the **true edge router** for everything behind the Brocade:
  - VLAN 10 = 192.168.1.0/24 for Proxmox and lab LAN (gateway 192.168.1.1 on t640).[^13_9][^13_7]
  - VLAN 20 = DMZ subnet (e.g., 10.20.0.0/24, gateway 10.20.0.1 on t640).[^13_7]
- BGW320 Wi‑Fi stays as a **parallel, simpler home LAN** that never passes through your Brocade/t640 segmentation, which keeps the homelab design clean.

If you’d like, I can help you decide:

- Which devices should stay on BGW Wi‑Fi vs be moved to a lab Wi‑Fi (e.g., later via an AP on VLAN 10 or a dedicated “homelab SSID” behind the t640).

### References

[^13_1]: <https://www.reddit.com/r/ATTFiber/comments/19d12qs/does_passthrough_mode_on_bgw320_affect_wifi/>

[^13_2]: <https://www.devonstephens.com/how-to-enable-ip-passthrough-on-att-bgw320-505/>

[^13_3]: <https://www.reddit.com/r/ATT/comments/mv4axt/bgw320500_guest_network_allows_guests_to_access/>

[^13_4]: <https://www.att.com/support/smallbusiness/article/smb-internet/KM1188700/>

[^13_5]: <https://www.reddit.com/r/ATTFiber/comments/19chou3/help_understanding_cascaded_router_setting_on/>

[^13_6]: <https://forum.netgate.com/topic/172535/pfsense-behind-bw320-with-static-ips>

[^13_7]: Homelab-IP-Schemes.xlsx

[^13_8]: Brocade_ICX-6430-C12.md

[^13_9]: Proxmox.md

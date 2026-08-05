# Linux Converted Acer Chromebox CXI2

## Project Requirements

A local eBay reselling business called Static Revival requested a small form factor workstation with HDMI output and 4 USB ports for listing eBay items, printing shipping labels, and general office productivity.

## Hardware Info

- Make/Model: Acer Chromebox CXI2
- Processor: Intel Celeron 3205U 1.5 GHz
- Architecture: x86_64
- RAM: 4 GB DDR3L SDRAM
- Storage: 16 GB
- Video: HDMI, DisplayPort
- Networking: Ethernet, WiFi (802.11 AC)

## Network Configuration

- Hostname: staticrev-rikku
- OpenSSH Server installed
  - Current local IP: 192.168.1.202
- Added to Tailscale Tailnet
  - 100.123.132.45

Yes — the cleanest way is to use **Tailscale for the remote admin path**, then lock SSH so it only accepts connections coming from `tailscale0`. Tailscale’s Ubuntu/Linux instructions support a simple install-and-auth flow, and Tailscale’s own Ubuntu firewall guide recommends using UFW to restrict SSH to the Tailscale interface. [tailscale](https://tailscale.com/docs/install/linux)

## 1) Install and bring up Tailscale

On the Lubuntu Chromebox:

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

The install script is the standard Linux method, and `tailscale up` will give you a login URL to join the machine to your tailnet. [tailscale](https://tailscale.com/docs/how-to/quickstart)

## 2) Find the Tailscale IP

After login, get the box’s Tailscale address:

```bash
tailscale ip -4
```

You’ll use that from your remote computer to SSH into the box over the VPN rather than over the public internet. [tailscale](https://tailscale.com/docs/how-to/secure-ubuntu-server-with-ufw)

## 3) Lock down SSH with UFW

If SSH is already working locally, switch the firewall to allow SSH only on the Tailscale interface:

```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow in on tailscale0 to any port 22 proto tcp
sudo ufw enable
sudo ufw status verbose
```

This follows the same model Tailscale documents for Ubuntu: deny general inbound traffic, then allow SSH over `tailscale0`. [supun](https://supun.io/tailscale-ssh-restrict)

## 4) Test before removing fallback access

From your remote machine, SSH to the Tailscale IP:

```bash
ssh youruser@100.x.y.z
```

Only after that works should you remove any old “allow ssh” rules that permit access from everywhere else. That prevents accidental lockout. [supun](https://supun.io/tailscale-ssh-restrict)

## 5) Optional hardening

If you want stronger control than network-level restriction alone, you can also use Tailscale SSH, which authenticates SSH access through Tailscale policy instead of your local SSH keys. For a small kiosk box, though, plain OpenSSH over Tailscale plus UFW is already a very strong setup. [tailscale](https://tailscale.com/docs/features/tailscale-ssh)

## Suggested final policy

- OpenSSH installed.
- Password login disabled.
- `tailscale0` allowed on TCP 22.
- No public WAN SSH.
- SSH used only through Tailscale. [tailscale](https://tailscale.com/docs/install/linux)

One note: Tailscale generally takes care of secure transport, but UFW is what enforces your “VPN only” exposure on the machine itself. [github](https://github.com/tailscale/tailscale/issues/11033)

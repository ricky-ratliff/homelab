# Homelab Documentation

![Tux Building Server](/Web/rickyratliff.com/img/tux-building-server-4.png)

## rklab.lan

I like to self-host applications and services for personal use and do projects to learn and experiment with various technologies. Each section below provides a brief overview and links to the full documentation for each of my projects.

## Network Projects

### Managed Layer 2 Switch Project

#### Hardware Info

- Make/Model: Brocade ICX-6430-C12
- Features: Compact, fanless, managed switch with two 1 GbE RJ-45 and two 1 GbE SFP ports for uplink and twelve 1 GbE RJ-45 ports with four PoE/PoE+ capable ports.

#### Project Summary

This was my first physical managed switch. I have worked with virtual networks on various hypervisors, but I knew this was going to be a different process. As expected, I had some issues (and learned a lot) while configuring this switch. I found this 12-port gigabit switch with PoE on eBay for $30 and figured it was worth a shot.

This model is *'End of Life'* according to the Ruckus [web page](https://support.ruckuswireless.com/products/121-ruckus-icx-6430-and-6450-campus-switches#f-product-facet=ICX-6430-6450&f-source=Documentation) for the product. However, they still provide software and documentation downloads as of September 2025.

The best resource for getting this thing up and running was [Jon Sands' website](https://fohdeesha.com/docs/index.html). I highly recommend reading and following along with his Brocade configuration guides carefully.

Full Project Documentation: [My Brocade ICX-6430-C12 Documentation Github Repo](https://github.com/ricky-ratliff/brocade-ICX-6430-C12.git)

## Server Projects

[**All Server Documentation**](./Servers/)

### rknix-t640

This device is an HP thin client running Ubuntu Server. I plan to use it as my homelab DMZ edge router plus run services (DHCP, DNS, Tailscale/Headscale, UFW firewall, Grafana for monitoring and logs)

[t640 Documentation](./Servers/t640.md)

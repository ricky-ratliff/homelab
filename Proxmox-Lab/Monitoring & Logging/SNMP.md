# SNMP

I am using SNMP as part of the observability toolset to provide monitoring, logging, and alerts for the Brocade ICX-6430-C12 on the t640 Ubuntu Server with Grafana.

## Resources

- [Tutorial: Grafana SNMP on Ubuntu](https://techexpert.tips/grafana/grafana-monitoring-snmp-devices/)
- [Tutorial: LibreNMS with InfluxDB and Grafana](https://docs.librenms.org/Extensions/metrics/InfluxDB/)

## rknix-t640

:memo: [t640 Grafana Configuration Notes](../Servers/t640.md#grafana)

## rknet-bro

### Tasks

- [ ] Review SNMP in Switch Admin Guide (p.145) and document commands and current configurations
- [ ] Configure Traps
- [ ] Configure Trap Receiver
- [ ] Open UDP 162 on both devices
- [ ] Secure access, confirm v3 support (p.148)

### Commands & Current Configs

- `show snmp server`:
  - Status: Enabled
- `show snmp engineid`:
  - Local SNMP Engine ID: 800007c703609c9f384bb6
- `show snmp user` `show snmp group`:
  - none configured yet

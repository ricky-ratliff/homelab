# t640 DNS (BIND9) Configuration Files

## External

:file_folder: File Location: `/etc/bind/named.conf.options`

These are the forwarding addresses the bind9 DNS service uses to make external DNS requests and then cache the responses and use those for future requests.

``` txt
...
forwarders {
  1.1.1.1;
  1.0.0.1;
};
```

## Internal

:file_folder: File Location: `/etc/dhcp/dhcpd.conf`

Ensures each lease includes the internal DNS server address.

``` txt
...
option domain-name-servers 10.45.1.3;
```

### Master Zone

:file_folder: File Location: `/etc/bind/named.conf.local`

``` sh
zone "rklab.lan" IN {
    type master;
    file "/etc/bind/net.rklab.lan";
};
```

### Forward Zone

:file_folder: Forward Zone File Location: `/etc/bind/net.rklab.lan`

#### Forward Zone Updates

##### :calendar: 05/24/2025

- Added RICKY-PC A record
- Updated serial `202208162` :arrow_right: `202208163`

```txt
$TTL 1D 
@ IN SOA rklab.lan. hostmaster.rklab.lan. ( 
 
202208163; serial 
 
8H ; refresh 
4H ; retry 
4W ; expire 
1D ) ; minimum 
IN A 10.45.1.3 
; 
@ IN NS rknix-t640.rklab.lan. 
rknix-t640      IN  A   10.45.1.3
rknix-pve       IN  A   10.45.1.100
RICKY-PC        IN  A   10.45.1.200
```

### Reverse Zone

#### Reverse Zone Updates

##### 05/24/2025 :calendar:

- Added RICKY-PC PTR Record
- Updated serial `202208162` :arrow_right: `202208163`

```txt
$TTL 86400
@   IN  SOA rklab.lan. hostmaster.rklab.lan. (
        2025051802 ; Serial
        3600       ; Refresh
        1800       ; Retry
        1209600    ; Expire
        86400 )    ; Minimum TTL

    IN  NS  rknix-t640.rklab.lan.

100 IN  PTR rknix-pve.rklab.lan.
200 IN  PTR RICKY-PC.rklab.lan.
```

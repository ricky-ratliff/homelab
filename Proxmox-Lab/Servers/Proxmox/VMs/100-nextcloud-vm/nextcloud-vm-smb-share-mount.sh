#! /bin/bash

# Script to mount an SMB share in a Nextcloud VM at /mnt/smb-share/ on Proxmox VE 9

# Mount the SMB share:  

mount -t cifs //192.168.1.2/Family/ /mnt/smb-share/Family/ -o username=Ricky,password=kADen5307*87,vers=3.0,uid=$(id -u www-data),gid=$(id -g www-data)  
   
# Use `vers=2.1` or `vers=1.0` if vers=3.0 fails (test with `smbclient -L //<windows-ip> -U <username>`).
# The `uid`/`gid` options ensure files are owned by Nextcloud's web user (www-data) for seamless integration.

# For persistence across reboots, add an entry to `/etc/fstab`: `//<windows-ip>/<share-name> /mnt/smb-share cifs credentials=/etc/smbcreds,vers=3.0,uid=33,gid=33 0 0` (create `/etc/smbcreds` with `username=...` and `password=...`, then `sudo chmod 600 /etc/smbcreds`).

# Verify the mount:  
ls /mnt/smb-share
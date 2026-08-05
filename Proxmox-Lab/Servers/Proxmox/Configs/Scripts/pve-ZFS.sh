#!/bin/bash
set -e
############################################################################
# pve-ZFS Script Notes                                                     #
############################################################################
# Script to set up ZFS pools and datasets on Proxmox VE server
#   Assumes the following disk configuration:
#   - 1TB SATA SSD (/dev/sdb) for VM storage (vmpool)
#   - 2x 4TB HDDs (/dev/sda, /dev/sdc) for media and backups (mediapool)
#       - RAID1 mirror
#   Adjust device names as necessary for your setup
############################################################################

### 0. Wipe SSD and both HDDs before creating pool (destructive!) ###

# Warning! The `wipefs` command **destroys data** on the specified
# drives. Double-check device names (`sda`, `sdb`, `sdc`) before running

# wipefs -a /dev/sda
wipefs -a /dev/sdb
# wipefs -a /dev/sdc
# sgdisk --zap-all /dev/sda
sgdisk --zap-all /dev/sdb
# sgdisk --zap-all /dev/sdc

### 1. Create ZFS Pools ###

# vmpool on 1TB SATA SSD (fast lab workloads)
zpool create -f \
	-o ashift=12 \
	-O compression=lz4 \
	-O atime=off \
	-O xattr=sa \
	-O acltype=posixacl \
	vmpool /dev/sdb

# mediapool as RAID1 mirror on 2x 4TB HDDs (media + backups)
# zpool create -f \
# 	-o ashift=12 \
# 	-O compression=lz4 \
# 	-O atime=off \
# 	-O xattr=sa \
# 	-O acltype=posixacl \
# 	mediapool mirror /dev/sda /dev/sdc

### 2. Create Datasets for vmpool (SSD) ###

zfs create -o mountpoint=/vmpool/images vmpool/images    # for generic VM/CT disk images
zfs create -o mountpoint=/vmpool/ct vmpool/ct            # container storage
zfs create -o mountpoint=/vmpool/vm vmpool/vm            # virtual machine disks
zfs create -o mountpoint=/vmpool/iso vmpool/iso          # ISO storage

### 3. Create Datasets for mediapool (HDD Mirror) ###

# Streaming media → compression=off (video already compressed)
zfs create -o mountpoint=/mediapool/streaming \
		   -o compression=off \
		   mediapool/streaming
# Backups → compression=lz4 saves space
zfs create -o mountpoint=/mediapool/homelab-backups \
		   -o compression=lz4 \
		   mediapool/homelab-backups
# User project files (Windows share) → ACLs + xattr
zfs create -o mountpoint=/mediapool/kaden \
		   -o compression=lz4 \
		   -o acltype=posixacl \
		   -o xattr=sa \
		   mediapool/kaden
# Photo/video archives → gzip-9 for maximum space savings
zfs create -o mountpoint=/mediapool/archives \
		   -o compression=gzip-9 \
		   mediapool/archives

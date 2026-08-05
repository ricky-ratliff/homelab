# Create Datasets for mediapool (HDD Mirror)

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
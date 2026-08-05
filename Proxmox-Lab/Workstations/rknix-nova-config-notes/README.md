# rknix-nova Configuration Notes

## About

Documentation repository for my Linux workstation configuration, dotfiles, and backup system notes.

## Backups

### Important Folders

#### Bash

- Alias definitions: `~.bash_aliases`
- Documents
- ssh keys

1. First backup
   1. Set up external hard drive as shared network drive and connected from Deja Dup using SMB
      1. `/run/user/1000/gvfs/smb-share:server=ricky-pc,share=seagate%20backups`

## Configurations

### Pywal

**:gear: JSON Color Scheme Config File Location**: `~/.cache/wal/schemes/`

1. Running `wal -i [/path/to/image]` generates a new color scheme from the specified image.
2. Pywal creates the associated **json** file `~/.cache/wal/schemes/_path_to_image_file_name_of_image_jpg.json` which is then used to generate the various application-specific configuration files to apply the color scheme.
3. This json file can be edited to change the color scheme manually. To apply the changes and update all of the associated application-specific configuration files with the changes, run `wal --theme [~/.cache/wal/schemes/_path_to_image_file_name_of_image_jpg.json]`.

### GNOME Software

- gnome terminal
- gnome tweaks
- gnome extensions

### Ubuntu system settings

- fonts
- keyboard shortcuts
  - night light

- Ricky-PC E$ SMB/CIFS Mounted Shared Folders
  - /mnt/Plex

```sh
ricky@rknix-nova:~$ sudo mkdir /mnt/Plex
ricky@rknix-nova:~$ sudo mount -t cifs //192.168.1.162/Plex /mnt/Plex -o username=windows_username,password=windows_password
ls -lah /mnt/Plex
ricky@rknix-nova:~$ lsl /mnt/Plex/
total 8.0K
drwxr-xr-x 2 root root 4.0K Oct  8  2024  .
drwxr-xr-x 3 root root 4.0K Jun 21 21:24  ..
drwxr-xr-x 2 root root    0 Mar  6  2024 'Archived Downloads'
drwxr-xr-x 2 root root    0 Mar 31  2024 'Family Videos'
drwxr-xr-x 2 root root    0 Dec 16  2023 'Health and Wellness'
drwxr-xr-x 2 root root    0 Jun  4 15:26  Movies
drwxr-xr-x 2 root root    0 May  3 16:08 'Music Documentaries and Live Shows'
drwxr-xr-x 2 root root    0 Nov  1  2024  Posters
drwxr-xr-x 2 root root    0 Apr 18 12:24 'TV Shows'

```

## Packages

- abs-guide
- ansible
- apache2
- cowsay
- deja-dup
- discord
- docbook-xml
- docker
- duplicity
- dynamips
- enchant2
- evince
- evolution-data-server
- fastfetch
- figlet/libcaca/toilet
- firefox
- flatpak
- fontconfig
- gh-cli
- gimp
- mysql
- nftables (netfilter)
- nodejs
- openssl
- php
- python
- python3-markdown
- pywal
- vscode
- anki
- calibre
- libreoffice
- mullvad
- remmina
- qemu/kvm
- qt5
- rhythmbox
- rsync
- tcpdump
- thunderbird
- tmux
- toilet
- gns3
- vmware workstation
- inkscape
- local (wordpress)
- librewolf
- filezilla
- wireshark

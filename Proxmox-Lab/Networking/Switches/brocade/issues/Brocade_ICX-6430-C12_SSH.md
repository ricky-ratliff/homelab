# Brocade ICX-6430-C12 SSH Setup & Troubleshooting

## Table of Contents

- [Brocade ICX-6430-C12 SSH Setup \& Troubleshooting](#brocade-icx-6430-c12-ssh-setup--troubleshooting)
  - [Table of Contents](#table-of-contents)
  - [Ubuntu SSH Commands](#ubuntu-ssh-commands)
    - [View/Follow (SSH) System Logs](#viewfollow-ssh-system-logs)
  - [Brocade SSH Commands](#brocade-ssh-commands)
  - [Config Files](#config-files)
    - [Brocade SSH Configs](#brocade-ssh-configs)
    - [Ubuntu ~/.ssh/config File](#ubuntu-sshconfig-file)
    - [Ubuntu tftpd-hpa config file](#ubuntu-tftpd-hpa-config-file)
  - [Issue #1: TFTP Public Key](#issue-1-tftp-public-key)
    - [Ubuntu SysLog Errors](#ubuntu-syslog-errors)
    - [Switch Errors](#switch-errors)
    - [Resolution](#resolution)
    - [Cleaning Up](#cleaning-up)
  - [Issue #2: Private Key Invalid Format](#issue-2-private-key-invalid-format)
    - [Current Key](#current-key)
    - [New Key](#new-key)
  - [Issue #3: Error in libcrypto When Loading Key](#issue-3-error-in-libcrypto-when-loading-key)
    - [3.1 Issue Description](#31-issue-description)
    - [3.2 Investigate \& Identify Potential Cause(s)](#32-investigate--identify-potential-causes)
      - [Review Brocade SSH Documentation](#review-brocade-ssh-documentation)
    - [3.3 Resolution](#33-resolution)
      - [Ubuntu Changes](#ubuntu-changes)
        - [SSH Key Changes](#ssh-key-changes)
        - [TFTPD-HPA Changes](#tftpd-hpa-changes)
      - [ICX-6430-C12 Changes](#icx-6430-c12-changes)

## Ubuntu SSH Commands

- Show SSH version: `ssh -V`
- Show SSH key length: `ssh-keygen -l -f ~/.ssh/id_rsa`
  - The key length is the first returned value
- Restart sshd service (after updating config file): `sudo systemctl restart sshd`

### View/Follow (SSH) System Logs

- `tail -F /var/log/syslog`
- `journalctl -fu ssh`

## Brocade SSH Commands

- Display SSH configuration: `show ip ssh config`
- Display currently loaded public keys: `show ip client-pub-key`
- Clear public keys: `clear public-key`
- Load public key from a TFTP server: `ip ssh pub-key-file tftp 1.2.3.4 public_key_file_name`

## Config Files

### Brocade SSH Configs

```shell
rknet-bro(config)#show ip ssh config
SSH server                 : Enabled
SSH port                   : tcp\22
Host Key                   :  RSA 2048
Encryption                 : aes256-cbc, aes192-cbc, aes128-cbc, aes256-ctr, aes192-ctr, aes128-ctr, 3des-cbc
Permit empty password      : No
Authentication methods     : Password, Public-key, Interactive
Authentication retries     : 3
Login timeout (seconds)    : 120
Idle timeout (minutes)     : 0
SCP                        : Enabled
SSH IPv4 clients           : All
SSH IPv6 clients           : All
SSH IPv4 access-group      :
SSH IPv6 access-group      :
SSH Client Keys            :
```

### Ubuntu ~/.ssh/config File

```shell
Host rknet-bro
   Hostname 10.45.1.2
   IdentitiesOnly yes
   IdentityFile ~/.ssh/id_rsa
   KexAlgorithms +diffie-hellman-group1-sha1
   PubkeyAcceptedKeyTypes=+ssh-rsa
   HostKeyAlgorithms=+ssh-rsa
```

### Ubuntu tftpd-hpa config file

```shell
# /etc/default/tftpd-hpa

TFTP_USERNAME="tftpd-hpa"
TFTP_DIRECTORY="/home/ricky/.ssh/"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure -vvvv"
```

## Issue #1: TFTP Public Key

Public key file transfer via tftpd-hpa from Ubuntu 22.04 to Brocade ICX 6430-C12 fails.

### Ubuntu SysLog Errors

```shell
ricky@rknixnova:~$ tail -F /var/log/syslog
Oct 16 19:00:48 rknix-nova kernel: [40652.357182] [UFW BLOCK] IN=wlp0s20f3 OUT= MAC=bc:09:1b:05:fd:a7:60:9c:9f:38:4b:b6:08:00 SRC=10.45.1.2 DST=10.45.1.224 LEN=67 TOS=0x00 PREC=0x00 TTL=64 ID=61 DF PROTO=UDP SPT=1027 DPT=69 LEN=47 
```

### Switch Errors

```shell
rknet-bro(config)#TFTP: received error request -- code 0 message Permission denied
SSH tftp client public key failed!
```

```shell
rknet-bro(config)#ip ssh pub-key-file tftp 10.45.1.224 id_rsa.pub
downloading public key file, please wait...
rknet-bro(config)#ERROR: key# 1 must end with ---- END SSH2 PUBLIC KEY ----
Error in SSH Public Key file!
```

### Resolution

Changed TFTP_USERNAME to "nobody" and restarted the tftpd-hpa server.

``` shell
# /etc/default/tftpd-hpa

TFTP_USERNAME="nobody"
TFTP_DIRECTORY="/home/ricky/.ssh/"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure -vvvv"
```

Changed ~/.ssh directory permissions and invoked tail in follow mode on /var/log/syslog before attempting to download the public key over tftp on the switch again to monitor the attempt.

```shell
~$ chmod 777 ./.ssh

Oct 16 21:31:36 rknix-nova in.tftpd[67453]: RRQ from 10.45.1.2 filename rknix@icx-6430-c12.pub

rknet-bro(config)#ip ssh pub-key-file tftp 10.45.1.224 rknix@icx-6430-c12.pub
downloading public key file, please wait...
rknet-bro(config)#Public key written

Finished downloading public key file!
```

I finalized the change on the switch by writing the config to memory with `write memory`.

### Cleaning Up

With the public key file now loaded on the switch, I needed to revert some changes to keep the systems secure.

- Reset permissions on ~/.ssh directory `chmod 700 ~/.ssh`
- Reset permissions on public key file `chmod 644 ~/.ssh/key-file.pub`
- Re-enabled UFW `sudo ufw enable`
- Disabled tftpd-hpa `sudo systemctl disable tftpd-hpa`

## Issue #2: Private Key Invalid Format

Attempting to ssh into Brocade ICX 6430-C12 from Ubuntu 22.04 produces the following error:

```shell
ssh_dispatch_run_fatal: Connection to 10.45.1.2 port 22: invalid format
```

### Current Key

- Bit length is 3072 bits, should be 2048 per switch specifications.
  - ssh-keygen -l -f ./id_rsa
3072 SHA256:zTvX5mhtOjOJJA4WMXkfrgNuN+Ca50kuv5W1JzyijiY ricky@rknix-nova (RSA)

### New Key

- ssh-keygen
  - [x] Use RSA: `-t rsa`
  - [x] Set to 2048 bits: `-b 2048`
  - [x] Must have a passphrase/password. Brocade ssh config parameter `Permit empty password` is set to `no`.
    - [x] Set when prompted during key generation

For the switch to accept your public key file it should start with:

---- BEGIN SSH2 PUBLIC KEY ----

and end with:

---- END SSH2 PUBLIC KEY ----

- Updated public and private keys with begin/end lines, confirmed they both ended with a newline, and successfully loaded the public key on the switch.
- Successfully connected to the switch with ssh and root password.

``` shell
ricky@rknix-nova:~/.ssh$ ssh root@rknet-bro 
Load key "/home/ricky/.ssh/id_rsa": error in libcrypto
(root@10.45.1.2) Password:
(root@10.45.1.2) Password:
SSH@rknet-bro>
```

## Issue #3: Error in libcrypto When Loading Key

### 3.1 Issue Description

Error in libcrypto when loading key. The key exchange process succeeds indicating that the correct public key has been loaded, but there is an issue preventing authentication.

```shell
ricky@rknix-nova:~$ ssh root@rknet-bro -v
OpenSSH_8.9p1 Ubuntu-3ubuntu0.10, OpenSSL 3.0.2 15 Mar 2022
... # ommited key exchange success logs
... # key is located and accepted, but authentication fails
Load key "/home/ricky/.ssh/id_rsa": error in libcrypto
debug1: Next authentication method: keyboard-interactive
(root@10.45.1.2) Password:
```

### 3.2 Investigate & Identify Potential Cause(s)

#### Review Brocade SSH Documentation

 I noticed that the Brocade Security Guide indicates that the key should be password-protected on the local host on page 91. I was unsure if I set a passphrase when I created the key, so I used `ssh-keygen` with the `-p` (passphrase) parameter to see if I was prompted for the current passphrase:

``` shell
~/.ssh/$ ssh-keygen -p -f ./id_rsa.pub 
```

The output was suprising, but confirmed that I had not set a passphrase on the key and let me know that there were permission issues as well:

``` shell
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@         WARNING: UNPROTECTED PRIVATE KEY FILE!          @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
Permissions 0644 for './id_rsa.pub' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Failed to load key ./id_rsa.pub: bad permissions
```

### 3.3 Resolution

Due to the lack of passphrase and bad permissions I decided the best course of action was to discard the existing public key and replace it with a new key with the proper configurations.

#### Ubuntu Changes

##### SSH Key Changes

- Created ~/.ssh/old_keys directory and moved bad key pair into it.
- Generated new 2048-bit RSA key pair with a passphrase
  - `ssh-keygen -t rsa -b 2048`
- Updated ~/.ssh/config file with new key name
- Made necessary changes to public key format
  - Added begin/end lines to new public key file per Brocade SSH key requirements documentation
  - Must begin with `---- BEGIN SSH2 PUBLIC KEY ----` and end with `---- END SSH2 PUBLIC KEY ----`
    - Using nano, I had to move `---- END SSH2 PUBLIC KEY ----` from the end of the key which is entirely on Line 1 to Line 2 and confirmed file ends with a new line

##### TFTPD-HPA Changes

- Disabled UFW on Ubuntu to allow tftp transfer of new key
  - `sudo ufw disable`
- Updated /etc/hosts.allow to allow inbound local subnet traffic to tftpd-hpa service
  - `in.tftpd: LOCAL, 10.45.1.0/24`
- Updated TFTP_USERNAME in tftpd-hpa config file `/etc/default/tftpd-hpa` to match the user with access to the files located in the TFTP_DIRECTORY:

```shell
# /etc/default/tftpd-hpa

TFTP_USERNAME="ricky"
TFTP_DIRECTORY="/home/ricky/.ssh/"
TFTP_ADDRESS="0.0.0.0:69"
TFTP_OPTIONS="--secure -vvvv"
```

#### ICX-6430-C12 Changes

- Removed old key from brocade
  - `ip ssh pub-key-file remove`
- Load new key from Ubuntu using tftpd-hpa

``` shell
SSH@rknet-bro(config)#ip ssh pub-key-file tftp 10.45.1.224 id_rsa_rknet-bro.pub
downloading public key file, please wait...
SSH@rknet-bro(config)#Public key written

Finished downloading public key file!
```

- Verified new public key
  - `show ip client-pub-key`
- Disconnected SSH session and re-connected to confirm the new key was configured correctly and functioning without errors.
- Saved changes to startup config file with `write memory`

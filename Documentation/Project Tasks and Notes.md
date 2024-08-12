# Project Tasks and Notes

## Network
### Construct a closed network. 
- [x] Turn off the windows firewall. 
- [x] Create two networks/VLANs (desktops and servers)
- [x] Install Windows Server (VM or standard hardware dealer's choice) GUI Mode.
- [x]  Install another server, single NIC on the server VLAN

## Install AD
- [x] Create your first active directory domain controller. Install this in GUI mode
- [x] Create another server but this time make it a core server. Make it a domain controller
- [x] Test AD replication via the gui and cmd
- [x] Create an OU for your workstations, create an OU for your users, and an OU for groups. From now on, any new computer or new user account must go into their respective OU. DO NOT MOVE THE DOMAIN CONTROLLERS FROM THE DOMAIN CONTROLLER OU.

## Configure DNS
- [x] Check out DNS. Do you have a reverse look up zone? No? Then set it up.
- Check out DNS. Records can get old and out of date and will screw up name to ip resolution. Make it so that scavenging happens automatically.
- [x] You need to block facebook.com via windows DNS. Make it so that when a DNS look up is performed, computers use a loop back address. Test this via cmd to make sure it resolves as expected.

## Configure DHCP
- [x] Set up DHCP on the first domain controller.
- [x] Set up a scope to hand out IPs for the Desktop VLAN. Make it so that this DHCP scope will be able to give endpoints the information they need networking wise to join a domain
- [x] Install a Windows desktop PC on the desktop VLAN
  - Your desktop's aren't getting IPs. Why? (hint: it's a routing/broadcast/relay issue)
- [x] Join that desktop to the domain
- [ ] Now that you're getting IPs from your DHCP server, configure DHCP clustering. Loadbalancing or failover is your choice. Now test it.

## Configure AD
- [x] Create a non-domain admin account in AD. Fill out the whole profile once the account is created.
- [x] Login to that desktop as a regular AD user and an Admin user. Try to install software under the non-admin account first and then the admin account. What's the difference?
- [x] Create another non-admin account. Make this non-admin user a local admin on that computer. Who else is also a local admin before you make any changes,
- [x] Review the attributes of that account in AD. You'll need advanced features for this.
- [x] Create an AD group. Add the first non-admin account to this group.
- [x] On that desktop, install the RSAT tools so you can remotely manage another computer
- [x] Setup remote management on the core server so that it can be managed from the MMC of another computer (there are a number of ways to do this)
- [x] Find out what server is holding the FSMO roles via the gui and the command prompt.
- [x] Split the FSMO roles between the servers. Try to keep forest level and domain level roles together.
- [x] On one of the domain controllers, create a file share set it so that only administrators and the second non admin account have access to it. Create another folder and give only the AD group you created permissions.
  - [x] Create A: drive partition and map "Adminitration" folder to it

## Configure Group Policy
- [x] Use group policy to map both shares as network drives as a computer policy to the desktops.
- [x] Login to the desktop as the first domain user. Do you see the network drive mapped in windows explorer? No? Use gpresult to find out why. If you do see it, try to access the drive. You should be denied if you set permissions correctly. Login as the second domain user, they should be able to open the mapped drive.
- [x] What if the account in the group tries to access the second drive? You should be able to get in.
- [x] login to the workstation as the second non-admin account. You should not have access to this drive because you are not in the group. Do not log off. Add this account to the group. Can you access the drive now? No? Logoff and login back in. Can you access the drive now?
- [x] Remove the share from the domain controller. We don't like putting shares on domain controllers if we don't have to.

## Add Additional DCs
- [ ] Build out another two servers and join it to the domain as member servers.
- [ ] Install DFS and File server roles/features on both servers.
- [ ] Create a file share on bother servers with the same folder name. Create files on both servers. Make sure they are different. (i.e server1 will have "TextDoc01", server 2 will have "TextDoc02" in their shares).
- [ ] Create a DFS name space. Add those shares to the name space.
- [ ] On a domain joined work station, navigate to the DFS namespace you created. You should be able to see both files.
- [ ] Create a DFS Replication group. Make it so that you have two way replication. You should now see both files on both servers. Make a change on one server and see if it replicates to another server. Does it work? Great. (you can shut down the file servers for now if you want or use them for the next step)

## Create WDS Server
- [ ] Create another server, join it to the domain, install Windows Deployment Service (WDS) and Windows Server Update Service (WSUS). You can choose to use the file servers you've already created instead of building out another VM. You only need one file server.
- [ ] Configure WDS so that you can PXE boot to it on the network. Make any required changes to routing and DHCP if need be.
- [ ] Upload an image to WDS for PXE deployment. Use WAIK and sysprep if you need to. (I haven't done this in the long time so you might not need sysprep anymore with WAIK, look it up)
- [ ] Create a new desktop VM but do not install an OS on it. Instead tell it to perform a PXE boot when you turn it on, have it install the OS from here.
- [ ] Configure WSUS so that you will only download Security updates for the desktop and server OS's ( highly recommend that you do not download any updates if you have access to the internet from this server)
- [ ] Bonus points, install WSUS on another server and create a downstream server
- [ ] Create some groups in WSUS. Servers and workstations will do nicely.
- [ ] Create a new group policy that points workstations into the WSUS workstation group, points to WSUS for updates, and stop workstations from automatically downloading updates.
- [ ] Read up on approving and pushing updates since the current assumption is that there are no updates to be pushed in this enclosed test network since there is no internet access to download them. I believe there is a way to manually add updates to WSUS but I'm a bit foggy on that. Research it.
- [ ] Do the same for servers.

## PowerShell
- [x] Create a new AD user via powershell.
- [ ] Create a new AD group via powershell.
- [ ] Print a list of all domain users and computers in powershell, names only
- [ ] Use powershell to pull a list of users who have new york as their office. If no users have new york listed as their - office, use powershell to set that attribute and then pull users who have new york as their office.
- [ ] Remove a user account from AD using powershell
- [ ] Add a user to a group using powershell
- [x] Provision new AD users via a CSV in powershell
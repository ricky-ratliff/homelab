# Proxmox PCI Passthrough Config

The RX 580 is a solid card for passthrough in Proxmox VE, but there are some important details when it comes to Plex/Jellyfin and HEVC (H.265) hardware acceleration:

## Plex/Jellyfin Hardware Acceleration Notes

- RX 580 **can** be used for H.264 encoding/decoding.
- RX 580 **cannot** encode HEVC — decode only.
- Plex officially only supports Intel QuickSync and NVIDIA NVENC for HEVC hardware transcoding. Jellyfin (FFmpeg-based) supports AMD VAAPI better, but still limited by the card’s hardware blocks.

:warning:  Plex on Linux doesn’t support AMD GPU encode

## Steps to Enable GPU Passthrough with RX 580

### 1. Verify IOMMU is Enabled

Check your kernel boot parameters:

```bash
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT
```

You should see something like: `GRUB_CMDLINE_LINUX_DEFAULT="quiet amd_iommu=on iommu=pt"`

Update grub and initramfs if you made changes:

```bash
update-grub
update-initramfs -u -k all
reboot
```

### 2. Check the GPU PCI IDs

Run `lspci -nnk | grep VGA` for graphics PCI ID and `lspci -nnk | grep Audio` for audio PCI ID.

```bash
root@rknix-pve:~# lspci -nnk | grep VGA
06:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Ellesmere [Radeon RX 470/480/570/570X/580/580X/590] [1002:67df] (rev e7)

root@rknix-pve:~# lspci -nnk | grep Audio
06:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Ellesmere HDMI Audio [Radeon RX 470/480 / 570/580/590] [1002:aaf0]
        Subsystem: Micro-Star International Co., Ltd. [MSI] Ellesmere HDMI Audio [Radeon RX 470/480 / 570/580/590] [1462:aaf0]
08:00.3 Audio device [0403]: Advanced Micro Devices, Inc. [AMD] Family 17h (Models 00h-0fh) HD Audio Controller [1022:1457]
        Subsystem: Gigabyte Technology Co., Ltd Family 17h (Models 00h-0fh) HD Audio Controller [1458:a182]
```

You’ll need **both IDs** (GPU + HDMI audio).

### 3. Bind GPU to `vfio-pci`

Edit or create `/etc/modprobe.d/vfio.conf`:

```bash
options vfio-pci ids=1002:67df,1002:aaf0 disable_vga=1
```

Update initramfs:

```bash
update-initramfs -u -k all
reboot
```

### 4. Verify VFIO Binding

After reboot:

```bash
lspci -nnk -d 1002:67df
lspci -nnk -d 1002:aaf0
```

Output should show: `Kernel driver in use: vfio-pci`

### 5. Add GPU to VM

In Proxmox web UI:

1. Edit the VM → **Hardware** → **Add** → **PCI Device**.
2. Select the RX 580 (and its audio device).
3. Check:

   - **All Functions**
   - **Primary GPU** (if needed)
   - **PCIe**
   - **ROM-Bar** (if VM won’t boot without it, you might need to dump GPU BIOS and specify it)

### 6. Configure Guest

- **Windows VM**: Install AMD Adrenalin drivers. Plex/Jellyfin should see the GPU for hardware acceleration.
- **Linux VM**: Install Mesa/AMDGPU drivers. Then enable VAAPI in Jellyfin or Plex.

You are missing `/dev/dri` because the kernel DRM/graphics driver for your AMD card is not loaded, so Proxmox never creates the GPU device nodes. The immediate “device path” problem is really “get the driver and DRM devices working on the host first”.

### Check that the GPU driver is loaded

Run these on the Proxmox host:

```bash
lspci -nnk -d 1002:67df
06:00.0 VGA compatible controller [0300]: Advanced Micro Devices, Inc. [AMD/ATI] Ellesmere [Radeon RX 470/480/570/570X/580/580X/590] [1002:67df] (rev e7)
        Subsystem: Micro-Star International Co., Ltd. [MSI] Radeon RX 580 ARMOR 8G OC [1462:3418]
        Kernel driver in use: vfio-pci
        Kernel modules: amdgpu
```

Look for a `Kernel driver in use:` line. For an RX 470/480/570/580/590 it should be `amdgpu`. If it shows `vfio-pci` or nothing, the card is either bound to VFIO or has no driver.

Also check:

```bash
lsmod | grep amdgpu
dmesg | grep -i amdgpu
```

If `amdgpu` is not present or dmesg shows errors, the driver is not active.

```bash

```

### Undo VFIO binding (if used)

If you previously passed the card to a VM, it may be bound to `vfio-pci`, which prevents `/dev/dri` from appearing.

Check for AMD/VFIO lines in:

- `/etc/modprobe.d/*vfio*.conf`
- `/etc/modprobe.d/blacklist.conf` (or similar, e.g. `blacklist-amdgpu.conf`)
- `/etc/modules`

If `amdgpu` is blacklisted or the PCI ID `1002:67df` is listed under `vfio-pci`, comment those lines out, then run:

```bash
update-initramfs -u
reboot
```

After reboot, re-run `lspci -nnk -d 1002:67df` and confirm the kernel driver is now `amdgpu`.

### Ensure firmware and packages are installed

On Proxmox 9 (Debian-based), make sure non-free firmware and Mesa bits are installed so `amdgpu` can initialize:

```bash
apt update
apt install firmware-amd-graphics mesa-vulkan-drivers mesa-vdpau-drivers
reboot
```

If you see amdgpu errors in `dmesg` after this, they usually mention missing firmware files; the above packages normally provide them.

### Confirm `/dev/dri` and find the path

Once `amdgpu` loads correctly, the kernel will create DRM nodes:

```bash
ls -l /dev/dri
ls -l /dev/dri/by-path
```

You should then see something like:

- `/dev/dri/card0`
- `/dev/dri/renderD128`
- `/dev/dri/by-path/pci-0000:06:00.0-card -> ../card0`
- `/dev/dri/by-path/pci-0000:06:00.0-render -> ../renderD128`

For the Jellyfin LXC “Device Path”, use:

- `/dev/dri/card0`
- `/dev/dri/renderD128`

Those are the paths you add as device passthrough entries to the container.

### If you still do not get `/dev/dri`

If, after ensuring amdgpu is not blacklisted, firmware is installed, and the driver is shown as in use, you still have no `/dev/dri`, then:

- Check BIOS/UEFI:
  - Disable “headless”/serial-only or special GPU offload modes.
  - Ensure the PCIe GPU is enabled as a primary or at least active graphics device.
- Make sure no other service is grabbing the card in some unusual way:
  - `grep -i vfio /proc/cmdline` to ensure no `vfio-pci.ids=1002:67df` on the kernel line.
- As a last check, reboot with a clean Proxmox kernel (no extra parameters) and see if `/dev/dri` appears; once it does, the same device nodes are what you use as the device path for the Jellyfin LXC.

Once `/dev/dri` exists and you can see `card0`/`renderD128`, the original LXC passthrough steps for Jellyfin will work as described.

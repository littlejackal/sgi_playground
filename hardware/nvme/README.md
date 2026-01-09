# Migrating spinning disk to nVME + ZuluScsi

## Goals

The goal of this exercise is to yeet the noisy spinning rust from your SGI workstation. 

Since the SGI development team lacked access to a time machine, the PROM has no concept of an nVME controller, and thus can't use it to load a bootable kernel.

Your two most viable options are:

- TFTP boot your kernel
- Place your kernel on something the PROM understands

Since ZuluSCSI / BlueSCSI / SCSIKnife / SCSI2SD devices are plentiful and readily available, we'll choose the latter and have PROM boot from SCSI.

## Considerations

- The actual space requirements to accomplish this are minimal. The last kernel my 6.5.30 Octane2 compiled is 11mb. When you're sourcing an SD card to boot from, consider whether you'd like to use this partition for anything else.

- As of when I'm writing this, all SCSI emulators will force the SGI bus to Single Ended operation. If this is A Problem™ for you, consider a SCSI emulator which lives on your external SCSI bus and adjust the directions as needed.

- SGI workstations with an SCA SCSI bus will likely expect disks to be available at specific SCSI IDs. I have no idea what happens if you present a HD image with SCSI ID 4 on a ZuluSCSI inserted into a SCA slot with SCSI ID 2. Maybe nothing, maybe something dire. YMMV.

## Configuration

### ZuluSCSI Configuration

- Create blank image on SD card with SCSI ID 2
  - I'm using SCSI ID 2 so I can place the ZuluSCSI into the middle SCSI bay. Adjust as necessary.
  - HD2.img

### On your spinning disk

[IRIX nVME Driver](https://github.com/techomancer/irixnvme)

- Compile irixnvme
- Compile with BUILTIN=1
- autoconfig kernel and reboot

- Validate the driver is present in hinv -v:

```shell
Integral SCSI controller 2: Version WD33C93
Disk drive: unit 0 on SCSI controller 2 (unit 0)
```

- Partition the image you intend to use to boot your kernel
  - I'll just be using a standard rootdrive layout which is one big partition
  - Alternatives could be two partitions, one smaller for the kernel and one larger with the remainder of the SD card capacity to store whatever you like

```shell
fx -x -d /dev/rdsk/dks0d2vol
- r (repartition)
- ro (rootdrive)
```

- Format and mount the partition as /bootdev

```shell
mkfs_xfs /dev/rdsk/dks0d2s0
mkdir /boot
mount /dev/rdsk/dks0d2s0 /boot
```

- Populate the partition's headers, and preload /unix and /stand

```shell
cp /unix /boot/unix
mkdir /boot/stand
# Pull /bootdev/stand/* from the running system's volume headers
/etc/dvhtool -v get ide /boot/stand/ide /dev/rdsk/dks0d1vh
/etc/dvhtool -v get sash /boot/stand/sash /dev/rdsk/dks0d1vh
/etc/dvhtool -v get fx /boot/stand/fx /dev/rdsk/dks0d1vh
# Push the files to the Zulu's new volume headers
/etc/dvhtool -v creat /boot/stand/ide ide /dev/rdsk/dks0d2vh
/etc/dvhtool -v creat /boot/stand/sash sash /dev/rdsk/dks0d2vh
/etc/dvhtool -v creat /boot/stand/fx fx /dev/rdsk/dks0d2vh
```

### nVME Setup

- Format and (temporarily) mount the nVME as /nvme

```shell
mkfs_xfs /dev/rdsk/dks2d0s0
mkdir /nvme && mount /dev/dsk/dks2d0s0 /nvme
```

- Use xfsdump to clone the running system to /nvme

```shell
cd / ; xfsdump -l 0 -J - / | ( cd /nvme ; xfsrestore - . )
```

- Probably not needed since we won't be booting from this drive, but populate the volume headers too

```shell
/etc/dvhtool -v c /boot/stand/sash sash /dev/rdsk/dks2d0vh
/etc/dvhtool -v c /boot/stand/ide ide /dev/rdsk/dks2d0vh
/etc/dvhtool -v c /boot/stand/fx fx /dev/rdsk/dks2d0vh
```

- Lastly, let's prep fstab so that it mounts the ZuluSCSI into /boot on bootup

```shell
echo "/dev/dsk/dks0d2s0 /boot xfs rw 0 0" >> /etc/fstab
```

- Shut the system down and pull the spinning rust, hopefully for the last time

### PROM Setup

- Set your root nvram variable to the nVME's XFS partition
  - Use -p to persist across reboots

```shell
setenv -p root dks2d0s0
```

- If you are removing your spinning disk, PROM *should* automatically update the SystemPartition and OSLoadPartition, presumably by probing the SCSI bus and finding the ZuluSCSI's XFS partitions
  - If for some reason this isn't happening, you can modify both by hand

```shell
setenv -p SystemPartition xio(0)pci(15)scsi(0)disk(2)rdisk(0)partition(8)
setenv -p OSLoadPartition xio(0)pci(15)scsi(0)disk(2)rdisk(0)partition(0)
```

- A cold boot should now successfully load /unix from the ZuluSCSI, then use dks2d0s0 as /dev/root. If all went well, you are now booted from nVME

### Post-boot tweaking

#### Autoconfig

autoconfig tries to reconfigure your kernel on any system changes, systunes, etc. Since IRIX expects the kernel to be /unix this obviously causes some issues

- Make sure that /boot exists and that the ZuluSCSI successfully mounts into it at bootup
- First we'll symlink /boot/unix to /unix to make it available to anything which expects it there

```shell
rm /unix
ln -s /boot/unix /unix
```

- autoconfig itself is a script in /etc/init.d which governs the behaviour of lboot. We'll need to make some changes to change /unix references to /boot/unix
  - etc/autoconfig.diff can be applied to a standard 6.5.30 installation

- autoconfig will now create /boot/unix.install when it reconfigures the kernel. /etc/rc0 is respoonsible for installing any pending /unix.install kernel to /unix, so it also needs to be updated to reference /boot/unix.install and /boot/unix
  - etc/rc0.diff can be applied to a standard 6.5.30 installation

- You can test the auto-installation of a new kernel
  - issue `autoconfig -vf` and validate whether /boot/unix.install was created
  - issue `reboot` and validate whether /boot/unix has been replaced by /boot/unix.install
    - since /boot/unix.install is MOVED to /boot/unix, you may want to md5sum /boot/unix.install before you reboot

- TODO: Modify rc0 to create a backup of /boot/unix before it does a replacement
- TODO: Validate what else needs updating to /boot because it can't handle a /unix symlink. savecore maybe??

#### Additional usage

Since you're now likely using a multi-gigabyte card to store a handful of 11MB files, the absolute waste of it all is probably washing over you.

Consider what else you can do with all your newfound space.

Given that your nVME is likely way faster than the ZuluSCSI, I would probably not recommend anything user interactive. Depending on the size of your nVME and how much data you are carrying at any given time, I think that the extra SD card space could be a perfect target to keep a backup of your system root drive.

I created a /boot/rootclone directory and will be running an xfsbackup of my nVME root drive into it, likely via cron.

Now obviously if you have a 1TB nVME drive and a 32GB or 64GB SD card this is going to eventually capacity out, so excluding any large data could be a good strategy.

I'll update this repo as I come up with something resembling a usable implementation of this. 
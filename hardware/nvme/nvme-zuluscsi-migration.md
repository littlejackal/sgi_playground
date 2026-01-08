# Migrating spinning disk to nVME + ZuluScsi

```text
:::.    :::.:::      .::..        :  .,::::::  
`;;;;,  `;;;';;,   ,;;;' ;;,.    ;;; ;;;;''''  
  [[[[[. '[[ \[[  .[[/   [[[[, ,[[[[, [[cccc   
  $$$ "Y$c$$  Y$c.$$"    $$$$$$$$"$$$ $$""""   
  888    Y88   Y88P      888 Y88" 888o888oo,__ 
  MMM     YM    MP       MMM  M'  "MMM""""YUMMM

  .        :   :::  .,-:::::/ :::::::..    :::. :::::::::::::::    ...   :::.    :::.
;;,.    ;;;  ;;;,;;-'````'  ;;;;``;;;;   ;;`;;;;;;;;;;'''';;; .;;;;;;;.`;;;;,  `;;;
[[[[, ,[[[[, [[[[[[   [[[[[[/[[[,/[[['  ,[[ '[[,   [[     [[[,[[     \[[,[[[[[. '[[
$$$$$$$$"$$$ $$$"$$c.    "$$ $$$$$$c   c$$$cc$$$c  $$     $$$$$$,     $$$$$$ "Y$c$$
888 Y88" 888o888 `Y8bo,,,o88o888b "88bo,888   888, 88,    888"888,_ _,88P888    Y88
MMM  M'  "MMMMMM   `'YMUP"YMMMMMM   "W" YMM   ""`  MMM    MMM  "YMMMMMP" MMM     YM
```

---

```text
::::::::::..   :::  .,::      .:
;;;;;;;``;;;;  ;;;  `;;;,  .,;; 
[[[ [[[,/[[['  [[[    '[[,,[['  
$$$ $$$$$$c    $$$     Y$$$P    
888 888b "88bo,888   oP"``"Yo,  
MMM MMMM   "W" MMM,m"       "Mm,
```

### Fresh IRIX install

- Compile irixnvme
- Compile with BUILTIN=1
- autoconfig kernel and reboot

---

```text
::::::::: ...    ::: :::      ...    ::: .::::::.   .,-::::: .::::::. :::
'`````;;; ;;     ;;; ;;;      ;;     ;;;;;;`    ` ,;;;'````';;;`    ` ;;;
    .n[['[['     [[[ [[[     [['     [[['[==/[[[[,[[[       '[==/[[[[,[[[
  ,$$P"  $$      $$$ $$'     $$      $$$  '''    $$$$         '''    $$$$
,888bo,_ 88    .d888o88oo,.__88    .d888 88b    dP`88bo,__,o,88b    dP888
 `""*UMM  "YmmMMMM""""""YUMMM "YmmMMMM""  "YMmMY"   "YUMMMMMP""YMmMY" MMM
```

### ZuluSCSI Setup

- Create blank image on SD card with SCSI ID 2:
  - HD2.img

- Partition the image in IRIX

```shell
fx -x -d /dev/rdsk/dks0d2vol
- r (repartition)
- ro (rootdrive)
```

- Format and mount the partition as /bootdev

```shell
mkfs_xfs /dev/rdsk/dks0d2s0
mkdir /bootdev && mount /dev/rdsk/dks0d2s0 /bootdev
```

- Populate the partition's headers, and preload /unix and /stand

```shell
cp /unix /bootdev/unix
mkdir /bootdev/stand
# Pull /bootdev/stand/* from the running system's volume headers
/etc/dvhtool -v get ide /bootdev/stand/ide /dev/rdsk/dks0d1vh
/etc/dvhtool -v get sash /bootdev/stand/sash /dev/rdsk/dks0d1vh
/etc/dvhtool -v get fx /bootdev/stand/fx /dev/rdsk/dks0d1vh
# Push the files to the Zulu's new volume headers
/etc/dvhtool -v creat /bootdev/stand/ide ide /dev/rdsk/dks0d2vh
/etc/dvhtool -v creat /bootdev/stand/sash sash /dev/rdsk/dks0d2vh
/etc/dvhtool -v creat /bootdev/stand/fx fx /dev/rdsk/dks0d2vh
```

### nVME Setup

- Format and mount the nVME as /nvme

```shell
mkfs -d name=/dev/rdsk/dks2d0s0 -l internal,size=2048b -b size=1k
mkdir /nvme && mount /dev/dsk/dks2d0s0 /nvme
```

- Use xfsdump to clone the running system to /nvme

```shell
cd / ; xfsdump -l 0 -J - / | ( cd /nvme ; xfsrestore - . )
```

- Probably not needed since we won't be booting from this drive, but populate the volume headers too

```shell
/etc/dvhtool -v c /bootdev/stand/sash sash /dev/rdsk/dks2d0vh
/etc/dvhtool -v c /bootdev/stand/ide ide /dev/rdsk/dks2d0vh
/etc/dvhtool -v c /bootdev/stand/fx fx /dev/rdsk/dks2d0vh
```

### PROM Setup

- Set your root nvram variable to the nVME's XFS partition
  - User -p to persist across reboots

```text
setenv -p root dks2d0s0
```

- If you are removing your spinning disk, PROM should automatically update the SystemPartition and OSLoadPartition
  - If for some reason this isn't happening, you can modify both by hand:

```text
setenv -p SystemPartition xio(0)pci(15)scsi(0)disk(2)rdisk(0)partition(8)
setenv -p OSLoadPartition xio(0)pci(15)scsi(0)disk(2)rdisk(0)partition(0)
```

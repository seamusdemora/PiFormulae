## Converting ext4 to btrfs Filesystem & Related Matters

If you're interested in trying the `btrfs` filesystem (as an alternative to `ext4`) on your Raspberry Pi, you've come to the right place. This procedure assumes your system is running the ***trixie*** release of RPi OS. If you're running another OS, you're welcome to ***try*** this procedure, but please keep in mind that it was written for RPi OS 'trixie' running on RPi hardware. FWIW, the "target" system hardware here is an [RPi Zero 2W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/), but the conversion procedure should work for any system.

Let's get to it... As currently written this procedure uses two (2) RPis. However, it's also *"do-able"* on a single system. I have done this *`btrfs` conversion* by creating new partitions on a 2nd SD card, and using `rsync` to copy from the original `ext4` *source* SD. An alternative to that approach is to use the `btrfs-convert` utility (p/o the `btrfs-progs` package) on the un-mounted  `ext4` *source* partition. I've elected not to include that alternative here, but if you're interested, let me know; I'll clean it up and post it here.  

**You will need a 2nd SD card for this procedure**; you will also need two (2) [USB-SD adapters](https://duckduckgo.com/?q=USB-SD%20adapter&t=ffab&ia=web). We will refer to this 2nd SD card as **SD2**. I used a SanDisk 64GB SDXC microSD card for **SD2**. Please note that this procedure will **not** modify your current trixie system (other than to install two software packages via `apt`), nor will it modify your **original SD card** - **SD1**. In this way, you have a "**fallback**" - your original system remains "as-is" on **SD1** in case something goes wrong, or you simply decide after a short trial that `btrfs` is not for you.

### `btrfs` Conversion Procedure for Raspberry Pis

Again, I used two RPis here for my convenience. I refer to these two RPis as the **TARGET RPi**, and the **SUPPORT RPi**; the **TARGET RPi** is the RPi that will have its root filesystem converted to `btrfs`. 

1.  On the **TARGET RPi**, use `apt` to update, upgrade & install two packages, and add `btrfs` support to your `initramfs`:

      ```
      sudo apt update
      sudo apt -y full-upgrade		                # optional
      sudo apt install btrfs-progs initramfs-tools
        # open editor & add the word `btrfs` to /etc/initramfs-tools/modules, or: 
      sudo echo "btrfs" >> /etc/initramfs-tools/modules
        # apply the change:
      sudo update-initramfs -u 
        # issue 'halt' to TARGET RPi, remove SD card (SD1) & insert SD1 into USB-SD adapter
      sudo halt
      ```


2.  On the **SUPPORT RPi**: Plug **SD1** ***and*** **SD2** into USB ports; verify using `lsblk --fs`.

      ```
      lsblk --fs
      NAME        FSTYPE FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
      sda
      ├─sda1      vfat   FAT32 bootfs 1C94-4EC3
      └─sda2      ext4   1.0   rootfs f0abac56-08be-42e2-8726-9baa083e8685
      sdb
      └─sdb1      exfat  1.0   64GB-SD 6FDB-2FBD
      nvme0n1
      ├─nvme0n1p1 vfat   FAT32 bootfs 91FE-7499                             434.5M    15% /boot/firmware
      └─nvme0n1p2 ext4   1.0   rootfs 56f80fa2-e005-4cca-86e6-19da1069914d  428.6G     1% /
      ```


3.  On the **SUPPORT RPi**: use `fdisk` to obtain needed information on `/dev/sda` (**SD1**).   

      ```
        # get information on SD1 from fdisk:
      sudo fdisk -l /dev/sda
      Disk /dev/sda: 59.48 GiB, 63864569856 bytes, 124735488 sectors
      Disk model: STORAGE DEVICE
      Units: sectors of 1 * 512 = 512 bytes
      Sector size (logical/physical): 512 bytes / 512 bytes
      I/O size (minimum/optimal): 512 bytes / 512 bytes
      Disklabel type: dos
      Disk identifier: 0x26576298
      
      Device     Boot   Start       End   Sectors  Size Id Type
      /dev/sda1         16384   1064959   1048576  512M  c W95 FAT32 (LBA)
      /dev/sda2       1064960 124735487 123670528   59G 83 Linux
      ```

4.  On the **SUPPORT RPi**: use `fdisk` to create three (3) partitions on `/dev/sdb` (**SD2**): 

      ```
      sudo fdisk /dev/sdb		# "blank" Command inputs are actually 'Enter' to accept default
      ...
      Command (m for help): o
      Created a new DOS (MBR) disklabel with disk identifier 0x6a99c805.
      The device contains 'gpt' signature and it will be removed by a write command. See fdisk(8) man page and --wipe option for more details.
      
      Command (m for help): p
      
      Disk /dev/sda: 59.48 GiB, 63864569856 bytes, 124735488 sectors
      Disk model: STORAGE DEVICE
      Units: sectors of 1 * 512 = 512 bytes
      Sector size (logical/physical): 512 bytes / 512 bytes
      I/O size (minimum/optimal): 512 bytes / 512 bytes
      Disklabel type: dos
      Disk identifier: 0x6a99c805
      
      Command (m for help): n
      Partition type
      p   primary (0 primary, 0 extended, 4 free)
      e   extended (container for logical partitions)
      Select (default p): 
      Partition number (1-4, default 1):
      First sector (2048-124735487, default 2048):
      Last sector, +/-sectors or +/-size{K,M,G,T,P} (2048-124735487, default 124735487): +512M
      
      Created a new partition 1 of type 'Linux' and of size 512 MiB.
      Partition #1 contains a vfat signature.
      
      Do you want to remove the signature? [Y]es/[N]o: y
      
      The signature will be removed by a write command.
      
      Command (m for help): n
      Partition type
      p   primary (1 primary, 0 extended, 3 free)
      e   extended (container for logical partitions)
      Select (default p): 
      Partition number (2-4, default 2):
      First sector (1050624-124735487, default 1050624):
      Last sector, +/-sectors or +/-size{K,M,G,T,P} (1050624-124735487, default 124735487): +50G
      
      Created a new partition 2 of type 'Linux' and of size 50 GiB.
      
      Command (m for help): n
      Partition type
      p   primary (2 primary, 0 extended, 2 free)
      e   extended (container for logical partitions)
      Select (default p): 
      Partition number (3,4, default 3):
      First sector (105908224-124735487, default 105908224):
      Last sector, +/-sectors or +/-size{K,M,G,T,P} (105908224-124735487, default 124735487): +6G
      
      Created a new partition 3 of type 'Linux' and of size 6 GiB.
      
      Command (m for help): p
      Disk /dev/sda: 59.48 GiB, 63864569856 bytes, 124735488 sectors
      Disk model: STORAGE DEVICE
      Units: sectors of 1 * 512 = 512 bytes
      Sector size (logical/physical): 512 bytes / 512 bytes
      I/O size (minimum/optimal): 512 bytes / 512 bytes
      Disklabel type: dos
      Disk identifier: 0x6a99c805
      
      Device     Boot     Start       End   Sectors  Size Id Type
      /dev/sda1            2048   1050623   1048576  512M 83 Linux
      /dev/sda2         1050624 105908223 104857600   50G 83 Linux
      /dev/sda3       105908224 118491135  12582912    6G 83 Linux
      
      Filesystem/RAID signature on partition 1 will be wiped.
      
      Command (m for help): t
      Partition number (1-3, default 3): 1
      Hex code or alias (type L to list all): c
      
      Changed type of partition 'Linux' to 'W95 FAT32 (LBA)'.
      
      Command (m for help): p		# this is what yours should look like
      Disk /dev/sda: 59.48 GiB, 63864569856 bytes, 124735488 sectors
      Disk model: STORAGE DEVICE
      Units: sectors of 1 * 512 = 512 bytes
      Sector size (logical/physical): 512 bytes / 512 bytes
      I/O size (minimum/optimal): 512 bytes / 512 bytes
      Disklabel type: dos
      Disk identifier: 0x6a99c805
      
      Device     Boot     Start       End   Sectors  Size Id Type
      /dev/sdb1            2048   1050623   1048576  512M  c W95 FAT32 (LBA)
      /dev/sdb2         1050624 105908223 104857600   50G 83 Linux
      /dev/sdb3       105908224 118491135  12582912    6G 83 Linux
      
      Filesystem/RAID signature on partition 1 will be wiped.
      
      Command (m for help): v
      No errors detected.
      Remaining 6244352 unallocated 512-byte sectors.
      
      Command (m for help): w
      The partition table has been altered.
      Calling ioctl() to re-read partition table.
      Syncing disks.
      ```


5.  On the **SUPPORT RPi**: copy from **SD1** to **SD2**, and format **SD2**: 

      ```
        # we take care of the `/boot/firmware` partition first (`dev/sdb1`);
        # copy the boot partition from SD1 (/dev/sda1) to SD2 (/dev/sdb1): 
      
      sudo dd if=/dev/sda1 of=/dev/sdb1 bs=512 
      
      1048576+0 records in
      1048576+0 records out
      536870912 bytes (537 MB, 512 MiB) copied, 29.9509 s, 17.9 MB/s 
      
        # we now format /dev/sdb2 and /dev/sdb3 as btrfs 
      
      sudo mkfs.btrfs -L rootfs /dev/sdb2 
      
      btrfs-progs v6.14
      See https://btrfs.readthedocs.io for more information.
      
      NOTE: several default settings have changed in version 5.15, please make sure
      this does not affect your deployments:
      - DUP for metadata (-m dup)
      - enabled no-holes (-O no-holes)
      - enabled free-space-tree (-R free-space-tree)
      
      Label:              rootfs
      UUID:               6112e919-f036-4da2-91c7-7bfaedd2c145
      Node size:          16384
      Sector size:        4096	(CPU page size: 16384)
      Filesystem size:    50.00GiB
      Block group profiles:
      Data:             single            8.00MiB
      Metadata:         DUP             256.00MiB
      System:           DUP               8.00MiB
      SSD detected:       no
      Zoned device:       no
      Features:           extref, skinny-metadata, no-holes, free-space-tree
      Checksum:           crc32c
      Number of devices:  1
      Devices:
      ID        SIZE  PATH
      1    50.00GiB  /dev/sdb2 
      
        # we now mount /dev/sda1 (SD1) and /dev/sdb1 (SD2) so that we can copy the contents 
        # of /dev/sda1 to /dev/sdb1 via rsync: 
      
      sudo mkdir -p /mnt/SD1 /mnt/SD2
      sudo mount /dev/sda2 /mnt/SD1 && sudo mount /dev/sdb2 /mnt/SD2
      sudo rsync -HAXav /mnt/SD1/ /mnt/SD2/ > rsync-log.txt 2>&1 
      sudo umount /mnt/SD1   # remove SD1, label it and set it aside for future use
      
        # peruse rsync-log.txt to verify a lof of files were copied!  :) 
        # format /dev/sdb3 as btrfs to use as an "extra space" to house snapshots, etc. 
      
      sudo mkfs.btrfs -L BTRFS1 /dev/sdb3
      
        # verify w/ lsblk --fs
      
      lsblk --fs
      NAME        FSTYPE FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
      sda
      ├─sda1      vfat   FAT32 bootfs C73C-AF74
      └─sda2      btrfs        rootfs b90c7819-cd45-4006-9d7b-7407f27085f0
      sdb
      ├─sdb1      vfat   FAT32 bootfs C73C-AF74
      ├─sdb2      btrfs        rootfs 6112e919-f036-4da2-91c7-7bfaedd2c145
      └─sdb3      btrfs        BTRFS1 ed7c6c3f-4ae7-4113-ae54-0b5891e03fbe
      nvme0n1
      ├─nvme0n1p1 vfat   FAT32 bootfs 91FE-7499                             434.5M    15% /boot/firmware
      └─nvme0n1p2 ext4   1.0   rootfs 56f80fa2-e005-4cca-86e6-19da1069914d  428.6G     1% /
      ```


6.  On the **SUPPORT RPi**: Minor edits to make to make SD2 bootable: 
      ```
        # /mnt/sdb2 should still be mounted at /mnt/SD2, so make required changes there first:
        
      sudo nano /mnt/SD2/etc/fstab		# or use your preferred editor to make these changes:
      
        # FROM: 
        
      PARTUUID="whatever-1"  /boot/firmware  vfat    defaults          0       2
      PARTUUID="whatever-2"  /               ext4    defaults,noatime  0       1
      
        # TO: 
        
      LABEL=bootfs          /boot/firmware  vfat    defaults          0       2
      LABEL=rootfs          /               btrfs   defaults,noatime  0       0
      # PARTUUID="whatever-1"  /boot/firmware  vfat    defaults          0       2
      # PARTUUID="whatever-2"  /               ext4    defaults,noatime  0       1
      
        # now mount /dev/sdb1 for another edit to cmdline.txt :
        
      sudo mount /dev/sdb1 /mnt/SD1
      sudo nano /mnt/SD1/cmdline.txt
      
        # FROM:
      
      console=serial0,115200 console=tty1 root=PARTUUID=whatever1 rootfstype=ext4 fsck.repair=yes rootwait cfg80211.ieee80211_regdom=US
      
        #TO:
      
      console=serial0,115200 console=tty1 root=LABEL=rootfs rootfstype=btrfs fsck.repair=no rootwait cfg80211.ieee80211_regdom=US
      
      # C'est terminé!! You should be able to remove SD2 from the SUPPORT RPi, 
      # insert it into the TARGET RPi and boot from it.
      ```
    
    *C'est terminé*! ... You should now be able to remove **SD2** from the **SUPPORT RPi**, insert it into the **TARGET RPi** and boot from it. And a quick comment on the above changes: Note that I used `LABEL`s instead of `PARTUUID`s. That's just a personal preference; you may use `PARTUUID` (or something else in **`ls -l /dev/disk`**, or via the **`blkid`** command). If I had hundreds of RPi, constantly swapping SD cards, I suppose I might find `PARTUUID`s useful... for my present purposes, `LABEL`s *mostly* work fine.  :) 

### Notes:

1. Re Step 6 above, the edit to `/etc/fstab`: The sixth field in a `/etc/fstab` line is known as 'fs_passno', and is used to determine the order that `fsck` is run. As there is no benefit to running `fsck` on a `btrfs` partition, 'fs_passno' is changed from `1` to `0`. And yes, this is redundant with `cmdline.txt`... Why? You can ask "The Raspberries" - I don't really know. 
2. Re Step 6 above, the `fsck.repair` edit to `cmdline.txt`: `fsck.repair` is set "=no" because `fsck` is not needed for `btrfs`.
3. Re Step 6; use of LABELs vs PARTUUIDs vs UUIDs, etc, etc. This may be useful to some: The folder `/dev/disk` contains nine (9) sub-folders dedicated to the various methods for referring to a device that is a "disk". If you want to use something other than LABEL, you can find it here. 
4. Re Step 1; the modification of `initramfs`: [Some accounts](https://unix.stackexchange.com/a/186954/286615) on the Internet state that changes made to `initramfs` are ephemeral; lasting only until the next kernel upgrade. IOW, when the kernel is upgraded (e.g. in `apt`), any changes made to initramfs must be re-applied to remain effective under the new/upgraded kernel. In researching this, I found a [post in the RPi GitHub Issues](https://github.com/raspberrypi/linux/issues/5342#issuecomment-1849894020) that ***seems*** to address the question, but like some other posts from this [knob](https://www.slangsphere.com/understanding-knob-slang-meaning-usage-and-cultural-impact/), it is [inscrutable](https://www.merriam-webster.com/dictionary/inscrutable). IOW this "answer" was unclear, and we may have to wait for a kernel upgrade to learn the answer. If you know the answer - please share! In the meantime, this may help: `lsinitramfs /boot/initrd.img-$(uname -r) | grep btrfs`
5. The ability of `btrfs` to make "snapshots" of the file system is obviously a major attraction for those that like to experiment with their RPi systems. I am still learning the configuration process, but I hear of an app named `snapper` that is said by some to be quite good. I'll post a follow-up to this recipe once I've "found my footing".

### References: 

If you want to capitalize on the *potential* advantages of `btrfs`, there is quite a lot to learn! This list of references is deliberately brief, but hopefully helpful toward an understanding. I've also included a couple of *"assessment articles"* on `btrfs` ICYI. More detailed references may follow. 

1. [The Btrfs filesystem: An introduction](https://lwn.net/Articles/576276/): *A series of articles from LWN (Linux Weekly News), published in 2013-2014. Note that sequels to this article are listed at the end of the article.* 
2. [Working with Btrfs – General Concepts](https://fedoramagazine.org/working-with-btrfs-general-concepts/): A series of articles from Fedora Magazine, published in 2022-2023. 
3. [Debian's btrfs Wiki](https://wiki.debian.org/Btrfs): There are several good [`btrfs` wikis](https://duckduckgo.com/?q=Btrfs%20Documentation%20(Btrfs%20Wiki)&t=ffab&ia=web); this one was selected for obvious reasons :) Check the wiki's [*change log*](https://wiki.debian.org/Btrfs?action=info) for the update history. 

4. **An assessment**: [Examining btrfs, Linux's perpetually half-finished filesystem](https://arstechnica.com/gadgets/2021/09/examining-btrfs-linuxs-perpetually-half-finished-filesystem/), from **ars technica**, dtd Sep, 2021
5. **An assessment:** [Is Btrfs still unstable?](https://darwinsdata.com/is-btrfs-still-unstable/), from **Darwin's Data**, dtd Oct 2023







<!---

Can I still hide stuff ?

Procedure II: Uses one Raspberry Pi

1.  With your TARGET RPi system up and running on **SD1**, insert **SD2** into a [USB-SD adapter](https://duckduckgo.com/?q=USB-SD%20adapter&t=ffab&ia=web), and plug the adapter into a USB port on the TARGET RPi. 

2.  Use [image-utils](https://github.com/seamusdemora/RonR-RPi-image-utils) (`image-backup`) to create a backup image of your current trixie system. Name this image file `trixie-btrfs.img`; we shall modify this image file to create a bootable RPi OS image. The `trixie-btrfs.img` may be saved to a USB device, NAS or whatever, but you must have access to this storage medium from your TARGET RPi trixie system. 

3.  Write the `trixie-btrfs.img` file to **SD2** using [Etcher](https://etcher.balena.io/) - or `dd`, or a competent image writer of your choice. 

4.  Issue a `halt` to your TARGET RPi system; remove power (unplug USB power cable), and remove **SD1**. Set **SD1** aside for safekeeping, and mark or label it as the "original" **SD1**.

5.  Insert **SD2** into your TARGET RPi system, apply power (plug USB power cable) and log in once the system boots. 

6.  Having booted from **SD2**, we modify this system's `initramfs` to add kernel support for booting `btrfs`. Recall that the [sole purpose of initramfs is to mount the root filesystem](https://www.linuxfromscratch.org/blfs/view/svn/postlfs/initramfs.html); we will give this `initramfs` the ability to mount a `btrfs` root filesystem by adding the single word: `btrfs` to `/etc/initramfs-tools/modules`, and then running `update-initramfs -u` afterwards. 

7.  We've done all that's needed to be done from the system running from **SD2**;  now issue a `halt` to the RPi, remove power, remove **SD2**, re-insert **SD1**, re-power the system under **SD1** and login. 

8.  Using a [USB-SD adapter](https://duckduckgo.com/?q=USB-SD%20adapter&t=ffab&ia=web), insert **SD2** into the adapter, and plug the adapter into a USB port on your TARGET RPi system running under **SD1**. Afterwards run `lsblk --fs` to verify that **SDA2** shows up as `/dev/sdX`, and note the device designation. 

9.  Install the `btrfs-progs` package on our running **SD1** system as follows: `sudo apt update && sudo apt install btrfs-progs`. Now "convert" the `ext4` filesystem on **SD2** (e.g. `/dev/sda2`) to `btrfs` by running: `sudo btrfs-convert -L /dev/sda2`. Note that `btrfs-convert` must be run on an un-mounted file system. 

10.  Next, we must make some edits to files on **SD2** - which means that both partitions in **SD2** must be `mount`ed. Assuming **SD2** is at `dev/sda1` & `/dev/sda2`, and mounted at `/mnt/sd2boot` and `/mnt/sd2root`: 

     -  open `/mnt/sd2boot/cmdline.txt` in your editor & make two changes:
        -  FROM: `rootfstype=ext4`  TO:  `rootfstype=btrfs`
        -  FROM: `fsck.repair=yes`  TO:  `fsck.repair=no` 

     -  open `/mnt/sd2root/etc/fstab` in your editor & make this change:
        -  FROM: `PARTUUID=26576298-02  /               ext4    defaults,noatime  0       1`
        -  TO: `PARTUUID=26576298-02  /               btrfs    defaults,noatime  0       0` 


    Please note the following: 
    
    A.  `fsck.repair` is set "=no" because `fsck` is not needed for `btrfs` 
    B.  PARTUUID remains the same. It was assigned during GPT partitioning process as a unique partition identifier, and does not change even if the partition is reformatted or moved. 
    C.  The sixth field in a `/etc/fstab` line is known as the 'fs_passno', and is used to determine the order that `fsck` is run. Again, as there is no benefit to running `fsck` on a `btrfs` partition, 'fs_passno' is changed from `1` to `0`. And yes, this is redundant with `cmdline.txt`... Why? You can ask "The Raspberries" - I don't really know. 

10.  At this point, **SD2** should now be bootable, ***and*** have a `btrfs` root partition. While there are additional "things" you'll likely want to do, you can now issue a `halt` on the **SD1**/`ext4` system, pull power, swap out **SD1** for **SD2**, re-power, and see your **SD2**/`btrfs` system boot! 

--> 

<!---

but If you're familiar with the commands, the outline may be all you need. The detailed procedure is just that - **d-e-t-a-i-l-e-d**; it is the exact procedure that was executed to arrive at a bootable RPi OS that uses `btrfs` for its root filesystem.  

1.  write trixie-bkup.img to SD card 1 (SD1), boot RPi, and 
2.  run echo btrfs >> /etc/initramfs-tools/modules && update-initramfs -u
3.  halt RPi; remove SD1; insert another SD card, boot, connect SD1 to USB as /dev/sdX
4.  run sudo btrfs-convert -L /dev/sdX
5.  mount /dev/sdY - the bootfs partition on SD1 & modify cmdline.txt
6.  set `/etc/fstab` as follows:

```
PARTUUID=26576298-02  /               btrfs   defaults,noatime  0       0
# for btrfs partition: change fs_passno (the sixth and final field) from 1 to 0;
# this turns fsck OFF as it is not needed for btrfs per https://unix.stackexchange.com/a/679848/286615
```

8.  once you're "happy" with the btrfs conversion, there are a few steps to tidy up:

```
sudo btrfs subvolume delete /mnt/ext2_saved  # or, on a live system: sudo rm -rf /ext2_saved
btrfs filesystem defrag -v -r -f -t 32M /mnt/btrfs

```

9.  `lsinitramfs /boot/initrd.img-$(uname -r) | grep btrfs`



*POTENTIALLY* good advice: 

1.  [Corruption-proof SD card filesystem for RPi ~~embedded Linux~~?](https://unix.stackexchange.com/a/186954/286615) 







--------------------------------------------------------------------------------------------------------------------

1.  sudo losetup -Pf /path/to/trixie-bkup.img
2.  run lsblk --fs to verify the loop mount has worked & get device locations for bootfs and rootfs
3.  run sudo btrfs-convert -L /dev/loop1p2
4.  mount the bootfs & modify cmdline.txt: sudo mount /dev/loop1p1 /mnt/bootfs
5.  "detach" the loop device: sudo losetup -d /dev/loop1
6.  write the modified /path/to/trixie-bkup.img to an SD card (Ethcher)



In an exploration of alternative file systems (to`ext4`), and their related snapshot (backup) capabilities: 

*  Beginning in 2018, user @Ingo made [several posts](https://raspberrypi.stackexchange.com/search?q=user%3A79866+%22LVM%22) in RPi SE generally promoting the use of LVM. In particular, in these two posts from [Jan](https://raspberrypi.stackexchange.com/a/78659/83790) & [Jul](https://raspberrypi.stackexchange.com/a/85959/83790) (updated in Jan 2021), he indicated the necessity of loading LVM drivers (via `initrd`/`initramfs`) to enable the system to boot from an LVM "drive". He outlined a rather complex configuration to achieve the objective of booting from an LVM partition that included:  

   *  changes in `config.txt` to select & configure the appropriate kernel-modules via `initramfs`
   *  listing the modules to load via edits to `/etc/initramfs-tools/initramfs.conf` 
   *  using `mkinitramfs` to create the ramdisks necessary for booting 
   *  use a 2nd computer to create LVM volumes on the SD card, and then... 
   *  ... move the root partition on SD card to an LVM volume
   *  ... make additional changes to `boot/cmdline.txt` and `etc/fstab` to reflect LVM volume names
   *  etc, etc... note that Ingo referred to this as the "simpler" configuration. I won't quibble with his choice of terms, but I cannot agree that this is a "simple" configuration. It also requires that **part of the procedure be repeated any time there is a kernel upgrade**. I left a comment for Ingo on Nov 9, 2025 asking if he thought the procedure had become "simpler". Now, in hindsight, I ~~believe that~~ *wonder if* it has.

*  **RE: Replacing** `ext4` with `btrfs` as the root filesystem; I found [this site/page](https://www.linuxfromscratch.org/blfs/view/svn/postlfs/initramfs.html) in a link from [this github thread](https://github.com/raspberrypi/linux/issues/5342#issuecomment-1849894020)...  The passages of interest are these: 

   ```
   # from the github thread
   "initramfs includes enough modules to get the rootfs loaded: 
   https://www.linuxfromscratch.org/blfs/view/svn/postlfs/initramfs.html
   and it is loaded by the firmware."
   
   # from the linked reference:
   "The only purpose of an initramfs is to mount the root filesystem."
   ```

   Together, these statements ***imply*** that one can boot from a `btrfs` root partition with no additional configuration required - just as easily as one can boot from an `ext4` partition. We *should be* able to verify this:

   ```bash
   lsinitramfs /boot/initrd.img-$(uname -r)
   # the following "suggests" that the implication above is true; in both cases, there were several lines of output for each
   $ lsinitramfs /boot/initrd.img-$(uname -r) | grep btrfs | less
   $ lsinitramfs /boot/initrd.img-$(uname -r) | grep lvm | less
   ```

   While not being intimately familiar with the construction or format of  these files, all I can say is that the above outputs "**suggest**" that everything needed to boot from a `btrfs` partition, or an LVM volume - is included in the default `initramfs` found on my RPi trixie system.  

   So - now the question becomes how to *efficiently* **install** the RPi OS root partition onto a `btrfs` or `lvm` partition? Or alternatively, can an `ext4` partition be **converted** to a `btrfs` or `lvm` partition? ... Let's go to a new bullet:

*  **Installing** and/or **converting** an existing `ext4 root` partition to `btrfs` or `lvm` :  

   Recall that while `btrfs` is a true filesystem, `lvm` is not. In fact `lvm` is designed to manage (virtually) any type of filesystem: `btrfs`, `ext4`, `dos`, etc.   

   We have already seen how to use `lvm` to create and format `ext4`, `vfat` and `btrfs` "partitions". There is even a ["*Baeldung blog*"](https://www.baeldung.com/linux/btrfs-lvm) that covers this. Again, `btrfs` is a true filesystem, and as it turns out, there is a command that *should* be able to convert an existing `ext4` partition to `btrfs`; the `btrfs-convert` utility will do an *in-place* conversion : 

   ```bash  
   btrfs-convert /dev/sdXn
   ```

   It seems that putting (installing) existing, default RPi partitions into corresponding LVM "partitions" may be done by using a loop mount to copy from one to the other. Let's take that up in a new bullet:

*  "**Moving**" image file partitions: 

   Let's take a look at what's inside an "image" file; e.g. a recent backup image made with `image-utils`:

   *  ```
      $ fdisk -l 20251105_Pi2W_trixie-imgbackup.img
      Disk 20251105_Pi2W_trixie-imgbackup.img: 3.35 GiB, 3592298496 bytes, 7016208 sectors
      Units: sectors of 1 * 512 = 512 bytes
      Sector size (logical/physical): 512 bytes / 512 bytes
      I/O size (minimum/optimal): 512 bytes / 512 bytes
      Disklabel type: dos
      Disk identifier: 0x26576298
      
      Device                              Boot   Start     End Sectors  Size Id Type
      20251105_Pi2W_trixie-imgbackup.img1         2048 1050623 1048576  512M  c W95 FAT32 (LBA)
      20251105_Pi2W_trixie-imgbackup.img2      1050624 7016207 5965584  2.8G 83 Linux
      ```

   We see that there are actually two images - one is the `/boot` partition (`*.img1`, a FAT32 partition), the other is the `/` root partition (`*.img2`, a Linux/`ext4` partition). We know from [another recipe here](https://github.com/seamusdemora/PiFormulae/blob/master/WorkingWithImage-backupFiles.md) that these images can be written/copied to a device file (e.g. `/dev/sdaX`). Accordingly, it should be possible to "move" these images from one partition type or filesystem to another. IOW, we can see filesystems and partitions as different containers for the actual contents: 

   *  ```
      *.img ==> /dev/pi_volgrp/pi_lv03 													: move image to lvm device
      *.img ==> /dev/pi_volgrp/pi_lv03 | btrfs-convert /dev/...	: convert filesystem
      ```

   And - having moved/converted the images, we ***hope*** that the "box stock" Rpi `initramfs` will simply boot from these "moved" images. 

   WRT setting /boot up under LVM, this article says ["maybe don't do that!"](https://www.baeldung.com/linux/lvm-boot-partition-recommendations). 



## To summarize: 

1.  Taking [the knob who authored this github post](https://github.com/raspberrypi/linux/issues/5342#issuecomment-1849894020) at his word, the "box stock" RPi `initramfs` has the ability to boot from LVM partitions and/or `btrfs` filesystems. 
2.  Consequently, we should be able to "*move*"**/**"*re-package*" our existing default images to different partitions/filesystems. ***and*** retain the ability to boot our system from them. 



-->


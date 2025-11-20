## Converting ext4 to btrfs Filesystem & Related Matters

If you're interested in trying the `btrfs` filesystem (as an alternative to `ext4`) on your Raspberry Pi, you've come to the right place. This procedure assumes your system is running the ***trixie*** release of RPi OS. If you're running another OS, you're welcome to ***try*** this procedure, but please keep in mind that it was written for RPi OS 'trixie' running on RPi hardware. FWIW, the "target" system hardware here is an [RPi Zero 2W](https://www.raspberrypi.com/products/raspberry-pi-zero-2-w/), but the conversion procedure should work for any system.

Let's get to it... As currently written this procedure requires two (2) RPis; however, a "desktop/laptop Linux" can probably be used in lieu of the second RPi. I have also done this *`btrfs` conversion* using only a single RPi (the "target" system), but have elected not to include that here - at least for now. If you need the single-RPi version of this procedure, let me know; I'll clean it up and post it here.  

**You will need a 2nd SD card for this procedure**; we refer to this 2nd SD card as **SD2**. I have used SanDisk 64GB SDXC microSD cards. The procedure will **not** modify your current trixie system (other than to install two software packages via `apt`), nor will we modify your **original SD card** - **SD1**. In this way, you have a "**fallback**" - your original system remains "as-is" on **SD1** in case something goes wrong, or you simply decide after a short trial that `btrfs` is not for you.

### `btrfs` Conversion Procedure Using Two Raspberry Pis

We refer to the two RPis as the **TARGET RPi**, and the **SUPPORT RPi**; the **TARGET RPi** is the RPi that will have its root filesystem converted to `btrfs`. 

1.  On the **TARGET RPi**, use `apt` to update, upgrade & install two packages, and add `btrfs` support to your `initramfs`:

      ```
        sudo apt update
        sudo apt -y full-upgrade		# optional
        sudo apt install btrfs-progs && sudo apt install initramfs-tools
        # open editor & add the word `btrfs` to /etc/initramfs-tools/modules, or: 
        sudo echo "btrfs" >> /etc/initramfs-tools/modules
        # apply the change:
        sudo update-initramfs -u
      ```

2.  On the **TARGET RPi**: shut the system down, remove power, remove the TARGET SD card - **SD1**, and insert the TARGET SD card (**SD1**) into a  [USB-SD adapter](https://duckduckgo.com/?q=USB-SD%20adapter&t=ffab&ia=web) . :

      ```
        sudo halt
        # remove power, remove SD card, insert SD card into USB adapter
      ```


3.  Plug the TARGET SD card (**SD1**) into a USB port on the **SUPPORT RPi**. Also, plug **SD2** into a USB port on the **SUPPORT RPi**. Then - verify you have what you need using `lsblk --fs`. Here, we see `/dev/sda` (**SD1**), and `/dev/sdb` (**SD2**). 

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


4.  On the **SUPPORT RPi**, we use `fdisk` to obtain needed information on `/dev/sda` (**SD1**). This information is needed to correctly prepare `/dev/sdb` (**SD2**) :  

      ```
        # get some information from fdisk on SD1:
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



5.  On the **SUPPORT RPi**, use `fdisk` to create three (3) partitions on `/dev/sdb` (**SD2**): 

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


5.  Again, on the **SUPPORT RPi**, we complete preparations of SD2 to make it bootable: 

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
           
        # We format /dev/sdb3 as btrfs to use as an "extra space" to house snapshots, etc. 
           
        sudo mkfs.btrfs -L BTRFS1 /dev/sdb3
      
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


6.  We now have a couple of minor edits to make to `/dev/sdb1` and `/dev/sdb2` to complete the procedure: 
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

    Just some quick comments on the above changes: Note that I used `LABEL`s instead of `PARTUUID`s. That's just a personal preference; you may use `PARTUUID` (or anything else in **`ls -l /dev/disk`**). If I had hundreds of RPi, constantly swapping SD cards, I suppose I might find `PARTUUID`s useful... for my present purposes, `LABEL`s work fine.  :) 

### Notes: 

1. Re Step 6 above, the `fsck.repair` edit to `cmdline.txt`: `fsck.repair` is set "=no" because `fsck` is not needed for `btrfs`. 
2.  Re Step 6 above, the edit to `/etc/fstab`: The sixth field in a `/etc/fstab` line is known as 'fs_passno', and is used to determine the order that `fsck` is run. Again, as there is no benefit to running `fsck` on a `btrfs` partition, 'fs_passno' is changed from `1` to `0`. And yes, this is redundant with `cmdline.txt`... Why? You can ask "The Raspberries" - I don't really know. 
3. Re Step 6; use of LABELs vs PARTUUIDs vs UUIDs, etc, etc. This may be useful to some: The folder `/dev/disk` contains nine (9) sub-folders dedicated to the various methods for referring to a device that is a "disk". If you want to use something other than LABEL, you can find it here. 
4. Re Step 1; the modification of `initramfs`: [Some accounts](https://unix.stackexchange.com/a/186954/286615) on the Internet state that changes made to `initramfs` are ephemeral; lasting only until the next kernel upgrade. IOW, when the kernel is upgraded (e.g. in `apt`), any changes made to initramfs must be re-applied to remain effective under the new/upgraded kernel. In researching this, I found a [post in the RPi GitHub Issues](https://github.com/raspberrypi/linux/issues/5342#issuecomment-1849894020) that ***seems*** to address the question, but like other posts from this [knob](https://www.slangsphere.com/understanding-knob-slang-meaning-usage-and-cultural-impact/), it is [inscrutable](https://www.merriam-webster.com/dictionary/inscrutable). IOW this "answer" was unclear, and we may have to wait for a kernel upgrade to learn the answer. If you know the answer - please share! In the meantime, this may help: `lsinitramfs /boot/initrd.img-$(uname -r) | grep btrfs`
5. The ability of `btrfs` to make "snapshots" of the file system is obviously a major attraction for those that like to experiment with their RPi systems. I am still learning the configuration process, but I hear of an app named `snapper` that is said by some to be quite good. I'll post a follow-up to this recipe once I've "found my footing".

<!---

Can I not hide stuff any longer?

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


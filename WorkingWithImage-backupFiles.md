# Working with \*.img (backup) files

I'm a big fan of [RonR's `image-utils`](https://github.com/seamusdemora/RonR-RPi-image-utils). It's able to create backups of your Raspberry Pi as [image files](https://en.wikipedia.org/wiki/IMG_%28file_format%29) quickly and efficiently. If my system or SD card becomes corrupted, I can restore it to operation with  minimal effort: 3 "ingredients" and about 5 minutes are required: 

1. The *.img file - created by routine/scheduled `image-backup` runs on your system
2. A spare micro SD card
3. [`Etcher`](https://etcher.balena.io/) to write the .img file to the micro-SD card   

The speed and efficiency of `image-backup` are especially noteworthy. Because `image-backup` uses `rsync` for file copying/syncing, a backup only requires the storage space that is actually used by your system. This is **unlike** `dd` which has no way to tell what is used vs. what is not used, because it has no concept of a **file**. Consequently a backup of a 32 GB SD card using `dd` requires: **...32GB!!** 

By comparison, for my systems (Lite; running *headless*), a backup of a 32GB SD card requires typically a 3-5GB \*.img file, and 5-10 minutes. 

Another efficiency of `image-utils` is its ability to **update** an \*.img file; in other words, instead of creating an entire new \*.img file from scratch, it can **update** an existing \*.img file to incorporate any changes to the filesystems since the last backup. This ability to **update** further reduces the time required for a backup from 5-10 minutes to potentially seconds. 

But this is covered in the [`image-utils` repo](https://github.com/seamusdemora/RonR-RPi-image-utils); this recipe is about **working with \*.img files**: 

Having an \*.img file, and being able to do a [loop mount](https://en.wikipedia.org/wiki/Loop_device) is a very efficient process for *"cloning"* new systems from existing ones, and for upgrading from one OS release to another. This is probably best communicated in examples. Let's clone a system from an \*.img file: 

## Cloning a system from an \*.img file:

The example I'll use here is cloning my trusty old RPi 3B+ to a new-ish [RPi 3A+](https://www.raspberrypi.com/news/new-product-raspberry-pi-3-model-a/). If you want/need to get your new RPi up and running ASAP, there's no quicker way than this:

### Step 1: Grab an existing backup \*.img file

Fortunately, I keep regular backups of my RPi 3B+; they're stored on an NAS drive. And so, I copy a recent backup \*.img file (called `back.img` here) from my NAS to `/home/pi` on my RPi 3B+. You can follow the steps below:

```bash
$ fdisk -l ./back.img
Disk ./back.img: 2.89 GiB, 3099590656 bytes, 6053888 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00f24f4c

Device      Boot  Start     End Sectors  Size Id Type
./back.img1        2048  526335  524288  256M  c W95 FAT32 (LBA)
./back.img2      526336 6053887 5527552  2.6G 83 Linux
```

As we see there are two (2) partitions, a FAT32 (from 2048 to 526335), and a Linux/`ext4` (from 526336 to 6053887) - or two partitions of 524,288 and 5,527,552 *sectors* (of 512 bytes/sector), respectively. 

### Step 2: Make a loop mount on the `back.img` file 

When I first tried to `mount` the two partitions, I got an "overlap" error: 

```bash
$ sudo mkdir -p /mnt/loopy/boot /mnt/loopy/root
$ sudo mount -o loop,offset=1048576 ./back.img /mnt/loopy/boot
$ sudo mount -o loop,offset=269484032 ./back.img /mnt/loopy/root
mount: /mnt/loopy/root: overlapping loop device exists for /home/pi/back.img.
```

I learned the solution for this is the `sizelimit` option: 

```bash
$ sudo umount /mnt/loopy/boot /mnt/loopy/root 
$ sudo mount -o loop,offset=1048576,sizelimit=268435456 ./back.img /mnt/loopy/boot 

# NOTE: sizelimit = 512 bytes/sector * 524288 sectors = 268435456 bytes 

$ sudo mount -o loop,offset=269484032,sizelimit=2830106624 ./back.img /mnt/loopy/root 

# NOTE: sizelimit = 512 bytes/sector * 5527552 sectors = 2830106624 bytes 
```

### Step 2 ALT: Easier & quicker method to create loop mount -

* Check to see what loop device #s are available: 

```bash
$ losetup -f
/dev/loop1
```

* Use `losetup` to create a loop for the entire image (all partitions):

```bash
$ sudo losetup -P /dev/loop1 /path/to/imagebackup.img
$ # done! - you can see what just happened using 'lsblk` :
$ lsblk --fs
NAME        FSTYPE FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop1
├─loop1p1   vfat   FAT32 bootfs B67C-D982
└─loop1p2   ext4   1.0   rootfs 5035e39d-cec4-4794-bbe0-12cda358425a
mmcblk0
├─mmcblk0p1 vfat   FAT32 bootfs EACA-13DA                             436.8M    14% /boot/firmware
└─mmcblk0p2 ext4   1.0   rootfs 21724cc6-e5a3-48a1-8643-7917dba3a9fb   53.4G     4% /
```

* And now you can `mount` the image file partitions if you need; for example:

```bash
$ sudo mount /dev/loop1p2 /mnt/loopy/root
```

### Step 3: Make the required changes for cloning to `back.img` 

Having successfully mounted the two partitions in `back.img`, I can now make the changes I need to create the cloned SD card for the RPi 3A+. I used the editor to modify three files in `/mnt/loopy/root/etc` : `hostname`, `hosts` and `dhcpcd.conf`. When I finished, I unmounted both (`root` & `boot` ). `back.img` has now been modified! Since I use my Mac (w/ Etcher) for "burning" SD cards, I transferred the modified `back.img` file to my NAS: 

```bash
$ sudo umount /mnt/loopy/root /mnt/loopy/boot 
$ rsync -avi ./back.img /mnt/SynologyNAS/rpi_share/raspberrypi3a 
sending incremental file list
>f.st...... back.img

sent 3,100,347,489 bytes  received 35 bytes  10,897,530.84 bytes/sec
total size is 3,099,590,656  speedup is 1.00 

# NOTE: don't use `cp` for this! 
```

### Step 4: "Burn" SD card with `back.img`, and boot from SD card

Next, plug a new SD card into my Mac, and start `Etcher`. When that's completed, install the cloned SD card into the RPI 3A+ and connect power.  Boom! it boots, and I can immediately get an SSH connection.  

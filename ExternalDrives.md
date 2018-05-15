# How Do I Connect an External Drive to a Raspberry Pi?

#### And Why Would I Want to Do This?
    
    1. The Raspberry Pi 3B+ has 4 USB 2.0 ports, and 
    2. external drives can be useful for all sorts of things:
        * local backup of RPi files, or a 'disk image' of the entire SD card
        * file sharing with your Mac, PC or another RPi 
        * reduce wear on your SD card 
        * thumb drives are cheap 

Since I deploy my RPi's in headless mode, and I'm a Mac user, the approach on this page reflects that. Another decision I've made that drives some elements of the approach here is my choice to use the exFAT file system on external drives connected to the RPi. I've chosen exFAT for the simple reasons that: a) it's supported by Linux, MacOS and Windows, and b) it doesn't have the limits on file size that FAT & FAT32 do. If you want to use another filesystem, [@wjglenn](https://twitter.com/wjglenn) has written a [good article in How-To Geek reviewing the tradeoffs between the most widely-used filesystems](https://www.howtogeek.com/73178/what-file-system-should-i-use-for-my-usb-drive/). If you're on board with all of that, let's get into the details: 

## 1. Determine what's connected before you begin

I'll do this first to make sure I've not forgotten drives that are already connected. The output also provides a good baseline to compare against in the next step. 

    sudo fdisk --list
    
Your output may resemble mine (trimmed for brevity):    

You might see 16 "RAM Disks" (discussed below)
    
    Disk /dev/ram0: 4 MiB, 4194304 bytes, 8192 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes

    Disk /dev/ram1: 4 MiB, 4194304 bytes, 8192 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    
    ...
    
    Disk /dev/ram15: 4 MiB, 4194304 bytes, 8192 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes

If you're using an SD card, you'll see something similar to the following. The device name is usually `/dev/sda`, `/dev/sdb`, or in this case `/dev/mmcblk0`.  A device name refers to the entire  disk; in this case `/dev/mmcblk0` is the entire SD card.

Note: "mmc" refers to "multi media card", "sd" refers to "SCSI driver", which oddly includes USB drives. Both are ["block devices".](http://pineight.com/ds/block/) Yes... it's incongruent alphabet soup, but deal with it. 

    Disk /dev/mmcblk0: 14.9 GiB, 15931539456 bytes, 31116288 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xbb8517b1

And you'll likely also see the two partitions of the SD card (*p1 and *p2)

    Device         Boot Start      End  Sectors  Size Id Type
    /dev/mmcblk0p1       8192    93802    85611 41.8M  c W95 FAT32 (LBA)
    /dev/mmcblk0p2      98304 31116287 31017984 14.8G 83 Linux

If you have other devices, they will also be listed. 

Now that we have seen the "complete" list produced by `fdisk -l`, we shall not use it again here. [`fdisk`](https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/) is primarily a tool for formatting and partitioning block devices, and that's not what we're after here. As we've seen, in this case, `fdisk` produces a lot of output that we just don't need now. Nevertheless, it's instructuve to see what it does, and to compare its output to another tool that gives us the essential information we need for the task of mounting an external drive: `lsblk`. `lsblk` excludes RAM Disks as they are a special class (contrived actually) of block deivices.  There are numerous optional arguments for `lsblk`, and we'll use the `--fs` (filesystem) option:

    lsblk --fs
    
Which yields (at least in Raspbian "stretch"):    
    
    NAME        FSTYPE LABEL  UUID                                 MOUNTPOINT
    mmcblk0                                                        
    ├─mmcblk0p1 vfat   boot   5DB0-971B                            /boot
    └─mmcblk0p2 ext4   rootfs 060b57a8-62bd-4d48-a471-0d28466d1fbb /
    
A nice, concise presentation! Here we see again the SD card (mmc), and its two partitions `/` and `/boot`. And we note that `/boot` is formatted as `vfat` (a [variant on FAT](https://stackoverflow.com/questions/11928982/what-is-the-difference-between-vfat-and-fat32-file-systems)), which we know to be true :)       

__NOTE: This paragraphis mostly trivial, so ignore it if you're not interested:__
If you're wondering what the 16 instances of `Disk /dev/ram*:` are, they are called __"RAM Disks"__, and are [explained here](https://www.kernel.org/doc/Documentation/blockdev/ramdisk.txt). There's also a good [Wikipedia article that explains the purpose and function of RAM disks](https://en.wikipedia.org/wiki/RAM_drive). But you'll need to formulate your own theory as to why they're used rather extensively in Raspbian, because it's not documented. My theory is that there are two reasons they're used: 1) to reduce the number of write cycles to the SD card, and 2) improve performance by reducing disk i/o latency.  

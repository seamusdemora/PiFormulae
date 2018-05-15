# How Do I Connect an External Drive to a Raspberry Pi?
####  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; (Served with sides of history, philosophy, humour and culture)

### And Why Would I Want to Do This?
    
    1. The Raspberry Pi 3B+ has 4 USB 2.0 ports, and 
    2. external drives can be useful for all sorts of things, and thumb drives are cheap:
        * local backup of RPi files, or a 'disk image' of the entire SD card
        * file sharing with your Mac, PC or another RPi 
        * reduce wear on your SD card 

Since I deploy my RPi's in headless mode, and I'm a Mac user, the approach on this page reflects that. Another decision I've made that determines some elements of the approach here is my choice to use the `exFAT` file system on external drives connected to the RPi. I've chosen `exFAT` for the simple reasons that: a) it's supported by Linux, MacOS and Windows, and b) it doesn't have the limits on file size that `FAT` & `FAT32` do. If you want to use another filesystem, [@wjglenn](https://twitter.com/wjglenn) has written a [good article in How-To Geek reviewing the tradeoffs between the most widely-used filesystems](https://www.howtogeek.com/73178/what-file-system-should-i-use-for-my-usb-drive/) wherein he recommends with sound rationale using `FAT32`. In any case, if you're on board with all of that, let's get into the details: 

## 1. Determine what drives are connected to the RPi before you begin

I'll do this first to make sure I've not forgotten drives that are already connected, and we know there's (probably) at least one. Having a list of connected drives also provides a good baseline for comparison in the next step. 

    sudo fdisk --list
    
Your output may resemble mine (trimmed for brevity); you might see 16 "RAM Disks" (discussed below):    
    
    Disk /dev/ram0: 4 MiB, 4194304 bytes, 8192 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes

    Disk /dev/ram1: 4 MiB, 4194304 bytes, 8192 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes
    
    ...  for /dev/ram2 -> /dev/ram14
    
    Disk /dev/ram15: 4 MiB, 4194304 bytes, 8192 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 4096 bytes
    I/O size (minimum/optimal): 4096 bytes / 4096 bytes

And, if you're using an SD card, the listing does not end here. It will include at least the following device named `/dev/mmcblk0` as shown below. A device name refers to the entire  disk; in this case `/dev/mmcblk0` is the entire SD card. Device names are usually cryptic abbreviations such as: `/dev/sda`, `/dev/sdb`, or in this case `/dev/mmcblk0`. The "mmc" part of the device name refers to "multi media card", "sd" refers to "SCSI driver", which oddly includes USB drives. Both are ["block devices".](http://pineight.com/ds/block/) Yes... it's incongruent alphabet soup, but deal with it. 

    Disk /dev/mmcblk0: 14.9 GiB, 15931539456 bytes, 31116288 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xbb8517b1

And immediately following in this same listing, you'll likely also see the two partitions of the SD card (\*p1 and \*p2):

    Device         Boot Start      End  Sectors  Size Id Type
    /dev/mmcblk0p1       8192    93802    85611 41.8M  c W95 FAT32 (LBA)
    /dev/mmcblk0p2      98304 31116287 31017984 14.8G 83 Linux

If you have other devices connected, they will also be listed. 

Now that we have seen the "complete" list produced by `fdisk -l`, we shall not use it again here. [`fdisk`](https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/) is primarily a tool for formatting and partitioning block devices, and that's not what we're after here. As we've seen, in this case, `fdisk` produces a lot of output that we just don't need now. Nevertheless, it's instructuve to see what it does. Next, we will compare its output to another tool that pares the non-essential information, and gives us what we need for the task of provisioning an external drive that the RPi can use: `lsblk`. `lsblk` excludes RAM Disks as they are a special class (contrived actually) of block deivices.  There are numerous optional arguments for `lsblk` (`man lsblk` is your friend), and we'll use the `--fs` (filesystem) option:

    lsblk --fs
    
Which yields (at least in Raspbian "stretch"):    
    
    NAME        FSTYPE LABEL  UUID                                 MOUNTPOINT
    mmcblk0                                                        
    ├─mmcblk0p1 vfat   boot   5DB0-971B                            /boot
    └─mmcblk0p2 ext4   rootfs 060b57a8-62bd-4d48-a471-0d28466d1fbb /
    
A nice, concise presentation in "tree" format! Here we see again the SD card (mmc), and its two partitions `/` and `/boot`. And we note that `/boot` is reported as formatted in `vfat` (a [variant on FAT](https://stackoverflow.com/questions/11928982/what-is-the-difference-between-vfat-and-fat32-file-systems)), which we know to be true. Having established our baseline, we'll move on to the next step. 

## 2. Plug a USB drive into one of the USB connectors on the Raspberry Pi

After the USB drive is plugged in to the RPi, run `lsblk` again at the RPi command line:

    lsblk --fs
    
For the SanDisk 16GB thumb drive that I plugged into my RPi, the result is: 

    NAME        FSTYPE LABEL       UUID                                 MOUNTPOINT
    sda                                                                 
    ├─sda1      vfat   EFI         67E3-17ED                            
    └─sda2      vfat   SANDISK16GB 7366-16EF                            
    mmcblk0                                                             
    ├─mmcblk0p1 vfat   boot        5DB0-971B                            /boot
    └─mmcblk0p2 ext4   rootfs      060b57a8-62bd-4d48-a471-0d28466d1fbb /

Which tells us that this device listed as `sda` must be the SanDisk 16GB thumb drive because it wasn't listed when we ran `lsblk` previously! And this result is further interesting for several reasons:

1. I had just formatted this USB drive in my Mac as `FAT32` (`VFAT` wasn't even an option), 
2. I did not intentionally request two partitions, yet two partitions were created: `sda1` and `sda2`, 
3. the `MOUNTPOINT` column is empty for `sda` and its two partitions... why wasn't it `mount`ed?

We must press on for the answers to these questions, and for our enlightenment. 

[Jack Sprat](https://en.wikipedia.org/wiki/Jack_Sprat) could eat no [`FAT`](https://en.wikipedia.org/wiki/File_Allocation_Table). Indeed! If one thinks of "fat" as having to do with wealth or abundance, then the "File Allocation Table" certainly fits in well with that thinking. There are numerous types, extensions and derivatives of this file system, some with subtle differences. [Design of the FAT file system is fluid](https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system); so much so that the boundaries between the different flavors has blurred. And so that seems to be what has happened with Apple's implementation of `FAT32`... they have become like Jack Sprat, and will eat no more `FAT`! THe good news is that for most practical purposes, Apple's implementation (`FAT32`) works with the Linux (and therefore Raspbian) implementation (`vfat`). We'll not worry this point further, but the knowledge may have given us a wee bit more "power".

What's with the "extra" partition? Why has the Mac's __Disk Utility__ app created a partition named `EFI`? I didn't (intentionally) ask for this! To answer, note there's a subtle clue in the `LABEL` column of the `lsblk` listing: `EFI`. Briefly, `EFI` stands for ["Extensible Firmware Interface"](https://en.wikipedia.org/wiki/EFI_system_partition). Its existence and its original design is a product of [Intel's laboratories](https://firmware.intel.com/learn/uefi/about-uefi). Since then, the __UEFI__ (now "Unified" :) specification has come under the control of the __UEFI Forum__ - a group of the computer industry's "heavy hitters", which includes Apple! The hyperlinks here will provide hours of reading pleasure, but the answer to this question is found in the __Disk Utility__ interface: Once the __Show All Devices__ option is selected, a __Scheme__ for `MBR` may be selected. `MBR` does not include an EFI partition 

![Disk Utility: Show All Devices](pix/DiskUtil-ShowVol.png "Disk Utility dialog with Show All Devices option checked" =320x)
<img src="pix/DiskUtil-ShowVol.png" alt="Disk Utility dialog with Show All Devices option checked" width="480">

So I re-formatted it again in my Mac as `exFAT`, re-inserted it into the RPi, and ran `lsblk --fs` again with this result: 

    NAME        FSTYPE LABEL       UUID                                 MOUNTPOINT
    sda                                                                 
    ├─sda1      vfat   EFI         67E3-17ED                            
    └─sda2      exfat  SANDISK16GB 5AFA-4B3E                            
    mmcblk0                                                             
    ├─mmcblk0p1 vfat   boot        5DB0-971B                            /boot
    └─mmcblk0p2 ext4   rootfs      060b57a8-62bd-4d48-a471-0d28466d1fbb /

Which is even more interesting! Note that MacOS apparently re-formatted the `sda2` partition from `vfat`to `exFAT`, but not `sda1`; it remains formatted as `vfat`. 

The other thing to notice is that the USB drive (`sda`) has two (2) partitions. Note also that `sda1` has a label of `EFI` assigned, and it didn't change after re-formatting. This [EFI partition](https://en.wikipedia.org/wiki/EFI_system_partition) was created only because the "scheme" selected in Mac's __Disk Utility__ was "GUID Partition Map"
This is potentially significant because there have been documented [issues wherein older versions of Raspbian (i.e. "wheezy") were unable to read GPT (GUID Partition Table)](http://www.zayblog.com/computer-and-it/2013/07/22/mounting-gpt-partitions-on-raspberry-pi/) drives. 

Why doesn't the RPi (Raspbian actually) just `mount` this thumb drive when I insert it? Clearly I meant to use the damn thing when I plugged it into the RPi's USB port! And that's what my Mac (and Windoze PC) does when I plug in. Is the RPi just being obtuse? Well, no, it's not being obtuse... but the OS reflects a different [culture](https://en.wikipedia.org/wiki/Culture). It's a culture that was born at the dawn of the ["computer age"](https://en.wikipedia.org/wiki/Information_Age), and like most cultures, is resistant to change. If it helps, you can think of it as I do: there is a bit of [asceticism](https://en.wikipedia.org/wiki/Asceticism) baked into the brains of the culture's leadership! But we shan't get overly philosophical or critical of this; rather, let's explore it and use it when it suits our purpose. OK - back to the drill! 





__NOTE: This paragraphis mostly trivial, so ignore it if you're not interested:__
If you're wondering what the 16 instances of `Disk /dev/ram*:` are, they are called __"RAM Disks"__, and are [explained here](https://www.kernel.org/doc/Documentation/blockdev/ramdisk.txt). There's also a good [Wikipedia article that explains the purpose and function of RAM disks](https://en.wikipedia.org/wiki/RAM_drive). But you'll need to formulate your own theory as to why they're used rather extensively in Raspbian, because it's not documented. My theory is that there are two reasons they're used: 1) to reduce the number of write cycles to the SD card, and 2) improve performance by reducing disk i/o latency.  
<p align="center"><b>(Served with sides of history, philosophy, humour and culture)</b></p>

# How To Connect a USB Drive to Raspberry Pi?

## Table of Contents

* [Background and Objectives:](#background-and-objectives)

  * [Why would I want to do connect an external drive?](#why-would-i-want-to-do-connect-an-external-drive) 
  
  * [But all of these instructions! Why is this so complicated? On my Mac, I plug the drive in, and it just works. I can read from it, and write to it immediately!](#but-all-of-these-instructions-why-is-this-so-complicated-on-my-mac-i-plug-the-drive-in-and-it-just-works-i-can-read-from-it-and-write-to-it-immediately) 
  
  * [Getting to the job at hand (finally)](#getting-to-the-job-at-hand-finally) 
  
   [1. Determine what drives are currently connected to the RPi](#1-determine-what-drives-are-currently-connected-to-the-rpi)
  
   [2. Plug the USB drive in the RPi, partition and format it](#2-plug-the-usb-drive-in-the-rpi-partition-and-format-it)
  
   * [NOTE 1: File systems and formats](#note-1-file-systems-and-formats)
  
   * [NOTE 2: Partitions and their uses](#note-2-partitions-and-their-uses)
  
   * [NOTE 3: Evolving Linux Support for exfat](#note-3-evolving-linux-support-for-exfat) 
  
     ​    [Partition:](#partition)
  
     ​    [Format:](#format)
  
   [3. Mount the USB drive](#3-mount-the-usb-drive) 

   [4. Re-Mount each time the RPi reboots:](#4-re-mount-each-time-the-rpi-reboots) 

   [5. Adjusting permissions and ownership in an exfat drive](#5-adjusting-permissions-and-ownership-in-an-exfat-drive) 

* [Summary and closing](#summary-and-closing) 
* [REFERENCES:](#references) 

## Background and Objectives:

Following is a procedure to mount a USB Drive on a Raspberry Pi. USB drives are typically small, portable data storage devices typically used for data transfer. USB drives are [block storage devices](https://en.wikipedia.org/wiki/Block_(data_storage)) which implies that they will be *formatted* IAW a particular [file system](https://en.wikipedia.org/wiki/File_system). This recipe utilizes one of the so-called [FAT file systems](https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system), chosen because of its compatibility with virtually all modern operating systems. Note however that while the FAT file system is ubiquitous, it does not compare particularly well *performance-wise* against other, more modern file systems. 

Rather than simply listing the steps in rote fashion, this recipe includes some background and context. This is done primarily for my benefit - as a learning exercise.  I hope this approach will be useful to others as well, an alternative to the typical "copy and paste tutorial" that invites copying command lines from a blog into a terminal window without thinking about what they mean.  But if you don't care about the explanations, ignore them; just follow the steps inside the code blocks. 

### Why would I want to do connect an external drive?

1. The Raspberry Pi has 4 USB ports, and 
2. external drives can be useful for all sorts of things:
    - local backup of RPi files, or a 'disk image' of the entire SD card
    - file sharing with your Mac, PC or another RPi 
    - reduce wear on your SD card 
3. USB drives are cheap

### But all of these instructions! Why is this so complicated? On my Mac, I plug the drive in, and it just works. I can read from it, and write to it immediately!

That's a good question. Unfortunately, the answer may not be straightforward, and will not satisfy all parties. The answer comes down to ["cultural differences"](http://www.analytictech.com/mb021/cultural.htm) between the ["Unix way"](http://wiki.c2.com/?UnixWay), and the ["Mac way"](https://developer.apple.com/macos/human-interface-guidelines/overview/themes/) of getting things done on a computer. The process for mounting a drive in [Unix/Linux/\*nix](https://en.wikipedia.org/wiki/Unix-like) systems is a [cultural artifact](https://en.wikipedia.org/wiki/Cultural_artifact), and it highlights the differences between two different philosophies for interacting with the user of the system. As a cultural practice, perhaps there is not one __right way__ to do something, and the __best way__ depends on your cultural orientation. For example, I recently learned that [as a dinner guest in France, bringing a bottle of wine may be considered offensive](https://theculturetrip.com/europe/france/articles/10-customs-only-the-french-can-understand/). Who knew? 

If that doesn't satisfy you, try this: It's self-evident that the drive-mounting process for many __\*nix__ systems (including RPi OS) is more complicated, and therefore time- & labor-intensive than it is for a Mac (or PC). Compared against the simpler mounting process for a Mac, we are hard-pressed to identify any real, compelling advantage that would induce a rational, unbiased person of average intelligence or better to use the more complicated process when given the choice. It comes down to this: If things are "better" in some way as a result of taking a more challenging path to our objective, the rational person may be inclined to take on that extra effort. But if there are no gains or advantages to "pay for" that extra investment of time and effort then one might question that approach. [Cultural sensitivity](https://redshoemovement.com/what-is-cultural-sensitivity/) demands awareness and a non-judgmental attitude. Be aware that there are people from the \*nix culture who [feel quite strongly that their way is the correct way](https://unix.stackexchange.com/questions/178077/why-do-we-need-to-mount-on-linux?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa), and will argue their point vehemently. That said, a more user-centric approach seems to be gaining some traction in the \*nix culture; there are now Linux "desktop systems" that mount external drives when plugged into the system - same as with the Mac. But many, including RPi OS 'Lite', still require a "manual" mount process. 

But none of this changes one simple fact: If you want to experiment with a Raspberry Pi, you'll need to adapt to this "Unix culture". And here's a carrot: learning is good, and it will clearly improve your skills in your Mac (maybe even PC) environment.

### Getting to the job at hand (finally)

Since I deploy my RPi's in headless mode, this recipe reflects *my choices*. For example, I like to use the [`exFAT`, or `exfat`](https://en.wikipedia.org/wiki/ExFAT) file system on USB thumb drives connected to the RPi. I've chosen `exFAT` for the simple reasons that: a) it's supported by Linux, MacOS and Windows, and b) it doesn't have the limits on file size that `FAT` & `FAT32` do (see [`exFAT` details](https://events.static.linuxfound.org/images/stories/pdf/lceu11_munegowda_s.pdf)). If you want to use another file system, [@wjglenn](https://twitter.com/wjglenn) has written a [good article on the "How-To Geek" website reviewing the tradeoffs between the most widely-used file systems](https://www.howtogeek.com/73178/what-file-system-should-i-use-for-my-usb-drive/). He recommends, with sound rationale, using `FAT32`; but you're free to choose whatever suits you. 

## 1. Determine what drives are currently connected to the RPi

Before we plug our external drive into the RPi, let's check to learn what drives are already connected; we know there's (probably) at least one. Having a list of connected drives will provide a reliable baseline for comparison in the next step. 

```bash
$ sudo fdisk --list
```

Your output may resemble mine (trimmed for brevity) below; you might see 16 "RAM Disks" (discussed below) listed in the output:        
```bash
Disk /dev/ram0: 4 MiB, 4194304 bytes, 8192 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
  
Disk /dev/ram1: 4 MiB, 4194304 bytes, 8192 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes

...  ad nauseum for '/dev/ram2' through '/dev/ram15'
```

If your RPi has an SD card, the listing continues as shown below, and it will include at least one more device named `/dev/mmcblk0`. 

We should cover some semantics: A device name refers to the entire  disk; in this case `/dev/mmcblk0` is the entire SD card. Device names are usually cryptic abbreviations such as: `/dev/sda`, `/dev/sdb`, or in this case `/dev/mmcblk0`. The `/dev` identifies it as a device, and is followed by a name. The "mmc" part of the device name refers to "multi media card". As we shall see shortly, another common type of device is named "sd", which refers to "SCSI driver" - __not__ [Secure Digital](https://en.wikipedia.org/wiki/Secure_Digital). Oddly perhaps, `sd` device names are also used for USB drives; this, owing perhaps to culturally-biased decisions, or perhaps [this explanation is more accurate](https://en.wikipedia.org/wiki/SCSI_command). Following is the `fdisk` report on the SD card used in my RPi:

    Disk /dev/mmcblk0: 14.9 GiB, 15931539456 bytes, 31116288 sectors
    Units: sectors of 1 * 512 = 512 bytes
    Sector size (logical/physical): 512 bytes / 512 bytes
    I/O size (minimum/optimal): 512 bytes / 512 bytes
    Disklabel type: dos
    Disk identifier: 0xbb8517b1

And immediately following in this same listing, you'll likely also see the two [*partitions*](https://www.howtogeek.com/184659/beginner-geek-hard-disk-partitions-explained/#what-is-a-partition) of the SD card (\*p1 and \*p2): (We'll come back to this concept of a *partition* shortly...) 

    Device         Boot Start      End  Sectors  Size Id Type
    /dev/mmcblk0p1       8192    93802    85611 41.8M  c W95 FAT32 (LBA)
    /dev/mmcblk0p2      98304 31116287 31017984 14.8G 83 Linux

If you have other Devices or Disks connected, they will also be listed in the `fdisk --list` output. 

We've now seen the output `fdisk --list` produces. We shall not use it again here as [`fdisk`](https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/) is primarily a tool for formatting and partitioning block devices, and that's not what we're after at this point.  As we've seen, `fdisk` produces a lot of output that we don't need now, but it's instructive to see what it does. 

Next, compare the output of `fdisk` to that of the `lsblk`  tool;  `lsblk` gives us what we need for the task of mounting an external drive for the RPi. `lsblk` excludes RAM Disks as they are a special class (contrived actually) of block devices.  There are numerous optional arguments for `lsblk` (`man lsblk` is your friend); we'll use the `--fs` (file system) option because its output is beautiful  :) 

    pi@raspberrypi3b:~ $ lsblk --fs

Which yields the following: 
```bash
NAME        FSTYPE FSVER LABEL      UUID                                 FSAVAIL FSUSE% MOUNTPOINT
mmcblk0
├─mmcblk0p1 vfat   FAT32 boot       19E2-67CF                             200.9M    20% /boot
└─mmcblk0p2 ext4   1.0   rootfs     97ca6ca8-5cb1-413f-84d0-569efd4e2c0f   25.8G     7% /
```

This output is indeed beautiful... a nice, concise presentation in "tree" format with *headings*! Here we see again the SD card *device* (`mmcblk0`), and its two partitions: p2 ( root,  `/` ) and p1 ( `/boot` ). We also note that `/boot` is reported as formatted in [`vfat`](http://wiki.linuxquestions.org/wiki/VFAT) (a [variant on FAT](https://stackoverflow.com/questions/11928982/what-is-the-difference-between-vfat-and-fat32-file-systems)) under the heading `FSTYPE`, whereas `root` ( `/` ) is formatted in `ext4`.  Having established our baseline, we'll move on to the next step. 

## 2. Plug the USB drive in the RPi, partition and format it

I'll use a SanDisk Cruzer 8GB USB drive for the balance of this recipe.  Plug this drive in to the RPi, and then run `lsblk --fs` again at the RPi command line:

```bash
$ lsblk --fs
NAME        FSTYPE FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINT
sda
mmcblk0
├─mmcblk0p1 vfat   FAT32 boot   19E2-67CF                             200.9M    20% /boot
└─mmcblk0p2 ext4   1.0   rootfs 97ca6ca8-5cb1-413f-84d0-569efd4e2c0f   25.8G     7% /
```

Your output may (will likely) vary from that shown above, unless you happen to have plugged an identical USB drive into your RPi. Note in the `lsblk` output above the `MOUNTPOINT` column is empty for `sda`, and that `sda` does not have a partition; e.g. `sda1`.  The absence of a partition was deliberate; i.e. existing partitions were removed for the purposes of this example. The absence of a `MOUNTPOINT` for `sda` simply reflects the fact that *this drive is not yet mounted*.  

Let's digress briefly to review file systems, file system formats and file system partitions:

##### NOTE 1: File systems and formats

As mentioned in a previously cited reference, a [filesystem](https://en.wikipedia.org/wiki/File_system) is all about the structure for organizing the data stored on a non-volatile memory storage device. This structure is also called the format, and the process of *formatting* a drive is just applying the chosen filesystem's data structure to the drive/device/partition.  

As mentioned previously, I prefer a  [`FAT`](https://en.wikipedia.org/wiki/File_Allocation_Table) filesystem for thumb drives due to the fact that FAT can be read and written on all the major OSs: Mac, Linux/Unix and Windows. FAT is a simple filesystem, but this is complicated somewhat by the different [***flavors*** of FAT](https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system); e.g. FAT16, FAT32, exFAT. I generally prefer the [exFAT](https://en.wikipedia.org/wiki/ExFAT) *flavor* because it will accommodate larger partition sizes than the other *FAT flavors*.  

##### NOTE 2: Partitions and their uses

In case you failed to get the definition of a partition provided in the link earlier, let's review that: 

> The thumb drive itself is a *device*.  It contains a mass of unallocated memory storage, but that unallocated memory is virtually useless to our operating system until it is: 1) *partitioned*, and 2) *formatted*. The partitioning process is simply dividing the memory storage on the device into *"blocks"* of data that can be *formatted* - or structured - by writing a filesystem onto the partition.  A partition can [may] encompass the entire device (i.e. all of its memory), or it can cover only a very small slice of the device's memory. The size of the partition should reflect its intended usage. 

Or perhaps this Wikipedia article on [disk partitioning](https://en.wikipedia.org/wiki/Disk_partitioning) will make more sense to you? 

##### Note 3: Evolving Linux Support for `exfat`

Using the `exfat` filesystem adds a few [wrinkles](https://idioms.thefreedictionary.com/add+a+new+wrinkle) to the mounting process. Support for `exfat` in Linux is *evolving*, and there are some changes we must be aware of if we're to succeed in this task: 

***First***, support for the `exfat` filesystem has been incorporated in the Linux kernel since version 5.4. In the unlikely event you're still running a kernel earlier than this, you're not *out-of-luck*, but you will have to adjust your approach, and understand that you'll be limited to the FUSE option. 

Verify your kernel version is > 5.4; FWIW I've listed 3 of my systems: 

```bash
$ uname -sr			# RPi 3B+; Raspbian GNU/Linux 11 (bullseye)
Linux 6.1.21-v7+ 
$ uname -sr			# RPi 4B; Raspbian GNU/Linux 11 (bullseye)
Linux 6.1.21-v8+ 
$ uname -sr			# RPi B+; Raspbian GNU/Linux 10 (buster)
Linux 5.10.103+
```

***Second***, some of the tools/utilities for dealing with `exfat` have been changed, and if you're on a *modern* version of the RPi OS/kernel, you'll need to have the *up-to-date* tools. Following old, outdated (or even plain incompetent) blogs and *How-Tos* can lead you into a world of confusion.  

Verify your *tools* are up-to-date; specifically *on a modern, up-to-date system* you should be using `exfatprogs`, and ***not*** `exfat-utils`. You can let `apt` verify this for you: 

```bash
$ sudo apt update
$ sudo apt install exfatprogs
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
exfatprogs is already the newest version (1.1.0-1).
```

On the subject of tools/utilities, I should share this:  I tried repeatedly to partition the USB drive in this recipe using `fdisk` and `parted`, but all of these attempts failed. I attribute this to my own ignorance. However, I was able to successfully partition the USB drive using `gdisk`.  Consequently, that's what I'll use in the sequel! 

### Partition:

Following is the sequence I saw/followed for `gdisk`: 

```bash
$ sudo gdisk /dev/sda
GPT fdisk (gdisk) version 1.0.6

Partition table scan:
  MBR: protective
  BSD: not present
  APM: not present
  GPT: present

Found valid GPT with protective MBR; using GPT.

Command (? for help): 

# following command sequence used:  n (add new partition), 8300 (filesystem type), w (write), Y (confirm write)
$ lsblk --fs
NAME        FSTYPE FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINT
sda
└─sda1
```

It appears from the `lsblk --fs` output that we have successfully created a new partition on `/dev/sda`, namely  `/dev/sda1`. 

### Format

Since we have kernel support for `exfat`, we should be able to use `mkfs -t exfat`: 

```bash
$ sudo mkfs -t exfat /dev/sda1
exfatprogs version : 1.1.0
Creating exFAT filesystem(/dev/sda1, cluster size=131072)

Writing volume boot record: done
Writing backup volume boot record: done
Fat table creation: done
Allocation bitmap creation: done
Upcase table creation: done
Writing root directory entry: done
Synchronizing...

exFAT format complete!
$ lsblk --fs
NAME        FSTYPE FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINT
sda
└─sda1      exfat  1.0          FDD5-6EBA

$ sudo exfatlabel /dev/sda1 CRUZER8GB     # apply a LABEL to the drive
exfatprogs version : 1.1.0
new label: CRUZER8GB
```

And so we can! We now have a *partitioned* and *formatted* `exfat` USB drive. 

## 3. Mount the USB drive

Before a drive can be mounted, a [mount point](https://www.linuxhp.com/linux-create-mount-point/) is needed in the RPi's file system; let's do that.  I like to have USB mount points in my `$HOME` directory, `/home/pi`. This may not be the best choice for a multi-user system, and others will counsel creating the mount point under `/media` or `/mnt`. You can do as you wish, but here's mine: 

```bash
$ mkdir /home/pi/mntThumbDrv 
```

That's right - a *mount point* is just a directory in the computer's file system!  Furthermore, that directory is (typically) empty until the `mount` is completed. Only then does the directory contain any data. Since we've now got everything we need for a `mount`, let's do that - and confirm it with `lsblk --fs`:  

```bash
$ sudo mount -t exfat /dev/sda1 ~/mntThumbDrv
$ lsblk --fs
NAME        FSTYPE FSVER LABEL     UUID                                 FSAVAIL FSUSE% MOUNTPOINT
sda
└─sda1      exfat  1.0   CRUZER8GB FDD5-6EBA                               7.5G     0% /home/pi/mntThumbDrv
```

## 4. Re-Mount each time the RPi reboots:

Now that the mount point has been created, let's consider a question of *usage*. By usage, I mean *"will the drive being mounted be used regularly - or, will it be used only one time?"*  If one plans that the mounted drive will be used regularly, and it is to be mounted each time the computer is booted, perhaps the easiest approach is to create an entry for that mounted drive in the file `/etc/fstab`. Otherwise, a *one-time* mount may be accomplished by running the `mount` command manually from the terminal - as shown in the preceding code block. 

A review of `man fstab` will get us started toward creation of an entry in `/etc/fstab`. Open `/etc/fstab` in your editor, and while reading `man fstab`, the following line may suggest itself: 

```
#1st field(fs_spec)  2nd field(fs_file)   3rd(fs_vfstype) 4th(fs_mntops)  5th(fs_freq) 6th (fs_passno)
#-----------------------------------------------------------------------------------------------------
# Don't copy headings; they are here for clarity only

LABEL=CRUZER8GB     /home/pi/mntThumbDrv exfat            rw,user,nofail        0      0
```

We can test this by `umount`ing `/dev/sda1`, and then running `mount -av`, and confirm with `lsblk --fs`: 

```bash
$ sudo umount /home/pi/mntThumbDrv 
$ sudo mount -av
/proc                    : already mounted
/boot                    : already mounted
/                        : ignored
/home/pi/mntThumbDrv     : successfully mounted
$ lsblk --fs
NAME        FSTYPE FSVER LABEL     UUID                                 FSAVAIL FSUSE% MOUNTPOINT
sda
└─sda1      exfat  1.0   CRUZER8GB FDD5-6EBA                               7.5G     0% /home/pi/mntThumbDrv 
```

## 5. Adjusting permissions and ownership in an `exfat` drive

And so we now have a working line for mounting our USB drive in `/etc/fstab`. Which brings up the question, ***"Should I have an entry in `/etc/fstab` if I only use the drive occasionally?"*** 

I would answer that question, ***"Yes!"***. The reason is in the `user` option in the 4th field (`fs_mntops`); this option allows an unprivileged user to `mount` the drive: 

```bash
$ mount ~/mntThumbDrv
$ lsblk --fs
NAME        FSTYPE FSVER LABEL     UUID                                 FSAVAIL FSUSE% MOUNTPOINT
sda
└─sda1      exfat  1.0   CRUZER8GB FDD5-6EBA                               7.5G     0% /home/pi/mntThumbDrv  
```

The `exfat` file system is *lightweight*; it includes very few of the features of filesystems such as `ext4` - the Linux *standard* filesystem. For example, missing from `exfat` is the file system's ***metadata*** for storing file **ownership** and file **permissions**. As a consequence of this, all ownership and permissions in an `exfat` volume are assigned by the OS at the time the volume is mounted. These values cannot be changed between mounts; i.e. the operations `chown` and `chmod` are simply ***not possible*** on an `exfat` partition. 

Which gets back to the `user` option in `fs_mntops`... *If a user mounts the `exfat` partition*, **ownership of all files is assigned to that user!**  If mounted by `root` (i.e. via `sudo`), then `root` has ownership of all files - which can be troublesome under some circumstances. Adding to this flexibility is the option `users` (plural of `user`). This option allows multiple users to `mount` the partition, and gives each of them ownership. [*I do not know how file conflicts are managed under multiple users*.] I suspect that most RPi systems are not typically used as *multi-user systems*, but this `user`/`users` option still presents some interesting ideas for sharing a USB drive.

The other way to adjust permissions and ownership of an `exfat` partition is to set it in `/etc/fstab`. Refer to `man mount.exfat-fuse` in the `FILE SYSTEM OPTIONS` section. (*I use the reference to `mount.exfat-fuse` because the Linux kernel maintainers [after 4+ years], have yet to produce any documentation for `exfat` in `man mount`!*  :O  ). To set ownership, use the `uid=` and `gid=` options.  To set permissions, use the `umask`, `dmask` or `fmask` options. Remember that these ownership and permission options apply to ***all files*** in the partition, and that they may not be changed while the partition is mounted; i.e.`chown` and `chmod` will never work on an `exfat` partition. 

## Summary and closing

I think that covers routine mounting of USB drives on RPi. We've focused on mounting `exfat` partitions connected via USB. That leaves network-mounted drives and the `systemd`-*supported* auto mount for another recipe(s). 

FINALLY: If you see an error in this "recipe", or you've got an idea to improve it, please fork this repository to your GitHub account, and once it's in your account, submit a "Pull Request" for the corrections or improvements you'd like to see. [Tom Hombergs has created a very good tutorial on how to do this](https://reflectoring.io/github-fork-and-pull/). 

## REFERENCES: 

1. [How to format USB with exFAT on Linux](https://linuxconfig.org/how-to-format-usb-with-exfat-on-linux) - from LinuxConfig.org, covers `gdisk` usage 
2. [Disk partitioning](https://en.wikipedia.org/wiki/Disk_partitioning); Wikipedia
3. [10 fdisk Commands to Manage Linux Disk Partitions](https://www.tecmint.com/fdisk-commands-to-manage-linux-disk-partitions/) 
4. [Beginner Geek: Hard Disk Partitions Explained](https://www.howtogeek.com/184659/beginner-geek-hard-disk-partitions-explained/#what-is-a-partition); from How-To-Geek
5. [How to Use Fdisk to Manage Partitions on Linux](https://www.howtogeek.com/106873/how-to-use-fdisk-to-manage-partitions-on-linux/); from How-To-Geek 
6. [Partitioning Disks in Linux](https://www.baeldung.com/linux/partitioning-disks); from Baeldung
7. [How To Partition and Format Storage Devices in Linux](https://www.digitalocean.com/community/tutorials/how-to-partition-and-format-storage-devices-in-linux); from DigitalOcean
8. [Top 6 Partition Managers  (CLI + GUI) for Linux](https://www.tecmint.com/linux-partition-managers/)
9. [A GitHub repo for exfatprogs](https://github.com/exfatprogs/exfatprogs) 
10. [Q&A: Is exfat-utils missing in debian 12?](https://unix.stackexchange.com/questions/759978/is-exfat-utils-missing-in-debian-12); U&L SE 
11. [exFAT filesystem *speed* and *disk usage* based on cluster size](https://gabrielstaples.com/exfat-clusters/#formatting-an-exfat-drive-on-linux-ubuntu&gsc.tab=0); from Gabriel Staples 
12. [Q&A: Create and format exFAT partition from Linux](https://unix.stackexchange.com/questions/61209/create-and-format-exfat-partition-from-linux); from U&L SE 
13. [How to Format a USB Disk as exFAT on Linux [Graphically and Command Line]](https://itsfoss.com/format-exfat-linux/#command-line); from ItsFoss.com 
14. [Q&A: What is the best way to format a USB stick such that it can be used with both Linux and Windows?](https://askubuntu.com/questions/1281698/what-is-the-best-way-to-format-a-usb-stick-such-that-it-can-be-used-with-both-li); from askUbuntu SE 
15. [How to partition USB drive in Linux](https://linuxconfig.org/how-to-partition-usb-drive-in-linux); from LinuxConfig.org 
16. [How to Create and Manage Linux Partitions using Parted](https://www.ubuntumint.com/create-linux-partitions-parted-command/); from UbuntuMint 
17. [Create a Partition in  Linux - A Step-by-Step Guide](https://www.digitalocean.com/community/tutorials/create-a-partition-in-linux); from DigitalOcean 
18. [How to Format Disk Partitions in Linux](https://phoenixnap.com/kb/linux-format-disk) 
19. [How to Mount and Use an exFAT Drive on Ubuntu Linux](https://itsfoss.com/mount-exfat/); from ItsFoss.com
20. [Search: 'linux format USB drive as exfat'](https://duckduckgo.com/?q=linux+format+USB+drive+as+exfat&t=ffnt&ia=web&atb=v297-1) 
21. [Search: 'linux format partition'](https://duckduckgo.com/?q=linux+format+partition&t=newext&atb=v369-1&ia=web) 
22. [Search: 'linux disk partition tools'](https://duckduckgo.com/?q=linux+disk+partition+tools&t=newext&atb=v369-1&ia=web) 
23. [Search: 'exfat-fuse vs. exfatprogs - which should i use'](https://duckduckgo.com/?q=exfat-fuse+vs.+exfatprogs+-+which+should+i+use&t=ftsa&atb=v297-1&df=y&ia=web) 
24. [Search: 'partition thumb drive with parted'](https://duckduckgo.com/?q=partition+thumb+drive+with+parted&t=newext&atb=v369-1&df=y&ia=web) 
25. [Search: 'linux exfat FUSE'](https://duckduckgo.com/?q=linux+exfat+FUSE&t=newext&atb=v369-1&ia=web) 



<!--- 

<!---  you can hide shit in here!      :) 

* [Background and Objectives:](#background-and-objectives)
  * [Why would I want to do connect an external drive?](#why-would-i-want-to-do-connect-an-external-drive)
  * [But all of these instructions! Why is this so complicated? On my Mac, I plug the drive in, and it just works. I can read from it, and write to it immediately!](#but-all-of-these-instructions-why-is-this-so-complicated-on-my-mac-i-plug-the-drive-in-and-it-just-works-i-can-read-from-it-and-write-to-it-immediately)
  * [Getting to the job at hand (finally)](#getting-to-the-job-at-hand-finally)
    [1. Determine what drives are currently connected to the RPi](#1-determine-what-drives-are-currently-connected-to-the-rpi) 
    [2. Plug the USB drive into the RPi](#2-plug-the-usb-drive-into-the-RPi)
  * [NOTE 1: File systems and formats](#note-1-file-systems-and-formats)
  * [NOTE 2: Partitions and their uses](#note-2-partitions-and-their-uses)  
    [3. Mount the USB drive](#3-mount-the-usb-drive) 
    [4. Create an entry in `/etc/fstab` to automount the USB drive](#4-create-an-entry-in-etcfstab-to-automount-the-usb-drive) 

---

> NOTE: The current recipe here does not consider potential differences due to the adoption of `systemd`. As `systemd` has now become "mainstream", the recipe must be revised accordingly. Until that happens, ***most*** of the following remains accurate and pertinent. If you'd like to add anything, please feel free to fork and issue a pull request - or simply open an issue.  

---

**\<A Brief Diversion Into Apple-dom : \>** 

Referring to the output of `lsblk --fs` above raises at least one question: What's with the partition of `sda` with the Label `EFI`? My Mac's [__Disk Utility__ app](https://www.howtogeek.com/212836/how-to-use-your-macs-disk-utility-to-partition-wipe-repair-restore-and-copy-drives/) created this `EFI` partition in `sda1` - but ***why*** ? 

To answer, we'll use `EFI` as our clue: Briefly, `EFI` stands for ["Extensible Firmware Interface"](https://en.wikipedia.org/wiki/EFI_system_partition). Its existence and its original design is a product of [Intel's laboratories](https://firmware.intel.com/learn/uefi/about-uefi). Since then, the __UEFI__ (now "Unified" :) specification has come under the control of the __UEFI Forum__ - a group of the computer industry's "heavy hitters", which includes Apple. 

The hyperlinks here will provide hours of reading pleasure, but the answer to the question is found in the __Disk Utility__ interface (Note that this is the *mojave* vintage of Disk Utility).  When the default __View__ option of __Show Only Volumes__ is selected, the __GUID Partition Map__ Scheme is also selected. [GUID Partition Table `GPT`](https://en.wikipedia.org/wiki/GUID_Partition_Table) is a subset of the UEFI specifications, and so, in the interest of sanity I suppose, Apple has tied the selection of __Show Only Volumes__ to selection of the __GUID Partition Map__ Scheme by default, although the specifications for `GPT` don't strictly prohibit `MBR`. Once the __Show All Devices__ option is selected, a __Scheme__ for `MBR` may be selected (see __Disk Utility__ screenshots below). And since `MBR` does not include an EFI partition, we should be able to lose that partition by selecting the __Master Boot Record__ Scheme.  

| 1. Select "Show All Devices"                                 | 2. Select MBR as Scheme option                               |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| <img src="pix/DiskUtil-ShowVol.png" alt="Disk Utility dialog with Show All Devices option checked" width="520"> | <img src="pix/DiskUtil-Scheme2.png" alt="Disk Utility dialog with Scheme selection shown" width="520"> |

Let's re-format the USB drive using __Disk Utility__ with the settings shown above, plug it back into the RPi and see if that holds up: 

```
    pi@raspberrypi3b:~ $ lsblk --fs
    NAME        FSTYPE LABEL       UUID                                 MOUNTPOINT
    sda                                                                 
    └─sda1      exfat  SANDISK16GB 5AFA-59C4                            
    mmcblk0                                                             
    ├─mmcblk0p1 vfat   boot        5DB0-971B                            /boot
    └─mmcblk0p2 ext4   rootfs      060b57a8-62bd-4d48-a471-0d28466d1fbb /
```

That looks like what was wanted: a single `exFAT` partition. But now that the `EFI` partition is gone, one could wonder, "What are we missing out on by not having this more modern scheme?" For this particular usage, the answer is, "Since I don't need to boot from this drive (nor do I have any boot files to write), I miss out on nothing." Additionally, in some older versions of Raspbian (e.g. "wheezy"), there have been reported [issues wherein Raspbian was unable to read GPT](http://www.zayblog.com/computer-and-it/2013/07/22/mounting-gpt-partitions-on-raspberry-pi/) drives. 

**Let's now leave this <A Brief Diversion Into Apple-dom : \>**, and return to the *real world* ! 

---

Let's now perform the partitioning and formatting of `sda` using the *native* Linux tools: 

We'll use `fdisk` here, but `parted` can also get the job done... here's [a `parted` *"how-to"*](https://www.digitalocean.com/community/tutorials/how-to-partition-and-format-storage-devices-in-linux)   

1. Plug the USB drive into the system

2. ```bash
   $ sudo fdisk /dev/sda
   # enter the following commands in order: n (add new partition), e (extended), 1 (partition #), defaults for start & end sectors, w (write), q (quit)
   ```

3. Run `lsblk` to confirm `fdisk`:  

   ```bash
   $ lsblk --fs
   NAME        FSTYPE FSVER LABEL  UUID                                 FSAVAIL FSUSE% MOUNTPOINT
   sda
   └─sda1
   ```

4. Format partition as `exfat`: 

   ```
   $ sudo mkfs.exfat -n CRUZER8GB /dev/sda1
   mkexfatfs 1.3.0
   Creating... done.
   Flushing... done.
   File system created successfully.
   ```

5. Run lsblk to confirm: 

   ```
   $lsblk --fs
   NAME        FSTYPE FSVER LABEL      UUID                                 FSAVAIL FSUSE% MOUNTPOINT
   sda         exfat  1.0   CRUZER8GB 3AA1-34E6
   ```

So - that's actually down to 2 steps. Knowing what you need to do is an *invaluable* timesaver!  We've now partitioned and formatted our thumb drive as a single `exfat` partition; it's time to `mount` this drive. 

---

[Jack Sprat](https://en.wikipedia.org/wiki/Jack_Sprat) could eat no [`FAT`](https://en.wikipedia.org/wiki/File_Allocation_Table). If one thinks of "fat" as having to do with wealth or abundance, then the "File Allocation Table" certainly fits in well with that thinking. There are numerous types, extensions and derivatives of this file system, some with only subtle differences. [Design of the FAT file system is fluid](https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system); so much so that the boundaries between the different flavors has blurred. And that seems to be what has happened with Apple's implementation of `FAT32`... they have become like Jack Sprat, and will eat no more `FAT`! The good news is that for most practical purposes, Apple's implementation (`FAT32`) works with the Linux (and therefore Raspbian) implementation (`vfat`). We'll not worry this point further, but the linked references have further details for those who are interested. 

---

Oh - one thing before we move on: There are several tools that show block devices connected to our RPi; e.g. `blkid`, `ls -laF /dev/disk/by-uuid/`, `df -h`, etc. We must choose our tool wisely; always read the `man` page before using a tool whose output we will depend on in a subsequent step. I literally spent hours puzzling over why the output of `blkid` was different than `lsblk --fs`. Had I read `man blkid` first, I would have known the following: 

   >Note  that  blkid  reads  information  directly  from devices and for non-root users it returns cached
   >unverified information.  It is better to use lsblk --fs to get a user-friendly overview of filesystems
   >and  devices.   lsblk(8) is also easy to use in scripts.  blkid is mostly designed for system services
   >and to test libblkid functionality. 

In other words, use `sudo blkid`, or don't use it at all! 

---

Note that we received a couple of warnings (`Operation not permitted`); those are due to differences in the RPi's native file system `ext4` and the `exFAT` file system, and for our purposes here, we need not worry about them ([REF](https://superuser.com/questions/468291/chmoding-file-on-exfat)).  

---



For this *recipe* we'll assume that a line will be added to `/etc/fstab` to mount the drive at each boot.  However, we'll cover the 'one-time' option first as it's illustrative. Begin by plugging the drive (assume a USB drive) into the system.  Once that's done use the command `lsblk --fs` to get the data we'll need to accomplish the mount: 

```
$lsblk --fs
NAME        FSTYPE FSVER LABEL      UUID                                 FSAVAIL FSUSE% MOUNTPOINT
sda         exfat  1.0   CRUZER8GB 3AA1-34E6
mmcblk0
├─mmcblk0p1 vfat   FAT32 boot       19E2-67CF                             200.9M    20% /boot
└─mmcblk0p2 ext4   1.0   rootfs     97ca6ca8-5cb1-413f-84d0-569efd4e2c0f   25.8G     7% /
```

And now the actual `mount`: 


```    bash
$ sudo mount /dev/sda /home/pi/mntThumbDrv
mount: unknown filesystem type 'exfat'
```

Uh-oh... wtfo? We've encountered an `unknown filesystem` error. Looks like RPi OS is telling us there's no support for the `exfat` file system. It seems we must take a detour on the Linux information superhighway!  But surely there's support for `exfat` in a modern system like this one? Let's search the `apt` repository to check: 

    pi@raspberrypi3b:~ $ apt-cache search exfat
    exfat-fuse - read and write exFAT driver for FUSE
    exfat-utils - utilities to create, check, label and dump exFAT filesystem
    ... (& other stuff we don't need now)

And we're in luck! Two relevant packages were found. Let's install them both following the [Package Maintenance recipe](https://github.com/seamusdemora/PiFormulae/blob/master/PackageMaintenance.md): 

```bash
$ sudo apt update 
...
$ sudo apt install exfat-fuse exfatprogs
... (ok)
```

Let's try the `mount` again:

```bash
$ sudo mount /dev/sda1 /home/pi/mntThumbDrv 
$ 
```

Which [smells like nirvana](https://www.youtube.com/watch?v=FklUAoZ6KxY)! We have just mounted our external USB drive, so persistence does pay off. Before we move forward, let's verify we've got what we think we have. We also need some additional information to add this drive to the `/etc/fstab` file: 

```bash
$ touch testfile.txt
$ echo "this is a test" > testfile.txt
$ cp testfile.txt ~/mntThumbDrv
cp: cannot create regular file '/home/pi/mntThumbDrv/testfile.txt': Permission denied 
```

Damn! Another speed bump!  :)   If you fall into this hole, you will note that even the use of `sudo` ***may*** not overcome the `Permission denied` error... I'll explain why below. 

Let's consult our system manuals again... but which manual?? After a bit of research, it turns out the correct manual is: 

```bash
$ man mount.exfat-fuse
```

After a brief review, it looks like some **options** are needed in our `mount` command: 

```bash
$ sudo mount -o uid=pi,gid=pi /dev/sda /home/pi/mntThumbDrv
```

Which does the trick:

```bash
$ cp testfile.txt ~/mntThumbDrv
$ ls -la ~/mntThumbDrv
total 68
drwxr-xr-x  2 pi pi 32768 Nov 10 21:11 .
drwxr-xr-x 16 pi pi  4096 Nov 10 21:10 ..
-rwxr-xr-x  1 pi pi    15 Nov 10 21:11 testfile.txt
```

OK, so things have finally worked out, but ***why*** were we unable to copy the file initially? 





We've written to, and read from, the `mount`ed drive, so it seems we've got it! 

## 4. Create an entry in `/etc/fstab` to automount the USB drive

We're nearly ready to modify the `/etc/fstab` file. In perusing `man fstab`, some of the [documentation](https://help.ubuntu.com/community/Fstab) available online and [advice](https://www.raspberrypi.org/forums/viewtopic.php?t=205016) on `fstab` that's published, we soon recognize there are some decisions to be made - options to be selected. And speaking of documentation, perhaps the most important is the *system manuals*; `man fstab` in this case. From `man fstab` we learn there are six (6) fields in a `fstab` entry: 

1. `fs_spec`  This is the most critical field. The oft-used specifications here are device node (e.g. `/dev/sda1`), `LABEL` and `UUID`. There are several other specs, but these 3 are sufficient for now. [Some advocate](https://www.raspberrypi.org/forums/viewtopic.php?t=205016) using the `UUID` spec and point out that it is more unique and therefore safer than the device node. But we're going to use the `LABEL` specification, and here's why: __We can set it; we have control over the value of `LABEL`, whereas we have no control over the so-called `UUID`.__ In fact, for all types of `FAT` partitions, they do not have a true `UUID`. The identifier shown as `UUID` by `lsblk --fs` isn't actually a `UUID` at all! This is indeed a very murky back alley. Understand though that while we've been drawn into this back alley because of the \*nix culture, this [arcanery](https://www.rd.com/culture/words-that-arent-words/) isn't unique to \*nix systems. Apple's Mac OS designers also had to deal with this complexity to make our lives easier. 
2. `fs_file`  This is the mount point we selected previously on our local filesystem; i.e. `/home/pi/mntThumbDrv`
3. `fs_vfstype`  This is the file system type of the drive (or partition) to be `mount`ed; it will typically reflect how the _to-be-mounted_ partition was formatted -  `exfat` in this case.
4. `fs_mntops`  A comma-separated list of options. We'll use: `rw,user,nofail` (no spaces) which will tell the OS that the drive is read & write, users may mount the drive, and no error will be flagged if the device is not present at boot time (which would stop the boot process!).
5. `fs_freq`  A flag that determines if the file system will be `dump`ed; `0` for our case
6. `fs_passno`  A flag that determines if the file system will be checked by `fsck`, and the order it's to be checked; `0` for our case

After working our way through all the fields, our `fstab` entry looks like this: 

    LABEL=SANDISK16GB /home/pi/mntThumbDrv exfat rw,user,nofail 0 0 

Use your preferred editor (e.g. `nano`) to add this `fstab` entry:

    pi@raspberrypi3b:~ $ sudo nano /etc/fstab
    (STEP1: save the existing `fstab` file as `/etc/fstab.bak`)
    (STEP2: add the new `fstab` entry from above at the end of the file; for example: )
        proc            /proc           proc    defaults          0       0
        PARTUUID=bb8517b1-01  /boot           vfat    defaults          0       2
        PARTUUID=bb8517b1-02  /               ext4    defaults,noatime  0       1
        # a swapfile is not a swap partition, no line here
        #   use  dphys-swapfile swap[on|off]  for that
        LABEL=SANDISK16GB /home/pi/mntThumbDrv exfat rw,user,nofail 0 0
    (STEP3: save the modified file as `/etc/fstab`)

Test the new `/etc/fstab` file using `mount -av` command (`mount` with `all` & `verbose` options) : 

    pi@raspberrypi3b:~ $ sudo mount -av
    /proc                    : already mounted
    /boot                    : already mounted
    /                        : ignored
    FUSE exfat 1.2.5
    /home/pi/mntThumbDrv     : successfully mounted

Use the `lsblk` command to verify that the thumb drive was mounted. As shown below, we see our chosen mount point listed for the `sda1` partition: `/home/pi/mntThumbDrv`. You may now read and write to this drive!   

    pi@raspberrypi3b:~ $ lsblk --fs
    NAME        FSTYPE LABEL       UUID                                 MOUNTPOINT
    sda                                                                 
    └─sda1      exfat  SANDISK16GB 5B00-9E5C                            /home/pi/mntThumbDrv
    mmcblk0                                                             
    ├─mmcblk0p1 vfat   boot        5DB0-971B                            /boot
    └─mmcblk0p2 ext4   rootfs      060b57a8-62bd-4d48-a471-0d28466d1fbb /

Out of an abundance of caution, we'll test the new `fstab` file in an effort to ward off any unpleasant surprises. As a minimum, we should check to see that we don't get a boot-stopping error if the drive is not inserted in the RPi. We can do this easily using `mount` as before. But! Before we remove the USB drive, it must be "un-mounted" using `umount` (no 'n' after the first 'u'!):

    pi@raspberrypi3b:~ $ sudo umount ~/mntThumbDrv
    (assuming no error is returned, it is safe now to remove the thumb drive)
    (once removed, use lsblk & note that /dev/sda1 is absent) 
    pi@raspberrypi3b:~ $ lsblk --fs
    NAME        FSTYPE LABEL  UUID                                 MOUNTPOINT
    mmcblk0                                                        
    ├─mmcblk0p1 vfat   boot   5DB0-971B                            /boot
    └─mmcblk0p2 ext4   rootfs 060b57a8-62bd-4d48-a471-0d28466d1fbb /
    pi@raspberrypi3b:~ $ sudo reboot
    # ...
    # after reboot, issue the mount command with the thumb drive still removed
    pi@raspberrypi3b:~ $ sudo mount -av
    /proc                    : already mounted
    /boot                    : already mounted
    /                        : ignored 
    # SUCCESS! no mount error with USB thumb drive removed from RPi

We have now seen that the `nofail` option in the `fstab` entry we crafted has done its job. We have one final test to wrap things up: re-insert the USB thumb drive into one of the RPi's USB ports, and then: 

    pi@raspberrypi3b:~ $ lsblk --fs
    NAME        FSTYPE LABEL       UUID                                 MOUNTPOINT
    sda                                                                 
    └─sda1      exfat  SANDISK16GB 5B00-9E5C                            /home/pi/mntThumbDrv
    mmcblk0                                                             
    ├─mmcblk0p1 vfat   boot        5DB0-971B                            /boot
    └─mmcblk0p2 ext4   rootfs      060b57a8-62bd-4d48-a471-0d28466d1fbb /

We have now seen that when we re-insert this USB thumb drive into our RPi, it will be "automatically" mounted. This new behavior will persist until we remove the `fstab` entry we created from `/etc/fstab`, or we change the `LABEL` on the USB drive. 

And that's it - we've completed the procedure, and mounted a USB flash drive on a RPi. Congratulations!  

If you wish to share files on this external drive with your Mac, [follow this recipe to mount this same external drive from your Mac.](FileShare.md) 

---

<!-- Created by https://github.com/ekalinin/github-markdown-toc -->

---



-->

-->

## Simple Partition Resizing in Raspberry Pi OS

I just got a new 500GB NVME drive for my RPi5. Due to the way I "installed"  RPi OS on the NVME drive, I wound up with a dinky 9GB root (`/`) partition! So, I had to "extend" or "resize" the root partition. I've not done much of this before - being a macOS and Raspberry Pi/SD card user. Doing some research before starting, I encountered a lot of warnings and cautions, especially for doing this from the command line. But I run headless, and it really cannot be that difficult.  I survived this, and thought I'd document the procedure for others - and myself when I need to do this again. 

We will use four tools for this task: 

- `lsblk --fs`
- `fdisk`
- `resize2fs`
- `e2fsck`	

### 1. Do not be apprehensive; this is not a difficult task! 

I'm sure it's possible to screw this up. I made one mis-step, but recovered easily. The command line interface is rather curt, and it uses words that invoke apprehension. For example, when resizing a partition, it must first be **deleted** (**`d`**). When you've got valuable data on a partition, the last thing you want to do is **delete**. But if you read ahead, you understand that it is not the data you are deleting, but only the partition markers.  

### 2. Start with `lsblk --fs` 

Use this handy tool to find out about all the block devices connected to your machine. Shown below are the results for my RPi5 that has two (2) devices attached: 

- an SD card with two partitions
- an NVME chip/module/card - also with two (2) partitions

You should also note that the NVME card is ***un-mounted - as it must be*** to resize its partitions. One of the nice things about the new NVME accommodations in RPI OS is the boot options. You may keep both devices connected at all times, and prioritize the boot order to favor one or the other (see `raspi-config` for this setup).

```bash
$ lsblk --fs
NAME        FSTYPE FSVER LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
mmcblk0
├─mmcblk0p1 vfat   FAT32 bootfs      146B-AD94                             447.6M    12% /boot/firmware
└─mmcblk0p2 ext4   1.0   rootfs      6e6b1b32-ff98-4ac1-961e-0512bc32d36d   23.5G    14% /
nvme0n1
├─nvme0n1p1 vfat   FAT32 bootfs      146B-AD94
└─nvme0n1p2 ext4   1.0   rootfs      ece25014-1cd7-4874-9bfc-f91e486bc000
```

### 3. Have a quick look with `fdisk -l`

Everything you do with the `fdisk` tool requires `root` privileges. You can probably **dispense** with `fdisk -l` as it provides scant information beyond `lsblk --fs`, but better to use it than not I suppose.

```bash
$ sudo fdisk -l
...
...    # reams of useless data on all 16 ram disks
...
Disk /dev/nvme0n1: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: CT500P3PSSD8
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x8a6020b5

Device         Boot   Start      End  Sectors  Size Id Type
/dev/nvme0n1p1         2048  1050623  1048576  512M  c W95 FAT32 (LBA)
/dev/nvme0n1p2      1050624 19890175 18839552    9G 83 Linux 
...
...    # Note that it does provide Size as well as Start & End blocks
```

### 4. Getting down to business with `fdisk`

Now we begin the "fun" part.  Note that in the first command, the entire device is given as input, rather than the partition of interest. One could also specify the partition of interest; i.e. `/dev/nvme0n1p2`; it makes little difference in the end. 

Note particularly that this command leads us into a command processor; the `:` serves as a prompt. You can enter an `m` for a list & brief explanation of all the commands, but you  needn't do that as we'll only be using a small subset of the commands for re-sizing the NVME's root partition. 

```bash
$ sudo fdisk /dev/nvme0n1		# we'll operate on the entire device rather than a single partition
Welcome to fdisk (util-linux 2.38.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help):
```

We will next enter 4 commands, with some details for one of them: **`p`** for *print,* **`d`** for *delete partition*, **`n`** for *add new partition*, and **`w`** for *write partition table to disk & exit*. 

Following the **`n`** entry, a prompt is issued to define the beginning and ending `sectors` . Defaults are offered; these defaults will result in allocating all un-allocated space on the device to  the new partition (new root partition). 

This was where I may have mis-stepped: *I began thinking* :)    I thought that I *might* want to make the `boot` partition a bit larger, and I might want to leave some space for *"other things"*. And so I initially spec'd the starting sector to be `1800000`, and the ending sector to be `840000000`. After executing the **`w`** command, and moving to the next step (`resize2fs`), I got an ominous message stating "`Bad magic number in super-block while trying to open /dev/nvme0n1p2`" *Oh shit!* :) 

Quickly researching this issue, I read something that suggested the cause *might be* the "gap" I left between the end partition p1 (`boot`) and the beginning of p2 (`root`).  The solution was simple enough: re-run `sudo fdisk /dev/nvme0n1`, delete the new partition I'd just created, make a new(er) one, and ***leave no gap***; i.e. start with the sector number immediately following the end of p1 (`1050624`) - as shown in the dialog below.  Lesson learned: my *thinking* gets me into trouble sometimes. 

```bash
Command (m for help): p
Disk /dev/nvme0n1: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: CT500P3PSSD8
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x8a6020b5

Device         Boot   Start       End   Sectors   Size Id Type
/dev/nvme0n1p1         2048   1050623   1048576   512M  c W95 FAT32 (LBA)
/dev/nvme0n1p2      1800000 840000000 838200001 399.7G 83 Linux

Command (m for help): d								# <== input 'd'
Partition number (1,2, default 2): 2

Partition 2 has been deleted.

Command (m for help): n								# <== input 'n'
Partition type
   p   primary (1 primary, 0 extended, 3 free)
   e   extended (container for logical partitions)
Select (default p): p									# <== input 'p'
Partition number (2-4, default 2):		# <== input nothing, accept default
First sector (1050624-976773167, default 1050624):	# <== input nothing, accept default
Last sector, +/-sectors or +/-size{K,M,G,T,P} (1050624-976773167, default 976773167): 840000000		# <== input 840000000; leave un-allocated space for future use

Created a new partition 2 of type 'Linux' and of size 400 GiB.
Partition \#2 contains a ext4 signature.

Do you want to remove the signature? [Y]es/[N]o: n		# <== input 'n'

Command (m for help): p								# <== input 'p'

Disk /dev/nvme0n1: 465.76 GiB, 500107862016 bytes, 976773168 sectors
Disk model: CT500P3PSSD8
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x8a6020b5

Device         Boot   Start       End   Sectors  Size Id Type
/dev/nvme0n1p1         2048   1050623   1048576  512M  c W95 FAT32 (LBA)
/dev/nvme0n1p2      1050624 840000000 838949377  400G 83 Linux

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

### 5. Nearly finished: run `e2fsck`

I actually was not aware that `e2fsck` was required; I only learned after starting `resize2fs`. 

```bash
$ sudo resize2fs /dev/nvme0n1p2
resize2fs 1.47.0 (5-Feb-2023)
Please run 'e2fsck -f /dev/nvme0n1p2' first.			# <== uhhh, OK

$ sudo e2fsck -f /dev/nvme0n1p2
e2fsck 1.47.0 (5-Feb-2023)
Pass 1: Checking inodes, blocks, and sizes
Pass 2: Checking directory structure
Pass 3: Checking directory connectivity
Pass 4: Checking reference counts
Pass 5: Checking group summary information
rootfs: 123316/584064 files (0.1% non-contiguous), 2233090/2354944 blocks
```

### 6. The final step: run `resize2fs` 

```bash
$ sudo resize2fs /dev/nvme0n1p2
resize2fs 1.47.0 (5-Feb-2023)
Resizing the filesystem on /dev/nvme0n1p2 to 104868672 (4k) blocks.
The filesystem on /dev/nvme0n1p2 is now 104868672 (4k) blocks long.
$
```



And that's it... you should be able to reboot using your NVME card with a lot more space! 

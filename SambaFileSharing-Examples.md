# Some Examples of File-Sharing Using Samba

This "recipe" is a *re-hash* of a [Question I answered recently on Stack Exchange](https://unix.stackexchange.com/a/786845/286615). 

The key to setting up 'shares' with `samba` on Raspberry Pi doing is in the `/etc/smb.conf` file. Open this file with your editor (I'll assume `nano` here), and go to the section named `#===== Share Definitions ====`; or perhaps it's just marked as `[homes]`. In any case, you're safe going to the end of the `/etc/smb.conf` file. 

For each share you want to add, you will add a **"configuration block"** to the  `/etc/smb.conf` file.  

And of course it's also necessary that the 'share' be `mount`-ed on the Raspberry Pi. We'll cover [the `mount` setup below](#4-mounting-the-shares) - after making the changes to `/etc/smb.conf`. 

### 1. Share a plugged-in USB drive:

To add a USB drive, add a *"configuration block"* we'll call `[usbshare]`: 

```bash
# Let's take care of creting the 'mount' point first:
$ sudo mkdir -p /mnt/myusbstick
#
$ sudo nano /etc/samba/smb.conf

#... editor opens file; add the following lines: 

[usbshare]
path = /mnt/myusbstick
read only = no
public = yes
writable = yes

#... save the file, and close the editor

$ 
```

### 2. Share the `home` folder on your RPi:

To add all the files from your Raspberry Pi's `home` directory, edit (or add) the following in your `/etc/smb.conf` file:

```bash
$ sudo nano /etc/samba/smb.conf

#... editor opens file; add/edit the following lines: 

[homes]
browseable = yes
read only = no

#... save the file, and close the editor

$ 
```

### 3. Share the root (`/`) folder on your RPi:

To add **all the files** from your Raspberry Pi, do this: 

```bash
$ sudo nano /etc/samba/smb.conf

#... editor opens file; add the following lines: 

[root$]
path = /
create mask = 0755
force user = root
browsable = yes

#... save the file, and close the editor

# an extra step is required here to add privileges needed for 'root' access

$ sudo smbpasswd -a root

New SMB password:
Retype new SMB password:
Added user root.
$
```

***NOTE: Be careful with this one (above); esp editing Linux files in a Windows text editor (i.e. don't do it unless you know what you're doing).***

### 4. Mounting the 'shares'

Before the `samba` server on your RPi can access the USB drive, the drive will have to be `mount`ed (**`homes` and `root$` are already mounted**) on your RPi. My usual preference is to set up all of my mounts in the file `/etc/fstab`, so we'll illustrate that here: 

First, plug the USB drive into the RPi. Then, from the terminal on the RPi, let's use `lsblk` to get the information we need to create the appropriate entry in `/etc/fstab`:

```bash
$ lsblk --fs

NAME        FSTYPE FSVER LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINT
sda
└─sda1      exfat  1.0   SANDISK16GB 5B00-9E5C
mmcblk0
├─mmcblk0p1 vfat   FAT32 bootfs      DDE5-BCDC                             203.1M    20% /boot
└─mmcblk0p2 ext4   1.0   rootfs      f877e440-e1dc-41e3-8cc0-62640c857595   48.7G    12% /
```

The USB drive is at `sda1`. Note the entries for `FSTYPE`, `LABEL`, and `UUID`; i.e. `exfat`, `SANDISK16GB` and `5B00-9E5C`, respectively. Your USB may be `FAT32` aka `vfat`, `ext<X>` or some Windows-peculiar filesystem. 

Add this USB drive to `/etc/fstab`, using our `nano` editor: 

```bash
$ sudo nano /etc/fstab

#... editor opens file; add the following line: 

LABEL=SANDISK16GB /mnt/myusbstick exfat rw,nofail,user 0 0   # note mount point from above

#... save the file, and close the editor

$
```

Next, create the *mount point* in the Rpi filesystem:

```bash
$ sudo mkdir /mnt/myusbstick   # from the smb.conf configuration for [usbshare]
```

Next, actually `mount` the USB drive: 

```bash
$ sudo mount -a
```

Assuming all that went OK, your USB drive should now be mounted on your RPi, and the `Samba` server should allow you to access it from any laptop/desktop OS whose OS supports `smb`/`samba` - i.e. virtually **all** mainstream OSs. 

In addition if you have chosen to add the 'share's named `homes` and `root$`, you will also be able to access `/home/pi` (or whatever user), and your `/` (root) file system folder.  



---



### REFERENCES:

Note that the [`Samba` documentation](https://duckduckgo.com/?q=edit+smb.conf+share+definitions&t=ffab&ia=web) is both wide and deep! However, it's there if you need it. 
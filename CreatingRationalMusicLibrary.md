## Create a Rational and Portable File Server for Your Music Library 

#### Contents:  
[0. Objective](#0-objective)  
[1. Select the USB storage media](#1-select-the-usb-storage-media)  
[2. Format, partition and mount the USB drive](#2-format-partition-and-mount-a-USB-drive)  
[3. Mounting a network storage device master source:](#3-mounting-a-network-storage-device-master-source)  
[4. Copy the Music Repository](#4-copy-the-music-repository)  
[4.ALT Copy Music Repositories using `rsync`](#4alt-copy-music-repositories-using--rsync)  
[5. Serve!](#5-serve)  

- [Linux vs. Samba <em><strong>permissions</strong></em>](#linux-vs-samba-permissions)  
- [Samba profile for single user pi](#samba-profile-for-single-user-pi)  
- [Samba profile for read-only guest access, write access for user pi](#samba-profile-for-read-only-guest-access-write-access-for-user-pi)  

#### 0. Objective

If you own some or all of the music you listen to, you will have a set of files, a *music library*, to deal with. Each of these files contains an encoded version of an element of your music collection. In many cases, a [*player* application](https://en.wikipedia.org/wiki/Comparison_of_audio_player_software)  (e.g. iTunes, Sonos, WinAmp, etc.) will access a music library by mounting a networked file server or [NAS](https://en.wikipedia.org/wiki/Network-attached_storage). Compared to a music library stored *locally* on your phone, or on your computer's hard drive, a networked file server has the advantage of being able to share your music library with several different player applications and users simultaneously. 

It's straightforward to build a networked file server using a Raspberry Pi (***RPi***) and a USB drive. As a bonus, this file server is easily portable, or even mobile, due to the small size and (relatively) low power consumption offered by the Raspberry Pi. The objective of this recipe is to create such a file server. 

#### 1. Select the USB storage media

Most RPi's have at least one USB 2.0 port, so this is a logical first requirement: USB 2.0 compatibility. Beyond that, the selection comes down primarily to two considerations: 

- Storage capacity 
- Physical size

Storage capacity will be based on the size of the music library. Determine the size of your music library (e.g. `du -sh /path/to/musiclib`), and select a device that will hold that PLUS a healthy margin for future growth - and some overhead. Consider buying a device with twice (2x) the storage capacity of your music library, or a bit more if your collection is still growing. 

Consider two general types of USB drives: A [USB flash drive (aka thumb drive](https://en.wikipedia.org/wiki/USB_flash_drive), and a USB external drive. USB flash drives will have an upper limit of 1 TB (as of Jan, 2019), whereas USB external drives are available with 12 TB or more. USB external drives will use more power than a flash drive, and the [600 mA current capacity of Raspberry Pi's USB ports](https://projects.drogon.net/testing-setting-the-usb-current-limiter-on-the-raspberry-pi-b/) should be considered carefully in selection. In general, drives that meet the USB 2.0 specification are compatible with RPi, assuming it's not powering other devices from its 5V bus. 

As an example, consider a music library with 10,000 files requiring 80 GB of storage. The [SanDisk Cruzer Glide flash drive](https://www.sandisk.com/home/usb-flash/cruzer-glide) is available in 256 GB capacity at a price in the range of \$40 USD. If greater capacity is desired or needed, the [WD *Passport*](https://www.wd.com/products/portable-storage/my-passport.html) series of external drives may be a reasonable choice. A WD Passport with 2 TB capacity is available at a price in the range of \$70 USD. As a USB 2.0 compatible device, the WD Passport won't draw more than 500 mA current. 

#### 2. Format, partition and mount a USB drive

As a starting point, we assume that a USB drive is connected to the RPi, but it is ***NOT*** mounted. Verify this from the `bash` command line in an RPi terminal window:  

```bash
$ lsblk --fs
NAME        FSTYPE LABEL       UUID                                 MOUNTPOINT
sda                                                                 
└─sda1      exfat  SANDISK16GB 5B00-9E5C                            /home/pi/mntThumbDrv
sdb                                                                 
└─sdb1      vfat   PASSPORT2TB F2EC-14F5                            
mmcblk0                                                             
├─mmcblk0p1 vfat   boot        5DB0-971B                            /boot
└─mmcblk0p2 ext4   rootfs      060b57a8-62bd-4d48-a471-0d28466d1fbb /
```

The `lsblk` output lists block storage devices connected to the RPi in a nice *tree* format. In this example, note three devices are plugged in (`sda`, `sdb` and `mmcblk0`), but only two partitions on one of the devices (`mmcblk0`) are mounted. It's clear the device identified as `sdb` is the *Passport* drive, but that won't always be obvious. In this case, the drive already had this descriptive `LABEL` applied before it was plugged in. In the general case, one may need to run `lsblk` before and after plugging a drive in to discern its identity. 

***AGAIN:*** It's important to note that the drive/device `sdb`, (actually its partition `sdb1`, with`LABEL=PASSPORT2TB`) has no `MOUNTPOINT` listed in the `lsblk` output above. This means that the device is "plugged in", but not mounted. If your device **IS** mounted, un-mount as follows:

```bash
$ sudo umount /path/to/mount/point
```

You won't be able to format (or partition) a mounted drive, so you should verify the `umount` command was effective by running the `lsblk —fs` command again. 

The `lsblk —fs` output above also tells us that `sdb` has a single partition: `sdb1`. That being the case, and since we want our music library in a single partition, we may proceed directly to formatting the drive. While there are numerous choices for file systems available, we'll use the `ext4` file system. This, because [`ext4` is a superior alternative to any of the `FAT` file systems.](https://unix.stackexchange.com/questions/501982/file-system-compatibility-with-cifs) It will handle the long file and directory names typically found in music file repositories, non-ASCII characters and it is the *default* file system used with Raspbian. 

If the device had no partitions, or the partitioning did not suit our purpose, the `fdisk` utility would be used to delete and create a partition. In this case, the entire drive will be used for our purpose, so the single partition only need be re-formatted to our chosen `ext4` filesystem:   

```bash
$ sudo sudo mkfs.ext4 -L PASSPORT2TB /dev/sdb1 
mke2fs 1.43.4 (31-Jan-2017)
/dev/sdb1 contains a vfat file system labelled 'PASSPORT2TB'
Proceed anyway? (y,N)
```

Respond to this question in the affirmative (`y`) if you are ready to format the drive, and erase everything that is currently stored on it. After responding with `y`, the following output: 

```bash
Creating filesystem with 488370431 4k blocks and 122093568 inodes
Filesystem UUID: 86645948-d127-4991-888c-a466b7722f05
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208, 
	4096000, 7962624, 11239424, 20480000, 23887872, 71663616, 78675968, 
	102400000, 214990848

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (262144 blocks): done
Writing superblocks and filesystem accounting information: done 

$ 
```

that indicates the format was successful. Note also that a `Filesystem UUID` was created. This `UUID` can be used (it's one of the options) as a *non-ambiguous* identifier when we make our entry in `/etc/fstab` to automount this partition. 

Verify the formatting with `lsblk` again:

```bash
$ lsblk --fs
NAME        FSTYPE LABEL       UUID                                 MOUNTPOINT
sda                                                                 
└─sda1      exfat  SANDISK16GB 5B00-9E5C                            /home/pi/mntThumbDrv
sdb                                                                 
└─sdb1      ext4   PASSPORT2TB 86645948-d127-4991-888c-a466b7722f05 

**[Note that the output relating to the SD card (mmcblk0) has been trimmed from the output as it is irrelevant to our current objectives.]** 
```

Next we'll create an entry for `/etc/fstab` to mount the *Passport* drive automatically at boot time. The mount point (`/home/pi/mntPassport`) , the values for `fs_spec`, `fs_mntops`, `fs_freq` and `fs_passno`  (ref: `man fstab`) developed in [this recipe](https://github.com/seamusdemora/PiFormulae/blob/master/ExternalDrives.md) will be re-used here with two changes: the `LABEL`, and the file system spec. Note that while the `UUID` value is often recommended instead the `LABEL` value for `fs_spec`. But this is a small system, with infrequent drive swaps, and the `LABEL` adds clarity. Therefore, the entry for `/etc/fstab` will be: 

```bash
LABEL=PASSPORT2TB /home/pi/mntPassport ext4 rw,user,nofail 0 0 
```

Next step: add this entry to  `/etc/fstab` using `nano`, or the editor of your choice: 

```bash
$ sudo nano /etc/fstab 
```

After adding the designated entry, save and exit `nano`, then test the new `/etc/fstab` entry: 

```bash
$ sudo mount -av 
/proc                    : already mounted
/boot                    : already mounted
/                        : ignored
/home/pi/mntThumbDrv     : already mounted
/home/pi/mntPassport     : successfully mounted
$ 
```

Which tells us that our `fstab` entry worked. Now we'll proceed to copy a music library to the partition we've just mounted.

#### 3. Mounting a network storage device master source:

For purposes of this recipe, assume the music library to be copied is on a NAS file server on a local (private) IP network. `mount` NetgearNAS-3 on your RPi as follows: 

```
sudo mount //192.168.1.246/music /home/pi/mntNetgearNAS-3 -o username=ringo,rw,vers=1.0
```

Obviously the IP address, file locations and `username` will vary in your installation, but the general approach will be the same. What is needed to conclude this step is to have a music library mounted on the RPi that can be used to source the file copy to the *Passport*. 

Before moving on, we may wish to know how much data is on the network storage device. For example, how large does our USB storage device need to hold the music files we wish to copy? Perhaps the best way to obtain this information is using the `ncdu` utility. `ncdu` is included with at least some Raspbian distros, or easily installed using `apt`. `ncdu` is simple to use, and its output arranged in an easy-to-read format: 

```bash
$ ncdu --si ~/mntNetgearNAS-3/music_lib
ncdu 1.12 ~ Use the arrow keys to navigate, press ? for help                                    
--- /home/pi/mntNetgearNAS-3/music_lib ---------------------------------------------------
     7.5 GB [#         ] /Compilations
     6.9 GB [#         ] /Podcasts
     5.2 GB [          ] /Ella Fitzgerald
     1.7 GB [          ] /Billie Holiday
     1.6 GB [          ] /The Beatles
     1.0 GB [          ] /The Rolling Stones
   966.0 MB [          ] /Louis Armstrong
   909.7 MB [          ] /Thelonious Monk
   892.2 MB [          ] /Fleetwood Mac
   814.4 MB [          ] /Duke Ellington
   
   ...
   
   Total disk usage: 141.1 GB  Apparent size: 141.1 GB  Items: 18930

```

The `--si` option is useful as it gives sizes in terms that are usually relatable to USB drive specifications. Check out `man ncdu` for all the details. 

#### 4. Copy the Music repository

**N.B. :** **Most people** will be best-served by following the procedure that uses `rsync` to copy the *"master repository"* to the *"portable repository"* for use by RPi. Why? Because - if you're like most - you're continuously adding new music to your  *"master repository"*.  `rsync` will maintain your *"portable repository"* in sync with less effort than repeating the `copy` operation. **In other words :** [***Skip to the next section now.***](#4alt-copy-music-repositories-using--rsync) 

Now that we've mounted the network (or local) storage device where the "master copies" of our music library are located, we'll we'll use it as the `source` to copy all files to the `destination` on the `sdb1` partition on the PASSPORT2TB device. The "copy", or `cp` command will be used, but `rsync` would work as well.  

Options for `cp` will maintain ownership and timestamps on all files, recursively copy all folders, sub-folders and files from the source, copy only files that don't exist on the destination, or have an older time stamp, and use the `pri_library` folder as the `parent` folder. The command below also logs the `verbose` output to a file, `cp_LOG`. 


``` bash
$ cd ~/mntNetgearNAS-3
$ sudo cp --preserve=ownership,timestamps --recursive --update --verbose --parents pri_library /home/pi/mntPassport > /home/pi/cp_LOG 
$ 
```

I'll backtrack here, and admit something: TL;DR. The `cp` command works fine, but in most cases you'll need to take additional steps of adjusting ownership and permissions after copying. Using the `install` command (instead of `cp`) can eliminate these extra steps. But we're here, so let's finish. We'll assume the top level directory for the music files is `music_library`. Proceed as follows: 

```bash
$ cd ~/mntPassport/music_library
$ sudo chown -R pi:pi . 
$
```

This will change both `user` and `group` ownership (`chown`) for all files and folders at the `music_library` level and below. It will also change ownership of all *hidden* files ***except*** **"`..`"**. This means it won't touch ownership for `~/mntPassport`. The entire music library should now be owned by user `pi` and group `pi`. Of course if you wish your music library to be owned by another user on your RPi, simply change user and group to match your preference.   

We will also change permissions (`chmod`) on our copied/imported music library to prevent unauthorized changes to the library.  We must do this in two steps because we need different permissions for files and folders. We want permissions for music files to be `644`; we want permissions for folders to be `755`. The difference is that we don't want the `executable` (`x`) bit set on the music files. Here we change permissions of the *music files* only, not the folders: 

```bash
$ find ~/mntPassport/music_library -type f -exec chmod 644 {} \;
$ 
```

The folders need the `executable` (`x`) bit set to allow users to enter (`cd`) and list (`ls`) the contents of a directory. Therefore, folder permissions will be set to `755`. We may use the following (similar) command to effect this: 

```bash
$ find ~/mntPassport/music_library -type d -exec chmod 755 {} \;
$
```

The `install` utility may be used as an alternative to `copy`. See `man install` for details. 

#### 4.ALT Copy Music Repositories Using  `rsync`

`rsync` may be used to copy the music library from the network drive to the USB drive, and also to keep the USB drive current (synchronized) with the network drive. However, you should know that ***`rsync` synchronizes in one direction: from source to destination***; i.e. if you designate the USB drive as the *destination*, then add files to your USB drive, `rsync` will not update the master drive. ***Changes flow in one direction only.*** 

  Note that `rsync` is a complex utility with a large number of arguments. You should read `man rsync`  carefully, and make use of the `--dry-run` argument to verify your command does what you intend. Following is the *syntax* of the `rsync` command: 

  ```bash
  rsync [options] source destination
  ```

  In this recipe, `rsync` is run from the command line of user `pi`, and it is desired that all files are owned by user `pi`. Permissions will be set such that the music files may be read by anyone, but only user `pi` has write permission. If this is not what you want/need, changing the permissions is straightforward as shown below. Note however that if you intend to run `rsync` as a `cron` job, you may need to make further adjustments. Following are source & destination on the RPi:

  - `source` location: `//NetgearNAS-3/pri_library` ; mounted at `~/mntNetgearNAS-3` 
  - `destination` location: ~/mntPassport/pri_library; a *permanently* mounted USB drive

  Following is the `rsync` command used to sync destination to source: 

  ```bash
  rsync -rtpv --chmod=D1755,F644 '/home/pi/mntNetgearNAS-3/' '/home/pi/mntPassport/pri_library'
  ```

  Let's cover the options: 

  - `-rtpv` is actually 4 options: `r`: *recursive*; `t`:sync file modification times; `p`: sync file/folder permissions; `v`: verbose output.
  - `--chmod=D1755,F644`: sets **D**irectory & **F**ile permissions to `1755` and `644` respectively. 

  [Here's a useful resource for checking `permissions`](https://chmodcommand.com/chmod-1755/)   

  Another useful option is:

  `--dry-run`: as implied, it produces output, but does not actually move any files. Useful for debugging & confidence-building. :)  Here, it's used with a `redirect` to capture the `rsync` output to a file with 3 servings of verbosity.  

  ```bash
   rsync -rtpvvv --chmod=D1755,F644 --dry-run '/home/pi/mntNetgearNAS-3/' '/home/pi/mntPassport/pri_library' > ~/rsync-out.txt
  ```

  As mentioned, `rsync` has numerous options. `man rsync` is your guide to understanding them.

- Finally, if you need ***2-way synchronization***, the [`Unison`](https://github.com/bcpierce00/unison) utility may be useful. In other words, changes made to either source or destination libraries will be propagated to the other. `Unison` is available is the RPi ports tree. 

#### 5. Serve!

Since a [Samba server is already installed and operational](https://github.com/seamusdemora/PiFormulae/blob/master/FileShare.md) on my RPi, all that needs to begin serving the new partition is to add a new `profile` to the Samba configuration file `/etc/samba/smb.conf`. For better or worse, [Samba offers a bewildering number of options](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html) for shares. In an effort to minimize confusion regarding Samba ***permissions***, let's review this topic briefly. After that, we'll cover two options for potentially useful Samba *profiles* below: 

- #### Linux vs. Samba ***permissions***

Before defining a Samba *profile*, a few words re. Linux vs. Samba permissions are in order: 

> Know that permissions assigned in `smb.conf` apply ***ONLY*** to Samba clients. That is, anyone who accesses the Samba share via the Samba server. Know that these Samba permissions ***DO NOT APPLY*** when logged into your RPi as a Linux user. However, this is not to say that Samba and Linux permissions are independent; they are ***NOT*** independent. 

> Samba permissions are ***limited*** by Linux system permissions. Following is a [useful summary](https://www.cyberciti.biz/tips/how-do-i-set-permissions-to-samba-shares.html):
>
> *"Limits set by kernel-level access control such as file permissions, file
> system mount options, ACLs, and SELinux policies cannot be overridden
> by Samba. Both the kernel and Samba must permit the user to perform an 
> action on a file before that action can occur."*

Two versions of the profile follow, the first restricts access to a user named `pi`, the second provides `guest` users with read-only access: 

- #### Samba profile for single user `pi`

```bash
$ sudo nano /etc/samba/smb.conf 

... ADD THE FOLLOWING TO THE END OF THE FILE, SAVE, THEN EXIT nano:

[passport2tb]
comment = RPi Music Library
path = /home/pi/mntPassport
writeable = yes
browseable = yes
create mask = 0700
directory mask = 0700
force user = pi
```

- #### Samba profile for read-only `guest` access, write access for user `pi`

```bash
[passport2tb]
path = /home/pi/mntPassport
writeable = yes
browseable = yes
public = yes
write list = pi
create mask = 0644
directory mask = 0755
force user = pi
```

Of course Samba's options allow many more options than the two we've shown here. Feel free to read the Samba docs, and the [Debuntu](https://www.debuntu.org/samba-how-to-share-files-for-your-lan-without-userpassword/) and [StackExchange](https://askubuntu.com/questions/88108/samba-share-read-only-for-guests-read-write-for-authenticated-users) sources I used for ideas. 

Once you've made your changes, check the .conf file for syntax errors: 

```bash
$ testparm
```

When you've cleared any syntax errors, restart the Samba server `smbd`: 

```bash
$ sudo service smbd restart
```

**Before we leave:** It's worth noting how Samba processes the `/etc/samba/smb.conf` file. As an example, if you used the single user profile above *verbatim*, and compare it to the output of `testparm` you will notice that some changes have been made. Here's how `testparm` sees this profile:

```bash
[passport2tb]
	comment = RPi Music Library
	path = /home/pi/mntPassport
	create mask = 0700
	directory mask = 0700
	force user = pi
	read only = No
```

- `writeable = yes` was replaced with `read only = no` 
  - Why? Because `writeable` is an "inverted synonym" for `read only` 

- `browseable = yes` was deleted 
  - Why? Because `Yes` is the default value for `browseable` 

These options have been left in the configuration spec above only because, IMHO, it's more *readable*, and reinforces the intent when the default values are included. 


---

REFERENCES:

1. [Documentation for `smb.conf`](https://www.samba.org/samba/docs/current/man-html/smb.conf.5.html) 
2. [mount.cifs - mount using the Common Internet File System (CIFS)](http://manpages.ubuntu.com/manpages/cosmic/en/man8/mount.cifs.8.html) 
3. [Google search for 'cifs'](https://www.google.com/search?ei=QflsXN6eGcz4_AbW_oagBg&q=cifs&oq=CIFS&gs_l=psy-ab.1.2.35i39j0i67l3j0i131j0i67l5.6818.6818..13051...0.0..0.89.89.1......0....1..gws-wiz.......0i71.Z2V6mCLXbzw) 
4. [cifs.com website: "All About CIFS"](https://www.cifs.com/) 
5. [File system compatibility with CIFS](https://unix.stackexchange.com/questions/501982/file-system-compatibility-with-cifs) (My question on Unix&Linux StackExchange) 
6. [Rsync (Remote Sync): 10 Practical Examples of Rsync Command in Linux](https://www.tecmint.com/rsync-local-remote-file-synchronization-commands/) 
7. [Rsync options to exclude certain subdirectories](https://stackoverflow.com/a/2194500/5395338) 
8. [Non-Beginner's Guide to Rsync](https://www.howtogeek.com/175008/the-non-beginners-guide-to-syncing-data-with-rsync/) 
9. [Unison as an alternative to Rsync for Bidirectional synchronization](https://www.cis.upenn.edu/~bcpierce/unison/), [Unison GitHub page](https://github.com/bcpierce00/unison)  
10. [A Stack Overflow Q&A related to this recipe](https://stackoverflow.com/questions/1529946/linux-copy-and-create-destination-dir-if-it-does-not-exist) 
11. [Related: Ideas on Managing a Music Library](https://www.techhive.com/article/3201150/how-to-manage-your-digital-music-library.html) 
12. [HowTo: recursive `chown`](https://aplawrence.com/Unixart/chown.html) Also see [this answer on SE](https://superuser.com/a/260939/907399) 
13. [Recursive permission changes to files and folders, a SE answer](https://stackoverflow.com/a/11512211/5395338) 
14. [Use `install` instead of `cp` to copy files and ***set*** attributes](https://www.ostechnix.com/copy-files-change-ownership-permissions-time/) 
15. [How to Partition and Format Drives](https://pimylifeup.com/partition-and-format-drives-on-linux/) 


<!---



TO DO:

- set up a `cron` job to maintain sync between source & dest 
- evaluate `rsync` as alternative to `cp` ; see [REF](https://stackoverflow.com/questions/1529946/linux-copy-and-create-destination-dir-if-it-does-not-exist) 
- update example `smb.conf` on github; [here](https://github.com/seamusdemora/PiFormulae/blob/master/seamus_smb.conf)  





```
THE DUST BIN: 

TEST CASE: 
cd ~/mntNetgearNAS-3 && sudo cp --preserve=ownership,timestamps --recursive --update --verbose --parents pri_library/Adele /home/pi/mntPassport > /home/pi/cp_LOG 

Why does it copy if it's NOT an update? 



rm --recursive --interactive=never ~/mntPassport/pri_library

```

--->
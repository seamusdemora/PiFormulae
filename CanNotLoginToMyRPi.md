## I've Broken Something, and I Can't Login to my RPi

***You can attempt to repair problems on the Pi by rebooting to a root shell. Here's how to do that:*** 

0. Remove the SD card; the `/boot`  partition is [FAT-formatted](https://en.wikipedia.org/wiki/File_Allocation_Table), and it can be mounted, read and written by virtually any computer on earth. The file you need to edit is: `/boot/cmdline.txt`). 
1. Append `init=/bin/sh` at the end of `cmdline.txt`. Re-insert the modified SD card, and reboot.
1. After booting you will be at the prompt in a root shell.
3. Your root file system is mounted as readonly now, so remount it as read/write
    `mount -n -o remount,rw /`

You can then edit files anywhere in the SD card/root file system, incl. the `ext4` partition.

Running `raspi-config` may be a good place to start; it will allow you to change your password, network settings, enable/disable SSH, change keyboard layout,  etc.



---

## REFERENCES:

1. [Changed keyboard layout & now can't enter password](https://raspberrypi.stackexchange.com/a/117828/83790); Full credit to the [effervescent](https://www.dictionary.com/browse/effervescent) @Milliways :)


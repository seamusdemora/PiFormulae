## I've Broken Something, and I Can't Login to my RPi

***You can attempt to repair problems on the Pi by rebooting to a root shell. Here's how to do that:*** 

0. Remove the SD card from the misbehaving RPi, and mount it on another computer (_N.B. the `/boot`  partition is [FAT-formatted](https://en.wikipedia.org/wiki/File_Allocation_Table), and it can be mounted, read and written by virtually any computer on earth._). The file you must edit is: `/boot/cmdline.txt`). 
1. Append `init=/bin/sh` at the end of `cmdline.txt`. Re-insert the modified SD card, and boot the system (plug in USB power cord). 
1. After booting you will be at the prompt in a root shell.
3. Your root file system is mounted as **read-only** at this point, and so will need to re-`mount` it as read-write:
   ```sh
   mount -n -o remount,rw /
   ```

4. You can now edit files anywhere on the SD card/root file system, incl. `/` - the root `ext4` partition.

5. Running `raspi-config` may be a good place to start; it will allow you to change your password, network settings, enable/disable SSH, change keyboard layout,  etc.


---

## REFERENCES:

1. [Changed keyboard layout & now can't enter password](https://raspberrypi.stackexchange.com/a/117828/83790); Full credit to the [effervescent](https://www.dictionary.com/browse/effervescent) @Milliways :)


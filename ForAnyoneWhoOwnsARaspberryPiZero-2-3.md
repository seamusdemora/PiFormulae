## For anyone who owns a Raspberry Pi Zero, 2 or 3: 

Do you get tired of supporting the `rpi-eeprom` tool that came with the default install given that **your RPi does not have an EEPROM**? `rpi-eeprom` takes about 50MB of space on your SD card, and for some reason, it is _very frequently_ updated. Are there any options for dealing with this?

You can "mark" `rpi-eeprom` to prevent it from being upgraded: 

```bash
sudo apt-mark hold rpi-eeprom
```

This may save a little bandwidth, but the app itself remains on your system. And you cannot "remove" `rpi-eeprom` due to some [*questionable* dependencies](https://github.com/raspberrypi/rpi-eeprom/issues/622)... Chief Know-Nothing has spoken!

This solution won't appeal to everyone, but I ***love it***. Here's the procedure: 

```bash 
sudo apt update
sudo apt install equivs
equivs-control rpi-eeprom.control
sed -i 's/<package name; defaults to equivs-dummy>/rpi-eeprom/g' rpi-eeprom.control
# edit rpi-eeprom.control to change the default Version
# From: 	# Version: <enter version here; defaults to 1.0>
# To: 		Version: 99
# save file & exit editor
equivs-build rpi-eeprom.control
sudo dpkg -i rpi-eeprom_99_all.deb
```

There's apparently not much documentation on `equivs`; this [Debian package description](https://packages.debian.org/sid/equivs) is all I could find. The manuals are `man equivs-control` and `man equivs-build`. And of course you can `apt purge equivs` to recover the space on your SD card. You can keep the `rpi-eeprom_99_all.deb` file for use on other systems. 

#### *A word on disaster recovery:*

For those (like me) who used `dpkg` to force the removal of `rpi-eeprom` : 

```bash
sudo dpkg --remove --force-depends rpi-eeprom
```

You will soon discover that this breaks your package system in a way that prevents you from using `apt` to install any new packages! Here's one way to recover from this disaster; another way would possibly have been to re-install `rpi-eeprom` (but we learn nothing from that!) :

```bash
cd /var/lib/dpkg
sudo cp -a status status-backup
# open file "status" in an editor, find and delete references to rpi-eeprom
# in any line that starts with "Recommends:", or "Depends"
# save the file and exit; you should now be able to install (e.g. 'equivs')
```

And finally, in the *"for whatever it's worth"* column, another use for `dpkg` & `apt` is to examine packages (e.g. `rpi-eeprom`): 

```bash
dpkg -L rpi-eeprom
# ⬆︎ gives you everything; you can filter the output in the usual ways; e.g.
dpkg -L rpi-eeprom | xargs file | grep executable 
/usr/bin/rpi-bootloader-key-convert:    Python script, ASCII text executable
/usr/bin/rpi-eeprom-config:             Python script, ASCII text executable
/usr/bin/rpi-eeprom-digest:             POSIX shell script, ASCII text executable
/usr/bin/rpi-eeprom-update:             POSIX shell script, ASCII text executable
/usr/bin/rpi-otp-private-key:           POSIX shell script, ASCII text executable
/usr/bin/rpi-sign-bootcode:             Python script, ASCII text executable

apt show -a rpi-eeprom
Package: rpi-eeprom
Version: 28.9-1
Priority: optional
Section: misc
Maintainer: Tim Gover <tim.gover@raspberrypi.com>
*Installed-Size: 49.6 MB     # my notation
Provides: rpi-eeprom-images
Depends: raspi-utils, python3, binutils, pciutils, python3-pycryptodome
Recommends: flashrom
Breaks: rpi-eeprom-images (<< 7.2)
Replaces: rpi-eeprom-images (<< 7.2)
Homepage: https://github.com/raspberrypi/rpi-eeprom/
Download-Size: 3,940 kB
APT-Sources: http://archive.raspberrypi.com/debian trixie/main arm64 Packages
Description: Raspberry Pi 4/5 boot EEPROM updater
 Checks whether the Raspberry Pi bootloader EEPROM is up-to-date and updates
 the EEPROM.
#---
Package: rpi-eeprom
Version: 1.0
Status: install ok installed
Priority: optional
Section: misc
Maintainer: Equivs Dummy Package Generator <pi@rpi2w>
*Installed-Size: 9,216 B    # my notation;  49.6 MB  vs.  0.009 MB
Download-Size: unknown
APT-Manual-Installed: yes
APT-Sources: /var/lib/dpkg/status
Description: Raspberry Pi 4/5 boot EEPROM updater
 Checks whether the Raspberry Pi bootloader EEPROM is up-to-date and updates
 the EEPROM. 
 
 # for dependencies:
 apt-cache depends rpi-eeprom
 apt-cache rdepends rpi-eeprom
```



## References:

1.  [Q&A: How to make apt ignore unfulfilled dependencies of installed package?](https://unix.stackexchange.com/questions/404444/how-to-make-apt-ignore-unfulfilled-dependencies-of-installed-package)  
2.  [Q&A: Equivs: enhance or update an existing package without uninstalling?](https://unix.stackexchange.com/questions/86176/equivs-enhance-or-update-an-existing-package-without-uninstalling) 
3.  [equivs Circumvent Debian package dependencies](https://tracker.debian.org/pkg/equivs) 
4.  [Faking dependencies with the equivs package](https://grayson.sh/blogs/faking-dependencies-with-the-equivs-package) 
5.  [Hacking Dependencies](https://wiki.debian.org/Packaging/HackingDependencies) - from the Debian Packaging wiki 

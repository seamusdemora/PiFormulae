## For anyone who owns a Raspberry Pi Zero, 2 or 3: 

Do you get tired of supporting the `rpi-eeprom` tool that came with the default install given that **your RPi does not have an EEPROM**? `rpi-eeprom` takes about 25MB of space on your SD card, and for some reason is frequently updated. 

You can "mark" `rpi-eeprom` to prevent it from being upgraded: 

```bash
sudo apt-mark hold rpi-eeprom
```

This may save a little bandwidth, but the app itself remains on your system. And you cannot "remove" `rpi-eeprom` due to some [*questionable* dependencies](https://github.com/raspberrypi/rpi-eeprom/issues/622). 

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
sudo dpkg -i rpi-eeprom_1.0_all.deb
```

There's apparently not much documentation on `equivs`; this [Debian package description](https://packages.debian.org/sid/equivs) is all I could find. The manuals are `man equivs-control` and `man equivs-build`. And of course you can `apt purge equivs` to recover the space on your SD card. You can keep the `rpi-eeprom_1.0_all.deb` file for use on other systems. 

#### *A word on disaster recovery:* 

For those (like me) who used `dpkg` to force the removal of `rpi-eeprom` : 

```bash
sudo dpkg --remove --force-depends rpi-eeprom
```

You will soon discover that this breaks your package system in a way that prevents you from using `apt` to install any new packages! Here's how to recover from this disaster:

```bash
cd /var/lib/dpkg
sudo cp -a status status-backup
# open file "status" in an editor, find and delete references to rpi-eeprom
# in any line that starts with "Recommends:", or "Depends"
# save the file and exit; you should now be able to install (e.g. 'equivs')
```


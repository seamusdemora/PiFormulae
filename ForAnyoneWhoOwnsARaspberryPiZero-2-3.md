## For anyone who owns a Raspberry Pi Zero, 2 or 3:

Do you get tired of supporting the `rpi-eeprom` tool that came with the default install given that **your RPi does not have an EEPROM**? `rpi-eeprom` takes about 50MB of space on your SD card, and for some reason, it is _very frequently_ updated. Are there any options for dealing with this?

One option (easiest) is to "mark" `rpi-eeprom` to prevent it from being upgraded: 

```bash
sudo apt-mark hold rpi-eeprom
```

This may save a little bandwidth, but the app itself remains on your system. And you cannot "remove" `rpi-eeprom` due to some [*questionable* dependencies... Chief Know-Nothing has spoken!](https://github.com/raspberrypi/rpi-eeprom/issues/622) [*credit where credit is due:* I'm not positive, but I do think some *progress* has been made in de-tangling the false dependencies in the `rpi-eeprom` package.]

This solution won't appeal to everyone, but I ***love it***. In summary, the procedure is to use package called `equivs` to create a *dummy package* - also named `rpi-eeprom`.  Then, we substitute the *dummy* `rpi-eeprom` for the "real" rpi-eeprom.  Here's the procedure: 

```bash
$ sudo apt update
$ sudo apt install equivs
# -----
$ equivs-control rpi-eeprom.control
# edit rpi-eeprom.control:
#   FROM: <package name; defaults to equivs-dummy>
#     TO: rpi-eeprom
#   FROM: # Version: <enter version here; defaults to 1.0>
#     TO: Version: 99
#   FROM: Description: <short description; defaults to some wise words>
#          long description and info
#     TO: Description: I am a dummy; I was created by 'equivs'
#           My function is to keep the real 'rpi-eeprom' out of a system that has no EEPROM!
# save file, exit editor
$ equivs-build rpi-eeprom.control
```

At this point, we have a `.deb` file that can be installed with the `dpkg` utility. Before we do that, I've learned that there are some ***quirks*** in `apt` that can be avoided by proceeding as follows: 

```bash
$ sudo apt purge rpi-eeprom 
...
$
# edit two archive files in '/var/lib/apt/lists', and remove the sections that 
# begin with the line: 'Package: rpi-eeprom'; approx 15 lines in each file:
$ sudo nano /var/lib/apt/lists/archive.raspberrypi.com_debian_dists_trixie_main_binary-arm64_Packages
$ sudo nano /var/lib/apt/lists/archive.raspberrypi.com_debian_dists_trixie_main_binary-armhf_Packages
# after making these edits, install the 'equivs' rpi-eeprom package:
$ sudo dpkg -i rpi-eeprom_99_all.deb
$ sudo apt update 
# verify that apt is "squared away": 
$ apt show -a rpi-eeprom
Package: rpi-eeprom
Version: 99
Status: install ok installed
Priority: optional
Section: misc
Maintainer: Equivs Dummy Package Generator <pi@rpi2w>
Installed-Size: 9,216 B
Replaces: rpi-eeprom (<< 99)
Download-Size: unknown
APT-Manual-Installed: yes
APT-Sources: /var/lib/dpkg/status
Description: I am a dummy; I was created by 'equivs'
 My function is to keep the real 'rpi-eeprom' out of a system that has no EEPROM!
```

**Before we forget:**  Recall that during the `apt purge rpi-eeprom`, `apt` told us that there were several programs that were no longer needed, and could be removed with `apt autoremove`. However --- that is part of the tangle of errors that ***Chief Know-Nothing*** created in the `rpi-eeprom` package that was foisted on us. Some of these packages identified for **autoremoval** are actually useful - even for RPi models Zero, 2 & 3! So let's take care of that: 

```bash
# Go ahead with the autoremoval (before we forget!)
$ sudo apt autoremove
REMOVING:
  device-tree-compiler  flashrom  libdtovl0  libfdt1  libftdi1-2  libjaylink0  pastebinit  python3-pycryptodome  raspi-utils-dt  raspi-utils-eeprom  raspi-utils-otp

... 

# Now - re-install the useful packages (your "usefuls" may differ from mine)
$ sudo apt install device-tree-compiler raspi-utils-dt 
...
$
# As confirmation that all is well, you can run 'apt show -a rpi-eeprom' again
```

You might be asking yourself, *"What happens if this goes badly?"*  Good question! Here's the answer: 

```bash
$ dpkg -l | grep rpi-eeprom  # make sure the equivs rpi-eeprom is still installed
$ sudo dpkg --purge rpi-eeprom  # remove equivs rpi-eeprom & related files
$ sudo mv /var/lib/apt/lists/archive.* ~/holding_area  # move archives to a convenient "holding area" until you're "out of the woods"
$ sudo apt update      # creates new archive.* files from the apt sources
$ sudo apt install rpi-eeprom
```

This will put you back to "square one" - where we started.

There's not much documentation on `equivs`; this [Debian package description](https://packages.debian.org/sid/equivs) is all I could find. The installed manuals are `man equivs-control` and `man equivs-build`. 

#### *Another word on disaster recovery:*

For those (like me) who used `dpkg` to force the removal of the "real" `rpi-eeprom` : 

```bash
$ sudo dpkg --remove --force-depends rpi-eeprom
```

You will soon discover that this breaks your package system in a way that prevents you from using `apt` to install any new packages! Here's one way to recover from this disaster; another way would possibly have been to re-install `rpi-eeprom` (but we learn nothing from that!) :

```bash
$ cd /var/lib/dpkg
$ sudo cp -a status status-backup
# open file "status" in an editor, find and delete references to rpi-eeprom
# in any line that starts with "Recommends:", or "Depends"
# save the file and exit; you should now be able to install (e.g. 'equivs')
```

#### *FWIW:*

And finally, in the *"for whatever it's worth"* column, you may use `dpkg` and `apt` to examine a package; e.g. `rpi-eeprom`: 

```bash
# List files installed to your system from package-name.
$ dpkg -L rpi-eeprom
# ⬆︎ gives you everything; pipe to 'less', or filter output as shown below
# Here's what you'll see BEFORE purging/removing the "real" rpi-eeprom package:
$ dpkg -L rpi-eeprom | xargs file | grep executable 
/usr/bin/rpi-bootloader-key-convert:    Python script, ASCII text executable
/usr/bin/rpi-eeprom-config:             Python script, ASCII text executable
/usr/bin/rpi-eeprom-digest:             POSIX shell script, ASCII text executable
/usr/bin/rpi-eeprom-update:             POSIX shell script, ASCII text executable
/usr/bin/rpi-otp-private-key:           POSIX shell script, ASCII text executable
/usr/bin/rpi-sign-bootcode:             Python script, ASCII text executable

# Here's what you'll see AFTER installing the 'equivs' rpi-eeprom package:
$ dpkg -L rpi-eeprom | xargs file | grep executable
# no executables - which is exactly what we wanted  :) 
#
# dpkg-query gives a somewhat different answer... 
$ dpkg-query -s rpi-eeprom
Package: rpi-eeprom
Status: install ok installed
Priority: optional
Section: misc
Installed-Size: 9
Maintainer: Equivs Dummy Package Generator <pi@rpi2w>
Architecture: all
Multi-Arch: foreign
Version: 99
Replaces: rpi-eeprom (<< 99)
Description: I am a dummy; I was created by 'equivs'
 My function is to keep the real 'rpi-eeprom' out of a system which has no EEPROM!
 #
 # if you want to review package dependencies:
 $ apt-cache depends rpi-eeprom   # packages that rpi-eeprom depends upon
 $ apt-cache rdepends rpi-eeprom  # packages that depend upon rpi-eeprom 
 #
 # finally, didja' know there was a 'rpi-eeprom-update.service' ?!
 # 'apt remove ...' probably deletes the service, but 'apt purge' does for sure
 # systemctl status rpi-eeprom-update.service
 #	Unit rpi-eeprom-update.service could not be found.
```



## References:

1.  [Q&A: How to make apt ignore unfulfilled dependencies of installed package?](https://unix.stackexchange.com/questions/404444/how-to-make-apt-ignore-unfulfilled-dependencies-of-installed-package)  
2.  [Q&A: Equivs: enhance or update an existing package without uninstalling?](https://unix.stackexchange.com/questions/86176/equivs-enhance-or-update-an-existing-package-without-uninstalling) 
3.  [Q&A: Using Debian's `equivs` to create a "substitute" package](https://unix.stackexchange.com/questions/801908/using-debians-equivs-to-create-a-substitute-package) 
4.  [equivs Circumvent Debian package dependencies](https://tracker.debian.org/pkg/equivs) 
5.  [Faking dependencies with the equivs package](https://grayson.sh/blogs/faking-dependencies-with-the-equivs-package) 
6.  [Hacking Dependencies](https://wiki.debian.org/Packaging/HackingDependencies) - from the Debian Packaging wiki 

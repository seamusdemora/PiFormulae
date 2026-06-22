## For anyone who owns a Raspberry Pi Zero, 2 or 3:

Are you tired of supporting the `rpi-eeprom` tool that came with the default Raspberry Pi install **given that your RPi does not even have an EEPROM ?** `rpi-eeprom` takes about [125MB of space on your SD card](https://github.com/raspberrypi/rpi-eeprom/issues/622#issuecomment-2448503724). And for reasons that are not clear, it is _frequently_ updated. Have you ever wondered if there are any _options_ for dealing with this? 

### There are at least two options:

#### Option 1: `apt-mark`

The _easiest_ option is to "mark" `rpi-eeprom` to prevent it from being upgraded: 

```bash
sudo apt-mark hold rpi-eeprom
```

This may save a little bandwidth, but the "fat" app itself remains on your system. And you cannot "`apt remove rpi-eeprom`" due to some *false* dependencies added by Raspberry Pi employees with a very dim knowledge of Debian's `apt` package system. And speaking of **dim knowledge**, [***Chief Know-Nothing enlightens us with his vapid opinions here.***](https://github.com/raspberrypi/rpi-eeprom/issues/622) 

After "banning" me from the RPi GitHub site for speaking up (or was it for simply submitting an Issue?), *Chief Know-Nothing* saved the last (and perhaps dumbest) remark on [Issue #622](https://github.com/raspberrypi/rpi-eeprom/issues/622) for himself: ***timg236*** wrote on Jan 7, 2025: "`The raspi-utils dependencies have been tidied up as part of ongoing package fragmentation work improve rpi-image-gen so closing this issue.`" ... "tidied up"?? ... ***That is a gross misrepresentation; they mostly remain fragmented, ill-conceived, and in more than one case - useless !*** 

As of this writing, the `raspi-utils` package still has an "imagined dependency" imposed by *Chief Know-Nothing* for the `rpi-eeprom` package. The `raspi-utils` package includes several tools that may be occasionally **_useful_** for RPi Zero, 2 and 3 owners, including `vcgencmd`, `dtoverlay`, and `dtparam`. But they have nothing to do with `rpi-eeprom`. Why all of these *imagined* dependencies?... stupidity is the only explanation I can imagine. 

#### Option 2: Use Debian's `equivs` package to create a "Dummy" package for `rpi-eeprom`: 

Are we obligated to acquiesce to the dim-witted Chief Know-Nothing... to accept for installation a bloated package whose name and sole function is to manage ***EEPROM hardware... hardware that does not even exist on RPi Zero, 2 or 3 ?*** As it turns out, thanks to the Debian heritage of the RPi software distribution, ***the answer is, "No - we are not bound to the Chief's brain-dead decisions."*** 

*  The first step is to remove the _Chief's_ `rpi-eeprom`: 

```bash
$ sudo apt purge rpi-eeprom
The following packages were automatically installed and are no longer required:
  flashrom  libftdi1-2  libjaylink0  librpieepromab0  pastebinit  python3-pycryptodome  raspi-utils-eeprom  raspi-utils-otp  rpieepromab
Use 'sudo apt autoremove' to remove them.         # <=== NOTE

REMOVING:
  raspi-utils*  raspinfo*  rpi-eeprom*

Summary:
  Upgrading: 0, Installing: 0, Removing: 3, Not Upgrading: 0
  Freed space: 6,196 kB

Continue? [Y/n] Y             # <===  USER INPUT HERE
(Reading database ... 88729 files and directories currently installed.)
Removing raspinfo (20260601-1) ...
Removing rpi-eeprom (28.27-1) ...
Removing raspi-utils (20260601-1) ...
Processing triggers for man-db (2.13.1-1) ...
(Reading database ... 88679 files and directories currently installed.)
Purging configuration files for rpi-eeprom (28.27-1) ...

$ sudo apt autoremove
REMOVING:
  flashrom  libftdi1-2  libjaylink0  librpieepromab0  pastebinit  python3-pycryptodome  raspi-utils-eeprom  raspi-utils-otp  rpieepromab

Summary:
  Upgrading: 0, Installing: 0, Removing: 9, Not Upgrading: 0
  Freed space: 7,660 kB

Continue? [Y/n] Y
(Reading database ... 88678 files and directories currently installed.)
Removing flashrom (1.4.0-3+rpt1) ...
Removing libftdi1-2:arm64 (1.5-10) ...
Removing libjaylink0:arm64 (0.4.0-1) ...
Removing rpieepromab (20260601-1) ...
Removing librpieepromab0:arm64 (20260601-1) ...
Removing pastebinit (1.7.1-1+~rpt2) ...
Removing python3-pycryptodome (3.20.0+dfsg-3) ...
Removing raspi-utils-eeprom (20260601-1) ...
Removing raspi-utils-otp (20260601-1) ...
Processing triggers for man-db (2.13.1-1) ...
Processing triggers for libc-bin (2.41-12+rpt1+deb13u3) ...
$
```

You can confirm the `rpi-eeprom` package has in fact been removed/purged if you'd like: 
```bash
$ apt-cache policy rpi-eeprom
rpi-eeprom:
  Installed: (none)           #  <====  means NOT INSTALLED!
  Candidate: 28.27-1
  Version table:
     28.27-1 500
        500 http://archive.raspberrypi.com/debian trixie/main arm64 Packages
        500 http://archive.raspberrypi.com/debian trixie/main armhf Packages
```

*  Now that `rpi-eeprom` and its dependencies have been removed (purged), we proceed to create a "Dummy" `rpi-eeprom` - one that takes up virtually no space on our SD card, but allows us to install the `raspi-utils` package - which is _at least occasionally_ useful!  To accomplish this we install a Debian package called `equivs`; `equivs` enables us to easily create a *dummy package* - also named `rpi-eeprom`.  Then, we install the *dummy* `rpi-eeprom` package, which in turn enables installation of `raspi-utils` (i.e. `vcgencmd`, `dtoverlay`, and `dtparam`). Here's how:

* Install `equivs` package: 

```bash
$ sudo apt update
$ sudo apt install equivs
...
$
```

* Create the **`rpi-eeprom.control`** file:

```bash
$ equivs-control rpi-eeprom.control
$ nano rpi-eeprom.control    # nano or vim, or vi, or ...

# edit rpi-eeprom.control as follows:

#   FROM: Package: <package name; defaults to equivs-dummy>
#     TO: Package: rpi-eeprom

#   FROM: # Version: <enter version here; defaults to 1.0>
#     TO: Version: 99.2     # for example!

#   FROM: Description: <short description; defaults to some wise words>
#          long description and info
#     TO: Description: I am a dummy; I was created by 'equivs'
#           My function is to keep the real 'rpi-eeprom' out of a system that has no EEPROM!

# save file, exit editor
$
```

* "Build" the Dummy `rpi-eeprom`: 

```bash
$ equivs-build rpi-eeprom.control                 # <=== Build
dpkg-buildpackage: info: source package rpi-eeprom
dpkg-buildpackage: info: source version 99.2
dpkg-buildpackage: info: source distribution unstable
dpkg-buildpackage: info: source changed by Equivs Dummy Package Generator <pi@rpi2w3>
dpkg-buildpackage: info: host architecture arm64
...
The package has been created.
Attention, the package has been created in the current directory,
not in ".." as indicated by the message above!
$
```

* Install the Dummy `rpi-eeprom`:

```bash
$ sudo dpkg -i rpi-eeprom_99.2_all.deb 
Selecting previously unselected package rpi-eeprom.
(Reading database ... 89497 files and directories currently installed.)
Preparing to unpack rpi-eeprom_99.2_all.deb ...
Unpacking rpi-eeprom (99.2) ...
Setting up rpi-eeprom (99.2) ...
$ 
```

*  And as before, we can confirm that the dummy was installed: 

```bash
$ apt-cache policy rpi-eeprom
rpi-eeprom:
  Installed: 99.2
  Candidate: 99.2
  Version table:
 *** 99.2 100
        100 /var/lib/dpkg/status
     28.27-1 500
        500 http://archive.raspberrypi.com/debian trixie/main arm64 Packages
        500 http://archive.raspberrypi.com/debian trixie/main armhf Packages
```

*  Now for the "acid test", let's try to install the `raspi-utils` package: 

```bash
   $ sudo apt update
   $ sudo apt install raspi-utils
   Installing:
     raspi-utils

   Installing dependencies:
     pastebinit  raspi-utils-eeprom  raspi-utils-otp  raspinfo

   Summary:
     Upgrading: 0, Installing: 5, Removing: 0, Not Upgrading: 0
     Download size: 109 kB
     Space needed: 558 kB / 57.0 GB available

   Continue? [Y/n] Y          # <=== USER INPUT
   Get:1 http://archive.raspberrypi.com/debian trixie/main arm64 pastebinit all 1.7.1-1+~rpt2 [54.0 kB]
   Get:2 http://archive.raspberrypi.com/debian trixie/main arm64 raspi-utils-otp all 20260601-1 [10.1 kB]
   Get:3 http://archive.raspberrypi.com/debian trixie/main arm64 raspi-utils-eeprom arm64 20260601-1 [27.4 kB]
   Get:4 http://archive.raspberrypi.com/debian trixie/main arm64 raspinfo all 20260601-1 [10.4 kB]
   Get:5 http://archive.raspberrypi.com/debian trixie/main arm64 raspi-utils all 20260601-1 [7,608 B]
   Fetched 109 kB in 1s (159 kB/s)
   Selecting previously unselected package pastebinit.
   (Reading database ... 89501 files and directories currently installed.)
   Preparing to unpack .../pastebinit_1.7.1-1+~rpt2_all.deb ...
   Unpacking pastebinit (1.7.1-1+~rpt2) ...
   Selecting previously unselected package raspi-utils-otp.
   Preparing to unpack .../raspi-utils-otp_20260601-1_all.deb ...
   Unpacking raspi-utils-otp (20260601-1) ...
   Selecting previously unselected package raspi-utils-eeprom.
   Preparing to unpack .../raspi-utils-eeprom_20260601-1_arm64.deb ...
   Unpacking raspi-utils-eeprom (20260601-1) ...
   Selecting previously unselected package raspinfo.
   Preparing to unpack .../raspinfo_20260601-1_all.deb ...
   Unpacking raspinfo (20260601-1) ...
   Selecting previously unselected package raspi-utils.
   Preparing to unpack .../raspi-utils_20260601-1_all.deb ...
   Unpacking raspi-utils (20260601-1) ...
   Setting up raspi-utils-eeprom (20260601-1) ...
   Setting up raspi-utils-otp (20260601-1) ...
   Setting up raspinfo (20260601-1) ...
   Setting up pastebinit (1.7.1-1+~rpt2) ...
   Setting up raspi-utils (20260601-1) ...
   Processing triggers for man-db (2.13.1-1) ...
   $
```

*  It worked... you've just off-loaded a useless package taking up space on your SD card, and saved some bandwidth by avoiding the necessity for periodic upgrades. `equivs` made this possible! 

#### Option 2 Summary:

While this worked, it might leave you "*scratching your head*" if - like me - you wonder about these additional dependencies we were obliged to install: `pastebinit`, `raspi-utils-eeprom`,  `raspi-utils-otp` and  `raspinfo`. My quick read on these options is that ***none of them*** really add anything useful for most users.  

All Raspberry Pis (incl Zero, 2 and 3) have a small amount of OTP (one-time programmable) memory, so the `raspi-utils-otp` may have utility for some users. Likewise, `raspinfo` is a "reporting tool" used to facilitate data gathering when (for example) submitting an Issue or bug report. `pastebininit` is a "command-line pastebin client" :) - yeah, used for posting stuff to pastebin **!?!** And `raspi-utils-eeprom` is another useless package for Zero, 2 and 3 owners. Wonder why it wasn't part of the `rpi-eeprom` package?

But the burning question in my mind at least is this: "How and why are any of these packages ***dependencies*** for the `raspi-utils` package which includes only `vcgencmd`, `dtoverlay`, and `dtparam`?" And once again, it is my belief that there are no real, true dependencies on `pastebininit` - or any of the others; they are "dependencies" only in weak, lazy or confused minds. Is this *Chief Know-Nothing's* idea of *"being tidied up as part of ongoing package fragmentation work"* **??** And so, these package *"dependencies"* for `raspi-utils` are probably all prime candidates for "dummy packages" created by `equivs`. But you can read the `man` pages for the three (3) utilities in `raspi-utils`, and make your own evaluation. Finally, and to close this recipe, I'd like to say that fortunately for us, very few RPi employees are as arrogant and stupid as *Chief Know-Nothing*. 

## References:

1.  [Q&A: How to make apt ignore unfulfilled dependencies of installed package?](https://unix.stackexchange.com/questions/404444/how-to-make-apt-ignore-unfulfilled-dependencies-of-installed-package)  
2.  [Q&A: Equivs: enhance or update an existing package without uninstalling?](https://unix.stackexchange.com/questions/86176/equivs-enhance-or-update-an-existing-package-without-uninstalling) 
3.  [Q&A: Using Debian's `equivs` to create a "substitute" package](https://unix.stackexchange.com/questions/801908/using-debians-equivs-to-create-a-substitute-package) 
4.  [equivs Circumvent Debian package dependencies](https://tracker.debian.org/pkg/equivs) 
5.  [Faking dependencies with the equivs package](https://grayson.sh/blogs/faking-dependencies-with-the-equivs-package) 
6.  [Hacking Dependencies](https://wiki.debian.org/Packaging/HackingDependencies) - from the Debian Packaging wiki 



<!--- 








Before we do that, I've learned that there are some ***quirks*** in `apt` that can be avoided by proceeding as follows: 

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

For those (like me) who used `dpkg` to **force** the removal of the "real" `rpi-eeprom` : 

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
$ systemctl status rpi-eeprom-update.service
  	Unit rpi-eeprom-update.service could not be found.
$
```



You can hide shit in here  :)   LOL 

--->

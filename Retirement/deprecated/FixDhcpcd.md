### Code Modifications for RPi Packages; using dhcpcd as an example

It happens sometimes that an error is discovered in an installed package, and it should be fixed sooner - rather than later. This recipe describes one way to do that. The example is an error I discovered in `dhcpcd`, the default network management package for Raspberry Pi OS.  

I discovered the error used as the example here using the `inform` option in `dhcpcd.conf`. Using `inform` set up an *"infinite loop"* in the code, and created a tsunami of log activity - not good for SD card life. It wasn't a debilitating error, but neither is it one that could wait for 6 months - or even 3 years as this seems to be the last time the repo was modified. 

Just for background, the `inform` option is set in `/etc/dhcpcd.conf` to create a stable/fixed IPv4 address for your system. If your network manager is `dhcpcd`, you may have encountered the `inform` option. If you've created a fixed ip address in `dhcpcd.conf`, but have not used the `inform` option, then you have done it incorrectly - or at least inefficiently. But why to use the `inform` option is another subject; this is about patching `dhcpcd` to correct an error when the `inform` option has been set in `dhcpcd.conf`.   

Since I have zero experience with building and changing source files managed under Debian-based systems, I'll have to write this recipe on that basis! If you have no experience, this is the guide for you :)  

First step is to make certain the `deb-src` repos are available to apt for fetching source files

```bash
$ cat /etc/apt/sources.list
deb http://raspbian.raspberrypi.org/raspbian/ bullseye main contrib non-free rpi
# Uncomment line below then 'apt-get update' to enable 'apt-get source'
deb-src http://raspbian.raspberrypi.org/raspbian/ bullseye main contrib non-free rpi 

$ $ cat /etc/apt/sources.list.d/raspi.list
deb http://archive.raspberrypi.org/debian/ bullseye main
# Uncomment line below then 'apt-get update' to enable 'apt-get source'
deb-src http://archive.raspberrypi.org/debian/ bullseye main

$ sudo apt update    # update sources.list, raspi.list & any others added
```

Unless you just know the name of the package, it will be necessary to search for it; e.g. we're looking for `dhcpcd`, so try this: 

```bash
$ apt-cache search dhcpcd
dhcpcd - DHCP client for automatically configuring IPv4 networking
dhcpcd-dbus - DBus bindings for dhcpcd
dhcpcd-gtk - GTK+ frontend for dhcpcd and wpa_supplicant
dhcpcd5 - DHCPv4, IPv6RA and DHCPv6 client with IPv4LL support
dhcpcd5-dbgsym - debug symbols for dhcpcd5
lxplug-network - Network plugin for lxpanel
```

In this case, a little research indicates that `dhcpcd5` is the package of interest.

To find the source packages, we use the `showsrc` option to display all versions of the source package records.


```bash
$ apt-cache showsrc dhcpcd5
# interesting/relevant lines follow:
Package: dhcpcd5
Binary: dhcpcd5
Version: 1:8.1.2-1+rpt5
Homepage: https://roy.marples.name/projects/dhcpcd
Vcs-Browser: https://salsa.debian.org/smlx-guest/dhcpcd5
Vcs-Git: https://salsa.debian.org/smlx-guest/dhcpcd5.git
# 
# NOTE two packages are listed for dhcpcd5
# 'Version: 1:8.1.2-1+rpt5' appears to be the correct one as dhcpcd --version ==> 8.1.2
...
$ 
```

Searching and reading through various sources, the following sequence was pieced together:


```bash
$ sudo apt install devscripts           # build tools for using `debuild`
$ apt-get source dhcpcd5
# ... several compressed files, and a directory named ~/dhcpcd5-8.1.2 were downloaded
$ cd dhcpcd5-8.1.2                      # cd to source dir
~/dhcpcd5-8.1.2 $ nano src/dhcp.c				# make required changes to the source
# you can download the dhcp.c file with the 1-line change from the `source` folder 
# here on GitHub; just copy over the same filename in ~/dhcpcd5-8.1.2/src
~/dhcpcd5-8.1.2 $ debuild -b -uc -us 
## you may get an 'unmet dependencies' error; I did when building on 'buster': 
## dpkg-checkbuilddeps: error: Unmet build dependencies: libudev-dev
## if so, this should fix it (REF: https://unix.stackexchange.com/a/416517/286615)
$ mk-build-deps --install --root sudo --remove
## and then run debuild again => 
~/dhcpcd5-8.1.2 $ debuild -b -uc -us
$ cd ..
$ sudo dpkg -i dhcpcd5_8.1.2-1+rpt5_armhf.deb # or whatever the name of the .deb file
$ dhcpcd --version
dhcpcd 8.1.2
$ 
```
If you got to this point, you have successfully built and installed the `dhcpcd5` package!

If you patched (or copied the revised) `dhcp.c` file into `~/dhcpcd5-8.1.2/src` before you built and installed the .deb file, you now have an updated dhcpcd!! (even tho' the version # reported by `dhcpcd --version` remains the same)

You may also want to put a "hold" on the package to prevent it from being over-written with the un-patched version during an 'apt upgrde'. The RPi Organization does not use the git repos advertised in 'apt-cache showsrc dhcpcd5', and my "merge request" had to be submitted manually. Consequently  I really do not know when or if the RPi Organization will incorporate this patch. If not, we may need to patch this indefinitely. To put a hold on 'dhcpcd' using 'apt' ([REF](https://askubuntu.com/questions/18654/how-to-prevent-updating-of-a-specific-package)) is simple: 

```bash
$ sudo apt-mark hold dhcpcd5
## to remove the hold:
$ sudo apt-mark unhold dhcpcd5
```

The `dpkg` tool will come in handy; e.g.:

```
$ dpkg -l dhcpcd5
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name           Version        Architecture Description
+++-==============-==============-============-====================================================
ii  dhcpcd5        1:8.1.2-1+rpt5 armhf        DHCPv4, IPv6RA and DHCPv6 client with IPv4LL support
```



### REFERENCES: 

1. [Build Packages From Source In Debian: Easy Step-By-Step Guide](https://www.linuxfordevices.com/tutorials/debian/build-packages-from-source) 
2. [Q&A: How to prevent updating of a specific package?](https://askubuntu.com/questions/18654/how-to-prevent-updating-of-a-specific-package) 
3. [Debian Packaging Tutorial; Lucas Nussbaum](https://www.debian.org/doc/manuals/packaging-tutorial/packaging-tutorial.en.pdf) 
4. [Debian Policy Manual](https://www.debian.org/doc/debian-policy/index.html) 

<!---

FWIW, it seems a rather unusual *realtionship* between `dhcpcd`, Debian and Raspberry Pi. By that, I mean that [`dhcpcd`](https://github.com/NetworkConfiguration/dhcpcd) is now at ver 9.3+, [Debian's "salsa" repo](https://salsa.debian.org/smlx-guest/dhcpcd5/-/tree/upstream) is now at ver 7.1, and Raspberry Pi uses ver 8.1.2. The `changelog` file in the source distribution for the RPi version indicates that 8.1.2 is November 2019 vintage, but apparently there have been *patches* made since then.  



It's a strange feeling that comes over you: I've "followed" Roy Marples for a few years now - since I began using his `dhcpcd` software on Raspberry Pi. While browsing his [GitHub site](https://github.com/NetworkConfiguration/dhcpcd) earlier today for the latest news, I clicked an [obscure link](https://roy.marples.name/archives/dhcpcd-discuss/) at the bottom of the page, and learned he's diagnosed with terminal cancer.  



### The GitHub Factor

For reasons that are unclear to me, `dhcpcd` - as distributed by the Raspberry Pi Organization - is available as source code only through their package repository. This works well enough - as you may have seen in the recipe listed above. Debian's packaging system has a well-earned reputation for reliability and consistency. However, in this case for `dhcpcd`, the Raspberry Pi Organization does not publish the source package on their GitHub site, nor do they have a formal system in place for users to submit change requests (aka pull requests, commit requests, etc). 

All of that said, the `dhcpcd` repo here aspires to improve that situation.

For the record, following are all the steps used in creating this GitHub repo for the "Raspberry Pi" version of Roy Marples' `dhcpcd` (aka `dhcpcd5`). All steps were performed on a RPi 3B+/bullseye : 

1. Download the source package for `dhcpcd5` (see above for details):

   ```bash
   $ apt-get source dhcpcd5
   ```

2. Prepare the source package for GitHub:

   ```bash
   $ cd dhcpcd5-8.1.2
   $ fakeroot debian/rules clean 
   # ...
   $ quilt pop -a
   # ...
   No patches applied
   # this *removes* all of the patches that were applied during apt-get
   # these patches remain in the package folder at ~/dhcpcd5-8.1.2, and 
   # will be re-applied to the code during the build process 
   
   ```

3. Set up the local `git` repository: 

   ```bash
   $ git init
   Initialized empty Git repository in /home/pi/dhcpcd5-8.1.2/.git/ 
   $ git config --global user.email "seamus@myemail.com"
   $ git config --global user.name "Seamus" 
   $ git add . 
   $ git commit -m "initial commit"
   On branch rpi3b
   nothing to commit, working tree clean
   ```

4. Set up the remote `git` repository at GitHub: 

   - Log into your GitHub account via a web browser on your laptop/whatever. 
   - Click the `+` symbol in the URHC of your GitHub Home to **create a new repository**  
   - When prompted for a repo name, enter `dhcpcd5`
   - GitHub will present the 'Quick setup' page 
   - Follow instructions: **'push an existing repository from the command line'**  

5. Return to the RPi command line to `push` ***local ==> remote***: 

   ```bash
   
   ```

    

   

-->

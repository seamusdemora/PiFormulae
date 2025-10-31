# Package Management:<br> Updating and Upgrading Raspberry Pi OS

Routine updates & upgrades in the same version

The "version upgrade"

In an earlier version of this recipe, I criticized Debian's documentation of their "package management" system. In fact, I said flatly that it was [god-awful](https://www.merriam-webster.com/dictionary/god-awful). I felt that was true - at the time. I've recently reviewed their documentation again, and found it to be _improved_... still somewhat disjointed - but improved. But [this inanity still exists](https://www.debian.org/doc/manuals/debian-handbook/sect.apt-get.en.html) in the Administrator's Handbook: 

>APT is a vast project, whose original plans included a graphical interface. It is based on a library which contains the core application, and apt-get is the first front end — command-line based — which was developed within the project. apt is a second command-line based front end provided by APT which overcomes some design mistakes of apt-get.
>
>Both tools are built on top of the same library and are thus very close, but the default behavior of apt has been improved for interactive use and to actually do what most users expect. The APT developers reserve the right to change the public interface of this tool to further improve it. Conversely, the public interface of apt-get is well defined and will not change in any backwards incompatible way. It is thus the tool that you want to use when you need to script package installation requests. 

Real progress is still slow, I suppose.  Anyway... my advice now is to skip the Administrator's Handbook - it seems no one in the Debian organization is putting any effort into it. 

## apt _vs._ apt-get
Some advocate using `apt`, others advocate using `apt-get`. I've come to favor the *newer* `apt` for my routine tasks. The differences between `apt` and `apt-get` are varied, and **you** will need to decide which you prefer. [Here's a good, brief explanation that might help](https://itsfoss.com/apt-vs-apt-get-difference/); there are many other comparisons available for the [cost of a search.](https://duckduckgo.com/?q=apt+vs+apt-get&t=ffnt&ia=web) 

## N.B.

The following lists of `apt` and `apt-get` commands is not intended to be a comprehensive list, and the "Explanation" column omits many details that may be significant to your usage! Always refer to the appropriate `man` pages if you have questions. 

## Routine "in-version" updates and upgrades

<html>
<head>
</head>
<body> 
<table class="minimalistBlack">
<thead>
<tr>
<th>Command</th>
<th>Explanation</th>
</tr>
</thead>
<tbody>
<tr>
<td width="30%"> <b><code>df -h</code></b></td>
<td width="70%">check available space; <code>apt</code> doesn't do this automatically, so it's up to you</td>
</tr>   
<tr>
<td><b><code>sudo apt update</code></b></td>
<td>updates the system's "Package List" from all configured sources</td>
</tr>
<tr>
<td width="30%"><b><code>sudo apt upgrade</code></b></td>
<td width="70%">upgrade all installed packages to the latest version from the sources enumerated in  <code>/etc/apt/sources.list</code>, but under no circumstances are currently installed packages removed, or packages not already installed retrieved and installed. <em>This is the "foolproof" version of an upgrade.</em></td>
</tr>
<tr>
<td width="30%"><b><code>sudo apt full-upgrade</code></b></td>
<td width="70%">upgrade all installed packages to the latest version from the sources enumerated in  <code>/etc/apt/sources.list</code>. It will add & remove packages if needed to upgrade the system.</td>
</td>
</tr>
<tr>
<td width="30%"><b><code>sudo apt-get dist-upgrade</code></b></td>
<td width="70%">Roughly equivalent to <code>apt full-upgrade</code>. Upgrade all installed packages to the latest version from the sources enumerated in  <code>/etc/apt/sources.list</code>. It will add & remove packages if necessary, and attempts to deal "intelligently" with changed dependencies. Exceptions may be declared in <code>apt_preferences(5)</code>.</td>
</tr>
<tr>
<td width="30%"><b><code>unattended-upgrades</code></b></td>
<td width="70%">A script to download and install upgrades automatically and unattended. It is run periodically by APT's  systemd  service (apt-daily-upgrade.service), or from cron (e.g. via /etc/cron.daily/apt). Operation is configured via file at <code>/etc/apt/apt.conf.d/50unattended-upgrades</code></td>
</tr>
<tr>
<td width="30%"><b><code>sudo reboot</code></b></td>
<td width="70%">when in doubt, or if "weird" things happen! <a href=https://www.raspberrypi.org/forums/viewtopic.php?t=184850>REFERENCE</a></td>
</tr> 
<tr>
<td> </td>
<td> </td>
</tr>
<tr>
<td> </td>
<td> </td>
</tr>   
</tbody>
</table>



## Finding, Inspecting, Installing and Removing Packages using `apt` 

<table class="minimalistBlack">
<thead>
<tr>
<th>Command</th>
<th>Explanation</th>
</tr>
</thead>
<tbody>

<tr>
<td width="30%"><b><code>apt search XXXX</code></b></td>
<td width="70%">Compared to <code>apt-cache search XXXX</code>, a less-compact, but more detailed listing. Take your pick! Can be verbose, so consider piping into a pager (<code>apt search XXXX | less</code>)</td>
</tr>

<tr>
<td width="30%"> <b><code>apt-cache search XXXX</code></b></td>
<td width="70%">You always  need the exact name of package "XXXX" - this is one way to get it. If you're looking for a package, and recall only that its name contains the characters `priv`, then `apt-cache search priv` should list all matching packages in the repository.</td>
</tr> 

<tr>
<td><code><b>apt list --installed</code></b></td>
<td>Displays list of packages satisfying certain criteria (e.g. <code>--installed</code>), or matching a <code>glob</code> pattern.</td>
</tr>

<tr>
<td width="30%"><b><code>apt show XXXX</code><br>--OR--<br><code>apt-cache show XXXX</code></b></td>
<td width="70%">Show information about package(s) XXXX including dependencies, installation size, sources, etc.</td>
</tr>

<tr>
<td width="30%"> <b><code>sudo apt install XXXX</code></b></td>
<td width="70%">Install package(s) named "XXXX"</td>
</tr>   

<tr>
<td width="30%"> <b><code>sudo apt remove XXXX</code></b></td>
<td width="70%">Remove a package "XXXX", leaving its configuration files on the system</td>
</tr>

<tr>
<td width="30%"><b><code>sudo apt autoremove</code></b></td>
<td width="70%">Remove packages that were automatically installed to satisfy dependencies for other packages, and are no longer needed due to dependency changes.</td>
</tr>

<tr>
<td width="30%"> <b><code>sudo apt purge XXXX</code></b></td>
<td width="70%">Remove a package "XXXX", deleting its configuration files from the system</td>
</tr>

<tr>
<td width="30%"> <b><code>sudo apt edit-sources</code></b></td>
<td width="70%">Opens <code>/etc/apt/sources.list</code> file for editing, and performs some basic sanity checks on the edited file.</td>
</tr>

<tr>
<td width="30%"> <b><code>sudo apt-mark hold <package-name></code></b></td>
<td width="70%"> hold is used to mark a package as on <b><i>hold</i></b>, preventing the package from being automatically installed, upgraded or removed.</td>
</tr>

<tr>
<td width="30%"> <b><code>sudo apt-mark unhold <package-name></code></b></td>
<td width="70%"> <b><i>removes</i></b> the <b><i>hold</i></b> status on the package (a reversal of hold).</td>
</tr>

<tr>
<td width="30%"> <b><code>sudo apt-mark showhold <package-name></code></b></td>
<td width="70%"> <b><i>lists</i></b> the packages on hold.</td>
</tr>

<tr>
<td> </td>
<td> </td>
</tr>

</tbody>
</table>
</body>
</html>



## Installing `.deb` packages

When available, it's usually *best* to install packages using `apt` or `apt-get`. But on occasion, you may need to install a `.deb` package. Here's a summary of how to do that: 

```bash
$ sudo dpkg -i ./some_pkg.deb    # from the folder where the .deb file is located
# ...
# Many times this will end well, but you may be notified that one or more dependencies
# have not been met; e.g.
some_pkg depends on libwhatever; however:
  Package libwhatever is not installed.  
# ...  
# The solution: 
$ sudo apt-get -f install 
# ...
Setting up libwhatever...
Setting up some_pkg.deb...
# refer to man apt-get for details
```

## Perform an "In Place" Version Upgrade

***N.B:*** The approach outlined here [**IS NOT** recommended by Raspberry Pi](https://forums.raspberrypi.com/viewtopic.php?t=389477&hilit=trixie&sid=3b08de45639c497872007516b76c0eb3#p2323593) for a "version upgrade"; e.g. bookworm-to-trixie. Nevertheless, this approach was developed and provided by RPi in [this forum post](https://forums.raspberrypi.com/viewtopic.php?t=389477). The procedure here has been slightly modified from that provided by RPi to reflect the fact that I use only Lite/headless versions of RPi OS, and adding a `tee` to the `apt` command that performs the ***"in-place upgrade"***. 

Without further ado: 

1.  Use `apt` to `update` & `upgrade` the existing bookworm system 

      ```bash
        $ sudo apt update
        $ sudo apt -y full-upgrade
      ```

2.  Perform a full image backup on the system to be upgraded. I recommend RonR's `image-utils` scripts for backups; the scripts are available [here](https://forums.raspberrypi.com/viewtopic.php?t=332000) and [here as a git repo](https://github.com/seamusdemora/RonR-RPi-image-utils) :

      ```bash
      $ sudo image-backup 
      # the script will prompt for everything needed to perform the backup:
      ```

3.  Once `image-backup` is successfully completed, we are ready to begin the *"in-place" upgrade* from *bookworm* to *trixie*: 

    -  In the file `/etc/apt/sources.list`, change every reference to "bookworm" to "trixie". 
    -  Do the same in the file `/etc/apt/sources.list.d/raspi.list`
    -  ***IF*** your system has other repository files - in addition to `raspi.list` - these files should also be updated. 

4.  Use `apt` to update the `.list` files modified in the previous step:

      ```bash
        $ sudo apt update
          ...
        # this will yield approx. 30 (or more) lines of output, the last of which should be similar to:
        # "518 packages can be upgraded. Run 'apt list --upgradable' to see them."
      ```


5.  And finally we reach the actual **upgrade**; recall this is for a ***Lite ("headless")*** system **ONLY**. If you are not upgrading a Lite system, please refer to the [RPi forum post](https://forums.raspberrypi.com/viewtopic.php?t=389477) for applicable instructions. 
  ***NOTE*** the addition of the environment variable `DEBIAN_FRONTEND`: The **`noninteractive`** option adopts the default option, whereas the **`readline`** option uses plain text to present the option rather than the `ncurses`-style presentation ([REF](https://unix.stackexchange.com/a/800850/286615)). 

      ```bash
        $ sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" --purge --auto-remove | tee upgrade_log.txt
        #
        # an alternative to use IF you must interact with the command:
        #
        $ sudo DEBIAN_FRONTEND=readline apt full-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" --purge --auto-remove | tee upgrade_log.txt
      ```
    As you might expect, this generates quite a lot of output in the terminal. Note that a `pipe` to `tee` has been appended to this command. This will be useful to maintain a record of the upgrade. Some other recommendations: 
    
    -  This ran successfully for me. If it did not do the same for you... hopefully you took Step #2 above (`sudo image-backup`). The voluminous output leaves many questions for me, but we'll save those for later.
    
    -  You'll be prompted to decide how to handle service re-starts; I recommend the "automated" option. 
    
    -  Read/scan the terminal output (or, the file to which the output is `tee`'d'); you'll find useful tidbits such as: 
    
       -  ```
          Setting up dbus (1.16.2-2) ...
          A reboot is required to replace the running dbus-daemon.
          ```
    
       -  ```
          dpkg: warning: unable to delete old directory '/lib/aarch64-linux-gnu/security': Directory not empty
          ```
    
       -  ```
          dpkg: libssl3:arm64: dependency problems, but removing anyway as you requested:
           wpasupplicant depends on libssl3 (>= 3.0.0).
           systemd depends on libssl3 (>= 3.0.0).
           rsync depends on libssl3 (>= 3.0.0).
           ppp depends on libssl3 (>= 3.0.0).
           openssl depends on libssl3 (>= 3.0.9).
           openssh-server depends on libssl3 (>= 3.0.17).
           openssh-client depends on libssl3 (>= 3.0.17).
           linux-kbuild-6.6.31+rpt depends on libssl3 (>= 3.0.0).
           libsystemd-shared:arm64 depends on libssl3 (>= 3.0.0).
           libsasl2-modules:arm64 depends on libssl3 (>= 3.0.0).
           libpython3.11-minimal:arm64 depends on libssl3 (>= 3.0.0).
           libkrb5-3:arm64 depends on libssl3 (>= 3.0.0).
           libfido2-1:arm64 depends on libssl3 (>= 3.0.0).
          ...
          dpkg: libgnutls30:arm64: dependency problems, but removing anyway as you requested:
           network-manager depends on libgnutls30 (>= 3.7.2).
          ...
          dpkg: python3.11: dependency problems, but removing anyway as you requested:
           python3 depends on python3.11 (>= 3.11.2-1~).
          ...
          dpkg: libreadline8:arm64: dependency problems, but removing anyway as you requested:
           wpasupplicant depends on libreadline8 (>= 6.0).
           gawk depends on libreadline8 (>= 6.0).
           fdisk depends on libreadline8 (>= 6.0).
           bc depends on libreadline8 (>= 6.0).
          ...
          dpkg: libdvdread8:arm64: dependency problems, but removing anyway as you requested:
           mkvtoolnix depends on libdvdread8 (>= 4.1.3).
          ```
    
       -  ```
          openssh (1:9.3p2-1) unstable; urgency=high
          
            OpenSSH 9.3p2 includes a number of changes that may affect existing
            configurations:
            ...
          ```

That concludes this recipe for the ***"in-place upgrade"***  - at least for now. I'll post additional installments as needed after I've gained some experience with this upgraded system. 

<!--- 





To do an in-place upgrade of the OS; e.g. from jessie to stretch:

Opinions vary on the details, but in general: (note: `sudo` needed for all commands, but omitted for brevity): 

1. `sudo apt-get update`,	`... upgrade`,		 `... dist-upgrade`

2. Verify no issues exist in previous updates or upgrades:
   `dpkg --audit`
   `dpkg --get-selections | grep hold`

3. BACKUP!!!

4. change `jessie` to `stretch in `/etc/apt/sources.list` 

5. `... update`, `... upgrade`, `... dist-upgrade` again (which may take a while!)

6. `reboot`

7. `cat /etc/os-release` to verify the upgrade was successful 


NOTE: This recipe augments [one at the raspberrypi.org website on the same subject- *but lost in the great documentation re-shuffle*](https://www.raspberrypi.org/documentation/raspbian/updating.md), and from [this source for linux tutorials](https://www.howtoforge.com/tutorial/how-to-upgrade-debian-8-jessie-to-9-stretch/).

## 

-->

## REFERENCES:

1. [Debian CLI for APT package management tools](https://wiki.debian.org/AptCLI) 
2. [Uninstalling Packages With Apt Package Manager](https://www.linuxfordevices.com/tutorials/ubuntu/uninstalling-packages-with-apt) 
3. [Q&A: clean, autoclean, and autoremove — combining them is a good step?](https://askubuntu.com/a/984800/831935) 
4. [Why you need apt-get clean options?](https://linuxhint.com/why_apt_get_clean/) 
5. [Debian / Ubuntu Linux Delete Old Kernel Images Command](https://www.cyberciti.biz/faq/debian-ubuntu-linux-delete-old-kernel-images-command/) 
6. [A Guide to Yum and Apt](https://www.baeldung.com/linux/yum-and-apt) 
7. [Chapter 4. Upgrades from Debian 9 (stretch)](https://www.debian.org/releases/buster/amd64/release-notes/ch-upgrading.en.html) 
8. [How to upgrade Debian 9 to Debian 10 Buster using the CLI](https://www.cyberciti.biz/faq/update-upgrade-debian-9-to-debian-10-buster/) 
9. [How to Configure sources.list on Debian 10](https://linoxide.com/linux-how-to/configure-sources-list-on-debian/) 
10. [Ubuntu ‘apt-get’ list of commands (list, update, upgrade, cheatsheet)](https://alvinalexander.com/linux-unix/ubuntu-apt-get-cache-list-search-commands-cheat-sheet/) 
11. [How to Install Development Tools on Debian 10/9/8](https://tecadmin.net/install-development-tools-on-debian/) 
12. [10 Cool Linux Terminal Commands](https://helpdeskgeek.com/linux-tips/10-cool-linux-terminal-commands-you-have-to-try/) - a couple of these actually *do* look cool! 
13. [Debian Package Dependencies](https://linuxhint.com/debian_package_dependencies/); another *useful* guide from [Frank Hofmann](https://linuxhint.com/author/frank_hofmann/) 
14. [Q&A: How to let `dpkg -i` install dependencies for me?](https://askubuntu.com/questions/40011/how-to-let-dpkg-i-install-dependencies-for-me) 
15. [Q&A: Capturing terminal output from Debian upgrade, but `tee` breaks ncurses dialog?](https://unix.stackexchange.com/a/800850/286615) 

<!--- 


| &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; Command &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; | Explanation |
| :---     | :---       |
| `sudo apt-get update`| updates the system's "Package List" |
| `df -h`      | check available space; `apt` doesn't! |
| `sudo apt-get upgrade` | upgrade all installed packages to the latest version from the sources enumerated in  `/etc/apt/sources.list`, but under no circumstances are currently installed packages removed, or packages not already installed retrieved and installed. This is the "foolproof" version of an upgrade. |
| `sudo apt-get dist-upgrade` | upgrade all installed packages to the latest version from the sources enumerated in  `/etc/apt/sources.list`. It will add & remove packages if necessary, and attempts to deal "intelligently" with changed dependencies. Exceptions may be declared in `apt_preferences(5)`. |
| `sudo apt-get clean` | removes the cruft from `/var/cache/apt/archives` left by previous upgrades |
| `sudo reboot` | when in doubt, or if "weird" things happen! [REFERENCE](https://www.raspberrypi.org/forums/viewtopic.php?t=184850) |


__-------------  WORK IN PROCESS; PLEASE IGNORE (or not - up to you!) -----------------__

<!DOCTYPE html>
<html>
<head>

<style>
table.minimalistBlack {
  width: 100%;
  text-align: left;
  border-collapse: collapse;
}
table.minimalistBlack td, table.minimalistBlack th {
  border: 1px solid #000000;
  padding: 5px 4px;
}
table.minimalistBlack tbody td {
  font-size: 13px;
}
table.minimalistBlack tr:nth-child(even) {
  background: #CFD1D1;
}
table.minimalistBlack thead {
  background: #CFCFCF;
  background: -moz-linear-gradient(top, #dbdbdb 0%, #d3d3d3 66%, #CFCFCF 100%);
  background: -webkit-linear-gradient(top, #dbdbdb 0%, #d3d3d3 66%, #CFCFCF 100%);
  background: linear-gradient(to bottom, #dbdbdb 0%, #d3d3d3 66%, #CFCFCF 100%);
  border-bottom: 2px solid #000000;
}
table.minimalistBlack thead th {
  font-size: 15px;
  font-weight: bold;
  color: #000000;
  text-align: center;
}
table.minimalistBlack tfoot td {
  font-size: 14px;
}
</style>
</head>

<body>
<table class="minimalistBlack">
<thead>
<tr>
<th>head1</th>
<th>head2</th>
</tr>
</thead>
<tbody>
<tr>
<td>cell1_1</td>
<td>cell2_1</td>
</tr>
<tr>
<td>cell1_2</td>
<td>cell2_2</td>
</tr>
<tr>
<td>cell1_3</td>
<td>cell2_3</td>
</tr>
<tr>
<td>cell1_4</td>
<td>cell2_4</td>
</tr>
<tr>
<td>cell1_5</td>
<td>cell2_5</td>
</tr>
</tbody>
</table>
</body>
</html>

-->

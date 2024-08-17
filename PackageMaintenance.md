# Package Management:<br> Updating and Upgrading Raspbian (Raspberry Pi OS)

In an earlier version of this recipe, I criticized Debian's documentation of their "package management" system. In fact, I said flatly that it was [god-awful](https://www.merriam-webster.com/dictionary/god-awful). I felt that was true - at the time. I've recently reviewed their documentation again, and found it to be _improved_... still somewhat disjointed and confusing - but improved. But [this inanity still exists](https://www.debian.org/doc/manuals/debian-handbook/sect.apt-get.en.html) in the Administrator's Handbook: 

>APT is a vast project, whose original plans included a graphical interface. It is based on a library which contains the core application, and apt-get is the first front end — command-line based — which was developed within the project. apt is a second command-line based front end provided by APT which overcomes some design mistakes of apt-get.
>
>Both tools are built on top of the same library and are thus very close, but the default behavior of apt has been improved for interactive use and to actually do what most users expect. The APT developers reserve the right to change the public interface of this tool to further improve it. Conversely, the public interface of apt-get is well defined and will not change in any backwards incompatible way. It is thus the tool that you want to use when you need to script package installation requests. 

Real progress is still slow, I suppose.  Anyway... my advice now is to skip the Administrator's Handbook - it seems no one in the Debian organization is putting any effort into it. 

## apt _vs._ apt-get
Some advocate using `apt`, others advocate using `apt-get`. I've come to favor plain old `apt` for all my routine tasks. The differences between `apt` and `apt-get` are varied, and **you** will need to decide. [Here's a good, brief explanation that might help](https://itsfoss.com/apt-vs-apt-get-difference/); there are many other comparisons available for the [cost of a search.](https://duckduckgo.com/?q=apt+vs+apt-get&t=ffnt&ia=web) 

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
<td><b><code>sudo apt upgrade</code></b></td>
<td>upgrade all installed packages to the latest version from the sources enumerated in  <code>/etc/apt/sources.list</code>, but under no circumstances are currently installed packages removed, or packages not already installed retrieved and installed. <em>This is the "foolproof" version of an upgrade.</em></td>
</tr>

<tr>
<td><b><code>sudo apt full-upgrade</code></b></td>
<td>upgrade all installed packages to the latest version from the sources enumerated in  <code>/etc/apt/sources.list</code>. It will add & remove packages if needed to upgrade the system.</td>
</td>
</tr>

<tr>
<td><b><code>sudo apt-get dist-upgrade</code></b></td>
<td>Roughly equivalent to <code>apt full-upgrade</code>. Upgrade all installed packages to the latest version from the sources enumerated in  <code>/etc/apt/sources.list</code>. It will add & remove packages if necessary, and attempts to deal "intelligently" with changed dependencies. Exceptions may be declared in <code>apt_preferences(5)</code>.</td>
</tr>

<tr>
<td><b><code>unattended-upgrades</code></b></td>
<td>A script to download and install upgrades automatically and unattended. It is run periodically by APT's  systemd  service (apt-daily-upgrade.service), or from cron (e.g. via /etc/cron.daily/apt). Operation is configured via file at <code>/etc/apt/apt.conf.d/50unattended-upgrades</code></td>
</tr>

<tr>
<td><b><code>sudo reboot</code></b></td>
<td>when in doubt, or if "weird" things happen! <a href=https://www.raspberrypi.org/forums/viewtopic.php?t=184850>REFERENCE</a></td>
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
<td width="30%"><b><code>apt show XXXX</code></b></td>
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
<td width="30%"> <b><code>sudo apt purge XXXX</code></b></td>
<td width="70%">Remove a package "XXXX", deleting its configuration files from the system</td>
</tr>

<tr>
<td width="30%"> <b><code>sudo apt-get clean</code></b></td>
<td width="70%">Clear the cache of the old and outdated packages</td>
</tr>

<tr>
<td width="30%"> <b><code>sudo apt-get autoremove</code></b></td>
<td width="70%">Remove packages that were automatically installed as dependencies and are no longer needed</td>
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

## Version Upgrade

***N.B:*** This is typically not a reliable method to upgrade Raspbian (though it often works well with some distributions) 

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

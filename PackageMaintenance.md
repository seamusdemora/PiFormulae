the sequence for installing a new package; e.g. `git` is:
> df -h

> sudo apt-get update

> sudo apt-get dist-upgrade

> sudo apt-get install git 

> sudo apt-get clean

The first command (`df -h`) will give you a chance to make sure you've got space on your "drive" for the installation. This is important as `apt` doesn't verify this before it starts! The last command (`sudo apt-get clean`) will __"take out the trash"__, and help conserve space on your "drive".


## Updating and Upgrading Raspbian 

### Routine "in-version" updates and upgrades

<table border="0", style="width:100%">
  <col style="width:45%">
  <col style="width:55%">
  <tr>
    <th>Command</th>
    <th>Explanation</th> 
  </tr>
  <tr>
    <td>`sudo apt-get update`</td>
    <td>updates the system's "Package List"</td> 
  </tr>
  <tr>
    <td>`df -h`</td>
    <td>check available space; `apt` doesn't! </td> 
  </tr>
  <tr>
    <td>`sudo apt-get upgrade`</td>
    <td>upgrade all installed packages to the latest version from the sources enumerated in `/etc/apt/sources.list`, but under no circumstances are currently installed packages removed, or packages not already installed retrieved and installed. This is the "foolproof" version of an upgrade.</td>
  </tr>
    <tr>
    <td>`sudo apt-get dist-upgrade`</td>
    <td>upgrade all installed packages to the latest version from the sources enumerated in `/etc/apt/sources.list`. It will add & remove packages if necessary, and attempts to deal "intelligently" with changed dependencies. Exceptions may be declared in `apt_preferences(5)`.</td>
  </tr>
  <tr>
    <td>`sudo apt-get clean`</td>
    <td>removes the cruft from ``/var/cache/apt/archives` left by previous upgrades</td>
  </tr>
</table>


|   command        | explanation |
| :---     | :---       |
| `sudo apt-get update`| updates the system's "Package List" |
| `df -h`      | check available space; `apt` doesn't! |
| `sudo apt-get upgrade` | upgrade all installed packages to the latest version from the sources enumerated in  `/etc/apt/sources.list`, but under no circumstances are currently installed packages removed, or packages not already installed retrieved and installed. This is the "foolproof" version of an upgrade. |
| `sudo apt-get dist-upgrade` | upgrade all installed packages to the latest version from the sources enumerated in  `/etc/apt/sources.list`. It will add & remove packages if necessary, and attempts to deal "intelligently" with changed dependencies. Exceptions may be declared in `apt_preferences(5)`. |  
| `sudo apt-get clean` | removes the cruft from ``/var/cache/apt/archives` left by previous upgrades |

### Version Upgrade

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


NOTE: This recipe augments [one at the raspberrypi.org website on the same subject](https://www.raspberrypi.org/documentation/raspbian/updating.md), and from [this source for linux tutorials](https://www.howtoforge.com/tutorial/how-to-upgrade-debian-8-jessie-to-9-stretch/)

## Use Samba to Share Files on Raspberry Pi

### Table of Contents

   * [Objective](#objective)  
   * [Q&amp;A: Why Would I Do This?](#qa-why-would-i-do-this)
   * [1. Check the fstab entry for the external drive](#1-check-the-fstab-entry-for-the-external-drive)
   * [2. Install Samba:](#2-install-samba)
   * [3. Configure Samba:](#3-configure-samba)  
         * [3.a Edit the Samba Configuration file](#3a-edit-the-samba-configuration-file)  
         * [3.b Add the user pi to Samba's password database file](#3b-add-the-user-pi-to-sambas-password-database-file)  
         * [3.c An example of Samba permissions](#3c-a-brief-overview-of-samba-permissions) 
         * [3.d Restart Samba to read the revised Samba Configuration file](#3d-restart-samba-to-read-the-revised-samba-configuration-file)  
   * [4. Connect to the Samba share:](#4-connect-to-the-samba-share)

### Objective

This "recipe" provides a method for sharing files over a local area network. Specifically, this recipe addresses configuring a **Raspberry Pi** (RPi) as a *file server* to share a USB thumb drive with *clients*. Sharing from the perspective of a **Mac** client is also addressed here; the process for sharing with a **Windows** or **Linux** client would be similar. 

The USB thumb drive is physically plugged into a USB port on a RPi. The thumb drive's only *partition* is formatted as an `exFAT` file system, and this file system is *mounted* on the RPi. Details for partitioning, formatting and mounting the thumb drive are covered in [another recipe](ExternalDrives.md). In this recipe we will install and configure [Samba](https://www.samba.org/) on the RPi. The **Samba** software will provide clients access to the files and folders on the thumb drive via the network. 

The reader should know that there are alternative approaches to achieving the objectives outlined above. The approach that follows reflects my opinion of the best option, but others may disagree. You should do your research, and are of course free to choose the approach that works best for you. 

### Q&A: Why Do This At All?

Answer: __Convenience__. One could simply unmount the USB thumb drive on the RPi, remove it, and plug it into a USB port on the client. If your RPi is on the other side of your desk, perhaps that's not much convenience. If it's upstairs, or in the garage, or in another country, the convenience is more substantial. Another potential advantage is that Samba effectively *translates* the thumb drive's native file system format to [*CIFS*](https://en.wikipedia.org/wiki/Server_Message_Block) - a near-universal standard. For example if the thumb drive were formatted as [*ext4*](https://en.wikipedia.org/wiki/Ext4), it may be difficult-to-impossible for a Mac or Windows client to read and write the thumb drive. As you'll see, it's easier to share using Samba. If you're ready, we'll get started: 

### 1. Check the `fstab` entry for the external drive

Check that you have a valid *mount point* - in this case at `/home/pi/mntThumbDrv`. The entry in `etc/fstab` will be similar to this: 

`LABEL=SANDISK16GB /home/pi/mntThumbDrv exfat rw,user,nofail 0 0` 

You can change this of course; these entries simply follow on the [previous recipe for mounting an external drive](https://github.com/seamusdemora/PiFormulae/blob/master/ExternalDrives.md). You do want the thumb drive/external drive to be auto-mounted if you're using Samba to serve it over the network. Auto-mount is accomplished through the `fstab` entry. 

### 2. Install Samba:

Before installing Samba, check to make sure it's not already installed: 

```bash
$ apt-mark showmanual | grep samba
samba
samba-common-bin
```

If you don't have both of these packages (`samba` and `samba-common-bin`) installed, install them as follows: 

```bash
$ sudo apt-get update
...
$ sudo apt-get upgrade
...
$ sudo apt-get install samba samba-common-bin 
...
```

This should complete without error. The output may contain messages about Samba's Domain Controller (DC) feature being "masked". We don't need the DC, so these messages may be ignored. 

### 3. Configure Samba:

#### 3.a Edit the Samba Configuration file

Samba configuration is done through the file `etc/samba/smb.conf`. Make a backup copy of `smb.conf`, and use your favorite editor to modify this file as follows: 

```bash
$ sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bkup
$ sudo pico /etc/samba/smb.conf
```

Add the following lines to the tail of `smb.conf`:

    [sandisk16gb]
    Comment = Shared Folder
    Path = /home/pi/mntThumbDrv
    Browseable = yes
    Writeable = yes
    only guest = no
    create mask = 0700
    directory mask = 0700
    force user = pi

The default `smb.conf` in Raspbian contains a number of settings that are not clear to me. Rather than wade through that, consider downloading and using this [minimal `smb.conf` file](seamus_smb.conf). As of this writing, it works on my RPi and supports my Mac client.  Alternatively, refer to the Samba project's configuration guide to [Setting up Samba as a Standalone Server](https://wiki.samba.org/index.php/Setting_up_Samba_as_a_Standalone_Server).  

One other item from the configuration file: the `[homes]` directive under the `Share Definitions` section implements a feature that you may find useful. __If enabled, `/home/pi` is exported as a Samba share!__ This only works if you log in as the `pi` user (as we do here). It's not enabled here, but you may enable it by uncommenting the appropriate lines in `smb.conf`, beginning with the `[homes]` directive. 

To use this configuration file, complete any edits you wish to make in `smb.conf`, verify that the backup file you created earlier is still in place, and save the edited file to `etc/samba/smb.conf`

#### 3.b Add the user `pi` to Samba's password database file

When we mount the exported Samba share, we'll authenticate as user `pi`. Samba knows nothing of `pi`'s password under Raspbian, so we'll need to create a password using `smbpasswd`. I'd recommend you use the same password in Samba that you use in Raspbian, but that's not required. Add `pi`'s Samba password as follows: 

    $ sudo smbpasswd -a pi 
    New SMB password:
    Retype new SMB password:

#### 3.c A Brief Overview of Samba Permissions

Clicking [this link](https://github.com/seamusdemora/PiFormulae/blob/master/CreatingRationalMusicLibrary.md#5-serve) will take you to another page in this repo. It's worth a quick review. After you've looked it over, you can return here by using your browser's **Back** button.

#### 3.d Restart Samba to read the revised Samba Configuration file

(Re)Start the Samba daemons to read the new `smb.conf` file: 

    $ sudo /etc/init.d/samba restart 
    # OR ALTERNATIVELY IF THAT FAILS (e.g. on stretch)
    $ sudo /etc/init.d/smbd restart 
    [ ok ] Restarting nmbd (via systemctl): nmbd.service. 
    [ ok ] Restarting smbd (via systemctl): smbd.service. 

### 4. Connect to the Samba share:

- Open a Finder window (or use one that's already open) 
- From keyboard, enter `command-k`, or click `Go, Connect to Server...`
- In the `Server Address` field enter the URL of your RPi; e.g. `cifs://raspberrypi3b.local` 
- Authenticate as user `pi` and password from `3.b` above, click `Connect` 

<img src="pix/samba_auth.png" alt="Samba Authentication" width="520">

- View exported share `sandisk16gb` in Finder 

<img src="pix/sambashare_finder.png" alt="Samba Share in Finder" width="520">


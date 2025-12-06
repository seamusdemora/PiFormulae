## Perform an "In Place" version upgrade from 'bookworm' to 'trixie' 

#### ToC:

   [The Upgrade:](#the-upgrade)

   [Post-Upgrade Issues:](#post-upgrade-issues)

### The Upgrade:

***N.B:*** The approach outlined here [**IS NOT** recommended by Raspberry Pi](https://forums.raspberrypi.com/viewtopic.php?t=389477&hilit=trixie&sid=3b08de45639c497872007516b76c0eb3#p2323593) for a "version upgrade"; e.g. bookworm-to-trixie. Nevertheless, this approach was developed and provided by RPi in [this forum post](https://forums.raspberrypi.com/viewtopic.php?t=389477). The procedure here has been slightly modified from that provided by RPi to reflect the fact that I use only Lite/headless versions of RPi OS. One other change was to add a `tee` to the `apt` command to capture all of the output to a file - to support *troubleshooting* in the event that becomes necesary. 

Without further ado: 

1.  Use `apt` to `update` & `upgrade` the existing bookworm system 

      ```bash
        $ sudo apt update
        $ sudo apt -y full-upgrade
      ```

2.  Perform a full image backup on the system to be upgraded. I use RonR's `image-utils` scripts for backups; the scripts are available [here](https://forums.raspberrypi.com/viewtopic.php?t=332000) and [here as a git repo](https://github.com/seamusdemora/RonR-RPi-image-utils) :

      ```bash
      $ sudo image-backup 
      # the script will prompt for everything needed to perform the backup:
      ```

3.  Once `image-backup` has successfully completed, we're ready to begin the *"in-place" upgrade* from *bookworm* to *trixie*: 

    -  In the file `/etc/apt/sources.list`, change every reference to "bookworm" to "trixie". 
    -  Do the same in the file `/etc/apt/sources.list.d/raspi.list`
    -  ***IF*** your system has other repository files - in addition to `raspi.list` - these files should also be updated. 

4.  Use `apt` to update the `*.list` files modified in the previous step:

      ```bash
        $ sudo apt update
          ...
        # this will yield approx. 30 (or more) lines of output, the last of which may be similar to:
        # "518 packages can be upgraded. Run 'apt list --upgradable' to see them."
      ```


5.  And finally we reach the actual **upgrade**; recall this is for a ***Lite ("headless")*** system **ONLY**. If you are not upgrading a Lite system, please refer to the [RPi forum post](https://forums.raspberrypi.com/viewtopic.php?t=389477) for applicable instructions. 
    ***NOTE*** the addition of the environment variable `DEBIAN_FRONTEND`: The **`noninteractive`** option adopts the default option, whereas the **`readline`** option uses plain text to present the option rather than the `ncurses`-style presentation ([REF](https://unix.stackexchange.com/a/800850/286615)). 

      ```bash
        $ sudo DEBIAN_FRONTEND=noninteractive apt full-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" --purge --auto-remove | tee trixie_upgrade.log
        #
        # or, if you wish to interact with the command, instead of accepting the default options:
        #
        $ sudo DEBIAN_FRONTEND=readline apt full-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" --purge --auto-remove | tee trixie_upgrade.log 
        #
        # here is the `full-upgrade` command without the pipe to `tee` - as posted in the RPi forum:
        #
        $ sudo apt full-upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" --purge --auto-remove
      ```
    As expected, this generates quite a lot of output in the terminal. Some other thoughts and recommendations: 
    
    -  This ran successfully for me. If it did not do the same for you... hopefully you took Step #2 above (`sudo image-backup`). The voluminous output leaves many questions for me, but we'll save those for later.
    
    -  You'll be prompted to decide how to handle service re-starts; I used the "automated" option. 
    
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

### Post-Upgrade Issues:

I hoped to avoid this section, but I'll itemize the post-upgrade issues here as I find them: 

1. **The `systemd-journald`** ***"surprise"***:

   I discovered this while troubleshooting occasional extensive delays during `reboot`. The [*long and short*](https://idioms.thefreedictionary.com/the+long+and+(the)+short+of+it)  of this issue is that *"The Raspberries"* decided to change the default for the first option in `/etc/systemd/journald.conf`; from: `Storage=persistent` to `Storage=volatile`. Personally speaking, I don't mind the change much, but I **do mind** the fact that it was an un-announced change. \<rant\> In fact, I consider it inconsiderate, and indicative of a haughty attitude by "The Raspberries".\</rant\> 

   The fallout from this issue is that the only `boot log` you can access is the one you're in now - which is useless if you're trying to troubleshoot an issue during `reboot`. Anyway, if you ask to see a list of the boot logs, you'll see something like this; *Note* the the time-date stamps of `November 1` and `December 5`.  In my case, `2025-11-01` reflects the date I performed the trixie upgrade:  

   ```bash
   $ journalctl --list-boots
   IDX BOOT ID                          FIRST ENTRY                 LAST ENTRY
    -1 6503176bb8ce4a3ca1edd3a9aec02b72 Sat 2025-11-01 02:54:13 UTC Sat 2025-11-01 03:08:54 UTC
     0 274ba1486c3e4444a0bd45b86250f50b Fri 2025-12-05 08:59:55 UTC Fri 2025-12-05 09:00:21 UTC
   
   ```

   An *astute* and *frequent* practitioner of `systemd-journald` probably would have seen this `--list-boots` report, and recognized the issue immediately. I am not such a practitioner! 

   So - what should I do to fix this? On this point, I'm not sure even being an *astute* and *frequent* practitioner of `systemd-journald` would be of much help... One can change the default value of the applicable parameter (`#Storage=auto`) in `/etc/systemd/journald.conf`, ***but this will have absolutely no effect!*** 

   This is because *"The Raspberries"* elected to put the controlling parameter definition in a rather odd place: `/usr/lib/systemd/journald.conf.d/40-rpi-volatile-storage.conf`. In that file the over-riding default is declared: **`Storage=volatile`** !  [RedHat (creator of `systemd`) says](https://learn.redhat.com/t5/Platform-Linux/Systemd-Unit-Files/td-p/46999), *" the /etc/systemd/system/ configuration directories take precedence over unit files in /usr/lib/systemd"*, but **note carefully** that the `journald.conf` file is in **`/etc/systemd` - ** ***not in*** **`/etc/systemd/system`** !  The mind boggles at the `systemd` [arcanery](https://www.merriam-webster.com/dictionary/arcane). 

   Anyway - all that said, these appear to be the choices for repairing the damage: 

   1. Change `Storage=volatile` to `Storage=persistent` in `/usr/lib/systemd/journald.conf.d/40-rpi-volatile-storage.conf` 
   2. Delete the file  `/usr/lib/systemd/journald.conf.d/40-rpi-volatile-storage.conf`, and use `/etc/systemd/journald.conf` (like a normal person  :)
   3. Add a folder & file at `/etc/systemd/journald.conf.d/99-raspi-config-journal-storage.conf` with two lines: `[Journal]` and `Storage=persistent`.
   4. Use `raspi-config` to set persistent storage under the "Advanced" options.   :| 

   There are probably many more options (this is `systemd` after all). I wonder about the *permanence* of 1. and 2. during a `systemd` upgrade, and I dislike `raspi-config` due to its chronic unreliability. That leaves 3. as perhaps the best choice for permanence. 



### References:

1. [RedHat systemd documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd)  
2. [Forum: Trixie: Storage in journal is now "volatile"](https://forums.raspberrypi.com/viewtopic.php?t=392855#p2343280) 

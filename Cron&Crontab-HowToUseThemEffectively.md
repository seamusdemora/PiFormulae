# cron & crontab: How to Use Them Effectively

*Note: This "recipe" is a merger of two older (now retired) recipes, and motivated by a desire to reduce the [sprawl](https://www.merriam-webster.com/dictionary/sprawl) of this RPi repo.* 

If you're interested, you can read about the [history of `cron`](https://en.wikipedia.org/wiki/Cron#History) in this Wikipedia article. Perhaps the best-known of the [modern versions of `cron`](https://en.wikipedia.org/wiki/Cron#Modern_versions) is Paul Vixie's implementation which first appeared in 1987; aka *Vixie cron*. This is the [version of `cron` used in Debian](https://wiki.debian.org/cron), and the sole focus of this recipe. 

## Table of Contents: 

1. [Introduction](#introduction) 
2. [Most FAQ: Why doesn't my crontab work?](#why-does-my-crontab-not-work) 
3. [What is cron's environment?](#what-is-the-cron-environment) 
4. [Where are my crontabs kept?](#where-are-my-crontabs-kept) 
5. [REFERENCES](#references) 

---

## Introduction:

Those getting started with `cron` may be wondering what exactly is meant by the terms `cron` and `crontab`. A bit of explanation is in order: 

* `cron` is the name given to the *daemon* or server that runs silently behind the scenes, and does all the "real work"; ref `man cron` on your system 
* `crontab` is the "`cron` `tab`le" - literally a timetable; it provides the primary interface between the user and `cron` the daemon; ref `man crontab` on your system

Let's get started; we'll begin with the **single most frequently asked question**:

---

## Why does my crontab not work?

### **The "Generic Answer"** to this question: **_`cron` is simple in some respects, but enigmatic in others._**

I would say that there are <s>three (3)</s> four (4) primary factors that confuse users:

### Factor #1: the "environment" is different.

*In Linux, ["the environment"](https://www.tutorialspoint.com/unix/unix-environment.htm) is defined by a collection of variables. When you run a "job" (a command or a script) under `cron` your job will run in a **different** **environment** than it does when you run it from (for example) your interactive shell (e.g. `bash`).* This is important - read it again!  

***Remedies & Solutions:***

- `PATH` is an environment variable; in `cron` `PATH` is typically limited to: `/usr/bin:/bin` - that's it - two folders! Therefore, it's good practice to use absolute path statements everywhere: `$HOME/scriptname.sh` instead of `scriptname.sh` or `./scriptname.sh` or `~/scriptname.sh`. 

- If you've been paying attention, you should now be asking, *"But how do I know what the environment is in `cron`?"*. That's a great question! - and there's a great answer: *"Ask `cron` to tell you what its environment is!"*...  [here's how to ask](#what-is-the-cron-environment). 

- You can add environment variables to the `cron` user's environment in `crontab` - [see this Q&A for how-to](https://stackoverflow.com/a/10657111/22595851).  And there are many other answers on SE (e.g. [1](https://unix.stackexchange.com/questions/27289/how-can-i-run-a-cron-command-with-existing-environmental-variables), [2](https://serverfault.com/questions/337631/crontab-execution-doesnt-have-the-same-environment-variables-as-executing-user), [3](https://stackoverflow.com/questions/2135478/how-to-simulate-the-environment-cron-executes-a-script-with)), but many of these are misguided - or flat-out *wrong*. My best advice is to proceed with caution, and test extensively before you deploy a solution. 

- I feel the following is a [silver bullet](https://www.merriam-webster.com/dictionary/silver%20bullet) solution to the problem of **environment**. It uses the `-l, --login` option of `su` to import any user's (effectively) complete environment. This can be done  without resort to the authentication requirement that usually  accompanies `su` - **if** it is run from the `root crontab`. As an example here, we start `mpg123` - a sound player that may be used with Bluetooth speakers. It is running with `pipewire` (*which may be partly responsible for the **environment***). 

  **Example #1:** 

    ```bash
    $ sudo crontab -e
    ... (in editor, add one line:) ...
    
    @reboot su pi -l -c /home/pi/start-mpg123.sh > /home/pi/start-mpg123.log 2>&1 
    # we use 'su' to become user 'pi'; ref 'man su'
    #    option '-l' : start a login shell
    #    option '-c' : pass a command to the (login) shell; i.e. '/home/pi/start-mpg123.sh'
    # where 'start-mpg123.sh' is a simple script shown below: 
    # save & exit editor
    
    $ cat ~/start-mpg123.sh
    #!/usr/bin/bash
    sleep 5
    if [ "$(/usr/bin/bluetoothctl devices Connected)" != "Device DF:45:E9:00:BE:8B OontZ Angle solo DS E8B" ]; then
        /usr/bin/bluetoothctl connect DF:45:E9:00:BE:8B
    fi
    /usr/bin/mpg123 --loop -1 /home/pi/rainstorm.mp3
    exit 0
    ```
  
  **Example #2:** 
  
  Ever try to control a `systemd` service from a script you start from `cron` ? If so, you might appreciate this application; consider a script that (for example) checks `status` of a service, and `restart`s the service if it's failed. I'll use another **music player** example - [**`mpd`**](https://github.com/MusicPlayerDaemon/MPD) . Consider this simplified script: `verify_mpd.sh`: 
  
  ``` 
  #!/usr/bin/bash 
  
  # check that the music player daemon (mpd) service is active/running & re-start it if not
  if systemctl -q --user is-active mpd.service; then
      echo "all is well with mpd"
  else
      echo "mpd.service is not active; re-start"
      systemctl -q --user restart mpd.service
      sleep 5
      if systemctl -q --user is-active mpd.service; then
          echo "mpd.service had failed; it was re-started successfully"
      else
          echo "mpd.service re-start was unsuccessful; exiting"
          exit 1
  fi
  ```
  
  If you run this script from a `user crontab`, the job will fail because the `cron` job does not include the environment required for using the `D-Bus` - a RedHat protocol required by RedHat's `systemd` :P .  You have two options: 
  
  1. add the `D-bus` environment to your script: 
  
        ```
        #!/usr/bin/bash
        ...
        XDG_RUNTIME_DIR=/run/user/$(id -u)
        DBUS_SESSION_BUS_ADDRESS=unix:path=${XDG_RUNTIME_DIR}/bus
        export DBUS_SESSION_BUS_ADDRESS XDG_RUNTIME_DIR
        ...
        ```
        
  2. use the "silver bullet" in the `root crontab` :) 
  
        ```
        $ sudo crontab -e
        # use your editor to add one line:
        */6 * * * * su pi -l -c /home/pi/verify_mpd.sh
        ```
  



### Factor #2: `cron` has no awareness of the state of other system services.

This is typically only an issue when using the `@reboot` scheduling facility in `cron/crontab`. As an example, consider a `cron` job that requires network services, and is scheduled `@reboot`. Those required network services *may or may not* have been started by `systemd` when `cron` starts, and so attempts to run its *network-dependent* `@reboot` job(s) *may or may not* be successful. 

By necessity, `cron` considers `@reboot` to be the point in time at which `cron` itself has been started by `systemd`.  Further, as `cron` has no insight into `systemd's` machinations, it cannot possibly know the status of other services at its start time.  Consequently - *before all the system's other services are available*, there will be some risk that an `@reboot` job will fail. 

FWIW: I asked a [Question on SE a few years ago, effectively "how to force `systemd` to make `cron` the final service started"](https://unix.stackexchange.com/q/680581/286615), but didn't get a useful answer. That this should be so difficult (impossible??) seems very weird to me; i.e. a software as complex as `systemd` has no concept of [ordinal numbers](https://www.cuemath.com/numbers/ordinal-numbers/)... what were they thinking?     

***Remedies & Solutions:*** 

- `sleep` before starting a script with service dependencies: 

   ```bash
   @reboot ( /usr/bin/sleep 30; /bin/bash /home/pi/startup.sh ) >> $MYLOGFILE 2>&1
   ```

* write your program/script to check availability of required resources 
* `cron` itself is a service, and yes - it may be managed under `systemd`! 

   The service file for `cron` is found in `/lib/systemd/system/cron.service`.  You may modify this file to add dependencies. For example: If many of your `cron` jobs require an active, operational network service be available, you may wish to [add the following](https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget/) to the `[Unit]` section your `cron.service` file:
   ```
   After=network-online.target
   ```

### Factor #3: `cron` output goes to `/dev/null`

Users sometimes wonder why they don't see any output at the terminal from their `cron` jobs - as they did when they ran the same program from their interactive shell (e.g. `bash`). 

***Remedies & Solutions:*** 

* `redirect (>, >>)` the output of your `cron` job to capture `stderr` & `stdout` in a file:

   ```bash
   @reboot ( /bin/sleep 30; /bin/bash /home/pi/startup.sh > /home/pi/cronjoblog 2>&1)
   ```

* enable logging for `cron`

   Edit the file `/etc/rsyslog.conf` to remove the comment (#) from `#cron`: 

   ```bash
   FROM:  #cron.*                         /var/log/cron.log  
   
   TO:     cron.*                         /var/log/cron.log
   ```

* use the `MAILTO` variable in your `crontab` 

   Assuming you have an MTA installed on your system, you may insert the `MAILTO` variable in your `crontab` to send email notifications to all your `cron` jobs - or to each one individually. See `man 5 crontab` for details, or peruse the references listed below. 
   
   If you want to install an MTA for *local* use only, the package `exim4-daemon-light` will serve that purpose : 
   
   ```bash
   $ sudo apt-get install exim4-daemon-light
   ```
   
### Factor #4: Other "quirks"

The `date` command is lying in wait to ambush you & waste hours of your time! I was just *ambushed!* 
The `date` command uses the `%` symbol to specify formatting styles, and `cron` _"can't handle the"_ `%`. 

***Remedies & Solutions:*** 

If you use the `date` command in `cron`, the **`%`** symbols must be *escaped*; as in **`\%`**.
Example:
```
echo "$(date "+%s" -d "+ 10 minutes")" > $WAKEALARM         # FAILS SILENTLY!!

echo "$(date "+\%s" -d "+ 10 minutes")" > $WAKEALARM        # THE CURE!!
```

---

## What is the cron environment?

We'll ask `cron` to tell us: 

### Step 1: Open the user crontab for editing:

```bash
   $ crontab -e 
   # alternatively, open the root crontab for editing: 
   $ sudo crontab -e
```

### Step 2: Add 1 line, save & exit the editor:

```
   * * * * * /usr/bin/printenv > /home/yourusername/user-cronenv.txt 2>&1
   # alternatively, for the root crontab:
   * * * * * /usr/bin/printenv > /home/yourusername/root-cronenv.txt 2>&1
```

### Step 3: Read cron's answer:

```bash
   $ cd && cat user-cronenv.txt
   (here's the answer I got:)
   HOME=/home/pi
   MAILTO=
   LOGNAME=pi
   PATH=/usr/bin:/bin
   LANG=en_GB.UTF-8
   SHELL=/bin/sh
   PWD=/home/pi
```

You may repeat Steps 1-3 above for the `root crontab`. Next, you may want to try adding an environment variable to your `crontab`, and observe the change in `user-cronenv.txt`. 

If you're not familiar with your own user *environment* under your *interactive/login* shell, it may be informative to run `printenv` from the CLI, and compare it against the `cron` *environment*. You'll notice numerous differences. Having this information, knowing how the `cron` user's environment differs from yours, will help create rational `cron` jobs, and help troubleshooting when they don't behave as you'd like. Finally, you can change the *environment* for `cron`; modify it to better meet your needs. See the REFERENCES for ideas.  

---

## Where are my crontabs kept?

You might have noticed that after editing a `crontab` (yours, or the `root` `crontab`) that your editor actually saves the "new" `crontab` in the `/tmp` directory; e.g. `/tmp/crontab.b6uLfb/crontab`. If you're the curious sort, you might have wondered, *"WTF?"*. 

The answer is not complicated, and reflects the care that was taken in the development of `cron`: 

When you call `crontab` from the command line, the editor you have previously chosen opens the file that contains your `crontab` file; it also does **syntax checking** on the edited file to make sure that your instructions to `cron` are *correct* instructions! 

The use of `/tmp` for storage is only, uh - *temporary*... IOW, a location from which `crontab` can do its syntax checks **before** saving the file to its "final destination". The "final destination" is ***currently*** at **`/var/spool/cron/crontabs`**... *currently* as of Debian 'bookworm'; you can verify this: 

```
$ sudo ls -l /var/spool/cron/crontabs
 
-rw------- 1 pi   crontab 1143 Feb 17 07:56 pi
-rw------- 1 root crontab 2270 Apr 13 21:21 root

# note: 'sudo' required due to 'drwx-wx--T' permissions of parent folder!
```

This *suggests* the possibility of a couple of tactics to ***preserve*** your `crontab`s: 

#### 1. "Relocate" your `crontab`:  

     # pwd = /home/pi
     $ mkdir -m mycrontabs
     $ crontab -l ~/mycrontabs/pi        # to save your crontab in $HOME/...
     $ crontab /home/pi/mycrontabs/pi    # to "install" your user crontab to a new location
     # and afterwards: 
     $ crontab -e                        # opens user crontab for editing in its new location
     # going forward, crontab uses this location in lieu of '/var/spool/cron/crontabs'
     # ... this can also be done for the root crontab! 

#### 2.  Create a `cron` job to backup your `crontab`: 

    # create a cron job to backup your crontab to $HOME
    $ crontab -e 
    # add a line:
    0 12 * * * /usr/bin/crontab -l > /home/pi/myctab/myctab.backup
    # save & exit editor



------

## REFERENCES:

1. [The **crontab guru** will help you with your schedule specification](https://crontab.guru/#30_0,1,2,3_*_*_*) 
2. [`cron`, `crontab`... What are you talking about?](https://www.ostechnix.com/a-beginners-guide-to-cron-jobs/) 
3. [Q&A: How can I run a cron command with existing environmental variables?](https://unix.stackexchange.com/questions/27289/how-can-i-run-a-cron-command-with-existing-environmental-variables) 
4. [Crontab – Quick Reference](https://www.adminschoice.com/crontab-quick-reference) 
5. [Execution environment of a cron job](https://help.dreamhost.com/hc/en-us/articles/215767107-Execution-environment-of-a-cron-job) - incl. the `MAILTO` variable 
6. [Q&A: How can I run a cron command with existing environmental variables?](https://unix.stackexchange.com/questions/27289/how-can-i-run-a-cron-command-with-existing-environmental-variables) U&L SE 
7. [Q&A: Where can I set environment variables that crontab will use?](https://stackoverflow.com/questions/2229825/where-can-i-set-environment-variables-that-crontab-will-use) SO SE
8. [Linux Privilege Escalation by Exploiting Cronjobs](https://www.hackingarticles.in/linux-privilege-escalation-by-exploiting-cron-jobs/) 
9. [Q&A: Is CRON secure?](https://serverfault.com/questions/309311/is-cron-secure) SF SE
10. [Q&A: How to set environment variable for everyone under my linux system?](https://stackoverflow.com/questions/1641477/how-to-set-environment-variable-for-everyone-under-my-linux-system) SO SE 
11. [How to enable logging for cron on Linux](https://www.techrepublic.com/article/how-to-enable-logging-for-cron-on-linux/) 
12. [Q&A: Where is the default terminal $PATH located on Mac?](https://stackoverflow.com/questions/9832770/where-is-the-default-terminal-path-located-on-mac) SO SE 
13. [How To Read and Set Environmental and Shell Variables on a Linux VPS](https://www.digitalocean.com/community/tutorials/how-to-read-and-set-environmental-and-shell-variables-on-a-linux-vps#setting-environmental-variables-at-login) fm DigitalOcean.
14. [Set and List Environment Variables in Linux](https://linoxide.com/linux-how-to/how-to-set-environment-variables-in-linux/) fm LinOxide 
15. [How to Add to the Shell Path in macOS Catalina 10.5 using Terminal](https://coolestguidesontheplanet.com/how-to-add-to-the-shell-path-in-macos-using-terminal/)  
16. [Crontab Email Settings ( MAILTO )](https://www.cyberciti.biz/faq/linux-unix-crontab-change-mailto-settings/) 
17. [Q&A: How to temporarily disable a user's cronjobs?](https://unix.stackexchange.com/questions/188501/how-to-temporarily-disable-a-users-cronjobs) - Yes, even `cron` is managed by `systemd`! 
18. [Why is my crontab not working, and how can I troubleshoot it?](https://serverfault.com/questions/449651/why-is-my-crontab-not-working-and-how-can-i-troubleshoot-it) - a canonical question at serverfaultSE
19. [Why crontab scripts are not working?](https://askubuntu.com/questions/23009/why-crontab-scripts-are-not-working) - a canonical question at askubuntuSE 
20. [Q&A: Where is the user crontab stored?](https://askubuntu.com/questions/216692/where-is-the-user-crontab-stored) 
21. [How to set the **PATH** environment variable in `cron`](https://www.baeldung.com/linux/cron-jobs-path) 
22. [How to **create & modify `crontab` from a script**!](https://www.baeldung.com/linux/create-crontab-script) 

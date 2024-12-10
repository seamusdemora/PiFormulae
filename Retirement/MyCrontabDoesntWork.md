## Q: Why does my crontab not work?



## A: `cron` is simple in some respects, but enigmatic in others:



### Issue #1: the PATH environment variable is different.

Your `cron` user has a different *environment* than your interactive shell (e.g. `bash`) user.  

Solutions:

- use absolute path statements: `/home/user/scriptname.sh` instead of `scriptname.sh` or `./scriptname.sh` 
- be really clever, and set the `cron` user's environment:  [set env for cron](https://stackoverflow.com/questions/2229825/where-can-i-set-environment-variables-that-crontab-will-use); [run cron with existing env](https://unix.stackexchange.com/questions/27289/how-can-i-run-a-cron-command-with-existing-environmental-variables) ; [more info in this answer on SE](https://serverfault.com/a/337921/515728) ; [still more on SE](https://stackoverflow.com/questions/2135478/how-to-simulate-the-environment-cron-executes-a-script-with) 
- know the differences! Ask `cron` to tell you what `environment` it's using - [here's how to ask](WhatIsCronEnvironment.md).



### Issue #2: `cron` has no awareness of the state of other system services.

This is typically only an issue when using the `@reboot` scheduling facility in `cron` - before all the system's other services are available.  When services are managed under `systemd`, system service dependencies (e.g. network is available) may be declared in a *"unit file"*, but `cron` is designed to support any program.  

Solutions: 

- `sleep` before starting a script with service dependencies: 

   ```bash
   @reboot ( /bin/sleep 30; /bin/bash /home/pi/startup.sh )
   ```

* write your program/script to check availability of required resources 
* `cron` itself is a service, and yes - it may be managed under `systemd`! 

   The service file for `cron` is found in `/lib/systemd/system/cron.service`.  You may modify this file to add dependencies. For example: If many of your `cron` jobs require an active, operational network service be available, you may wish to [add the following](https://www.freedesktop.org/wiki/Software/systemd/NetworkTarget/) to the `[Unit]` section your `cron.service` file:
   ```
   After=network-online.target
   ```

### Issue #3: `cron` output goes to `/dev/null`

New users sometimes wonder why they don't see any output at the terminal from their `cron` jobs - as they did when they ran the same program from their interactive shell (e.g. `bash`). 

Solutions: 

* redirect the output of your `cron` job to capture `stderr` & `stdout` to a file:

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
   
   

------

REFERENCES:

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
17. [Why is my crontab not working, and how can I troubleshoot it?](https://serverfault.com/questions/449651/why-is-my-crontab-not-working-and-how-can-i-troubleshoot-it) - a canonical question at serverfaultSE
17. [Why crontab scripts are not working?](https://askubuntu.com/questions/23009/why-crontab-scripts-are-not-working) - a canonical question at askubuntuSE
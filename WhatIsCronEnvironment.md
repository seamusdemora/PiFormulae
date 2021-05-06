### Q: What is the *environment* for `cron`?

When issues arise using `cron` to schedule events, a frequently-heard explanation is that `cron` runs with a different set of *environment* variables than a "normal" user (e.g. `pi`). That's all well and good, but what *is* the *environment* for the `cron` user? If one is to avoid errors due to an incorrect *environment* when using `cron`, it would be useful to know what that *environment* is. 

In some cases, it would be possible to become a different user `su`, and having become that other user, simply execute the `env` or `printenv` command. Try that for the `cron`user:  

```bash
$ su cron
No passwd entry for user 'cron'
$
```

Which rules out that approach. We can try [other methods for listing all users on a system](https://www.2daygeek.com/3-methods-to-list-all-the-users-in-linux-system/), but that also leads nowhere. In fact, there is no user named `cron`, nor is there a need for one. `cron` is actually the name of the daemon that resides in `/usr/sbin`, and it is owned by `root`. 

Nevertheless, a `cron` job runs in an *environment* that is different than your user *environment*. For background on what the Linux/Unix *environment* is, read [this tutorial explaining the *environment*, and how it is created.](https://www.tutorialspoint.com/unix/unix-environment.htm) 

But let's get back on point, and answer the question: What is the *environment* for `cron`?

### A: Let's ask `cron` to tell us!

Create a shell script in your home directory (`~/`) as follows (or with the editor of your choice): 

```
$ nano ~/envtst.sh
```

Enter/C+P the following in the editor: 

```bash
#!/bin/sh 
echo "env report follows for user "$USER >> /home/pi/envtst.sh.out 
env >> /home/pi/envtst.sh.out 
echo "env report for user "$USER" concluded" >> /home/pi/envtst.sh.out
echo " " >> /home/pi/envtst.sh.out
```

Save the file and exit the editor; then set the file permissions as executable, and open your `crontab` for editing:  

```bash
$ chmod a+rx ~/envtst.sh
$ crontab -e 
crontab: installing new crontab
```

Enter the following line at the bottom of your `crontab`: 

```bash
* * * * *  /home/pi/envtst.sh >> /home/pi/envtst.sh.err 2>&1
```

Save and exit your `crontab`. Use `tail` to view the output & (hopefully) observe the *environment* for `cron`. If there's nothing in the file after a minute, view the file `~/envtst.sh.err` for error messages, and adjust as required.  (NOTE: If you want to clear all prior error messages after troubleshooting: `$ > ~/envtst.sh.err`) 

```bash
$ tail -f ~/envtst.sh.out
env report follows for user 
HOME=/home/pi
LOGNAME=pi
PATH=/usr/bin:/bin
LANG=en_GB.UTF-8
SHELL=/bin/sh
PWD=/home/pi
env report for user  concluded
^C
```

This will repeat every minute, so enter `^C` to stop the `tail` listing, edit your `crontab` again to "comment out" (or delete) the line just added. Save and exit the editor. 

Note in the `tail` output above that `cron` has a rather sparse *environment*; only six (6) variables are used to define it. In particular, note the `PATH` consists of only two directories. This is why your crontab entry fails if, for example, you're trying to launch a Python script that resides in your home directory. 

If you're not familiar, with your own user *environment*, it's useful to compare it against the `cron` *environment*. We'll use the same shell script to add that to the "output" file `~/envtst.sh.out`:

```bash
$ ~/envtst.sh 
$
```

To view the output, open `~/envtst.sh.out`in your editor, or `cat ~/envtst.sh.out` to see it in your terminal. It will likely be a fairly extensive output; 30 lines of text, more or less. Note in particular the following lines (assuming you've run this as user `pi`) : 

```bash
USER=pi
...
HOME=/home/pi 
LOGNAME=pi
_=/home/pi/envtst.sh
...
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/games:/usr/games 
...
SHELL=/bin/bash
```

You'll notice numerous differences. Having this information, knowing how the `cron` user's environment differs from yours, will help create rational `cron` jobs, and help troubleshooting when they don't behave as you'd like. Finally, you can change the *environment* for `cron`; modify it to better meet your needs. See the REFERENCES below, and [this recipe](https://github.com/seamusdemora/PiFormulae/blob/master/MyCrontabDoesntWork.md) for more `cron`-related stuff.  

------

REFERENCES AND FOLLOW-UP:

1. A sequel could be [How to Set the environment for `cron`](https://www.unix.com/shell-programming-and-scripting/163494-setting-environment-variables-cron-file.html) 
2. Other approaches to setting cron's environment are in [this Q&A on SO](https://stackoverflow.com/questions/2229825/where-can-i-set-environment-variables-that-crontab-will-use) 

3. Should `sudo` be used in a `crontab`? No, use root's crontab: `sudo crontab -e` [Q&A#1](https://askubuntu.com/questions/419548/how-to-set-up-a-root-cron-job-properly), [Q&A #2](https://askubuntu.com/questions/173924/how-to-run-a-cron-job-using-the-sudo-command) 

4. [Setting the environment variable defining the default editor in macos](http://osxdaily.com/2011/03/07/change-set-the-default-crontab-editor/) 
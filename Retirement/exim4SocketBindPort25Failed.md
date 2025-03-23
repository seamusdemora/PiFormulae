## `exim4` Issues - a Review of `/var/log/exim4/paniclog`

[`exim4`](https://en.wikipedia.org/wiki/Exim) is a Mail Transfer Agent (MTA), but as configured on my RPi, it cannot send or receive mail from the Internet.  It is [passed down to RPi from Debian](https://wiki.debian.org/Exim), and was installed on my system as a ***"Suggested Package"*** when I installed `at`.  It may be used on the RPi primarily as a means for service daemons (e.g. [using the `MAILTO` variable in `cron`](https://www.cyberciti.biz/faq/linux-unix-crontab-change-mailto-settings/)) to communicate **issues** to the administrator. For that reason alone, it should be maintained. 

It seems there is a problem with the default `exim4` configuration for RPi. If you rummage about in the log files occasionally as I do, you may have noticed several files in`/var/log` : `mail.warn`, `mail.info`, `mail.err`, `mail.log`, `syslog` and `daemon.log` containing the following ALERT:  

> **exim4: ALERT: exim paniclog /var/log/exim4/paniclog has non-zero size, mail system possibly broken** 

Following up, you may see the following error message in `/var/log/exim4/paniclog`:  

> **socket bind() to port 25 for address ::1 failed: Cannot assign requested address: daemon abandoned**

Note that address **`::1` is the IPv6 *loopback* address**; equivalent (*roughly*) to 127.0.0.1 in IPv4.

You will also note that the `exim4` daemon is not running; 

``` bash
$ pgrep exim 
$
```

I think this is a **bug** - an issue with the default configuration files installed with `exim4`. Here's what I did to address that: 

### 1. Edit the `exim4` configuration file as follows: 

   ```bash
   $ sudo nano /etc/exim4/update-exim4.conf.conf
   ```
   **Edit this line:**

   ```
   FROM: dc_local_interfaces='127.0.0.1 ; ::1'
     TO: dc_local_interfaces='127.0.0.1'
   ```

   Save & exit the editor, apply the update & re-start `exim4`: 

   ```bash
   $ sudo update-exim4.conf
   $ sudo systemctl restart exim4
   ```


   Other solutions advised adding the following line to the configuration file, but I found this unnecessary. 

   ```
   disable_ipv6='true'
   ```

### 2. Verify `/etc/sysctl.conf` contains the following line: 


   ```
   net.ipv6.conf.all.disable_ipv6 = 1
   ```

   Other solutions also advised adding this line, but it was included in my default conf file.

### 3. OPTIONAL: Clear the logs 

   Clearing `/var/log/exim4/paniclog` will stop recurring "false alarm" log entries in, e.g. `/var/log/mail.warn`: 

   ```bash
   $ sudo truncate -s 0 /var/log/exim4/paniclog
   ```


---

### REFERENCES: 

1. [exim4 won't bind to port 25](https://www.linux.org/threads/exim4-wont-bind-to-port-25.22915/) 
2. [exim in the Debian wiki](https://wiki.debian.org/Exim) 
3. [An Internet search on `exim`](https://duckduckgo.com/?t=ffnt&q=exim4&ia=web) 
4. [Crontab Email Settings ( MAILTO )](https://www.cyberciti.biz/faq/linux-unix-crontab-change-mailto-settings/) 
## `exim4` Issues - a Review of `/var/log/exim4/paniclog`

[`exim4`](https://en.wikipedia.org/wiki/Exim) is a *local* mail server on RPi. It's a full Mail Transfer Agent (MTA), but as configured on my RPi, it cannot send or receive mail from the Internet. It is [passed down to RPi from Debian](https://wiki.debian.org/Exim), and used on the RPi primarily as a means for service daemons (e.g. `cron`) to communicate **issues** to the administrator. For that reason alone, it should be maintained. 

If you rummage about in the log files occasionally as I do, you may have noticed several files in`/var/log` : `mail.warn`, `mail.info`, `mail.err`, `mail.log`, `syslog` and `daemon.log` containing the following ALERT:  

> **exim4: ALERT: exim paniclog /var/log/exim4/paniclog has non-zero size, mail system possibly broken** 

Following up, you may see the following error message in `/var/log/exim4/paniclog`:  

> **socket bind() to port 25 for address ::1 failed: Cannot assign requested address: daemon abandoned**

Note that address **`::1` is the IPv6 *loopback* address**; equivalent (*roughly*) to 127.0.0.1 in IPv4.

You will also note that the `exim4` daemon is not running; 

``` bash
$ pgrep exim 
$
```

This may mean that your RPi has a default configuration issue; i.e. I think this is a **bug**. Here's what you can do to address that: 

1. Edit the `exim4` configuration file; **two (2) changes are needed** to disable IPv6: 

   ```bash
   $ sudo nano /etc/exim4/update-exim4.conf.conf
   ```

   **Change 1:**  Add the following line to the bottom of the file listing: 

   ```
   disable_ipv6='true'
   ```

   **Change 2:**  Edit this line:

   ```
   FROM: dc_local_interfaces='127.0.0.1 ; ::1'
     TO: dc_local_interfaces='127.0.0.1'
   ```

   Save & exit the editor, apply the update & re-start `exim4`: 

   ```bash
   $ sudo update-exim4.conf
   $ sudo systemctl restart exim4
   ```

2. Verify that `/etc/sysctl.conf` contains the following line (it should be there by default):


   ```
   net.ipv6.conf.all.disable_ipv6 = 1
   ```

3. [OPTIONAL:] 

   Clear `/var/log/exim4/paniclog`  to stop recurring "false alarm" log entries in, e.g. `/var/log/mail.warn` : 
   
   ```bash
   $ sudo truncate -s 0 /var/log/exim4/paniclog
   ```
   
   Edit the log files `/var/log/mail.warn` and `/var/log/exim4/paniclog` to note when you made the change(s) described above, or delete the log entries pertaining to this error to "start fresh".



---

### REFERENCES: 

1. [exim4 won't bind to port 25](https://www.linux.org/threads/exim4-wont-bind-to-port-25.22915/) 
2. [exim in the Debian wiki](https://wiki.debian.org/Exim) 
3. [An Internet search on `exim`](https://duckduckgo.com/?t=ffnt&q=exim4&ia=web) 
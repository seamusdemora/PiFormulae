## Networking - An alternative to 'NetworkManager'

If you're weary of constantly searching for the proper command to invoke some networking option in 'NetworkManager' (via `nmcli` or `nmtui`), or perhaps wondering, *"What were "The Raspberries" thinking?!"* when  they threw over the relative simplicity of `dhcpcd` for the complexity of 'NetworkManager'... ***this recipe may offer some respite***. 

As of this writing, none of the following information is covered in the ["Official" documentation for Raspberry Pi](https://www.raspberrypi.com/documentation/computers/configuration.html#networking). Their coverage is limited to a few paragraphs on 'NetworkManager' - the "**default**" for 'bookworm'. Fortunately, Raspberry Pi is *fundamentally a Debian distribution*, and that gives us options. One of the simpler options for network configuration is available using [`ifupdown`](https://www.computerhope.com/unix/ifup.htm).  There is a `systemd` service built for it under the inauspicious name `networking.service`, and it is ***ready-to-use***! As far as the Debian documentation goes - well, it's *typical* for Debian methinks... Most of the documentation applicable to this topic is in three places: 

1.  Debian's [NetworkConfiguration wiki](https://wiki.debian.org/NetworkConfiguration) 
2.  Debian's [WiFi wiki](https://wiki.debian.org/WiFi/HowToUse) 
3.  `man interfaces` on your system

You may be wondering about the *relationship* between 'NetworkManager' and `ifupdown`. There's a statement on [this page](https://wiki.debian.org/NetworkManager#doc) that explains it fairly succinctly:  

>  NetworkManager will only handle interfaces **not** declared in `/etc/network/interfaces`

IOW, 'NetworkManager' defers control of any interface defined under `/etc/network/interfaces` to `ifupdown`. This seems reasonable, but my RPi systems only have (or use) a single interface... so what's the point of having 'NetworkManager' around at all? I'll address this question shortly. 

One other thing before we get into the [*nitty-gritty*](https://idioms.thefreedictionary.com/nitty-gritty) required to implement our simplified network configuration: package dependencies. The [Debian documentation](https://wiki.debian.org/WiFi/HowToUse#Using_ifupdown_and_wpasupplicant) states that there are some packages required for `ifupdown`  networking. ***For WiFi***, the Debian document  lists these packages as required: 

>  [ifupdown](https://packages.debian.org/ifupdown), [iproute2](https://packages.debian.org/iproute2), [wpasupplicant](https://packages.debian.org/wpasupplicant) (aka wpa_supplicant; For WPA2 support), [iw](https://packages.debian.org/iw), and [wireless-tools](https://packages.debian.org/wireless-tools) 

You should check *your* system to be sure, but all of these packages were *pre-installed* (included) in the [*64-bit Raspberry Pi OS Lite* distro](https://www.raspberrypi.com/software/operating-systems/) offered by "The Raspberries". Perhaps the easiest way to verify this is as follows: 

```bash 
$ sudo apt update
$ sudo apt install ifupdown iproute2 wpasupplicant iw wireless-tools
$
# you will *probably* receive a message fm 'apt' to the effect: "already latest version"
```

### A simpler network configuration:

Say *hello* to simplicity! Here's what's required: 

1.  I'll use a WiFi configuration as an example; Ethernet is even simpler. We first create (or modify) the  `/etc/networks/interfaces` file as follows: 

      ```
        $ sudo nano /etc/networks/interfaces          # open the file in your favorite editor
        
        # add the following lines for a DHCP configuration
        # the wifi device
        auto wlan0                       # alternatively: auto eth0
        iface wlan0 inet dhcp            # alternatively: iface eth0 inet dhcp
           wpa-ssid MySSIDaccesspoint
           wpa-psk MySSIDpassword
        # the loopback network interface
        auto lo
        iface lo inet loopback
        # ----------------------------------------------------------------------------
        # Alternatively, use the following for a static/manual IP address assignment
        # the wifi device
        auto wlan0
        iface wlan0 inet static
           wpa-ssid MySSIDaccesspoint
           wpa-psk MySSIDpassword
           address 192.168.1.221                  # use values appropriate for your network
           netmask 255.255.255.0                  #              "
           gateway 192.168.1.1                    #              "
         # dns-nameserver 8.8.8.8									# conflicted! 
        
        # the loopback network interface
        auto lo
        iface lo inet loopback
      ```

2.  And that's it - that is *all the configuration required*! After saving the  `/etc/networks/interfaces` file, you may `reboot`. For reasons that are not yet clear to me, I had to perform a "cold boot" (i.e. pull power, then re-apply) on some systems instead of a `reboot`. 

3.  Note the ***conflicted*** comment on the `dns-nameserver` line. The Debian docs seem *ambiguous* about the use of the `dns-nameserver` option. While `dns` does not even appear in `man interfaces`, it does contain a section titled `OPTIONS PROVIDED BY OTHER PACKAGES`. You should read this section if you have any interest in enabling this `dns-nameserver` option. **However**, some of you will have a *gateway device(s) (e.g. firewall/DHCP server/etc)* that may assign DNS for hosts on your network, and for those of you who **do not**, the easiest option is to use `/etc/resolv.conf` to assign DNS servers. This is done by declaring 1 DNS server per line (`nameserver 8.8.8.8` for example), and no more than 3 `nameserver` lines; ref `man resolv.conf`.  

4.  Oh - a [*word to the wise*](https://idioms.thefreedictionary.com/word+to+the+wise) before moving on. *If you are setting up a static/fixed IP address*, you should verify that it is actually working! One obvious thing to do is make an SSH connection to the fixed-IP host you've just provisioned. Another thing is to verify that the static IP host has DNS; i.e. from your SSH connection to your static-configured host try `ping google.com` or something similar. **A working DNS is imperative for things such as system timekeeping!** 



### What's the point of having 'NetworkManager' around?

First thing to say here is that this part of the recipe is strictly optional... and if you're just evaluating `ifupdown` my advice would be to skip this step. That said, let's trim some cruft  :) 

Like most daemons/services in Linux today, 'NetworkManager' is run under a `systemd` unit. In fact, there are (at least) three `systemd` units devoted to networking - even on a 'Lite' distro:

*  `systemd-networkd.service`
*  `NetworkManager.service`
*  `networking.service`

The `networking.service` is the only one we actually need when using `ifupdown` networking, so let's `disable` the other two. Note that a `disable` doesn't delete or remove anything permanently - it is simply a way to tell `systemd` to ***not*** start a service on `boot`. This will do it: 

   ```bash
   $ sudo systemctl disable NetworkManager.service
   ```

Afterwards, you can check status of all 3 services; you should see this: 

   ```bash
   $ systemctl status NetworkManager.service
   ○ NetworkManager.service - Network Manager
        Loaded: loaded (/lib/systemd/system/NetworkManager.service; disabled; preset: enabled)
        Active: inactive (dead)
          Docs: man:NetworkManager(8)
   $ systemctl status systemd-networkd.service
   ○ systemd-networkd.service - Network Configuration
        Loaded: loaded (/lib/systemd/system/systemd-networkd.service; disabled; preset: enabled)
        Active: inactive (dead)
   TriggeredBy: ○ systemd-networkd.socket
          Docs: man:systemd-networkd.service(8)
                man:org.freedesktop.network1(5)
   $ systemctl status networking.service
   ● networking.service - Raise network interfaces
        Loaded: loaded (/lib/systemd/system/networking.service; enabled; preset: enabled)
        Active: active (exited) since Fri 2025-02-28 22:02:27 UTC; 6min ago
   ```

Note that we got this result without having to disable the `systemd-networkd.service`. Why? I don't really know, but suspect that `systemd-networkd` disables itself when `networking.service` is enabled - which apparently occurs when the file `/etc/network/interfaces` is *"populated"*. In any event, we are now running slightly *more efficiently* without these unneeded services, and a simple network management scheme. 

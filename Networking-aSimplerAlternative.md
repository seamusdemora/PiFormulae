## Networking - An alternative to 'NetworkManager'

If you're weary of constantly searching for the proper command to invoke some networking option in 'NetworkManager' (via `nmcli` or `nmtui`), or perhaps wondering, *"What were "The Raspberries" thinking?!"* when  they threw over the relative simplicity of `dhcpcd` for the complexity of 'NetworkManager'... ***this recipe may offer some respite***. You have two options here: 1) read some background details, or 2) [skip ahead to the implementation](#a-simpler-network-configuration).

### Background; some details and documentation

As of this writing, none of the following information is covered in the ["Official" documentation for Raspberry Pi](https://www.raspberrypi.com/documentation/computers/configuration.html#networking). Their coverage is limited to a few paragraphs on 'NetworkManager' - the "**default**" for 'bookworm'. Fortunately, Raspberry Pi is *fundamentally a Debian distribution*, and that gives us options. One of the simpler options for network configuration is available using [`ifupdown`](https://www.computerhope.com/unix/ifup.htm) - a.k.a  ***'network interfaces'*** - as it uses the file `/etc/network/interfaces`.  There is also a `systemd` service built for it under the inauspicious name `networking.service`, and it is ***ready-to-use***! 

As far as the Debian documentation goes - well, it's *typical* for Debian methinks... Most of the documentation applicable to this topic is in three places: 

1.  Debian's [NetworkConfiguration wiki](https://wiki.debian.org/NetworkConfiguration) 
2.  Debian's [WiFi wiki](https://wiki.debian.org/WiFi/HowToUse) 
3.  `man interfaces` on your system

By now you hopefully understand that `ifupdown` networking is simply network configuration that uses file located at `/etc/network/interfaces`. As you will see, this method of network configuration is quite simple, and works perfectly well for Raspberry Pi. 

You may be wondering about the *relationship* between 'NetworkManager' and `ifupdown`. There's a statement on [this page](https://wiki.debian.org/NetworkManager#doc) that explains it fairly succinctly:  

>  NetworkManager will only handle interfaces **not** declared in `/etc/network/interfaces`

IOW, 'NetworkManager' defers control of any interface defined under `/etc/network/interfaces` to `ifupdown`. This seems reasonable, but my RPi systems only have (or use) a single interface... so what's the point of having 'NetworkManager' around at all? I'll address this question shortly. 

You may also be harboring doubts about the future viability of  [`ifupdown`](https://www.computerhope.com/unix/ifup.htm); or maybe heard rumors that  it has been or may be ***deprecated***. That seems ***highly unlikely*** to me, but you can [get some insight into the discussion](https://lwn.net/Articles/989055/), and decide for yourself. Note that it is the [first option listed in Debian's Network Configuration wiki](https://wiki.debian.org/NetworkConfiguration#A4_ways_to_configure_the_network). 

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

1.  I'll use a WiFi configuration as an example; Ethernet is even simpler. We first create (or modify) the  `/etc/network/interfaces` file as follows: 

      ```
        $ sudo nano /etc/network/interfaces          # open the file in your favorite editor
        
        # add the following lines for a ***DHCP configuration***
        auto wlan0                       # alternatively: auto eth0
        iface wlan0 inet dhcp            # alternatively: iface eth0 inet dhcp
           wpa-ssid <MySSIDaccesspoint>
           wpa-psk <MySSIDpassword>
        # the loopback network interface
        auto lo
        iface lo inet loopback
        # ----------------------------------------------------------------------------
        # Alternatively, use the following for a ***static IP configuration***
        auto wlan0
        iface wlan0 inet static
           wpa-ssid <MySSIDaccesspoint>
           wpa-psk <MySSIDpassword>
           address 192.168.1.221                  # use values appropriate for your network
           netmask 255.255.255.0                  #              "
           gateway 192.168.1.1                    #              "
        # the loopback network interface
        auto lo
        iface lo inet loopback
      ```

2.  You should verify your network DNS settings also; this is stored in `/etc/resolv.conf` under `ifupdown` networking: 

    ```bash
    $ sudo nano /etc/resolv.conf 
    
    # For a ***DHCP configured host***:
    domain yournetname.local
    search yournetname.local
    nameserver 192.168.1.1			# or whatever the IP addr of your Gateway/DNS server is
    
    # For a ***static IP configured host***: 
    domain yournetname.local
    search yournetname.local
    nameserver 192.168.1.1			# or whatever the IP addr of your Gateway/DNS server is
    nameserver 8.8.8.8					# this is google's DNS, if you're using something else
    nameserver 8.8.4.4					# then use that instead
    ```


3.  And that's it - that is *all the configuration required*! After editing and saving the  `/etc/network/interfaces` and `/etc/resolv.conf` files, you may `reboot`. For reasons that are not yet clear to me, I had to perform a "cold boot" (i.e. pull power, then re-apply) on some systems instead of a `reboot`. 
5.  Oh - a [*word to the wise*](https://idioms.thefreedictionary.com/word+to+the+wise) before moving on. *If you are setting up a static/fixed IP address*, you should verify that it is actually working! One obvious thing to do is make an SSH connection to the fixed-IP host you've just provisioned. Another thing is to verify that this static IP host has DNS; i.e. from your SSH connection to your static-configured host try `ping www.google.com` or something similar. **A working DNS is imperative for things such as system timekeeping and `apt` !** 

### What's the point of having 'NetworkManager' around?

First thing to say here is that this part of the recipe is **optional**... and if you're just evaluating `ifupdown` my advice would be to skip this step. That said, let's trim some cruft  :) 

Like most daemons/services in Linux today, 'NetworkManager' is run under a `systemd` unit. In fact, there are (at least) three `systemd` units devoted to networking - even on a 'Lite' distro:

*  `systemd-networkd.service`
*  `NetworkManager.service`
*  `networking.service`

The `networking.service` is the only one we actually need when using `ifupdown` networking, so let's `disable` the other two. Note that a `disable` doesn't delete or remove anything permanently - it is simply a way to tell `systemd` to ***not*** start a service on `boot`. This will do it: 

   ```bash
   $ sudo systemctl disable NetworkManager.service
   $ sudo systemctl disable systemd-networkd.service
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

### Further explorations

For those of you who may be inclined to *muck around* with `systemd` a bit, I offer the following brief guide to `systemd`.  I'm by no means an expert (heck, I don't even **like** `systemd`!); I used these commands in my *exploration*. 

#### Useful `systemd` commands

```bash
# list enabled/disabled services on your system:
$ systemctl list-unit-files --state=enabled     # or --state=disabled 

# disable/enable services: 
$ sudo systemctl [enable | disable] <service_name> 

# mask/unmask a service: makes it “impossible” to load the service 
sudo systemctl [mask | unmask] <service_name>

# systemd report on time required for system boot
$ systemd-analyze time                          # or, 'systemd-analyze'
$ systemd-analyze blame
$ systemd-analyze critical-chain

# systemd general support & documentation
$ systemctl cat <service_name>
$ systemctl help <service_name>

```



#### Some useful `systemd` documentation 

A [good explanation](https://www.baeldung.com/linux/systemctl-mask-disable) of the difference between `mask` and `disable` 

A [helpful blog](https://opensource.com/article/20/9/systemd-startup-configuration) exploring use of `systemd-analyze` 

RedHat Documentation: [Optimizing systemd to shorten the boot time](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_systemd_unit_files_to_customize_and_optimize_your_system/optimizing-systemd-to-shorten-the-boot-time_working-with-systemd#optimizing-systemd-to-shorten-the-boot-time_working-with-systemd) 

The [whole banana](https://www.freedesktop.org/software/systemd/man/latest/systemd-analyze.html) of `systemd-analyze` 

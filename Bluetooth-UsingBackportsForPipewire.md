## Improving Bluetooth Reliability Through 'debian-backports'

This is *more-or-less* a continuation of a recipe segment that was [started under another recipe](./Bluetooth-AudioForBookwormLite.md#build-and-configure-bluez-alsa-under-bookworm-lite). Briefly, this recipe is an effort to get the *"best"* (most reliable) performance from the Bluetooth susbsystem on my [Raspberry Pi Zero 2W](https://datasheets.raspberrypi.com/rpizero2/raspberry-pi-zero-2-w-product-brief.pdf). After using [`bluez-alsa`](https://github.com/Arkq/bluez-alsa) for a few months, I was still experiencing the occasional audio *dropouts*. I learned that a `pipewire` package version 1.2.1 was available through Debian's 'backports'  (*as opposed to* **ver 0.3.65** through the default `/etc/apt/sources.list`). I decided to give it a try.  

I tried to *think through the considerations*: 

* the Zero 2W is a *lightweight* system, but `pipewire` is a rather *heavyweight* application  
* the Zero 2W has **only** 2.4 GHz WiFi, whereas the 3A+ also has 5 GHz - meaning that there's greater risk of interference with BT in the Zero 2W
* the hardware upgrade angle wasn't compelling for the Zero 2W due to no USB-A ports (and my personal distaste for USB adapters)

My assessment was that the *improvement options* are limited for the Zero 2W **!** 

And I made another observation: For reasons that are unclear to me, the **RPi 3A+ *seems to default* to use of the 5GHz WiFi band**. I've checked this repeatedly, and never found it to use the 2.4 GHz band: 

   ```bash
   $ iw dev wlan0 link
   Connected to 74:83:c2:3e:f3:fb (on wlan0)
         	SSID: Mesh01
         	freq: 5180
         	RX: 1673385825 bytes (5919710 packets)
         	TX: 308305811 bytes (837543 packets)
         	signal: -66 dBm
         	rx bitrate: 200.0 MBit/s
         	tx bitrate: 292.5 MBit/s
   ...
   ```

That can't be *accidental*, but I've found no explanation in the documentation. What's also a mystery (to me) is how to change the WiFi frequency band! And of course the Zero 2W has no option to use 5 GHz - a hardware limitation. 

So - this explains ***why*** I decided to try the backport-upgrade method for `pipewire`. All that said, the following explains ***how*** I did the upgrade. 

#### **NOTE:** I conducted a *"reliability test"* on the backported `pipewire`. The test ran for just over a week, and [the results are listed below](#results-of-a-reliability-test-of-pipewire). 

### Installation:

#### 1. Add `debian-backports` to `/etc/apt/sources.list`:

```bash
$ sudo apt edit-sources
# OR, more conventionally:
$ sudo nano /etc/apt/sources.list
# you *should see* this in your editor:

deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
# Uncomment deb-src lines below then 'apt-get update' to enable 'apt-get source'
#deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian-security/ bookworm-security main contrib non-free non-free-firmware
#deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware

# Add one line at the end of the file:

deb http://deb.debian.org/debian bookworm-backports main contrib non-free

# save & exit the editor
```

***NOTE :*** All of the sources listed here were from **debian.org** - instead of **raspberrypi.org** as it is on 'bullseye'   systems. (???) 



#### 2. Update `apt` 

```bash
$ sudo apt update
...
# this updates your apt source tree
$
```

#### 2.a [Contingency step - only if required] 

I don't *think* this step is necessary for 'bookworm' as all the default sources are 'debian.org'.  However, it **was** necessary for 'bullseye' where the sources were 'raspberrypi.org', and so I include it here *just in case* you get warnings/errors complaining about a `GPG error`. 

While performing the `apt update` step, you may see something similar to this:

```bash
$ sudo apt update
...
W: GPG error: http://deb.debian.org/debian ... InRelease: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY 0E98404D386FA1D9 NO_PUBKEY 6ED0E7B82643E131
E: The repository 'http://deb.debian.org/debian ... InRelease' is not signed.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
$
```

If you do, the solution is fairly simple: 

```bash
# download the Debian key:  

$ curl -O http://http.us.debian.org/debian/pool/main/d/debian-archive-keyring/debian-archive-keyring_2023.4_all.deb 

# install the Debian key:

$ sudo dpkg -i debian-archive-keyring_2023.4_all.deb  

Selecting previously unselected package debian-archive-keyring.
...
```

And that should take care of it. 



#### 3. Install `pipewire` from backports:

```bash
$ sudo apt install -t bookworm-backports pipewire pipewire-audio-client-libraries libspa-0.2-bluetooth
...
$
```



#### 4. Reboot 

```bash
$ sudo reboot
...
```



### Post-Installation:

Hopefully, the `pipewire` installation went without any [hitches](https://www.merriam-webster.com/dictionary/hitch#dictionary-entry-2). If this install was *from scratch* (on a new system), you still have a few more steps before you can begin listening to audio via BT: 

1. Use `bluetoothctl` to connect your speaker/headphones  
2. Modify the `getty@tty1.service` 
3. Install a player; e.g. `mpg123` or `cmus` (if you're feeling ambitious :) 

I'll skip the details for these 3 items as they've already been covered in the other BT recipes ([1](https://github.com/seamusdemora/PiFormulae/blob/master/Bluetooth-AudioForBookwormLite.md) or [2](https://github.com/seamusdemora/PiFormulae/blob/master/Bluetooth-UpgradeRPiBtHardware.md)). 

If all went well, you should be able to start playing music; e.g.:

```bash 
$ /usr/bin/mpg123 /home/pi/rainstorm.mp3
```

I conducted a *"reliability test"* over a period of approximately of 1 week, and [reported the results below](#results-of-a-reliability-test-of-pipewire). 

---

*Some diagnostics to consider:*

---

You may also want (or need) to *check on a few things*; for example status of related `systemd` services, and maybe `journalctl` or `dmesg`. FWIW, here's what I see on my Zero 2W system as it's playing sounds through my 'OontZ Angle solo' speaker - YMMV: 

* Version

```bash
$ pipewire --version; wireplumber --version
pipewire
Compiled with libpipewire 1.2.1
Linked with libpipewire 1.2.1
wireplumber
Compiled with libwireplumber 0.4.17
Linked with libwireplumber 0.4.17
```

* bluetooth.service

```bash
$ systemctl status bluetooth.service
● bluetooth.service - Bluetooth service
     Loaded: loaded (/lib/systemd/system/bluetooth.service; enabled; preset: enabled)
     Active: active (running) since Wed 2024-07-31 05:51:27 UTC; 4 days ago
       Docs: man:bluetoothd(8)
   Main PID: 496 (bluetoothd)
     Status: "Running"
      Tasks: 1 (limit: 404)
        CPU: 257ms
     CGroup: /system.slice/bluetooth.service
             └─496 /usr/libexec/bluetooth/bluetoothd

Jul 31 05:51:34 rpi2w bluetoothd[496]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/aptx_ll_0
Jul 31 05:51:34 rpi2w bluetoothd[496]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/aptx_ll_duplex_1
Jul 31 05:51:34 rpi2w bluetoothd[496]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/aptx_ll_duplex_0
Jul 31 05:51:34 rpi2w bluetoothd[496]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/faststream
Jul 31 05:51:34 rpi2w bluetoothd[496]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/faststream_duplex
Jul 31 05:51:34 rpi2w bluetoothd[496]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSink/opus_05
Jul 31 05:51:34 rpi2w bluetoothd[496]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/opus_05
Jul 31 05:51:34 rpi2w bluetoothd[496]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSink/opus_05_duplex
Jul 31 05:51:34 rpi2w bluetoothd[496]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/opus_05_duplex
Jul 31 05:58:08 rpi2w bluetoothd[496]: /org/bluez/hci0/dev_DF_45_E9_00_BE_8B/sep1/fd0: fd(31) ready
```

* pipewire.service

```bash
$ systemctl --user status pipewire.service
● pipewire.service - PipeWire Multimedia Service
     Loaded: loaded (/usr/lib/systemd/user/pipewire.service; enabled; preset: enabled)
     Active: active (running) since Wed 2024-07-31 05:51:33 UTC; 4 days ago
TriggeredBy: ● pipewire.socket
   Main PID: 640 (pipewire)
      Tasks: 3 (limit: 404)
        CPU: 533ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/session.slice/pipewire.service
             └─640 /usr/bin/pipewire

Jul 31 05:51:33 rpi2w systemd[624]: Started pipewire.service - PipeWire Multimedia Service.
```

* wireplumber.service

   ```bash
   $ systemctl --user status wireplumber.service
   ● wireplumber.service - Multimedia Service Session Manager
        Loaded: loaded (/usr/lib/systemd/user/wireplumber.service; enabled; preset: enabled)
        Active: active (running) since Wed 2024-07-31 05:51:33 UTC; 4 days ago
      Main PID: 642 (wireplumber)
         Tasks: 5 (limit: 404)
           CPU: 2h 8min 1.634s
        CGroup: /user.slice/user-1000.slice/user@1000.service/session.slice/wireplumber.service
                └─642 /usr/bin/wireplumber
   
   Jul 31 05:51:34 rpi2w wireplumber[642]: Failed to get percentage from UPower: org.freedesktop.DBus.Error.NameHasNoOwner
   Jul 31 05:51:34 rpi2w wireplumber[642]: <WpPortalPermissionStorePlugin:0x55a46bcce0> Failed to call Lookup: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.impl.portal.PermissionStore was not provided by any .>
   Jul 31 05:51:34 rpi2w wireplumber[642]: <WpPortalPermissionStorePlugin:0x55a46bcce0> Failed to call Lookup: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.impl.portal.PermissionStore was not provided by any .>
   Jul 31 05:51:34 rpi2w wireplumber[642]: <WpPortalPermissionStorePlugin:0x55a46bcce0> Failed to call Lookup: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.impl.portal.PermissionStore was not provided by any .>
   Jul 31 05:51:34 rpi2w wireplumber[642]: <WpPortalPermissionStorePlugin:0x55a46bcce0> Failed to call Lookup: GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: The name org.freedesktop.impl.portal.PermissionStore was not provided by any .>
   Jul 31 05:53:42 rpi2w wireplumber[642]: RFCOMM receive command but modem not available: AT+CHLD=?
   Jul 31 05:53:42 rpi2w wireplumber[642]: RFCOMM receive command but modem not available: AT+CCWA=1
   Jul 31 05:53:42 rpi2w wireplumber[642]: RFCOMM receive command but modem not available: AT+NREC=0
   Jul 31 05:53:42 rpi2w wireplumber[642]: Failed to register battery provider. Error: org.freedesktop.DBus.Error.UnknownMethod
   Jul 31 05:53:42 rpi2w wireplumber[642]: BlueZ Battery Provider is not available, won't retry to register it. Make sure you are running BlueZ 5.56+ with experimental features to use Battery Provider.
   ```

Hmmm... still *not happy* even though the sound is perfect (AFAICT)

* journalctl

   ```bash
   $ journalctl | grep -i bluetooth | less 
   # this can be quite a *dump* if your system has been running for a while
   # to limit output to "current events", try this: 
   $ journalctl --follow | grep -i bluetooth
   ```

* dmesg 

   ```bash
   sudo dmesg | egrep -i 'bluetooth|oontz' | less 
   [    9.787238] Bluetooth: Core ver 2.22
   [    9.789729] NET: Registered PF_BLUETOOTH protocol family
   [    9.789762] Bluetooth: HCI device and connection manager initialized
   [    9.789802] Bluetooth: HCI socket layer initialized
   [    9.789818] Bluetooth: L2CAP socket layer initialized
   [    9.789870] Bluetooth: SCO socket layer initialized
   [    9.883372] Bluetooth: HCI UART driver ver 2.3
   [    9.883420] Bluetooth: HCI UART protocol H4 registered
   [    9.883631] Bluetooth: HCI UART protocol Three-wire (H5) registered
   [    9.885391] Bluetooth: HCI UART protocol Broadcom registered
   [   10.238985] Bluetooth: hci0: BCM: chip id 94
   [   10.239441] Bluetooth: hci0: BCM: features 0x2e
   [   10.242381] Bluetooth: hci0: BCM43430A1
   [   10.242421] Bluetooth: hci0: BCM43430A1 (001.002.009) build 0000
   [   10.252928] Bluetooth: hci0: BCM43430A1 'brcm/BCM43430A1.raspberrypi,model-zero-2-w.hcd' Patch
   [   10.993485] Bluetooth: hci0: BCM: features 0x2e
   [   10.996692] Bluetooth: hci0: BCM43436 37.4MHz Class 1.5 RaspBerry Pi Zero2 [Version: 1017.1042]
   [   10.996730] Bluetooth: hci0: BCM43430A1 (001.002.009) build 1042
   [   10.997457] Bluetooth: hci0: BCM: Using default device address (43:43:a1:12:1f:ac)
   [   12.648760] Bluetooth: BNEP (Ethernet Emulation) ver 1.3
   [   12.648787] Bluetooth: BNEP filters: protocol multicast
   [   12.648807] Bluetooth: BNEP socket layer initialized
   [   12.656562] Bluetooth: MGMT ver 1.22
   [   19.349144] Bluetooth: RFCOMM TTY layer initialized
   [   19.349194] Bluetooth: RFCOMM socket layer initialized
   [   19.349220] Bluetooth: RFCOMM ver 1.11
   [  133.421480] input: OontZ Angle solo DS E8B (AVRCP) as /devices/virtual/input/input0
   ```

---

---

### Results of a "Reliability Test" of `pipewire`:

The setup was simple: 

```bash
$ nohup /usr/bin/mpg123 --loop -1 /home/pi/rainstorm.mp3 &
```

I tracked the playtime using this script:

```bash
#!/usr/bin/bash
#
# What do I do?
# I count the number of reps & calculate playing time from nohup.out for mpg123
#
ntime=$(grep -o "\[73:05\]" nohup.out | wc -l)
etime=$(( $ntime*73/60 ))
echo -e "Elapsed play time in hours: $etime;\tReps: $ntime"
```

I stopped the test on Wed, 7 Aug; the output of the script above was: 

> `Elapsed play time in hours: 169;	Reps: 139`

### RESULT: Over 169 hours of continuous, un-interrupted playtime. 👍

---

---



## REFERENCES & Recommended Reading:

1. [Debian Backports Instructions](https://backports.debian.org/Instructions/); instructions for *using* backports 
2. [Debian backports wiki](https://wiki.debian.org/Backports) 
3. [Installing Debian Backports on Raspberry Pi](https://www.complete.org/installing-debian-backports-on-raspberry-pi/); J. Goerzen: running Debian backports on Raspberry Pi

 




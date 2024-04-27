## Bluetooth Audio on Ras Pi *Lite* (Yes, It Can Be Done)

Any of you that have followed my misadventures on [Stack Exchange](https://raspberrypi.stackexchange.com/users/83790/seamus?tab=profile) will know that I have struggled [off-and-on for **years**](https://raspberrypi.stackexchange.com/questions/116819/bluetooth-blues-redux) trying to get my Raspberry Pi OS 'Lite' to play audio over Bluetooth. This came to a head recently during a [dialog with the RPi staff on GitHub](https://github.com/RPi-Distro/repo/issues/369) (note most of my comments have been deleted by the staff). Yeah... I got a little fed up with that nonsense; I guess they didn't want anyone else to see what I'd written. It wasn't abusive at all - but it was *pointed* :) 

Anyway, it's been a couple of days since that row, and I'm happy to report that I've got something working! Following is a summary; I can post additional details if anyone is interested. What follows is a summary of the blow-by-blow installation & test procedure. For those of you not interested in this (likely all of you :), you may skip to the [Summary](#-summary) to get the important stuff. 

### Preliminaries

Start with a fresh install of 'bookworm Lite'. I've avoided 'bookworm' because of the large number of issues reported, but someone who tried it suggested to me that the 'Lite' version was OK - even "good". And so I downloaded the 64-bit version of 'bookworm Lite', and I installed in on my Raspberry Pi 3A. 

I then wasted some time trying to get BT working using nothing but the base installation. I thought I might learn something - I was wrong. I did manage to list & research each Bluetooth-related package in the base installation of 'bookworm Lite': 

| Package name       | Description                                                  |
| ------------------ | ------------------------------------------------------------ |
| pi-bluetooth       | Raspberry Pi 3 bluetooth; Loads BCM43430A1 firmware on boot  |
| libbluetooth3      | Library to use the BlueZ Linux Bluetooth stack               |
| bluez              | BlueZ is the official Linux Bluetooth protocol stack         |
| bluez-firmware     | Firmware; required for BT dongles based on Broadcom BCM203x & RPi chipset |
| alsa-topology-conf | ALSA config files; topology config files used by libasound2 for audio hardware |
| alsa-ucm-conf      | ALSA Use Case Manager config files; used with the alsaucm tool |
| alsa-utils         | Utilities to configure & use ALSA; incl alsactl, alsaucm, aplay, arecord, speaker-test |

I did learn there is a project called [`bluez-alsa`](https://github.com/arkq/bluez-alsa) that actually looked impressive. If I hadn't had some limited success with [`pipewire`]() on 'bullseye Lite', I probably would have tried it. It *seems* to be a very efficient package that will get audio working without consuming a lot of resources. If you're interested in trying it, you should know that it involves building from source - there are no pre-compiled packages available. 

### Install `pipewire`, etc

As I said, I had some *limited* success using `pipewire` on 'bullseye Lite'. I wanted the latest version I could get, so I tried getting that from Debian's `bullseye-backports` tree. While on 'bullseye Lite' I did manage to get my Bluetooth speaker (an old JBL Flip 5) *paired* and *trusted* with `bluetoothctl` (p/o the `bluez` package). This was a grubby exercise that calls for patience, but one that's necessary in the 'Lite/Headless' world. However - in the end, despite the fact I had some limited success, there were still issues on 'bullseye Lite'. I decided to try 'bookworm Lite' as my platform. Turned out to be a good decision.

The `pipewire` installation couldn't be easier... Debian's `apt` just handles everything (*almost!*). Here's the first few lines of the `pipewire installation` - **a 3.7MB download**: 

```bash
$ sudo apt install pipewire
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  libasyncns0 libavahi-client3 liblilv-0-0 liblua5.3-0 libmp3lame0 libmpg123-0 libopus0 libpipewire-0.3-0 libpipewire-0.3-common libpipewire-0.3-modules
  libpulse0 libserd-0-0 libsndfile1 libsord-0-0 libspa-0.2-modules libsratom-0-0 libvorbisenc2 libwebrtc-audio-processing1 libwireplumber-0.4-0 libx11-xcb1
  pipewire-bin pipewire-pulse rtkit wireplumber
Suggested packages:
  opus-tools pulseaudio serdi sordi libspa-0.2-bluetooth pulseaudio-utils wireplumber-doc
The following NEW packages will be installed:
  libasyncns0 libavahi-client3 liblilv-0-0 liblua5.3-0 libmp3lame0 libmpg123-0 libopus0 libpipewire-0.3-0 libpipewire-0.3-common libpipewire-0.3-modules
  libpulse0 libserd-0-0 libsndfile1 libsord-0-0 libspa-0.2-modules libsratom-0-0 libvorbisenc2 libwebrtc-audio-processing1 libwireplumber-0.4-0 libx11-xcb1
  pipewire pipewire-bin pipewire-pulse rtkit wireplumber
0 upgraded, 25 newly installed, 0 to remove and 0 not upgraded.
```

I did *not* install any of the "Suggested packages". Afterwards, I checked the version - looks like what I expected - ver 0.3.65:

```bash
$ pipewire --version
pipewire
Compiled with libpipewire 0.3.65
Linked with libpipewire 0.3.65
```

I then installed `mpg123` a command-line audio player at **1.8MB**. Also got an mp3 file to test with. I decided it wouldn't hurt anything to do a `reboot`.

Next came some checks on `systemd`; I learned earlier that keeping `systemd` happy was a prerequisite to success... and this (below) certainly *did not look like success!*

```bash
$ systemctl status bluetooth.service
● bluetooth.service - Bluetooth service
     Loaded: loaded (/lib/systemd/system/bluetooth.service; enabled; preset: enabled)
     Active: active (running) since Thu 2024-04-11 06:49:51 UTC; 4min 13s ago
       Docs: man:bluetoothd(8)
   Main PID: 552 (bluetoothd)
     Status: "Running"
      Tasks: 1 (limit: 380)
        CPU: 205ms
     CGroup: /system.slice/bluetooth.service
             └─552 /usr/libexec/bluetooth/bluetoothd

Apr 11 06:49:51 rpi3a bluetoothd[552]: src/plugin.c:plugin_init() Failed to init mcp plugin
Apr 11 06:49:51 rpi3a bluetoothd[552]: profiles/audio/bap.c:bap_init() D-Bus experimental not enabled
Apr 11 06:49:51 rpi3a bluetoothd[552]: src/plugin.c:plugin_init() Failed to init bap plugin
Apr 11 06:49:51 rpi3a bluetoothd[552]: Bluetooth management interface 1.22 initialized
Apr 11 06:49:51 rpi3a bluetoothd[552]: profiles/sap/server.c:sap_server_register() Sap driver initialization failed.
Apr 11 06:49:51 rpi3a bluetoothd[552]: sap-server: Operation not permitted (1)
Apr 11 06:49:51 rpi3a bluetoothd[552]: Failed to clear UUIDs: Failed (0x03)
Apr 11 06:49:51 rpi3a bluetoothd[552]: Failed to add UUID: Failed (0x03)
Apr 11 06:49:51 rpi3a bluetoothd[552]: Failed to add UUID: Failed (0x03)
Apr 11 06:49:51 rpi3a bluetoothd[552]: Failed to add UUID: Failed (0x03)
```

I tried using `bluetoothctl`, thinking something might have *come unglued*, but this was futile. Still more searching on the Internet led me to ["the solution"](https://forums.debian.net/viewtopic.php?t=155520) in the Debian forum: ***a missing package!*** Installation proceeded quickly - a **406 kB download**: 

```bash
$ sudo apt install libspa-0.2-bluetooth
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  libfreeaptx0 liblc3-0 libldacbt-abr2 libldacbt-enc2 libsbc1
The following NEW packages will be installed:
  libfreeaptx0 liblc3-0 libldacbt-abr2 libldacbt-enc2 libsbc1 libspa-0.2-bluetooth
0 upgraded, 6 newly installed, 0 to remove and 0 not upgraded.
```

Now, let's see if `systemd` feels better about things: 

```bash
$ systemctl status bluetooth.service
● bluetooth.service - Bluetooth service
     Loaded: loaded (/lib/systemd/system/bluetooth.service; enabled; preset: enabled)
     Active: active (running) since Thu 2024-04-11 07:04:11 UTC; 54min ago
       Docs: man:bluetoothd(8)
   Main PID: 550 (bluetoothd)
     Status: "Running"
      Tasks: 1 (limit: 380)
        CPU: 270ms
     CGroup: /system.slice/bluetooth.service
             └─550 /usr/libexec/bluetooth/bluetoothd

Apr 11 07:06:36 rpi3a bluetoothd[550]: Endpoint registered: sender=:1.19 path=/MediaEndpoint/A2DPSource/aptx_ll_0
...
Apr 11 07:08:01 rpi3a bluetoothd[550]: /org/bluez/hci0/dev_B8_F6_53_9B_1A_97/sep1/fd0: fd(29) ready
```

Note that final word: **`ready`** !  That smells like **SUCCESS  :)**  And in fact it was. As soon as I logged in, I heard my speaker chime indicating that it was connected and ready to go. I started `mpg123` as follows to confirm: 

```bash
$ nohup mpg123 --loop -1 rainstorm.mp3 &
[1] 2378
```

Finally - this was just the sound needed for a good night's sleep. 

### Here's a quick way to generate a *playlist* for `mpg123`:

* Assuming your music library is mounted on an external storage device at `/mnt/music` 

* ```bash
  $ find "/mnt/music" -type f -name "*.mp3" > playlist.txt
  ```
* Start `mpg123` in background & *shuffle-play* the playlist:

* ```bash
  $ nohup mpg123 -z -@ playlist.txt &
  ```

* 

### Summary

Following is a summary of the packages installed & command-line-fu used: 

```bash
$ sudo apt install pipewire								#pipewire
...
$ sudo apt install libspa-0.2-bluetooth		#the rest of pipewire
...
$ systemctl status bluetooth.service			#systemd check
```

The `mpg123` player was a separate installation of course; it's in the repo if you're interested. The total of all downloads was **approximately 6 MB**. 

For those interested in such things, following is a screen shot of `htop` running on the RPi 3A+ to give you an idea of the resources required to play BT audio on that hardware. The packages installed here appear to be consuming about 17% of the CPU:

![htop-rpi3a](/pix/htop-rpi3a.png)

### One Other Issue:

As it turns out, there was one other issue that had to be resolved: `pipewire` operates in *userland*, and this means that when the user logs out, `pipewire` shuts down; *i.e. no more music*! I've solved this by modifying the `systemd` service: `getty@tty1` as follows: 

```bash
$ sudo vim /etc/systemd/system/getty.target.wants/getty@tty1.service
```

#### Make the following edits:

#### FROM:

```
[Service]
...
ExecStart=-/sbin/agetty -o '-p -- \\u' --noclear - $TERM
```

#### TO: 

```
[Service]
...
#  ExecStart=-/sbin/agetty -o '-p -- \\u' --noclear - $TERM
ExecStart=
ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM
```

#### Save changes & reboot

The above changes simply add an `autologin` for user `pi` (or the user you've selected to run `pipewire`). After the `reboot` you can check that user `pi` has been logged in on `tty1`: 

```bash 
$ who
pi       tty1         1970-01-10 21:45
pi       pts/0        -3386239902218585523 (192.168.1.209)
```

And now, you may `logout` if you wish, and your music will continue to play! 


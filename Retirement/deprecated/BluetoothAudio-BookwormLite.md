## Bluetooth Audio on Ras Pi *Lite* (Yes, It Can Be Done)

##### *Updated Jul 21, 2024; see the [Summary](#summary) if you don't need all the verbiage!*

Any of you that have followed my misadventures on [Stack Exchange](https://raspberrypi.stackexchange.com/users/83790/seamus?tab=profile) will know that I have struggled [off-and-on for **years**](https://raspberrypi.stackexchange.com/questions/116819/bluetooth-blues-redux) trying to get my Raspberry Pi OS 'Lite' to play audio over Bluetooth. This frustration came to a head recently during a [dialog with the RPi staff on GitHub](https://github.com/RPi-Distro/repo/issues/369). This was (and is) one of the worst cases of ***corporate irresponsibility*** I have ever seen!  Yes, I got more than a little fed up with the nonsense from *some of* the Raspberry Pi maintainers.  It wasn't an abusive exchange - but it was *pointed*. Pointed enough that I was "banned" from their GitHub site - apparently *"for life"*.  Wow!... This is one thin-skinned bunch of assholes! 

Imagine you have a profitable business selling Raspberry Pi hardware. You know that part and parcel of that business is producing and maintaining a certain amount of **software**. But then you allow some of your employees to dictate terms to users/customers - not a good recipe for business success I am told. To close this [*brouhaha*](https://dictionary.cambridge.org/dictionary/english/brouhaha) I'm sick and tired of the asses who refuse to support their own software product because they deem it to be *niche*. 

... So a bit of time has passed since that episode. As I reported a few days afterwards (in an earlier revision of this recipe), I managed to get `pipewire`,  `wireplumber` (and assorted other dependencies) working! ***Yes!*** I was actually able to play music on an old 'JBL Flip5' BT speaker ***through my Raspberry Pi "Lite" system***.  

Most recently, I have now managed to extend this success with Bluetooth: 

* I've done a *fresh installation* of the latest RPi OS Lite (July 4, 2024) 'bookworm' on my [RPi 3A](https://datasheets.raspberrypi.com/rpi3/raspberry-pi-3-a-plus-product-brief.pdf) 
* I've gotten Bluetooth audio working on a [Pi Zero 2W](https://datasheets.raspberrypi.com/rpizero2/raspberry-pi-zero-2-w-product-brief.pdf) 'bookworm' using [`bluez-alsa`](https://github.com/Arkq/bluez-alsa) 

I'll cover both of these ([`pipewire`](#install-and-configure-pipewire-under-bookworm-lite) and [`bluez-alsa`](#build-and-configure-bluez-alsa-under-bookworm-lite)) in the sequel. 

## SUMMARY:

For those of you who want to get right down to business, following is a SUMMARY of the DETAILED procedures that follow: 

#### 1. Pair your speaker (or other device) with RPi using `bluetoothctl`

  ```bash
  $ bluetoothctl
  [bluetooth]# help <prints a brief command summary>
  [bluetooth]# power on
  [bluetooth]# pairable on
  [bluetooth]# scan on
  << scanning begins, wait until your device shows up, and then: >>
  [bluetooth]# scan off
  [bluetooth]# trust <device id; e.g. B8:F6:53:9B:1A:97>
  [bluetooth]# pair <device id; e.g. B8:F6:53:9B:1A:97>
  [bluetooth]# quit
  ```

#### 2. Install `pipewire` packages

  ```bash
  $ sudo apt install pipewire libspa-0.2-bluetooth
  ```

#### 3. [OPTIONAL] Modify `getty@tty1.service`

  ```bash
  $ sudo vim /etc/systemd/system/getty.target.wants/getty@tty1.service
  
  FROM: 
     [Service]
     ExecStart=-/sbin/agetty -o '-p -- \\u' --noclear - $TERM
  TO: 
     [Service]
     ExecStart=
     ExecStart=-/sbin/agetty --autologin pi --noclear %I $TERM
  ```

#### 4. `sudo reboot`



## DETAILS:

### Install and Configure `pipewire` under 'bookworm Lite'

Start with a fresh install of 'bookworm Lite'. I decided to [*start from scratch*](https://idioms.thefreedictionary.com/start+from+scratch) mainly to convince myself that I had not *inadvertently* installed or configured something that might have influenced the outcome; i.e. my thinking is that *accidental success* is worse than *failure*! Here are the detailed steps I followed: 

#### 1. Do the `bluetoothctl` rain dance

Before beginning the `pipewire` installation, I used the `bluetoothctl` package to:

* scan & discover my JBL Flip5 BT speaker
* "trust" & "pair" the Flip5 with the RPi3A BT controller

As I've written previously, using `bluetoothctl` is a grubby effort that seems (to me) rather [*hit-or-miss*](https://idioms.thefreedictionary.com/hit+or+miss) exercise. It seems the *most awkward* part is getting the speaker to show up during the "scan". I also had some troubles getting the "trust" established as there were repeated *"Device B8:F6:53:9B:1A:97 not available"* errors after the speaker was discovered during the "scan". In general, here's how I undertook the `bluetoothctl` [rain dance](https://www.collinsdictionary.com/us/dictionary/english/rain-dance): 

  ```bash
  $ bluetoothctl
  Agent registered
  [CHG] Controller B8:27:EB:F3:8A:58 Pairable: yes
  [bluetooth]#help
  # "help" lists a command summary
  [bluetooth]# power on
  Changing power on succeeded
  [bluetooth]# pairable on
  Changing pairable on succeeded
  [bluetooth]# scan on
  Discovery started
  [CHG] Controller B8:27:EB:F3:8A:58 Discovering: yes
  [NEW] Device 78:B8:B3:5A:49:CA 78-B8-B3-5A-49-CA
  [NEW] Device 22:A2:77:3A:65:3B 22-A2-77-3A-65-3B
  ...
  # blah, blah, blah; on and on and on... eventually, with some luck, you hit "paydirt"
  ...
  [NEW] Device B8:F6:53:9B:1A:97 JBL Flip 5
  ...
  [bluetooth]# scan off
  Discovery stopped
  ...
  [bluetooth]# trust B8:F6:53:9B:1A:97
  [CHG] Device B8:F6:53:9B:1A:97 Trusted: yes
  Changing B8:F6:53:9B:1A:97 trust succeeded
  [bluetooth]# pair B8:F6:53:9B:1A:97
  Attempting to pair with B8:F6:53:9B:1A:97
  [CHG] Device B8:F6:53:9B:1A:97 Connected: yes
  [CHG] Device B8:F6:53:9B:1A:97 Bonded: yes
  [CHG] Device B8:F6:53:9B:1A:97 UUIDs: 00001101-0000-1000-8000-00805f9b34fb
  [CHG] Device B8:F6:53:9B:1A:97 UUIDs: 0000110b-0000-1000-8000-00805f9b34fb
  [CHG] Device B8:F6:53:9B:1A:97 UUIDs: 0000110c-0000-1000-8000-00805f9b34fb
  [CHG] Device B8:F6:53:9B:1A:97 UUIDs: 0000110e-0000-1000-8000-00805f9b34fb
  [CHG] Device B8:F6:53:9B:1A:97 ServicesResolved: yes
  [CHG] Device B8:F6:53:9B:1A:97 Paired: yes
  Pairing successful
  ...
  # this is (AFAIK) as far as you can go w/ `bluetoothctl`, so next command is "quit"
  ...
  [bluetooth]# quit
  ```

<!---

I've avoided 'bookworm' because of the large number of issues reported, but someone who tried it suggested to me that the 'Lite' version was OK - even "good". And so I downloaded the 64-bit version of 'bookworm Lite', and I installed in on my Raspberry Pi 3A. 

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

-->

#### 2. Install `pipewire`

<!---

As I said, I had some *limited* success using `pipewire` on 'bullseye Lite'. I wanted the latest version I could get, so I tried getting that from Debian's `bullseye-backports` tree. While on 'bullseye Lite' I did manage to get my Bluetooth speaker (an old JBL Flip 5) *paired* and *trusted* with `bluetoothctl` (p/o the `bluez` package). This was a grubby exercise that calls for patience, but one that's necessary in the 'Lite/Headless' world. However - in the end, despite the fact I had some limited success, there were still issues on 'bullseye Lite'. I decided to try 'bookworm Lite' as my platform. Turned out to be a good decision.

* The `pipewire` installation couldn't be easier... Debian's `apt` just handles everything (*almost!*). Here's the first few lines of the `pipewire installation`: 

-->

* The `pipewire` installation is straightforward.  The `apt install` pulls in ***all but one*** of the required dependencies: 

    ```bash
    $ sudo apt update 
    ...
    $ sudo apt -y full-upgrade
    ...
    $ sudo apt install pipewire
    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    The following additional packages will be installed:
      libasyncns0 libavahi-client3 liblilv-0-0 liblua5.3-0 libmp3lame0 libmpg123-0 libopus0 libpipewire-0.3-0 libpipewire-0.3-common
      libpipewire-0.3-modules libpulse0 libserd-0-0 libsndfile1 libsord-0-0 libspa-0.2-modules libsratom-0-0 libvorbisenc2
      libwebrtc-audio-processing1 libwireplumber-0.4-0 libx11-xcb1 pipewire-bin pipewire-pulse rtkit wireplumber
    Suggested packages:
      opus-tools pulseaudio serdi sordi libspa-0.2-bluetooth pulseaudio-utils wireplumber-doc
    The following NEW packages will be installed:
      libasyncns0 libavahi-client3 liblilv-0-0 liblua5.3-0 libmp3lame0 libmpg123-0 libopus0 libpipewire-0.3-0 libpipewire-0.3-common
      libpipewire-0.3-modules libpulse0 libserd-0-0 libsndfile1 libsord-0-0 libspa-0.2-modules libsratom-0-0 libvorbisenc2
      libwebrtc-audio-processing1 libwireplumber-0.4-0 libx11-xcb1 pipewire pipewire-bin pipewire-pulse rtkit wireplumber
    0 upgraded, 25 newly installed, 0 to remove and 0 not upgraded.
    Need to get 3,871 kB of archives.
    After this operation, 19.5 MB of additional disk space will be used.
    Do you want to continue? [Y/n] Y
    
    ...
    
    $ 
    ```

* Next, install two of the **suggested packages**: `libspa-0.2-bluetooth` and `wireplumber-doc` (only  `libspa-0.2-bluetooth` is required): 
    ```bash
  $ sudo apt install libspa-0.2-bluetooth wireplumber-doc
  Reading package lists... Done
  Building dependency tree... Done
  Reading state information... Done
  The following additional packages will be installed:
    libfreeaptx0 liblc3-0 libldacbt-abr2 libldacbt-enc2 libsbc1
  The following NEW packages will be installed:
    libfreeaptx0 liblc3-0 libldacbt-abr2 libldacbt-enc2 libsbc1 libspa-0.2-bluetooth wireplumber-doc
  0 upgraded, 7 newly installed, 0 to remove and 0 not upgraded.
  Need to get 3,474 kB of archives.
  After this operation, 8,040 kB of additional disk space will be used.
  Do you want to continue? [Y/n] Y
  
  ...
  
  $
  ```

* Check the versions of `pipewire` & `wireplumber` - here's what I got on July 21, 2024:
    ```bash
    $ pipewire --version
    pipewire
    Compiled with libpipewire 0.3.65
    Linked with libpipewire 0.3.65 
    
    $ wireplumber --version 
    wireplumber
    Compiled with libwireplumber 0.4.13
    Linked with libwireplumber 0.4.13
    ```

* A *player* is needed; I installed `mpg123`: 

    ```bash 
    $ sudo apt install mpg123
    Reading package lists... Done
    Building dependency tree... Done
    Reading state information... Done
    The following additional packages will be installed:
      libaudio2 libice6 libjack-jackd2-0 libopenal-data libopenal1 libout123-0 libportaudio2 libsm6 libsndio7.0 libsyn123-0 libxt6 x11-common
    Suggested packages:
      nas jackd2 sndiod jackd oss-compat oss4-base pulseaudio
    The following NEW packages will be installed:
      libaudio2 libice6 libjack-jackd2-0 libopenal-data libopenal1 libout123-0 libportaudio2 libsm6 libsndio7.0 libsyn123-0 libxt6 mpg123
      x11-common
    0 upgraded, 13 newly installed, 0 to remove and 0 not upgraded.
    Need to get 1,906 kB of archives.
    After this operation, 5,411 kB of additional disk space will be used.
    Do you want to continue? [Y/n] Y
    
    ...
    
    $
    ```

* Let's `reboot` to get everything ***re-started***, and then check our `systemd bluetooth.service`: 

    ```bash
    $ sudo reboot
    
    ...
    
    $ systemctl status bluetooth.service
    ● bluetooth.service - Bluetooth service
         Loaded: loaded (/lib/systemd/system/bluetooth.service; enabled; preset: enabled)
         Active: active (running) since Sun 2024-07-21 20:17:57 UTC; 11min ago
           Docs: man:bluetoothd(8)
       Main PID: 569 (bluetoothd)
         Status: "Running"
          Tasks: 1 (limit: 174)
            CPU: 202ms
         CGroup: /system.slice/bluetooth.service
                 └─569 /usr/libexec/bluetooth/bluetoothd
    
    Jul 21 20:28:34 rpi3a bluetoothd[569]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/aptx_ll_1
    Jul 21 20:28:34 rpi3a bluetoothd[569]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/aptx_ll_0
    Jul 21 20:28:34 rpi3a bluetoothd[569]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/aptx_ll_duplex_1
    Jul 21 20:28:34 rpi3a bluetoothd[569]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/aptx_ll_duplex_0
    Jul 21 20:28:34 rpi3a bluetoothd[569]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/faststream
    Jul 21 20:28:34 rpi3a bluetoothd[569]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/faststream_duplex
    Jul 21 20:28:34 rpi3a bluetoothd[569]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSink/opus_05
    Jul 21 20:28:34 rpi3a bluetoothd[569]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/opus_05
    Jul 21 20:28:34 rpi3a bluetoothd[569]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSink/opus_05_duplex
    Jul 21 20:28:34 rpi3a bluetoothd[569]: Endpoint registered: sender=:1.20 path=/MediaEndpoint/A2DPSource/opus_05_duplex
    ```


* No complaints from `systemd`... will wonders never cease? Let's try to play some sounds:

    ```bash
    $ $ nohup mpg123 --loop -1 rainstorm.mp3 &
    [1] 835
    $ nohup: ignoring input and appending output to 'nohup.out' 
    
    # YES! We have the sound of 'rainstorm.mp3' coming from the speakers! 
    ```


* Let's check the `pipewire.service` and the `wireplumber.service`: 

    ```bash
    #NOTE: the '--user' option 
    $ systemctl --user status pipewire
    ● pipewire.service - PipeWire Multimedia Service
         Loaded: loaded (/usr/lib/systemd/user/pipewire.service; enabled; preset: enabled)
         Active: active (running) since Sun 2024-07-21 22:40:34 UTC; 5h 44min ago
    TriggeredBy: ● pipewire.socket
       Main PID: 723 (pipewire)
          Tasks: 3 (limit: 174)
            CPU: 52.651s
         CGroup: /user.slice/user-1000.slice/user@1000.service/session.slice/pipewire.service
                 └─723 /usr/bin/pipewire
    
    Jul 21 22:40:35 rpi3a pipewire[723]: mod.rt: RTKit error: org.freedesktop.DBus.Error.AccessDenied
    Jul 21 22:40:35 rpi3a pipewire[723]: mod.rt: could not make thread 780 realtime using RTKit: Permission denied
    Jul 21 22:40:35 rpi3a pipewire[723]: spa.v4l2: '/dev/video14' VIDIOC_ENUM_FRAMEINTERVALS: Inappropriate ioctl for device
    Jul 21 22:40:35 rpi3a pipewire[723]: spa.v4l2: '/dev/video15' VIDIOC_ENUM_FRAMEINTERVALS: Inappropriate ioctl for device
    Jul 21 22:40:35 rpi3a pipewire[723]: spa.v4l2: '/dev/video21' VIDIOC_ENUM_FRAMEINTERVALS: Inappropriate ioctl for device
    Jul 21 22:40:35 rpi3a pipewire[723]: spa.v4l2: '/dev/video22' VIDIOC_ENUM_FRAMEINTERVALS: Inappropriate ioctl for device
    Jul 21 22:40:35 rpi3a pipewire[723]: spa.v4l2: '/dev/video14' VIDIOC_ENUM_FRAMEINTERVALS: Inappropriate ioctl for device
    Jul 21 22:40:35 rpi3a pipewire[723]: spa.v4l2: '/dev/video15' VIDIOC_ENUM_FRAMEINTERVALS: Inappropriate ioctl for device
    Jul 21 22:40:35 rpi3a pipewire[723]: spa.v4l2: '/dev/video21' VIDIOC_ENUM_FRAMEINTERVALS: Inappropriate ioctl for device
    Jul 21 22:40:35 rpi3a pipewire[723]: spa.v4l2: '/dev/video22' VIDIOC_ENUM_FRAMEINTERVALS: Inappropriate ioctl for device
    
    $ systemctl --user status wireplumber
    ● wireplumber.service - Multimedia Service Session Manager
         Loaded: loaded (/usr/lib/systemd/user/wireplumber.service; enabled; preset: enabled)
         Active: active (running) since Mon 2024-07-22 04:28:56 UTC; 41s ago
       Main PID: 717 (wireplumber)
          Tasks: 5 (limit: 174)
            CPU: 1.264s
         CGroup: /user.slice/user-1000.slice/user@1000.service/session.slice/wireplumber.service
                 └─717 /usr/bin/wireplumber
    
    Jul 22 04:28:56 rpi3a wireplumber[717]: Can't find org.freedesktop.portal.Desktop. Is xdg-desktop-portal running?
    Jul 22 04:28:56 rpi3a wireplumber[717]: RTKit error: org.freedesktop.DBus.Error.AccessDenied
    Jul 22 04:28:56 rpi3a wireplumber[717]: could not set nice-level to -11: Permission denied
    Jul 22 04:28:56 rpi3a wireplumber[717]: SPA handle 'api.libcamera.enum.manager' could not be loaded; is it installed?
    Jul 22 04:28:56 rpi3a wireplumber[717]: PipeWire's libcamera SPA missing or broken. libcamera not supported.
    Jul 22 04:28:56 rpi3a wireplumber[717]: RTKit error: org.freedesktop.DBus.Error.AccessDenied
    Jul 22 04:28:56 rpi3a wireplumber[717]: could not make thread 757 realtime using RTKit: Permission denied
    Jul 22 04:28:57 rpi3a wireplumber[717]: Trying to use legacy bluez5 API for LE Audio - only A2DP will be supported. Please upgrade bluez5.
    Jul 22 04:28:57 rpi3a wireplumber[717]: <WpSiAudioAdapter:0x5580d0e060> Object activation aborted: proxy destroyed
    Jul 22 04:28:57 rpi3a wireplumber[717]: <WpSiAudioAdapter:0x5580d0e060> failed to activate item: Object activation aborted: proxy destroyed
    ```

    And so it seems that neither the `pipewire` nor `wireplumber` services are "happy". I currently have no idea what to do about that... but am *very pleased* that the BT audio seems to work quite well without it! 

#### 3. Modify the `getty@tty1.service`

`pipewire` and `wireplumber` are under a `systemd` service file that runs in **userland**. The [*long and the short of that*](https://dictionary.cambridge.org/dictionary/english/long-and-the-short-of-it) is that when the user who started these services logs off - they stop working - the audio "goes away". That may be *inconvenient* at times. Fortunately, there is a way around this problem: keep your user (presumably user `pi`) logged in under `getty`. Fortunately, this is fairly straightforward - or even unnecessary if you're happy stopping BT audio when you log off. 

If you want to make this change, here's one way to do it:

``` fuckyousystemd
N.B. There are several ways to modify service files in systemd. I am aware some consider it "bad form" to edit the main file directly, but that is how I'm going to do it here.
```

```bash
$ sudo vim /etc/systemd/system/getty.target.wants/getty@tty1.service
```

#### Make the following edits:

##### FROM:

```
[Service]
...
ExecStart=-/sbin/agetty -o '-p -- \\u' --noclear - $TERM
```

##### TO:

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



## Build and configure `bluez-alsa` under 'bookworm Lite'

If you're *considering your options* for a Bluetooth audio setup, the most important thing to consider wrt `bluez-alsa` is that ***it is not available as an `apt` package***. IOW, you must download the source files, and build (compile) `bluez-alsa`.  

This is not as difficult as it may sound! But it's *probably* a bit more challenging than installing `pipewire`. Here's a rough outline on how to approach this: 

* Visit the[`bluez-alsa` GitHub site](https://github.com/Arkq/bluez-alsa), and review the README file.
* Review the [build and installation file](https://github.com/arkq/bluez-alsa/blob/master/INSTALL.md) 
* Review the [wiki for build and installation details](https://github.com/arkq/bluez-alsa/wiki/Installation-from-source) 

The [wiki](https://github.com/arkq/bluez-alsa/wiki/Installation-from-source) contains most of the *step-by-step* details needed to download the source, build it on your RPi and install it there. The authors of `bluez-alsa` have also created a [Discussions tab](https://github.com/arkq/bluez-alsa/discussions) on their GitHub site as a vehicle for technical support. You should peruse and search existing Q&A before you ask new questions, but the support here is truly amazing! 

I'll not go into more details here at this time as I'm still learning myself. I have managed to successfully install `bluez-alsa` on my RPi Zero 2W running under 'bookworm Lite'. It's been running flawlessly for about 3 months as I write this. Compared to `pipewire`, `bluez-alsa` is a much more *lightweight* software solution. I even built (compiled) `bluez-alsa` on the Zero 2W! 





<!---

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

-->

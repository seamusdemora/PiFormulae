# Bluetooth Audio on Raspberry Pi *Lite* 

#### (*Yes, It Can Be Done*)

### ToC

​	Background (keep reading)

​	[Summary](#summary)

​	[Detailed Installation & Configuration](#all-the-details)

​	[Example BT setup on Pi Zero 2W](#an-example-bluetooth-setup) 

---

```
Foreword:
---------
This "recipe" was written for the 'bookworm' RPi OS distro. Consequently, its relevance is fading. In my case, I 
have recently upgraded my RPi 3A+ system from 'bookworm' to 'trixie' (ref 'In-Place Upgrade URL' below). The 
(mostly) positive experience from that in-place upgrade is that the Bluetooth functionality survived the upgrade! 
However, there has been at least one "negative": The BT speaker no longer automatically connects following a 
'reboot'; I'll troubleshoot this once I have some time. AFAIK now, the procedures in this recipe remain valid for a 
"fresh" 'trixie' install, but again I'll likely update/refresh/revise (or rewrite) this recipe after doing a 
fresh install. So - until then ...

In-Place Upgrade URL:
https://github.com/seamusdemora/PiFormulae/blob/master/PackageMaintenance.md#perform-an-in-place-version-upgrade
```



Any of you that have followed my misadventures on [Stack Exchange](https://raspberrypi.stackexchange.com/users/83790/seamus?tab=profile) will know that I have struggled [off-and-on for **years**](https://raspberrypi.stackexchange.com/questions/116819/bluetooth-blues-redux) trying to get my Raspberry Pi OS 'Lite' to play audio over Bluetooth. This frustration came to a head recently during a [dialog with the RPi staff on GitHub](https://github.com/RPi-Distro/repo/issues/369). This was (and is) a simple case of ***corporate irresponsibility***!  I got more than a little fed up with the nonsense from *some of* the Raspberry Pi maintainers.  It wasn't an abusive exchange - but it was *pointed*. Pointed enough that I was "banned" from their GitHub site - apparently *"for life"*.  Wow!... This is one thin-skinned bunch of assholes! 

And Raspberry Pi is not like other *open-source* projects - this organization makes a tidy profit from the sale of devices, and supporting their industrial customer base. Consequently, they have an obligation to support the items they sell!  Imagine that you have a profitable business selling Raspberry Pi hardware. You *should realize* that part and parcel of that business is producing and maintaining a certain amount of **software**. But then you allow some of your employees to *lord it over* users/customers. IMO, their attitude is _**all wrong!**_ Unlike many other *open source* projects, **_Raspberry Pi provides nothing for free_**!  To close this [*brouhaha*](https://dictionary.cambridge.org/dictionary/english/brouhaha): I'm sick and tired of _arses_ who refuse to support their own software product because they deem it to be *niche*. \<END OF RANT\>

... So a bit of time has passed since that episode. As I reported a few days afterwards (in an earlier revision of this recipe), I managed to get `pipewire`,  `wireplumber` (and assorted other dependencies) working! ***Yes...*** I was actually able to play music on an old 'JBL Flip5' BT speaker ***through my Raspberry Pi 3A+ "Lite" system!***  

Recently, I have managed to extend this success with Bluetooth: 

* Completed a *fresh installation* (documented herein) of `pipewire` (ver '0.3.65') on the latest [RPi OS Lite (July 4, 2024) 'bookworm'](https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2024-07-04/) on an [**RPi 3A+**](https://datasheets.raspberrypi.com/rpi3/raspberry-pi-3-a-plus-product-brief.pdf) 
* I temporarily used  [`bluez-alsa`](https://github.com/Arkq/bluez-alsa) as a solution on my  **[RPi Zero 2W](https://datasheets.raspberrypi.com/rpizero2/raspberry-pi-zero-2-w-product-brief.pdf)** 'bookworm, 64-bit'. It worked, but I found it *less reliable* than the `pipewire` installation.  Consequently, I have *amiably* removed the section devoted to `bluez-alsa` in this recipe.  
* Most recently, have **upgraded `pipewire` to ver. 1.2.1** on RPi Zero 2W 'bookworm' using Debian's `bookworm-backports`     

I'll cover this in the sequel below. 

## SUMMARY:

> ***of `pipewire` installation on RPi 3A+ under 'bookworm'***

##### NOTE: *(see [DETAILS](#all-the-details) below for more information)*

For those of you who want to get right down to business, following is a SUMMARY of the [DETAILED](#all-the-details) procedures that follow: 

#### 1. Pair your speaker (or other device) with RPi using `bluetoothctl`

  ```bash
  $ bluetoothctl
  [bluetooth]# help <prints a brief command summary>
  [bluetooth]# power on
  [bluetooth]# pairable on
  [bluetooth]# scan on
  << scanning begins, wait until your device (speaker, headphones) shows up, and then: >>
  [bluetooth]# scan off
  [bluetooth]# trust <device id; e.g. B8:F6:53:9B:1A:97>
  [bluetooth]# pair <device id; e.g. B8:F6:53:9B:1A:97>
  [bluetooth]# quit
  ```

#### 2. Install `pipewire` packages (incl. `libspa-0.2-bluetooth`)

  ```bash
  $ sudo apt install pipewire libspa-0.2-bluetooth
  ```

#### 3. Modify `getty@tty1.service` [OPTIONAL, but recommended]

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

---

## All the DETAILS:

### Install and Configure `pipewire` under 'bookworm Lite'

Start with a fresh install of 'bookworm Lite'. I decided to [*start from scratch*](https://idioms.thefreedictionary.com/start+from+scratch) mainly to convince myself that I had not *inadvertently* installed or configured something that might have influenced the outcome; i.e. my thinking is that *accidental success* is worse than *failure*! Here are the detailed steps I followed: 

#### 1. Do the `bluetoothctl` rain dance

Before beginning the `pipewire` installation, I used the `bluetoothctl` package to:

* scan & discover my 'JBL Flip5' BT speaker
* "trust" & "pair" the Flip5 with the RPi3A BT controller

As I've written previously, using `bluetoothctl` is a grubby effort that seems (to me) a rather [*hit-or-miss*](https://idioms.thefreedictionary.com/hit+or+miss) exercise. It seems the *most awkward* part is getting the speaker to show up during the "scan". I also had some troubles getting the "trust" established as there were repeated *"Device B8:F6:53:9B:1A:97 not available"* errors after the speaker was discovered during the "scan". In general, here's how I undertook the `bluetoothctl` [rain dance](https://www.collinsdictionary.com/us/dictionary/english/rain-dance): 

  ```bash
  $ bluetoothctl
  Agent registered
  [CHG] Controller B8:27:EB:F3:8A:58 Pairable: yes
  [bluetooth]# help
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

#### 2. Install `pipewire`

* The `pipewire` installation is straightforward.  The `apt install` pulls in ***all but one*** of the required dependencies: 

    ```bash
    $ sudo apt update 
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


* No complaints from `systemd`... [*will wonders never cease?*](https://idioms.thefreedictionary.com/Will+wonders+never+Cease!) Let's try to play some sounds:

    ```bash
    $ $ nohup mpg123 --loop -1 rainstorm.mp3 &
    [1] 835
    $ nohup: ignoring input and appending output to 'nohup.out' 
    
    # YES! We have the sound of 'rainstorm.mp3' coming from the speaker! 
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

    And so it seems that neither the `pipewire` nor `wireplumber` services are "happy". I currently have no idea what to do about that... but am *very pleased* that the BT audio seems to work quite well [in spite of  it](https://dictionary.cambridge.org/dictionary/english/in-spite-of)! 

#### 3. Modify the `getty@tty1.service`

`pipewire` and `wireplumber` are under a `systemd` service file that runs in **userland**. The [*long and the short of that*](https://dictionary.cambridge.org/dictionary/english/long-and-the-short-of-it) is that when the user who started these services logs off - they stop working - the audio "goes away". That may be *inconvenient* at times. Fortunately, there is a way around this problem: keep your user (presumably user `pi`) logged in under `getty`. Fortunately, this is fairly straightforward - or even unnecessary if you're happy stopping BT audio when you log off. 

If you want to make this change, here's **_two ways_** to do it:

The **_"preferred"_** way to do it. Note that this method *may* protect your changes from `apt upgrade`s: 
```bash
sudo systemctl edit getty@tty1.service
```

The _**"other"**_ way to do it. Note that some consider it "bad form" to edit the *"main file"* directly.
```bash
$ sudo vim /etc/systemd/system/getty.target.wants/getty@tty1.service
```

#### Make the following changes:

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

Once you see your user listed on `tty1`, you may `logout` if you wish, and your music will continue to play! 



## An example Bluetooth setup

This section falls into the "[*for what it's worth*](https://www.merriam-webster.com/dictionary/for%20what%20it's%20worth)" category (like many other sections here :)  I wrote in a [related recipe](https://github.com/seamusdemora/PiFormulae/blob/master/Bluetooth-UsingBackportsForPipewire.md#results-of-reliability-testing-of-the-backported-pipewire) regarding a "reliability test" I performed on a then-new `pipewire` installation. This section describes a simple project that grew out of that testing: a "white-noise BT music player". I use it every night, and it seems to have helped me get more and better sleep! Following is a quick recipe: 

#### Ingredients:

***After*** performing Steps 1, 2 & 3 above:

*  [Raspberry Pi Zero 2W](https://datasheets.raspberrypi.com/rpizero2/raspberry-pi-zero-2-w-product-brief.pdf), running 'bookworm-64 Lite' 
*  A "white noise" file I named [`rainstorm.mp3`](pix/rainstorm.mp3) (thunderstorm recording originally found on YouTube) 
*  A small BT speaker (OontZ Solo Bluetooth 5 watt mini-Speaker, ~$20) 
*  "Custom Software" - shown below

#### Software: 

<sub>**NOTE for "Lite" users: The script below does not avoid the necessity of using `bluetoothctl` to initially "pair" and "trust" your Bluetooth speaker. This is a "one-time" requirement - one time per speaker, that is.**</sub> 

*  a short `bash` script & installation of the `mpg123` package: 

   *  ```bash
      $ nano start-storm.sh          # add the following lines, save & exit
      
      #!/usr/bin/bash
      sleep 5
      if [ "$(/usr/bin/bluetoothctl devices Connected)" != "Device DF:45:E9:00:EB:DD OontZ Angle solo DS E8B" ]; then
          /usr/bin/bluetoothctl connect DF:45:E9:00:BE:8B
      fi
      sleep 1
      /usr/bin/mpg123 --loop -1 /home/pi/rainstorm.mp3
      ```

   *  ```bash
      $ sudo apt update
      $ sudo apt install mpg123
      ```

*  a one-line entry in the `root crontb` to start playing at `reboot`: 

   *  ```bash
      $ sudo crontab -e                # add the following line, save & exit 
      
      @reboot su pi -l -c /home/pi/start-storm.sh > /home/pi/start-storm.log 2>&1
      ```



<!---

## Build and configure `bluez-alsa` under 'bookworm Lite'

If you're *considering your options* for a Bluetooth audio setup, the most important thing to consider wrt `bluez-alsa` (as described in this recipe) is that *it's not available *as-is* in `apt` package format*. IOW, what we cover here requires you download the source files, and build (compile & install) `bluez-alsa`.  

This is not as difficult as it may sound! But it's *probably* a bit more challenging than installing `pipewire`. Here's a rough outline on how to approach this: 

* Visit the[`bluez-alsa` GitHub site](https://github.com/Arkq/bluez-alsa), and review the README file.
* Review the [build and installation file](https://github.com/arkq/bluez-alsa/blob/master/INSTALL.md) 
* Review the [wiki for build and installation details](https://github.com/arkq/bluez-alsa/wiki/Installation-from-source) 

The [bluez-alsa wiki](https://github.com/arkq/bluez-alsa/wiki/Installation-from-source) contains most of the *step-by-step* details needed to download the source, build it on your RPi and install it there. The authors of `bluez-alsa` have also created a [Discussions tab](https://github.com/arkq/bluez-alsa/discussions) on their GitHub site as a vehicle for technical support. You should peruse and search existing Q&A before you ask new questions, but the support here is truly amazing! 

I'll defer on more details at this time. I did manage to successfully install `bluez-alsa` on my [RPi Zero 2W](https://datasheets.raspberrypi.com/rpizero2/raspberry-pi-zero-2-w-product-brief.pdf) running under 'bookworm Lite'. This installation worked well (but not flawlessly) for about 3 months. Compared to `pipewire`, `bluez-alsa` is a much more *lightweight* software solution. I even built (compiled) `bluez-alsa` on the Zero 2W! 

In an effort to overcome the occasional *glitch* in BT audio on my Zero 2W running `bluez-alsa`, I decided to try the 'bookworm-backport' of `pipewire`.  I re-installed the [latest release of 'bookworm'](https://downloads.raspberrypi.com/raspios_lite_armhf/images/raspios_lite_armhf-2024-07-04/), and added `bookworm-backports` to `/etc/apt/sources.list`. I'm not going to delve into the details of that installation here as this *recipe* has already become too wordy for my tastes; I'll put this in a new *recipe*, and add a link here when it's completed.  

-->

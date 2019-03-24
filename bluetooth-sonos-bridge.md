I've tried to simplify the tutorial at [the Instructables website for playing music direct to Sonos over a Bluetooth connection](https://www.instructables.com/id/Play-Bluetooth-on-Sonos-Using-Raspberry-Pi/) by doing everything from the command line & cutting out some items that seemed superfluous. Here we go: 

#### 1. The `darkice` and `icecast2`libraries are needed.

`darkice` will be encode the bluetooth audio source into an mp3 stream, and `icecast2` will serve that to Sonos as a Shoutcast stream.

```bash
$ apt-cache search darkice
darkice - Live audio streamer
darksnow - simple graphical user interface to darkice
$ apt-cache search icecast2
darkice - Live audio streamer
icecast2 - streaming media server
libcry-ocaml-dev - MP3/Ogg Vorbis broadcast OCaml module
pd-pdogg - collection of Ogg/Vorbis objects for Pd
```

Confirms that both packages are available, and *suggests* that formats other than `mp3` may also be available. 

Next, install `darkice` and `icecast2` : 

```bash
$ sudo apt install darkice 
...
$ sudo apt-get install icecast2
...
```

The `icecast2` installation will prompt for several configuration steps. Select `<Yes>` at the configuration screen, then make entries (or select defaults) in the `hostname` and `password` fields: 

... screenshots ...

####2. Create the `/home/pi/darkice.cfg` file:

```bash
$ nano darkice.cfg 
```

Copy and paste the following into the editor window: 

```bash
[general]
duration        = 0      # duration in s, 0 forever
bufferSecs      = 1      # buffer, in seconds
reconnect       = yes    # reconnect if disconnected

[input]
device          = phone   # name of bluetooth device
sampleRate      = 44100   # sample rate 11025, 22050 or 44100
bitsPerSample   = 16      # bits
channel         = 2       # 2 = stereo

[icecast2-0]
bitrateMode     = cbr       # constant bit rate ('cbr' constant, 'abr' average)
#quality         = 1.0       # 1.0 is best quality (use only with vbr)
format          = mp3       # format. Choose 'vorbis' for OGG Vorbis
bitrate         = 320       # bitrate
server          = localhost # or IP
port            = 8000      # port for IceCast2 access
password        = hackme    # source password for the IceCast2 server
mountPoint      = rapi.mp3  # mount point on the IceCast2 server .mp3 or .ogg
name            = BluetoothPi
```

Following is the somewhat opaque explanation for settings in the `darkice.cfg` file: 

> You'll notice the "quality" line is commented out with a # in front of it. It is used only if you set "bitrateMode = vbr" (variable bitrate). You can't have a quality value set when using cbr (constant bitrate) or the stream will stutter and skip. Conversely, if you decide to use vbr then you need to comment out the "bitrate = 160" line and uncomment the "quality" line.

> NOTE: The highest quality mp3 bitrate you can have is 320 kbps; however, both the WiFi and Bluetooth radios on the Raspberry Pi are on the same chip so if you max out the bandwidth of both, bluetooth audio can stutter or freeze. We are going to be changing a setting later that will remedy this however it limits the WiFi bandwidth somewhat so I reduced the audio bitrate for this project to 160 kbps since I plan to keep it on WiFi exclusively. If you are using ethernet it is not an issue and you can safely set the bitrate to 320 kbps.

Since my Raspberry Pi uses Ethernet rather than WiFi, the `darkice.cfg` file specifies a value of `320` for `bitrate`. If you're using WiFi, leave it at `160` - at least for now. 

#### 3. Create the `darkice.sh` file & Schedule it in `cron`:

```bash
$ nano darkice.sh  
```

Copy and paste the following into the editor window: 

```bash
#!/bin/bash
while :; do sudo /usr/bin/darkice -c /home/pi/darkice.cfg; sleep 5; done
```

Set permissions for `darkice.sh`, start the `icecast2` service and schedule `darkice.sh` to start at boot time: 

```bash
$ sudo chmod 777 /home/pi/darkice.sh
$ sudo service icecast2 start  
$ crontab -e 
```

Add the following line to `pi`'s `crontab`: 

```bash
@reboot sleep 15 && /usr/bin/sudo /home/pi/darkice.sh > /home/pi/cronjoblog 2>&1
```

Write out (`^O`) and Exit (`^X`) the editor, then reboot the Raspberry Pi: 

```bash
$ sudo reboot
```





```bash
$ hciconfig -a
hci0:	Type: Primary  Bus: UART
	BD Address: B8:27:EB:67:85:55  ACL MTU: 1021:8  SCO MTU: 64:1
	UP RUNNING 
	RX bytes:778 acl:0 sco:0 events:48 errors:0
	TX bytes:1775 acl:0 sco:0 commands:48 errors:0
	Features: 0xbf 0xfe 0xcf 0xfe 0xdb 0xff 0x7b 0x87
	Packet type: DM1 DM3 DM5 DH1 DH3 DH5 HV1 HV2 HV3 
	Link policy: RSWITCH SNIFF 
	Link mode: SLAVE ACCEPT 
	Name: 'raspberrypi3b'
	Class: 0x000000
	Service Classes: Unspecified
	Device Class: Miscellaneous, 
	HCI Version: 4.2 (0x8)  Revision: 0x118
	LMP Version: 4.2 (0x8)  Subversion: 0x6119
	Manufacturer: Broadcom Corporation (15)
```

 ```bash
$ sudo nano /etc/asound.conf
 ```

Copy and paste the following into the editor - USE YOUR BD ADDRESS, NOT THIS ONE:

```
pcm.phone {
	type plug
	slave.pcm {
		type bluealsa
		device "B8:27:EB:67:85:55"
		profile "a2dp"
	}
}
```

Something is wrong... very wrong


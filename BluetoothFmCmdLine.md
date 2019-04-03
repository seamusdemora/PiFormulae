Verify that the Bluetooth service is running:

```bash
$ service bluetooth status 
```

If the service is NOT running: 

```bash
$ service bluetooth start
...
```

Launch the `bluetoothctl` app & get the `bluetoothctl` prompt.  Note that entering `help` at the prompt will provide a synopsis of all available commands.

```bash
$ sudo bluetoothctl 
...
[bluetooth] power on 
...
[bluetooth] agent on 
...
[bluetoothctl] scan on 
... 
```

If your speakers are within range/turned on/behaving properly/etc the `scan` will list them as a `[NEW] Device`, and then give you the speaker's MAC address in the form XX:XX:…:XX, and device type. Once your speakers have been found in the scan, you may begin the pairing process:

```bash
[bluetoothctl] pair XX:XX:XX:XX:XX:XX 
...
```

For some device classes, you may be prompted to enter a PIN code. For speakers, this code will likely be on a printed label somewhere on the speaker. 

To ensure that the pairing is successful: 

```bash
[bluetoothctl] paired-devices 
```

```
[NEW] Device F4:4E:FD:2A:3C:B6 SoundCore mini
pair F4:4E:FD:2A:3C:B6 
Attempting to pair with F4:4E:FD:2A:3C:B6
[CHG] Device F4:4E:FD:2A:3C:B6 Connected: yes
Request confirmation
[agent] Confirm passkey 231525 (yes/no): yes
[bluetooth]# scan off
Discovery stopped
[bluetoothctl] paired-devices
Device 78:4F:43:A3:27:EA JM MacBook Pro 15"
Device A8:66:7F:4D:1A:B2 JMiPhone (3)
Device F4:4E:FD:2A:3C:B6 SoundCore mini 
[bluetooth]# connect F4:4E:FD:2A:3C:B6
Attempting to connect to F4:4E:FD:2A:3C:B6
Failed to connect: org.bluez.Error.Failed
[bluetooth]# info F4:4E:FD:2A:3C:B6
Device F4:4E:FD:2A:3C:B6
	Name: SoundCore mini
	Alias: SoundCore mini
	Class: 0x240404
	Icon: audio-card
	Paired: yes
	Trusted: no
	Blocked: no
	Connected: no
	LegacyPairing: no
	UUID: Audio Sink                (0000110b-0000-1000-8000-00805f9b34fb)
	UUID: A/V Remote Control Target (0000110c-0000-1000-8000-00805f9b34fb)
	UUID: A/V Remote Control        (0000110e-0000-1000-8000-00805f9b34fb)
	UUID: Handsfree                 (0000111e-0000-1000-8000-00805f9b34fb)
	
[bluetooth]# trust F4:4E:FD:2A:3C:B6
[CHG] Device F4:4E:FD:2A:3C:B6 Trusted: yes
Changing F4:4E:FD:2A:3C:B6 trust succeeded
[bluetooth]# connect F4:4E:FD:2A:3C:B6
Attempting to connect to F4:4E:FD:2A:3C:B6
Failed to connect: org.bluez.Error.Failed 
```

BFH! 

[Possible solution #1](https://unix.stackexchange.com/questions/258074/error-when-trying-to-connect-to-bluetooth-speaker-org-bluez-error-failed) : `sudo apt install pulseaudio-module-bluetooth`  

also, installed: `sudo apt install pulseaudio-module-bluetooth` 

and… `sudo pactl load-module module-bluetooth-discover`

Still no joy :( 

Possible solution #2 : 

```
it's complicated...
```

Which should verify the device is paired by listing its MAC adds and device type.

Posted [question on RPi SE](https://raspberrypi.stackexchange.com/questions/95532/bluetooth-blues), 18 Mar 2019



REFERENCES: 

1. [Pairing from Ubuntu Core](https://docs.ubuntu.com/core/en/stacks/bluetooth/bluez/docs/reference/pairing/outbound.html)  
2. [Introduction to Pairing](https://docs.ubuntu.com/core/en/stacks/bluetooth/bluez/docs/reference/pairing/introduction) 
3. [How to Connect a Bluetooth Speaker to a Laptop](https://www.wikihow.com/Connect-a-Bluetooth-Speaker-to-a-Laptop) 
4. [Bluetooth Educational Kits](https://www.bluetooth.com/develop-with-bluetooth/build/developer-kits?utm_campaign=developer&utm_source=internal&utm_medium=blog&utm_content=bluez-on-pi3) 
5. [Bluetooth on Modern Linux, a YouTube presentation by Szymon Janc](https://www.youtube.com/watch?v=tclS9arLFzk) 
6. [Connect Bluetooth speaker to Raspberry Pi](http://youness.net/raspberry-pi/how-to-connect-bluetooth-headset-or-speaker-to-raspberry-pi-3) 
7. [The OMX Music Player for Raspberry Pi](https://www.raspberrypi.org/documentation/raspbian/applications/omxplayer.md) 
8. [Q&A from RPi SE - Try It](https://raspberrypi.stackexchange.com/a/96087/83790)
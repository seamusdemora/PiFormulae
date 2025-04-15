## The "Music Player" project

#### -- includes reading keyboard input from `/dev/input`

I'm working on a music player project: a "music controller" that accepts input from a small keyboard, and translates that input to commands for `mpd` and `mpc`.  `mpd` (Music Player Daemon) is quite an old project; first released in 2003 according to the [change log](https://raw.githubusercontent.com/MusicPlayerDaemon/MPD/v0.24.3/NEWS). It seems to be fairly unique in the universe of *music players* as it uses a client-server model for its software; `mpd` being the server, and numerous client software including `mpc` which is a product from the same `mpd` team. There is a [Wikipedia article on `mpd`](https://en.wikipedia.org/wiki/Music_Player_Daemon). 

The keyboard will be connected to an "embedded Linux" device (a Raspberry Pi) via USB. This keyboard is to provide the "complete interface" for the music player; the user will not need to "log in" to the "embedded Linux" device to control the music. The keyboard will be similar to the one shown below. 

I've never done anything with keyboards. All the keyboards I've ever used have been full-size keyboards that are plugged into a USB port, and they "just work". I've never given them any thought until now. So I ***begin in the darkness***.  

<img src="https://github.com/seamusdemora/PiFormulae/blob/master/pix/small_kybd.jpg" height="500px" />

### Project overview and research:

This project will use a "headless" Raspberry Pi running the "Lite" distribution. There is no monitor or display to provide visual feedback to the user; in fact users should be able to use the player without ever having to log in.  The user's sole interface to the music player is the keyboard. Each keystroke produces a "message" to be read and translated into a command for the "music player". In this case, the "music controller" is a `bash` script with a bunch of `mpc` commands. 

As usual, this job began with some research :)  

*  These were productive searches: [1](https://duckduckgo.com/?t=ffab&q=linux+how+to+read+input+from+a+device+file%3F&ia=web), [2](https://duckduckgo.com/?t=ffab&q=read+%2Fdev%2Finput+device+file+to+get+keyboard+input&ia=web), [3](https://duckduckgo.com/?q=read+%22%2Fdev%2Finput%22+using+bash&t=ffab&ia=web), [4](https://duckduckgo.com/?q=detect+keyboard+inputs+from+%22%2Fdev%2Finput%22+in+%22bash%22&t=ffab&ia=web). 
*  This [Baeldung article](https://www.baeldung.com/linux/mouse-events-input-event-interface) turned out to be very helpful, though initially it didn't make a lot of sense to *a newbie like* me  :)  
*  [This document](https://www.kernel.org/doc/html/latest/input/input.html) is part of the Linux kernel documentation, but it's *quite a good overview* IMO! [*Comment: This is the "way it goes"... the more you learn, the more things make sense*  :P ] 
*  [This Q&A provided a nearly perfect example](https://unix.stackexchange.com/questions/428399/how-can-i-run-a-shell-script-on-input-device-event), but I didn't discover it until later.  

I now have a reasonably good idea of how to proceed... I have wandered through the darkness, but I am now beginning to see the light. Here's how it went: 

### Reading the keyboard:

`/dev` is always full of surprises. I thought the `tree` command could show me the [*"lay of the land"*](https://idioms.thefreedictionary.com/lay+of+the+land) - and it did. The command output below suggested which device I needed to read from: `/dev/input/event3`:

```
$ tree /dev/input
/dev/input
├── by-id
│   └── usb-045e_Microsoft_Natural_Keyboard_Elite-event-kbd -> ../event3
├── by-path
│   ├── platform-3f902000.hdmi-event -> ../event1
│   └── platform-3f980000.usb-usb-0:1.1.3:1.0-event-kbd -> ../event3
├── event0
├── event1
├── event2
├── event3
└── mice
```

Still completely in the dark, having just read the Baeldung article I Installed the `evemu-tools` package, and used the `evemu-describe` tool to verify that `event3` was the correct device. At this point I do not have the 6-key keyboard, and so have [*scrounged up*](https://idioms.thefreedictionary.com/scrounge+up) an old keyboard, and plugged it into my RPi: 

```
$ sudo evemu-describe
Available devices:
/dev/input/event0:	vc4-hdmi
/dev/input/event1:	vc4-hdmi HDMI Jack
/dev/input/event2:	OontZ Angle solo DS E8B (AVRCP)
/dev/input/event3:	Microsoft Natural Keyboard Elite
Select the device event number [0-3]: 3
```

Next, used `evemu-record` to "record" some keypresses on `/dev/input/event3`. Regarding permissions (need for `sudo`), `ls -l /dev/input` revealed that group `input` was needed by user `pi`. A quick check using `groups pi` showed `pi` belonged to `input`; so no need for `sudo`. : 

```
$ evemu-record /dev/input/event3 
...
E: 0.000001 0004 0004 458772	# EV_MSC / MSC_SCAN             458772
E: 0.000001 0001 0010 0001	# EV_KEY / KEY_Q                1
E: 0.000001 0000 0000 0000	# ------------ SYN_REPORT (0) ---------- +0ms
E: 0.224991 0004 0004 458772	# EV_MSC / MSC_SCAN             458772
E: 0.224991 0001 0010 0000	# EV_KEY / KEY_Q                0
E: 0.224991 0000 0000 0000	# ------------ SYN_REPORT (0) ---------- +224ms
E: 1.130001 0004 0004 458778	# EV_MSC / MSC_SCAN             458778
E: 1.130001 0001 0011 0001	# EV_KEY / KEY_W                1
E: 1.130001 0000 0000 0000	# ------------ SYN_REPORT (0) ---------- +906ms
E: 1.370985 0004 0004 458778	# EV_MSC / MSC_SCAN             458778
E: 1.370985 0001 0011 0000	# EV_KEY / KEY_W                0
```

And so it appears I can now read the keystrokes coming from `/dev/input/event3`! This `evemu-record` output could be `piped` to a `read` statement in `bash`!  

Initially, I had not appreciated that `evemu-record` would do what I needed.  And so continued searches led to other tools/packages to experiment with: a package called `evtest` ([*mentioned here*](https://www.baeldung.com/linux/mouse-events-input-event-interface)) was also installed.  Initially `evtest` [did not look *promising*](https://packages.debian.org/bookworm/evtest) due to this statement: *"evtest is now in maintenance mode"*. However, I subsequently received assurances that `evtest` would likely work fine for this application. 

The Baeldung article was also helpful in showing which methods ***not to use*** for reading the device file. Quite a bit of space was devoted to this - which *confused* me (c'mon, it can't be this arcane!). 

```
$ cat /dev/input/event3
=��gE�=��gE�=��gE�=��gъ=��gъ=��gъ    # hmmm... :) 

$ cat /dev/input/event3 | od -t x1 -w24     # then pressed "q" key:
0000000 7b b5 fc 67 00 00 00 00 6f e7 0d 00 00 00 00 00 04 00 04 00 14 00 07 00
0000030 7b b5 fc 67 00 00 00 00 6f e7 0d 00 00 00 00 00 01 00 10 00 01 00 00 00
0000060 7b b5 fc 67 00 00 00 00 6f e7 0d 00 00 00 00 00 00 00 00 00 00 00 00 00
0000110 7c b5 fc 67 00 00 00 00 1b 97 01 00 00 00 00 00 04 00 04 00 14 00 07 00
0000140 7c b5 fc 67 00 00 00 00 1b 97 01 00 00 00 00 00 01 00 10 00 00 00 00 00
0000170 7c b5 fc 67 00 00 00 00 1b 97 01 00 00 00 00 00 00 00 00 00 00 00 00 00
# then pressed "w" key:
0000000 78 b6 fc 67 00 00 00 00 17 6d 03 00 00 00 00 00 04 00 04 00 1a 00 07 00
0000030 78 b6 fc 67 00 00 00 00 17 6d 03 00 00 00 00 00 01 00 11 00 01 00 00 00
0000060 78 b6 fc 67 00 00 00 00 17 6d 03 00 00 00 00 00 00 00 00 00 00 00 00 00
0000110 78 b6 fc 67 00 00 00 00 f5 e1 05 00 00 00 00 00 04 00 04 00 1a 00 07 00
0000140 78 b6 fc 67 00 00 00 00 f5 e1 05 00 00 00 00 00 01 00 11 00 00 00 00 00
0000170 78 b6 fc 67 00 00 00 00 f5 e1 05 00 00 00 00 00 00 00 00 00 00 00 00 00
# not for me, thanks
```

`man evtest` suggests this form of the command: `evtest [--grab] /dev/input/eventX`; let's give it a try from the terminal: 

```bash
$ kbdev='/dev/input/event3'
$ evtest "$kbdev"
# mucho output confirming device name & a list of "Supported events"; which included:
    Event code 16 (KEY_Q)
    Event code 17 (KEY_W)
# at the end of this report, it waits for keyboard input...
# I pressed the "q" and then the "w" key; here's what I saw:
Testing ... (interrupt to exit)
Event: time 1744618104.560451, type 4 (EV_MSC), code 4 (MSC_SCAN), value 70014
Event: time 1744618104.560451, type 1 (EV_KEY), code 16 (KEY_Q), value 1
Event: time 1744618104.560451, -------------- SYN_REPORT ------------
Event: time 1744618104.761436, type 4 (EV_MSC), code 4 (MSC_SCAN), value 70014
Event: time 1744618104.761436, type 1 (EV_KEY), code 16 (KEY_Q), value 0
Event: time 1744618104.761436, -------------- SYN_REPORT ------------
Event: time 1744618106.026437, type 4 (EV_MSC), code 4 (MSC_SCAN), value 7001a
Event: time 1744618106.026437, type 1 (EV_KEY), code 17 (KEY_W), value 1
Event: time 1744618106.026437, -------------- SYN_REPORT ------------
Event: time 1744618106.243429, type 4 (EV_MSC), code 4 (MSC_SCAN), value 7001a
Event: time 1744618106.243429, type 1 (EV_KEY), code 17 (KEY_W), value 0
Event: time 1744618106.243429, -------------- SYN_REPORT ------------
# This is much better than 'cat' :) 
```

Let's try this in a short script: 

```bash
#!/usr/bin/bash

kbdev='/dev/input/event3'
event_Q='*code 16 (KEY_Q), value 0*'  # trigger on key release (0)
event_W='*code 17 (KEY_W), value 0*'

evtest "$kbdev" | while read line; do
  case $line in
    ($event_Q) echo "Q key released" ;;
    ($event_W) echo "W key released" ;;
  esac
done 
```

A short test showed "this works"! I'll return and resume this once I have the "6-key" keyboard, and have made further progress. 

Until then ...




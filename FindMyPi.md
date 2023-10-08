## What's the IP address of my Raspberry Pi?

This is a frequently-asked question by newcomers - at least those newcomers who are operating in "headless mode". You've bought a Raspberry Pi, burned a Raspbian image to its microSD card, and applied power. That's great, but you would like to connect to the Raspberry Pi at some point! 

You may be missing one important piece of information: What's the IP address of my new RPi? 

```bash
ssh pi@?????????  # WHAT'S THE IP ADDRESS?
```

 I've [attempted to explain what's responsible for this issue](https://github.com/seamusdemora/PiFormulae/blob/master/ThinkingAboutARP.md) in this rumination piece on `arp`, aka the [Address Resolution Protocol](https://en.wikipedia.org/wiki/Address_Resolution_Protocol). And I'll offer a potentially unpopular opinion here: The [RPi organization](https://www.raspberrypi.org/about/) should fix this; at least mitigate the issue. Perhaps the solution would involve the `boot` folder, since it's a FAT partition, and easily readable and writeable by all OS? I'll quit whining now, and get to the business at hand. 

### Maybe you shouldn't care about the IP address! 

Since the introduction of [mDNS or zeroconf networking](https://en.wikipedia.org/wiki/Zero-configuration_networking) and [`avahi`](https://en.wikipedia.org/wiki/Avahi_(software)) in RPi, this has become a "[_non-problem_](https://www.collinsdictionary.com/dictionary/english/nonproblem)" - at least if they're using macOS or Linux hosts to initiate the ssh connection to the RPi. Many macOS users will have [Bonjour](https://en.wikipedia.org/wiki/Bonjour_(software)) "out of the box", and Linux users will also have `avahi` - if it's installed. Even some Windows users may benefit from **zeroconf** if they've [installed Bonjour](https://support.apple.com/downloads/Bonjour_for_Windows), or perhaps iTunes. But then [some Windows users don't want it](https://apple.stackexchange.com/questions/45765/do-i-really-need-bonjour-on-windows). Perhaps the simplest way to learn if you're a beneficiary of **zeroconf** is simply to try this command:  

```bash
ssh pi@raspberrypi.local
```

This often works because `pi` is the default user, and `raspberrypi` is the default hostname. The use of the `.local` suffix chosen by Bonjour and Avahi has been a [bit chaotic, in part because of Microsoft's inconsistent and conflicting support advice to their user base](https://en.wikipedia.org/wiki/.local). However, as **zeroconf** has ["picked up steam"](https://idioms.thefreedictionary.com/pick+up+steam), this seems to be less problematic. 

The [`.local`](https://en.wikipedia.org/wiki/.local) suffix is worth expending a few sentences. First, there are some who seem to fear that the `.local` suffix is a ***security risk?!*** I don't feel this is a valid concern; `.local` is a [**Special Use Domain Name**](https://en.wikipedia.org/wiki/Special-use_domain_name) used for Multicast DNS iaw Section 3 of	RFC 6762. However, [Microsoft has given conflicting advice re the use of `.local`](https://en.wikipedia.org/wiki/.local#Microsoft_recommendations), so Windows users should perhaps pay attention to Microsoft's inconsistent recommendations. 

In Raspberry Pi the use of the `.local` suffix is included in the default configuration for `avahi`, under `/etc/avahi-daemon.conf`. See `man avahi-daemon.conf` for guidance and options, and note the default value: `domain-name=.local`. Also note that it's typically not necessary to edit `/etc/avahi-daemon.conf` as the daemon reads `/etc/hostname`, and (in Debian at least) the `/etc/hosts` file includes an entry for `127.0.1.1` which also typically reflects the hostname.

### IP address discovery

All that said, here's an [approach I outlined in response to a question on StackExchange](https://raspberrypi.stackexchange.com/questions/82837/is-it-possible-to-set-a-static-ip-for-the-first-boot-of-headless-pi-ethernet-gad/82859#82859) some time ago. Here's the "recipe", and some [inline code that I copied from here](https://gist.github.com/blu3Alien/4585961). Finally, if you're interested, [here's some background on why this question gets asked so frequently.](https://github.com/seamusdemora/PiFormulae/blob/master/ThinkingAboutARP.md)

Try this first: 

```
arp -a | grep -E --ignore-case 'b8:27:eb|dc:a6:32'
```


The two hex strings (`b8:27:eb|dc:a6:32`) in this command reflect the two [OUI](https://en.wikipedia.org/wiki/Organizationally_unique_identifier) values used by "The Foundation" for production of all RPi devices - through RPi ver 4B as of this writing. If your RPi isn't in your arp cache this command won't yield anything useful. If that's the case, then create the following file in your favorite editor on your Mac, and save/write it as `pingpong.sh`: 
```
#!/bin/sh

: ${1?"Usage: $0 ip subnet to scan. eg '192.168.1.'"}

subnet=$1
for addr in `seq 0 1 255 `; do
( ping -c 3 -t 5 $subnet$addr > /dev/null ) &
done
arp -a | grep -E --ignore-case 'b8:27:eb|dc:a6:32'
```
make it executable:

```chmod 755 pingpong.sh``` 

and then execute it (use __your__ network address here, not necessarily __192.168.1.__):

```bash pingpong.sh 192.168.1.```

-- or --

```./pingpong.sh 192.168.1.```

Your output may look like this: This output reflects my network; it has 2 RPis connected, and one of them is a 3B+ with WiFi enabled ***and*** the Ethernet port connected to a switch (or router): 
```
? (192.168.1.19) at b8:27:eb:3a:b9:78 on en0 ifscope [ethernet]
? (192.168.1.27) at b8:27:eb:cd:2f:ff on en0 ifscope [ethernet]
? (192.168.1.28) at b8:27:eb:cd:2f:ff on en0 ifscope [ethernet]
```

This case is interesting: My "old" RPi is connected to a Ethernet switch with IP address is `192.168.1.19`. My "new" RPi 3B+ is connected to the same Ethernet switch, and also has its built-in WiFi enabled. It seems wrong that both the Ethernet and the WiFi adapters use the same MAC address! No idea what's going on here, but apparently this is a "feature" of Raspbian since I haven't changed it! 

That's it; knowing the IP address you can now initiate an SSH connection to your RPi. Final note: This script was executed on my MacBook, so YMMV on a different platform. 

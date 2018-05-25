# What's the IP address of my new Raspberry Pi? 

This is likely the most frequently-asked question by newcomers - at least those newcomers who are operating in "headless mode". They've bought a Raspberry Pi, burned a Raspbian image to its microSD card, and applied power. That's great, but most of them would like to connect to their Raspberry Pi at some point. They know they can connect using `SSH`, but what's the IP address of their new RPi? It happens all the time. I've [attempted to explain what's responsible for this issue](https://github.com/seamusdemora/PiFormulae/blob/master/ThinkingAboutARP.md) here. And I'll offer an unpopular opinion here: The RPi organization should fix this; at least mitigate the issue. Perhaps the `boot` folder, since it's a FAT partition, would be a good resource in resolving this issue? I'll quit whining now, and get to the business at hand. 

All that said, here's an [approach I outlined in response to a question on StackExchange](https://raspberrypi.stackexchange.com/questions/82837/is-it-possible-to-set-a-static-ip-for-the-first-boot-of-headless-pi-ethernet-gad/82859#82859) recently. Here's the "recipe", and some [inline code that I copied from here](https://gist.github.com/blu3Alien/4585961). Finally, if you're interested, [here's some background on why this question gets asked so frequently.](https://github.com/seamusdemora/PiFormulae/blob/master/ThinkingAboutARP.md)

Try this first: 

```arp -a | grep --ignore-case b8:27:eb``` 

If your RPi isn't in your arp cache that won't yield anything useful. If that's the case, then create the following file in your favorite editor on your Mac, and save/write it as `pingpong.sh`: 
```
#!/bin/sh

: ${1?"Usage: $0 ip subnet to scan. eg '192.168.1.'"}

subnet=$1
for addr in `seq 0 1 255 `; do
( ping -c 3 -t 5 $subnet$addr > /dev/null ) &
done
arp -a | grep b8:27:eb
```
make it executable:

```chmod 755 pingpong.sh``` 

and then execute it (use __your__ network address here, not necessarily __192.168.1.__):

```bash pingpong.sh 192.168.1.```

-- or --

```./pingpong.sh 192.168.1.```

Your output should look like this (if you have 2 RPis on .local, and one of them is a 3B+ with WiFi enabled and Ethernet port connected to your switch or router): 
```
? (192.168.1.19) at b8:27:eb:3a:b9:78 on en0 ifscope [ethernet]
? (192.168.1.27) at b8:27:eb:cd:2f:ff on en0 ifscope [ethernet]
? (192.168.1.28) at b8:27:eb:cd:2f:ff on en0 ifscope [ethernet]
```

And so, this case is interesting: My "old" RPi is connected to a Ethernet switch and its IP address is `192.168.1.19`. My "new" RPi 3B+ is connected to the same Ethernet switch, and also has its built-in WiFi enabled. It seems wrong that both the Ethernet and the WiFi adapters use the same MAC address, but this is "by design" since I haven't changed it! 

And that's it; now you can initiate an SSH connection to your RPi. Final note: This code was executed on my MacBook, so YMMV on a different platform.

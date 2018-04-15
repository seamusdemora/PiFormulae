As typical, this page will be a placeholder for half-baked recipes and/or code to do something useful. The intention is to return here and `finish up` soon :) That said, here's an [approach I outlined in response to a question on StackExchange](https://raspberrypi.stackexchange.com/questions/82837/is-it-possible-to-set-a-static-ip-for-the-first-boot-of-headless-pi-ethernet-gad/82859#82859) just now. Here's the "recipe", and some [inline code that I copied from here](https://gist.github.com/blu3Alien/4585961). 

Try this first: 

>arp -a | grep --ignore-case b8:27:eb 

If your RPi isn't in your arp cache that won't yield anything useful. If that's the case, then create the following file in your editor, save it as `pingpong.sh`: 

    #!/bin/sh

    : ${1?"Usage: $0 ip subnet to scan. eg '192.168.1.'"}

    subnet=$1
    for addr in `seq 0 1 255 `; do
    #   ( echo $subnet$addr)
    ( ping -c 3 -t 5 $subnet$addr > /dev/null && echo $subnet$addr is Alive ) &
    done

make it executable:

> chmod 755 ~/pingpong.sh 

and then execute it (use __your__ network address here, not necessarily __192.168.1.__:

> ~/pingpong.sh 192.168.1. 

Your output should look like this: 

        192.168.1.11 is Alive
        192.168.1.19 is Alive
        192.168.1.28 is Alive
        ...
        192.168.1.255 is Alive
        192.168.1.0 is Alive

Now, your RPi should be in your arp cache, so run `arp` as before: 

> arp -a | grep --ignore-case b8:27:eb 

And you should then see something like this: 

    ? (192.168.1.19) at b8:27:eb:3a:b9:78 on en0 ifscope [ethernet]

And so, for this case, the IP address of your RPi is `192.168.1.19`

This code was executed on my MacBook, so YMMV on a different platform.

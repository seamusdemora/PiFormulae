## Find my IP addresses from command line or a script

It's useful to know what IP addresses have been assigned to your network Interfaces, and keep tabs on that. Reporting a host's IP address can be automated via a `bash` script, and that script can be scheduled to run periodically with `cron` or under `systemd`. Here are the essentials: 

You should use `ip` (instead of `ifconfig`) as it's current, maintained, and perhaps most importantly for scripting purposes, it produces a consistent & parsable output. Following are a few similar approaches: 

If you want the IPv4 address for your Ethernet interface `eth0`: 
```  bash
$ ip -4 -o addr show eth0 | awk '{print $4}'
192.168.1.166/24  
```

Or, as a script: 
```bash
#! /usr/bin/bash
INTFC=wlan0
MYIPV4=$(ip -4 -o addr show $INTFC | awk '{print $4}')
echo $MYIPV4
```
Which will give the following output when run:
```
192.168.1.166/24
```
The output produced above is in [CIDR notation.](https://whatismyipaddress.com/cidr) If CIDR notation isn't wanted, it can be stripped: 
```  bash
$ ip -4 -o addr show eth0 | awk '{print $4}' | cut -d "/" -f 1 
192.168.1.166  
```

Another option that IMHO is "most elegant" gets the IPv4 address for whatever interface is used to connect to the specified remote host (8.8.8.8 in this case). Courtesy of @gatoatigrado in [this answer](https://stackoverflow.com/questions/12474172/how-to-find-network-interface-name): 

``` bash
$ ip route get 8.8.8.8 | awk '{ print $NF; exit }'
192.168.1.166
```

Or, as a script: 
``` bash
#! /usr/bin/bash
RHOST=8.8.8.8  
MYIP=$(ip route get $RHOST | awk '{ print $NF; exit }')
echo $MYIP
```
This works perfectly well on a host with a single interface, but more advantageously will also work on hosts with multiple interfaces and/or route specifications.  

`ip` would be my preferred approach, but it's certainly not the only way to skin this cat - nor the simplest. Here's another approach that uses `hostname` if you prefer something easier/more concise: 

``` bash
#! /usr/bin/bash
# simplest for single interface system:
hostname -I
# for multiple interface systems:
hostname --all-ip-addresses | awk '{print $1}'  
```

Or, if you want the IPv6 address: 
```  bash
#! /usr/bin/bash
hostname --all-ip-addresses | awk '{print $2}'  
```


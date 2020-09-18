## HOW TO: Disable/Enable ping response in Linux

Few days ago I was dealing with **SYSCTL** (man sysctl)  utility and I was looking for a certain kernel parameter, I wish to set  it on the fly and I've found other useful information too.

sysctl is used to modify kernel parameters at runtime, one of these  parameter could be ping daemon response, if you want to disable ping  reply on your network you just simply need to issue something like:

```bash
$ sudo sysctl -w net.ipv4.icmp_echo_ignore_all=1 
net.ipv4.icmp_echo_ignore_all = 1 
$ 
```

Now try to ping your machine, you'll get no replies at all.
To  re-enable ping replies: 

```bash
$ sudo sysctl -w net.ipv4.icmp_echo_ignore_all=0
net.ipv4.icmp_echo_ignore_all = 0
$
```

The `-w` flag is used if you want to change some settings, take a look at kernel flags you can set at runtime (linux sources) 



------

OTHER REFERENCES:

[How to Change Kernel Runtime Parameters in a Persistent and Non-Persistent Way](https://www.tecmint.com/change-modify-linux-kernel-runtime-parameters/) 

[Use /proc/sys and sysctl to modify and set kernel runtime parameters](https://www.rootusers.com/use-procsys-and-sysctl-to-modify-and-set-kernel-runtime-parameters/) 

[Q&A: Change kernel parameters at runtime](https://unix.stackexchange.com/a/123050/286615) 

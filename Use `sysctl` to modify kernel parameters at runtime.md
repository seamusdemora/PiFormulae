## Example: using `sysctl` to Disable/Enable `ping` replies 

Dealing with the **`sysctl`** (`man sysctl`)  utility recently,  looking for a certain kernel parameter I wish to set  it on the fly. I've found other useful information:

`sysctl` is used to modify kernel parameters at runtime. As an example, one of these  kernel parameters controls the system's response to a `ping` issued from another host. If you want to disable `ping`  responses, you can do that with `sysctl`:

```bash
$ sudo sysctl -w net.ipv4.icmp_echo_ignore_all=1 
net.ipv4.icmp_echo_ignore_all = 1 
$ 
```

Now try to `ping` your machine, to verify it does not respond.
Afterwards, to  re-enable `ping` replies: 

```bash
$ sudo sysctl -w net.ipv4.icmp_echo_ignore_all=0
net.ipv4.icmp_echo_ignore_all = 0
$
```

The `-w` flag is used if you want to change some settings. `sysctl` will also provide a list of all kernel parameters on your system that can set at runtime:

```bash
$ sysctl -a
```





------

OTHER REFERENCES:

[How to Change Kernel Runtime Parameters in a Persistent and Non-Persistent Way](https://www.tecmint.com/change-modify-linux-kernel-runtime-parameters/) 

[Use /proc/sys and sysctl to modify and set kernel runtime parameters](https://www.rootusers.com/use-procsys-and-sysctl-to-modify-and-set-kernel-runtime-parameters/) 

[Q&A: Change kernel parameters at runtime](https://unix.stackexchange.com/a/123050/286615) 

### How To Find the Hardware Version of a Raspberry Pi

1. Get the "Revision" value from /proc/cpuinfo as follows: 

```
$ grep Revision /proc/cpuinfo
```

2. Consult: [RPi_HardwareHistory webpage](https://elinux.org/RPi_HardwareHistory)

	Enter the table using the "Revision" value from Step 1. 
	
3. Alternatively, to avoid the chore of looking up the designation from the Revision value: 

```bash
$ cat /proc/device-tree/model && echo
```

​        Which will yield something like: 

> Raspberry Pi 4 Model B Rev 1.1

​        Note that the purpose of the `echo` here is simply to add a newline. 
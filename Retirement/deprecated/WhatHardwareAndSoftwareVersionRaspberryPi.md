### How To Find the Hardware & Software Version of a Raspberry Pi

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

>​         Raspberry Pi 4 Model B Rev 1.1

​        Note that the purpose of the `echo` here is simply to add a newline. 

4. Get the OS version: 

```bash
$ cat /etc/os-release 
```

​        Which will yield something like this: 

    PRETTY_NAME="Raspbian GNU/Linux 9 (stretch)"
    NAME="Raspbian GNU/Linux"
    VERSION_ID="9"
    VERSION="9 (stretch)"
    VERSION_CODENAME=stretch
    ID=raspbian
    ID_LIKE=debian
    HOME_URL="http://www.raspbian.org/"
    SUPPORT_URL="http://www.raspbian.org/RaspbianForums"
    BUG_REPORT_URL="http://www.raspbian.org/RaspbianBugs"

5. Get the *"system information"*, incl. kernel version: 

```
$ uname -a    # get all available system information
Linux raspberrypi3b 4.19.66-v7+ #1253 SMP Thu Aug 15 11:49:46 BST 2019 armv7l GNU/Linux
$ uname -s    # kernel name
Linux
$ uname -n    # network node hostname
raspberrypi3b
$ uname -r    # kernel release
4.19.66-v7+
$ uname -v    # kernel version
#1253 SMP Thu Aug 15 11:49:46 BST 2019
$ uname -m    # machine hardware name
armv7l
$ uname -p    # processor type
unknown
$ uname -i    # hardware platform
unknown
$ uname -o    # operating system
GNU/Linux
```



<hr>

### REFERENCES:

1. [Get Raspberry Pi Hardware Model Designation](https://www.unixtutorial.org/command-to-confirm-raspberry-pi-model) 
2. [Q&A, SE: How can I determine which OS image I am running?](https://raspberrypi.stackexchange.com/questions/6974/how-can-i-determine-which-os-image-i-am-running) 


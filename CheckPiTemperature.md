## Getting the Operating Temperature of a Raspberry Pi

The "official" Raspberry Pi documentation defines available methods for [monitoring core temperatures](https://www.raspberrypi.com/documentation/computers/config_txt.html#monitoring-core-temperature).

#### Get the temperature of the GPU and CPU:

The [`vcgencmd` utility](https://www.raspberrypi.org/documentation/raspbian/applications/vcgencmd.md) will provide the temperature of the GPU module on the RPi. Note that it will provide other data also.

```bash
$ vcgencmd measure_temp
temp=53.0'C
```

The temp of the CPU is found in a file: `/sys/class/thermal/thermal_zone0/temp` 

The value recorded here is 1,000 ***x*** the temp in °C. Here's one way to get the temp from the contents of this file: 

```bash
$ cpu=$(</sys/class/thermal/thermal_zone0/temp)
$ echo "$((cpu/1000))°C"
56°C
```

Which will give a [*truncated*](https://techterms.com/definition/truncate) integer value. Calculating a [real number](https://en.wikipedia.org/wiki/Real_number) can be done using the `calc` command. If `calc` isn't available, it can be installed as follows:  

```
$ sudo apt-get install apcalc
```

And the calculation is then performed as follows: 

```bash
$ calc $(</sys/class/thermal/thermal_zone0/temp)/1000
53.556
```

#### There is a *new* temperature available:

According to [this source](https://pip.raspberrypi.com/categories/685-whitepapers-app-notes/documents/RP-004340-WP/Extra-PMIC-features-on-Raspberry-Pi-4-and-Compute-Module-4.pdf), there's an option in `vcgencmd` that reads the internal temperature of the PMIC (Power Mgt IC) [e.g. the RPi 4 PMIC](https://www.maxlinear.com/Company/press-releases/2019/MaxLinear%E2%80%99s-MxL7704-PMIC-Powers-the-Raspberry-Pi-4), for the RPi 4 & RPi 5 models. However, the following command reports ***something*** on all RPi models:

```bash
$ vcgencmd measure_temp pmic
temp=52.4'C
```

#### That's a lot of commands to get the temperature - is there an easier way? 

Of course - define a *function* in `~/.bashrc`<sup id="a1">[Note 1](#f1)</sup>: 

```bash
pitemp () {
printf %'s\n' "PMIC temperature: $(vcgencmd measure_temp pmic | grep -o [0-9][0-9]\.[0-9])°C"
printf %'s\n' "GPU temperature: $(vcgencmd measure_temp | grep -o [0-9][0-9]\.[0-9])°C"
printf %'s\n' "CPU temperature: $(calc -p $(</sys/class/thermal/thermal_zone0/temp)/1000)°C"
}
```

Edit `~/.bashrc` to add this function, then `source` it, and run it: 

 ```bash
$ source .bashrc    
# OR, IF YOU PREFER: 
$ . ~/.bashrc 	# This also sources .bashrc to your current shell
$ pitemp
PMIC temperature: 51.4°C
GPU temperature: 52.0°C
CPU temperature: 54.043°C
$
 ```

---

<b id="f1">Note 1:</b> If you have more than a few aliases (or functions), you may find it preferable to put them in a separate file; e.g. `~/.bash_aliases`. Why? Frequent edits to `~/.bashrc` may result in accidental changes that affect `bash` default behavior, and restoring it might be difficult - the restoration will certainly require more of your time! Therefore, placing your aliases and functions in `~/.bash_aliases` may be a better approach. Note also that the filename `~/.bash_aliases` works **because** this filename is defined in `~/.bashrc` as follows: 

```bash
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
```

This ensures that each time `~/.bashrc` is *sourced*, `~/.bash_aliases` is also *sourced*. And yes, you can add or change this to include whatever filenames you wish to use; `~/.bash_functions`, or `~/.bash_prototypes`, or *whatever*.  [↩](#a1) 

---

### ADDENDUM:

And speaking of **Raspberry Pi 4B** and temperature, know this: [*"The Organization"*](https://www.raspberrypi.org/) announced a [*new firmware build for the USB3 host adapter that should save about 300mW*](https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=243500&p=1490467&hilit=vl805#p1490467). This was eventually applied through the routine `apt-get upgrade` process, and you may not have noticed it. If you're wondering whether the fix has been applied, it's easy to check: 

```
# in May, 2020, you would've seen this on an RPi 4:
$ sudo rpi-eeprom-update
BCM2711 detected
BOOTLOADER: up-to-date
CURRENT: Thu 16 Apr 17:11:26 UTC 2020 (1587057086)
 LATEST: Thu 16 Apr 17:11:26 UTC 2020 (1587057086)
 FW DIR: /lib/firmware/raspberrypi/bootloader/critical
VL805: up-to-date
CURRENT: 000137ad
 LATEST: 000137ad

# in Jul, 2024, you would have seen this on an RPi 4 ('bullseye'):
$ sudo rpi-eeprom-update
BOOTLOADER: up to date
   CURRENT: Wed 11 Jan 17:40:52 UTC 2023 (1673458852)
    LATEST: Wed 11 Jan 17:40:52 UTC 2023 (1673458852)
   RELEASE: default (/lib/firmware/raspberrypi/bootloader/default)
            Use raspi-config to change the release.

  VL805_FW: Dedicated VL805 EEPROM
     VL805: up to date
   CURRENT: 000138c0
    LATEST: 000138c0

# in Jul, 2024, you would have seen this on an RPi 5 ('bookworm'):
$ sudo rpi-eeprom-update
BOOTLOADER: up to date
   CURRENT: Wed  5 Jun 15:41:49 UTC 2024 (1717602109)
    LATEST: Wed  5 Jun 15:41:49 UTC 2024 (1717602109)
   RELEASE: default (/lib/firmware/raspberrypi/bootloader-2712/default)
            Use raspi-config to change the release.
```

If the command fails, or if you get a different output, you may need to run the upgrade process. 

*The Organization* did thermal testing on this firmware. Their [test results were briefed in this blog post](https://www.raspberrypi.org/blog/thermal-testing-raspberry-pi-4/?from=hackcv&hmsr=hackcv.com). The blog highlights the improvements of the various firmware upgrades, and explains that the power-dissipation management firmware can be gotten through the normal `apt full-upgrade` process.

---

### REFERENCES:

 [How to Benchmark a Raspberry Pi Using Vcgencmd, Oct, 2023](https://www.tomshardware.com/how-to/raspberry-pi-benchmark-vcgencmd); outlines numerous uses for the `vcgencmd` utility.
 
 [Q&A: Alias quotation and escapes](https://raspberrypi.stackexchange.com/questions/111889/alias-quotation-and-escapes); setting up aliases and functions for getting the temperature. 

[Q&A: Why is Raspberry Pi 3B / 3B+'s CPU temperature precision 0.538°C?](https://raspberrypi.stackexchange.com/questions/95389/why-is-raspberry-pi-3b-3bs-cpu-temperature-precision-0-538c) 

[Q&A: Raspberry Pi tolerance towards high temperature](https://raspberrypi.stackexchange.com/questions/98485/raspberry-pi-tolerance-towards-high-temperature) 

[How to find out Raspberry Pi GPU and ARM CPU temperature on Linux](https://www.cyberciti.biz/faq/linux-find-out-raspberry-pi-gpu-and-arm-cpu-temperature-command/) 


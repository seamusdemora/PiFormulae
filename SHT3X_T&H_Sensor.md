## Using Sensiron's SHT3X Temp/Humidity Sensors

This recipe outlines (what I feel is) the *simplest*, and most *straightforward* use of Sensiron's ubiquitous temperature and humidity sensors. This recipe was developed on a RPi 3A+ running an *up-to-date* 64-bit version of the RPi OS 'bookworm'. Here we use a *shell script* to **set** control parameters, and **get** temperature & humidity readings from `sysfs`. 

| ![SHT3x_chip](./pix/SHT3x_chip.png)     | ![SHT3x-module-2](./pix/SHT3x-module-2.jpg)   |
| --------------------------------------- | --------------------------------------------- |
| ![SHT3x-module](./pix/SHT3x-module.jpg) | ![SHT3x-w-display](./pix/SHT3x-w-display.jpg) |

For those wondering *WTFIGO* wrt use of `sysfs`, I'm afraid I have no explanation. Like everyone else, I heard that the Linux kernel maintainers had finally pushed `sysfs` usage into oblivion - some 6 years after they elected to deprecate it. Yet, here it is - and looking none the worse for wear! In fact, the *key piece* of documentation that enables this recipe was found in the [kernel documentation](https://www.kernel.org/doc/html/latest/hwmon/sht3x.html)! Clearly, there is a lot I don't know about `sysfs`. And while the kernel documentation made perfectly clear ***how*** the SHT3X interface was implemented, it was completely silent on ***where*** to find the proper folder. For that, I had to resort to *digging around*.   

But enough of that, let's get into the recipe: 

### 1. The first step is to connect the sensor to the RPi: 

The schematic is simple: 2 wires for power, and two wires for I2C. **PLEASE NOTE** that I am using `i2c0` for this SHT3X connection; this due to the fact that the default `i2c1` was not in use/not available on this particular RPi 3A+. You may use any `i2cX` channel available for your RPi; simply watch out for commands including a specific reference to `i2c0`, and adjust accordingly.  

<!-- Begin schematic: In order to preserve an editable schematic, please
     don't edit this section directly.
     Click the "edit" link below the image in the preview instead. -->

![schematic](https://i.sstatic.net/mLq5TW5D.png)

<!-- End schematic -->

### 2. The second step is to declare an `overlay`:  

Run `raspi-config`; in the `Interfaces` section, ensure that the I2C interface is enabled. Open file `/boot/firmware/config.txt` (for RPi OS 'bookworm', or `/boot/config.txt` in prior versions of the OS)   in your editor, and add the following lines. You will need to `reboot` after making these changes:

```bash
dtoverlay=i2c0 

dtoverlay=i2c-sensor,i2c0,sht3x
```

### 3. Consult the documentation for details:

Sensiron's website is a great source for documentation on the SHT3X. You will find [application & driver software](https://sensirion.com/products/catalog/SHT30-DIS-F) here, but we will not require that for this example. 

Instead, we will use documentation for the Linux kernel; specifically: [the driver documentation for the SHT3x](https://www.kernel.org/doc/html/latest/hwmon/sht3x.html) (prepared by Sensiron staff). This document contains the `sysfs` interface documentation, and is **the key** for using the sensor. It **does not** explain exactly where in `/sys` these interface files are found, but a bit of *digging around* on my RPi 3A+, and reading [this document](https://www.kernel.org/doc/html/latest/i2c/i2c-sysfs.html) revealed its location to be as follows: 

```bash
$ cd /sys/devices/platform/soc/3f205000.i2c/i2c-0/0-0044/hwmon/hwmon3

$ ls -l 
lrwxrwxrwx 1 root root    0 May 31 20:01 device -> ../../../0-0044
-rw-r--r-- 1 root root 4096 May 31 20:01 heater_enable
-r--r--r-- 1 root root 4096 May 31 20:01 humidity1_alarm
-r--r--r-- 1 root root 4096 May 31 20:01 humidity1_input
-rw-r--r-- 1 root root 4096 May 31 20:01 humidity1_max
-rw-r--r-- 1 root root 4096 May 31 20:01 humidity1_max_hyst
-rw-r--r-- 1 root root 4096 May 31 20:01 humidity1_min
-rw-r--r-- 1 root root 4096 May 31 20:01 humidity1_min_hyst
-r--r--r-- 1 root root 4096 May 31 20:01 name
lrwxrwxrwx 1 root root    0 May 31 20:01 of_node -> ../../../../../../../../firmware/devicetree/base/soc/i2c@7e205000/sht3x@44
drwxr-xr-x 2 root root    0 May 31 20:01 power
-rw-r--r-- 1 root root 4096 May 31 20:01 repeatability
lrwxrwxrwx 1 root root    0 May 31 20:01 subsystem -> ../../../../../../../../class/hwmon
-r--r--r-- 1 root root 4096 May 31 20:01 temp1_alarm
-r--r--r-- 1 root root 4096 May 31 20:01 temp1_input
-rw-r--r-- 1 root root 4096 May 31 20:01 temp1_max
-rw-r--r-- 1 root root 4096 May 31 20:01 temp1_max_hyst
-rw-r--r-- 1 root root 4096 May 31 20:01 temp1_min
-rw-r--r-- 1 root root 4096 May 31 20:01 temp1_min_hyst
-rw-r--r-- 1 root root 4096 May 31 19:34 uevent
-rw-r--r-- 1 root root 4096 May 31 20:01 update_interval
```

Which we see matches the [kernel documentation for the SHT3X](https://www.kernel.org/doc/html/latest/hwmon/sht3x.html). 

Note also that the directory name reflects my use of `i2c0` - instead of the default `i2c1`. You should adjust the location if you're using another I2C channel. 

### 4. A "one-shot" script to see some T&H readings

The availability of the [driver documentation](https://www.kernel.org/doc/html/latest/hwmon/sht3x.html) and `sysfs` interface description provide for a very **straightforward** method to control the sensor, and take readings from it. This may perhaps be done most simply using a shell script to read/write the `sysfs` files; a script that performs a ***"one-shot"*** reading is shown below: 

```bash
#!/usr/bin/bash
# read Temp & Humidity from the 'temp1_input' & 'humidity1_input' files
cd /sys/class/hwmon/hwmon2

# Fahrenheit = (Celsius * 1.8) + 32

denominator=1000
temp_c=$(< temp1_input)
t_c=$(echo "scale=1; $temp_c / $denominator" | bc)
t_f=$(echo "scale=1; ($t_c * 1.8) + 32" | bc)
# echo -e "$t_c deg C\t$t_f deg F"

humid_r=$(< humidity1_input)
h_r=$(echo "scale=1; $humid_r / $denominator" | bc)
# echo "$h_r per cent"

printf "Temperature: %4.1f deg C, %5.1f deg F\tHumidity: %4.1f %% relative humidity\n" $t_c $t_f $h_r


```

This script reads temperature and humidity measured by the sensor; each run yields one measurement each for temperature & humidity. 

Note the use of [`bc` (basic calculator)](https://www.gnu.org/software/bc/manual/html_mono/bc.html) in the script; it's here because `bash` doesn't do *floating point numbers* - only integers. The somewhat *odd syntax* here is due to the fact that `bc` is actually an *interactive* calculator. You may need to install `bc` (using `apt`) as it's not included in all distros. If you prefer *reverse Polish notation* (a former H-P calculator user?), you may opt for [`dc`](https://www.gnu.org/software/bc/manual/dc-1.05/html_mono/dc.html).  If you want *floating point* calculations in your shell script by another means, I'd suggest [this excellent article](https://www.baeldung.com/linux/shell-round-floating-point-numbers), or [this one](https://www.howtogeek.com/floating-point-math-in-linux-bash/) for alternatives to `bc` and `dc`. 

Once again, the script above is for *one-shot* readings. If you prefer to monitor & update periodically, you may prefer a *daemon*-style script that runs in the background; perhaps writing its results to a log, or driving a small display. For a daemon, you may want to use several of the other parameter files; for example, `update_interval` and/or `repeatability`. You can also set high and low alarms for temperature and humidity - even supply hysteresis settings. We'll leave those for another day :) 


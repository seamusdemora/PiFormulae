### Device Tree Experiments 

I wanted to experiment with the [character device API for GPIO](https://elinux.org/images/c/cb/Linux_GPIO-Evolution_and_Current_State_of_the_User_API.pdf), so I installed [`gpiod`](https://www.ics.com/blog/gpio-programming-exploring-libgpiod-library) on my RPi 3B+/bullseye.   I hit a snag with my first command:

```bash
$ sudo apt-get install gpiod
# ...
$ gpioinfo
gpiochip0 - 54 lines:
	line   0:      unnamed       unused   input  active-high
	line   1:      unnamed       unused   input  active-high
	line   2:      unnamed       unused   input  active-high
	line   3:      unnamed       unused   input  active-high
...
	line  52:      unnamed       unused   input  active-high
	line  53:      unnamed       unused   input  active-high
gpiochip1 - 8 lines:
	line   0:      unnamed       unused  output  active-high
	line   1:      unnamed       unused  output  active-high
	line   2:      unnamed       "led1"  output   active-low [used]
	line   3:      unnamed       unused  output  active-high
	line   4:      unnamed       unused   input  active-high
	line   5:      unnamed "cam1_regulator" output active-high [used]
	line   6:      unnamed       unused  output  active-high
	line   7:      unnamed       unused   input  active-high
```

Every line being listed as `unnamed` didn't look like a promising start. On my RPi 4B however, all the lines had `pin names`. Some research turned up a [discussion on GitHub](https://github.com/raspberrypi/linux/issues/2760) explaining the cause for this: no updates had been made for older RPi models. 

A link was given to a source for the [RPi 3B+ dts file](https://github.com/raspberrypi/linux/blob/rpi-5.15.y/arch/arm/boot/dts/bcm2710-rpi-3-b-plus.dts), and it was suggested that anyone interested in *pin names* for an unsupported model was welcome to update the `dts` file & recompile it with a kernel that would read it properly. This sounded like a fair amount of work for a lazy man, and I wondered if it might be easier to add the pin names with a *device tree overlay*? I decided to try:

I've been curious about the ***device tree*** for a while, but my only experience with it has been limited to adding an occasional ***overlay*** specification to `/boot/config.txt`. Some overlays have piqued my curiosity, and motivated me - briefly - to learn more, but after looking at the *overlay source code*, that motivation melted - the code struck me as *impenetrably arcane*. And getting [smacked down on the RPi forum](https://forums.raspberrypi.com/viewtopic.php?t=330552#p1978724) didn't help either. But sometimes, disparaging remarks are motivational, and finally - trial and error yielded a result that seems to get the job done - **an overlay that adds pin names to the RPi 3b+ :** 



The following suggests that this overlay seems to  work! Copy the [source file]((source/3BP_pin_name_overlay.dts)) to your RPi 3B+, and follow these steps to compile, add and test it: 

```bash
$ dtc -@ -Hepapr -I dts -O dtb -o 3BPpin_nm.dtbo 3BP_pin_name_overlayRev1.dts 
$ sudo cp 3BPpin_nm.dtbo /boot/overlays 

# Add the following line to `boot/config.txt`: 
dtoverlay=3BPpin_nm
#
$ sudo reboot 
... # following the reboot: 
$ gpioinfo
gpiochip0 - 54 lines:
	line   0:     "ID_SDA"       unused   input  active-high
	line   1:     "ID_SCL"       unused   input  active-high
	line   2:       "SDA1"       unused   input  active-high
	line   3:       "SCL1"       unused   input  active-high
...
	line  52: "SD_DATA2_R"       unused   input  active-high
	line  53: "SD_DATA3_R"       unused   input  active-high
gpiochip1 - 8 lines:
	line   0:      "BT_ON"       unused  output  active-high
	line   1:      "WL_ON"       unused  output  active-high
	line   2:  "PWR_LED_R"       "led1"  output   active-low [used]
	line   3:    "LAN_RUN"       unused  output  active-high
	line   4:         "NC"       unused   input  active-high
	line   5:  "CAM_GPIO0" "cam1_regulator" output active-high [used]
	line   6:  "CAM_GPIO1"       unused  output  active-high
	line   7:         "NC"       unused   input  active-high
```

If you encounter any issues adapting this to your model of RPi, make a comment in the [Issues section here](https://github.com/seamusdemora/PiFormulae/issues). I may or may not be able to help, but promise you won't get a smackdown! 

---

### REFERENCES & NOTES:

Nothing particularly useful for others here, but I added this for my benefit since the `device tree` coding, syntax and resources are not very well documented in the [RPi documentation](https://www.raspberrypi.com/documentation/computers/configuration.html#part1) (*IMHO*). 

1. [Device Tree What it Is](https://elinux.org/Device_Tree_What_It_Is) 
1. [Device Tree Reference](https://elinux.org/Device_Tree_Reference) 
1. [Linux and the Devicetree](https://www.kernel.org/doc/html/latest/devicetree/usage-model.html) 

##### From an end-to-end review of the [Device Tree forum](https://forums.raspberrypi.com/viewforum.php?f=107), some items that attracted my attention: 

*  Note: The `dtoverlay` command allows overlays to be applied at runtime (some more successfully than others). And using the -h option is useful for reading helpful details from `/boot/overlays/README.`[REF](https://forums.raspberrypi.com/viewtopic.php?t=154240&sid=c60e827f81e206d06e23e8cc4f895532) 

* Related to above: [Dynamic device tree  LED](https://forums.raspberrypi.com/viewtopic.php?t=175267&sid=ba00bcd4a924247d7a002ec6a984fdd9#p1118474) 

* [Tips for debugging overlays](https://forums.raspberrypi.com/viewtopic.php?t=186438&sid=8b81712a7d2a3b98ad16928961958347#p1177179) 

* [How to handle more than one device](https://forums.raspberrypi.com/viewtopic.php?t=178721#p1138555) - e.g. multiple i2c devices on single bus? 

* [how to trigger an action when input signal is detected](https://forums.raspberrypi.com/viewtopic.php?t=185571#p1172620) - fuzzy, but potentially useful 

* [GPIO set high/low with dtoverlays](https://forums.raspberrypi.com/viewtopic.php?t=192763#p1208274) - In summary, overlays can't set GPIO pin state at boot, but dtb can!

* [PWM without root access](https://forums.raspberrypi.com/viewtopic.php?t=194174#p1216065) - not re DT, but some info for PWM usage 

* [phandle problems with machine driver](https://forums.raspberrypi.com/viewtopic.php?t=195553#p1223630) - note diff in "target" & "target-path"; `target = <&i2c1>;` 

* [Device Tree Overlays Using New libgpiod API?](https://forums.raspberrypi.com/viewtopic.php?t=209467&sid=b151860bbc80a36d97f06b3a025c28b8#p1309336) - see links for libgpiod tools & code 

* [Adding Device Tree to EEPROM config file.](https://forums.raspberrypi.com/viewtopic.php?t=197030&sid=b151860bbc80a36d97f06b3a025c28b8#p1231442) - how to put your overlays into EEPROM (Pi4 only) 

* [Two drivers using same gpio pin](https://forums.raspberrypi.com/viewtopic.php?t=208574&sid=b151860bbc80a36d97f06b3a025c28b8#p1314710) - follow-up on this... ***sounds*** useful 

* [Confirmation of gpio-poweroff Behavior](https://forums.raspberrypi.com/viewtopic.php?t=201483#p1253978) 

* [What is the KEY_POWER event in DT?](https://forums.raspberrypi.com/viewtopic.php?t=234465) - I still don't know

* [disable dtoverlay from command line](https://forums.raspberrypi.com/viewtopic.php?t=252334#p1539960) 

* [Re: RPi4 Ethernet LED control](https://forums.raspberrypi.com/viewtopic.php?t=252057#p1599713) - a dtparam to turn off Ethernet LEDs 

* [Cant turn off Power LED on Rasp Pi 4 Model B](https://forums.raspberrypi.com/viewtopic.php?t=279758#p1694494) - oh yes, you can! 

* [Debugging device tree with yocto](https://forums.raspberrypi.com/viewtopic.php?t=305144#p1825795) - some debugging intellegence 

* [Re: Set default state of GPIO to High on boot using Device Tree.](https://forums.raspberrypi.com/viewtopic.php?t=306585#p1836635) - evolution of the `gpio-led` overlay 

* The so-called `runtime overlay mechanism`: what is it? see `man dtoverlay` 

* [Understanding the behaviour of device tree compatible](https://forums.raspberrypi.com/viewtopic.php?t=307802#p1841518) - in summary, `compatible` is meaningless 

* [ethernet phandle in overlay](https://forums.raspberrypi.com/viewtopic.php?t=309434#p1850833) - however, the `phandle` is important 

* [Re: Supported RTCs in Device Tree](https://forums.raspberrypi.com/viewtopic.php?t=305248#p1826475) - how-to: loading & unloading kernel modules 

* [DS3234 RTC Device Tree overlay](https://forums.raspberrypi.com/viewtopic.php?t=309814#p1852837) - worthy of study - add RTC for SPI i/f 

* [Where are the source for the firmware/overlays .dtbo files](https://forums.raspberrypi.com/viewtopic.php?t=311646&sid=85c0b95751a206b723e435fd3cc3889f#p1863822) - Pretty well hidden! 

* [Multiple dtoverlay=gpio-shutdown line in config.txt](https://forums.raspberrypi.com/viewtopic.php?t=310269&sid=85c0b95751a206b723e435fd3cc3889f#p1855568) - gpio-shutdown is just a special case of gpio-key 

* [gpio-fsm - a finite state machine overlay](https://forums.raspberrypi.com/viewtopic.php?t=304278&sid=85c0b95751a206b723e435fd3cc3889f#p1821210) - How about that? A FSM that uses virtual GPIOs in an overlay 

* [gpio-poweroff and active-delay-ms](https://forums.raspberrypi.com/viewtopic.php?t=323508#p1936341) - New options for the gpio-poweroff overlay 

* [A question about flags](https://forums.raspberrypi.com/viewtopic.php?t=326293#p1952701) - "overlays don't support addressing bits or boolean arithmetic" 

* [how to use dtoverlay to load a different driver](https://forums.raspberrypi.com/viewtopic.php?t=330088#p1976001) - but now, `compatible` is not meaningless... ?! 

* [Overlay source files that match the dtbo files included with distribution](https://forums.raspberrypi.com/viewtopic.php?t=330517#p1978428) - find source files for overlays
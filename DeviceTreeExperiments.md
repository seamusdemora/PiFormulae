### Device Tree Experiments 

I've wondered about this thing called the ***device tree*** for a while. On occasion, I've used a feature that piqued my curiosity, and motivated me - however briefly - to learn more; perhaps to create some clever code to do something useful. But when I looked at the *source code* for building device trees, it had the effect of taking a very cold shower... the code struck me as *impenetrably arcane*. And so I contented myself with the use of ***device tree overlays*** created by others, and available for loading through the `/boot/config.txt` file  - a rough functional equivalent to the old BIOS. 

I'll blether more later on ***device tree*** concepts & background, but I want to show an example now. I have created a dirt-simple ***device tree overlay*** to create pin numbers that can be used with the *"new"* character-based API; specifically the `gpiod` package. I installed `gpiod` on my RPi 3B+, and: 

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

Which didn't look very helpful as none of the 62 listed GPIO pins had a `pin name` - all were `unnamed`. I tried this same command on my RPi 4B, and the `gpioinfo` output had `pin names` for all GPIO pins... but why? Some research turned up a discussion on GitHub where it was written by one of the maintainers that while the device tree blobs for *some* RPi models had been updated, others had not. A link was given to a source for the `pin names`, and it was suggested that anyone interested in `pin names` for an unsupported model was welcome to *roll their own*. I decided to give it a go - I figured that there would never be a simpler overlay to write than one that added pin names, and I had an example that was *reasonably* close. 

After some frustration, and a few trials and errors, I cobbled this [device tree overlay source file that adds pin names for the RPi 3B+](source/3BP_pin_name_overlay.dts) - it seems to  work! Following are the steps to compile, add and test it: 

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

That's it for the first installment; more to follow.
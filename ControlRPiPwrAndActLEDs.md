### Those Damn LEDs

The red/Power LED, and the green/Activity LED are among the most controversial items of native hardware on the Raspberry Pi. The other two native hardware LEDs are the Ethernet (`eth0`) *"link"* and *"status"* LEDs. Many questions have been asked online about how to extinguish, dim, re-purpose & modify these LEDs.  In some cases this has been motivated by RPi usage in low-light photography or video recording, other cases because they disturb user's sleep and in others just due to personal preference. Personally, I find the LED's brightness levels annoying, and I see a *near-zero* utility in them. But whether you love them or hate them, this recipe details a few methods for controlling the LEDs. 

#### An Overview:

This recipe covers two methods for controlling the behavior of the RPi "native" LEDs: 

1. [sysfs](#led-control-with-sysfs) via direct writes to specific files 
2. [device tree](#led-control-using-the-device-tree) via parameters (`dtparam=`) & overlays (`dtoverlay=`) in `/boot/config.txt`  

There are likely other methods (e.g. direct firmware manipulation), but those will not be covered here. And while `sysfs` is said to be *deprecated*, as of this writing it remains a viable method for all Raspberry Pi models. Comparing these two methods, perhaps the key difference is that `sysfs` can provide spontaneous, non-persistent, real-time behavioral changes to the LEDs, whereas device tree changes are persistent between boots. Some device tree configuration changes (e.g. those covered here) **require** a reboot to effect configuration changes, while others may be added or removed during run time using the `dtoverlay` command. 

Configuration of the PWR & ACT LEDs is perhaps most easily handled through the RPi's ***device tree***. In general, the *device tree* is a "map" that informs the kernel how to interface with the hardware devices connected to our system. The *device tree* may be envisioned as a re-configurable *base tree* defined in the **`.dtb`** files in `/boot`. This "tree" or "map" may be changed or re-configured using either ***overlays***, or ***parameters***.  The ***overlays*** effectively alter portions of the "tree" to alter behavior, add hardware, or accomplish more significant or complex objectives. The "compiled" ***overlays*** are contained in **`.dtbo`** files in `/boot/overlays`, and the instructions to add a particular overlay is entered in the `/boot/config.txt` file. For simpler changes not requiring alterations of the *base tree*, *device tree **parameters*** may be declared; these are also invoked in `/boot/config.txt`. 

In summary, the *device tree* controls *some of the* behaviors of the PWR & ACT LEDs, and those controls may be re-configured using `dtparam` variables (for simpler changes), or `dtoverlay` (for more complex changes). 

#### LED control using the device tree:

The `dtparam` and `dtoverlay` settings are described in the README file - available in your *local* filesystem at `/boot/overlays/README`, or [online at RPi's GitHub site](https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README). All of the changes discussed in this *recipe* may be accommodated using *device tree **parameters*** (`dtparam`); no ***overlays*** are required. N.B. that there are [*discrepancies*](#device-tree-readme-documentation-discrepancies) (or *confusion* - take your pick) between the "official documentation", and the behavior of the RPi Power and Activity LEDs. The following table summarizes the `dtparam` settings for the PWR & ACT LEDs: 

| GREEN/act/led0 LED | RED/pwr/led1 LED  | Descriptive Summary                                   |
| ------------------ | ----------------- | ----------------------------------------------------- |
| act_led_trigger    | pwr_led_trigger   | controls ON/OFF & drive signal pattern                |
| act_led_activelow  | pwr_led_activelow | `=1` inverts the drive signal pattern                 |
| act_led_gpio       | pwr_led_gpio      | **N/A for native LED**; defines GPIO for external LED |

Before we can proceed, one question must be answered: *"What are the possible values for the `*_led_trigger` parameters?"* A couple are mentioned in the "official documentation", but are there others? Here's one way to discover the possible values: 

   ```bash
   $ sudo find /sys/devices -name '*trigger*'
   /sys/devices/platform/leds/leds/led0/trigger
   /sys/devices/platform/leds/leds/led1/trigger
   /sys/devices/virtual/leds/default-on/trigger
   /sys/devices/virtual/leds/mmc0/trigger
   
   $ cat /sys/devices/platform/leds/leds/led0/trigger
   none rc-feedback kbd-scrolllock kbd-numlock kbd-capslock kbd-kanalock kbd-shiftlock kbd-altgrlock kbd-ctrllock kbd-altlock kbd-shiftllock kbd-shiftrlock kbd-ctrlllock kbd-ctrlrlock timer oneshot heartbeat backlight gpio cpu cpu0 cpu1 cpu2 cpu3 [default-on] input panic actpwr mmc1 mmc0 rfkill-any rfkill-none rfkill0 rfkill1
   
   $ cat /sys/devices/platform/leds/leds/led1/trigger
   none rc-feedback kbd-scrolllock kbd-numlock kbd-capslock kbd-kanalock kbd-shiftlock kbd-altgrlock kbd-ctrllock kbd-altlock kbd-shiftllock kbd-shiftrlock kbd-ctrlllock kbd-ctrlrlock timer oneshot heartbeat backlight gpio cpu cpu0 cpu1 cpu2 cpu3 default-on input panic actpwr mmc1 [mmc0] rfkill-any rfkill-none rfkill0 rfkill1
   ```

If you experiment with all of the `trigger` values here, you will learn that many of them don't seem to work, or at least provide to visual evidence. And some values work on some models - but not on others. You'll need to do your own experimentation to learn these values. The values that seem to work with the models I tested were:

```
none, timer, heartbeat, default-on, mmc0: Worked consistently across tested models RPi
cpu: Worked on all platforms except RPi 4B
Tested models: RPi 4B, RPi 3B+, RPi B Plus 
```



There are several things worth noting here: 

1. `led0` is the GREEN/`act` LED ;  `led1` is the RED/`pwr` LED 
2. The `trigger` ***values are not the same across all platforms***; use the commands shown above to learn the values appropriate for your platform. ***The values listed above are from a RPi 4B***. 
3. The trigger value that is currently in effect is enclosed in brackets; `[default-on]` & `[mmc0]` for `led0` & `led1` respectively. 
4. AFAIK, there are no more detailed descriptions for these values than the ones you might guess from reading the value itself; i.e. if `kbd-numlock` were designated as the `dtparam` value for `led0`, I would *guess* that the GREEN LED would be illuminated when the `NUMLOCK` key on a connected keyboard was pressed. It seems likely that could be re-purposed to indicate something else, but... not today.

And so we may now have enough information to determine how these `dtparam` settings influence the operation of the GREEN/`act` & RED/`pwr` LEDs on the RPi board. Using a RPi 4B as the test platform, the following values of `_trigger` and `_activelow` were evaluated. Experiment with these if you wish; a reboot is required after each change to `/boot/config.txt`. 

  

  * ```bash
    dtparam=act_led_trigger=none
    # dtparam=act_led_activelow=
    dtparam=pwr_led_trigger=none
    # dtparam=pwr_led_activelow=
    
    # BEHAVIOR: Both RED & GREEN LEDs are extinguished
    ```

  * ```bash
    dtparam=act_led_trigger=mmc0        # the default value
    dtparam=act_led_activelow=on        # on ==> invert
    dtparam=pwr_led_trigger=heartbeat   # heartbeat activity
    # dtparam=pwr_led_activelow=
    
    # BEHAVIOR: GREEN LED is OFF during SD card activity, ON otherwise; RED LED flashesON & OFF in a "heartbeat" pattern
    ```

  * ```bash
    dtparam=act_led_trigger=default-on
    # dtparam=act_led_activelow=
    dtparam=pwr_led_trigger=mmc0
    # dtparam=pwr_led_activelow=
    
    # BEHAVIOR: RED & GREEN LEDs have 'swapped roles'; GREEN LED is ON always, RED LED driven by SD card activity
    ```

  * ```bash
    dtparam=act_led_trigger=timer
    dtparam=act_led_activelow=off
    dtparam=pwr_led_trigger=timer
    dtparam=pwr_led_activelow=on
    
    # BEHAVIOR: The 'FULL OBNOXIOUS MODE'; use this when your RPi is located in a toxic waste dump. :)
    ```

#### LED control with `sysfs`

LED behavior may also be changed by writing appropriate values to `sysfs`, but these changes are ***not persistent***; i.e. system defaults (the values set in `/boot/config.txt`) will be restored at the next boot. Note that the `_activelow` property is ***not available*** for modification in `sysfs` as it is with the `dtparam` configuration in `/boot/config.txt` . There are 4 files that can be (*easily*) modified in `sysfs` to control the behavior of the Red and Green LEDs:  

```
# led1 = RED LED
/sys/devices/platform/leds/leds/led1/brightness		# '0' for OFF, '1' for ON 
/sys/devices/platform/leds/leds/led1/trigger 			# sets "pattern" or "behavior" (see below)
# led0 = GREEN LED
/sys/devices/platform/leds/leds/led0/brightness		# '0' for OFF, '1' for ON 
/sys/devices/platform/leds/leds/led0/trigger			# sets "pattern" or "behavior" (see below)

# 'trigger' values are model dependent; list all possible values as follows: 
$ cat /sys/devices/platform/leds/leds/led0/trigger 
```

Writing to `sysfs` files requires `root` privileges & may be done in at least 3 ways: or *more securely:* [4](https://unix.stackexchange.com/a/70383/286615), [5](https://unix.stackexchange.com/questions/276624/what-is-the-safest-way-for-programmatically-writing-to-a-file-with-root-privileg) 

1. ```
   Become the root user:
   $ sudo -i
   ---- Optionally, to orient yourself in this root shell: 
   # whoami; pwd
   root
   /root
   ---- then write away...
   # echo 0 > /sys/devices/platform/leds/leds/led1/brightness  
   ```

2. ```
   Start a new shell with root privileges:
   $ sudo sh -c 'echo 0 > /sys/devices/platform/leds/leds/led1/brightness'
   $ 
   ```

3. ```
   Apply 'sudo' to 'tee'  - not to redirect '>'
   $ echo "0" | sudo tee /sys/devices/platform/leds/leds/led1/brightness > /dev/null
   ```

Some examples follow: 

1. Turn both Red and Green LEDs OFF: 

   ```
   $ sudo sh -c 'echo 0 > /sys/devices/platform/leds/leds/led0/brightness'
   $ sudo sh -c 'echo 0 > /sys/devices/platform/leds/leds/led1/brightness'
   ```

2. Turn Red OFF, Trigger Green with 'heartbeat' pattern 

    ```
    $ sudo sh -c 'echo 0 > /sys/devices/platform/leds/leds/led1/brightness' # Red OFF
    $ sudo sh -c 'echo "heartbeat" > /sys/devices/platform/leds/leds/led0/trigger' 
    ```


3. Use the Red LED to indicate 'Activity' & turn Green LED OFF

   ```
   $ sudo sh -c 'echo 1 > /sys/devices/platform/leds/leds/led1/brightness' 
   $ sudo sh -c 'echo "mmc0" > /sys/devices/platform/leds/leds/led1/trigger'
   $ sudo sh -c 'echo 0 > /sys/devices/platform/leds/leds/led0/brightness'
   ```



## REFERENCES:

1. [Raspberry Pi 4: exchange power LED with activity LED](https://raspberrypi.stackexchange.com/questions/136606/raspberry-pi-4-exchange-power-led-with-activity-led) & this [answer](https://raspberrypi.stackexchange.com/a/136611/83790) 
1. [`/boot/overlays/README` file; GitHub upstream version](https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README) 



##  DEVICE TREE README DOCUMENTATION DISCREPANCIES

I consider the file `/boot/overlays/README` (also available [online at GitHub](https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README)) the *"Official Documentation"* for changes to the RPi *device tree*. The document is well worth reading by all RPi users, as it serves as a guide to which *overlays* and *parameters* should be declared and defined in `/boot/config.txt`. During the boot process, the device tree - as modified by `dtparam`s & `dtoverlay`s - informs the kernel which hardware is available for use & how to use it. It is helpful when reading this document to keep in mind that `dtparam` changes are applied to the "base" device tree - or device tree blob (.dtb), whereas `dtoverlay` changes are additions to the tree. 

That said, there are some confusing/incorrect passages in README. This excerpt from the README is one example:  

##### RE: dtparam `act_led_activelow` : 

>N.B. For Pi 3B, 3B+, 3A+ and 4B, use the act-led overlay. 

This note is incorrect. As you can see by running the examples above, the `dtparam` changes work fine. If you read on, you will eventually reach the documentation for the `act-led overlay` referenced above:

##### RE: dtoverlay `act-led`

>Info:   Pi 3B, 3B+, 3A+ and 4B use a GPIO expander to drive the LEDs which can
>only be accessed from the VPU. There is a special driver for this with a
>separate DT node, which has the unfortunate consequence of breaking the
>act_led_gpio and act_led_activelow dtparams.
>This overlay changes the GPIO controller back to the standard one and
>restores the dtparams.  

Perhaps this makes sense to some, but it reads as gibberish to me. It suggests that it is necessary to use the overlay for `act-led` to enable the `_activelow` and `_gpio` properties of the `dtparam` for `act_led`. I'll assume that `act-led` and `act_led` refer to the same hardware. However, note that this `act-led overlay` has ***not*** been declared in the changes we have made to our `/boot/config.txt` - nor is it included in the *default* version of that file. Further - if this overlay is enabled - at least on the model RPi 4B, the GREEN/`act`LED does not seem to work at all. 



---

<!---

I'm not sure what you've described can be implemented, but if it can be, it will likely be in the reconfiguration of the RED/pwr LED, and the GREEN/act LED in your `/boot/config.txt` file. Even if your preferred behavior cannot be created exactly as you've described it, this answer may help you find a configuration that comes closer than the default.

#### 



Model		: Raspberry Pi Model B Plus Rev 1.2:

/sys/devices/platform/leds/leds/led1 

cat trigger: none rc-feedback kbd-scrolllock kbd-numlock kbd-capslock kbd-kanalock kbd-shiftlock kbd-altgrlock kbd-ctrllock kbd-altlock kbd-shiftllock kbd-shiftrlock kbd-ctrlllock kbd-ctrlrlock timer oneshot heartbeat backlight gpio cpu cpu0 default-on input panic actpwr [mmc0] rfkill-any rfkill-none

timer: on & off ~ 1/sec 

cpu: steady on

heartbeat: "heartbeat"

mmc0: "disk activity"


/sys/devices/platform/leds/leds/led0

cat trigger: none rc-feedback kbd-scrolllock kbd-numlock kbd-capslock kbd-kanalock kbd-shiftlock kbd-altgrlock kbd-ctrllock kbd-altlock kbd-shiftllock kbd-shiftrlock kbd-ctrlllock kbd-ctrlrlock timer oneshot heartbeat [backlight] gpio cpu cpu0 default-on input panic actpwr mmc0 rfkill-any rfkill-none



-->
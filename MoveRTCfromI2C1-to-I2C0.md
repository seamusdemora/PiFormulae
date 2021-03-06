### Move your Real-Time Clock (RTC) from channel  I2C1 to I2C0:

If you need/want to use an I2C *channel* other than `i2c1` (the default for `dtoverlay=i2c-rtc`), this is possible using the configuration steps shown below. One reason for doing so is that the clock signal for `i2c1` (`SCL1)`) uses GPIO 3 (physical pin 5); GPIO 3 is apparently **unique** in that it is required for the [*"single-button-run-stop"* feature](https://github.com/seamusdemora/PiFormulae/blob/master/docs/gpio-shutdown_20210620.md). *(see also the [complete & current version of the `/boot/overlays/README` file](https://github.com/raspberrypi/firmware/blob/master/boot/overlays/README))* 

In this recipe, we'll move the RTC **from** I2C bus channel `i2c1` **to** channel`i2c0`, and verify its function. 

There are warnings re use of `i2c0`. In some cases, things change over time, which create [some confusion](https://www.raspberrypi.org/forums/viewtopic.php?f=44&t=138897#p922764). But today - unless you use a *HAT with EEPROM*, the *Pi Camera*, or the *"Official" 7" Pi display - you shouldn't encounter any issues using `i2c0` with the RTC. In fact, the current `dtoverlay=i2c-rtc`  supports the use of `i2c0 ` via a *parameter* option. See `/boot/overlays/README` for details. 

All of that said, we'll proceed as follows:

   * **Remove Power and Change Wiring Connections for Using I2C0**

| 3231 RTC | `i2c0` GPIO |    `i2c0` pin #     |
| :------: | :---------: | :-----------------: |
|   SDA    |   GPIO 0    | pin 27 (from pin 3) |
|   SCL    |   GPIO 1    | pin 28 (from pin 5) |

   > **NOTE:** Verify your RTC has *pullups* (2K𝛀 is reasonable) on SDA & SCL lines - otherwise, you will need to add them to pins 27 & 28 - pulled up to the 3V3 bus. 

* **Apply Power and Re-configure the device tree in `/boot/config.txt`:** 

| param/overlay |                  FROM                  |                     TO                      | CMT                             |
| :-----------: | :------------------------------------: | :-----------------------------------------: | :------------------------------ |
|    dtparam    |           dtparam=i2c_arm=on           |             #dtparam=i2c_arm=on             | disables i2c1; see NOTE 2 below |
|    dtparam    |                                        |              dtparam=i2c_vc=on              | enables i2c0 (Pi 4)             |
|   dtoverlay   | dtoverlay=i2c-rtc,ds3231,wakeup-source | dtoverlay=i2c-rtc,ds3231,wakeup-source,i2c0 | connect RTC via i2c0            |

> **NOTES:**  
>
> 1. Some settings are *hardware-dependent* (RPi version). Consult `/boot/overlays/README` for details. 
> 2. Disabling `i2c1` is ***optional***, but *iaw* recommendation not to enable unused features. 

* **Verification:** 

  ```bash
  $ sudo i2cdetect -y 0
       0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
  00:          -- -- -- -- -- -- -- -- -- -- -- -- --
  10: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  20: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  30: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  40: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  50: -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
  60: -- -- -- -- -- -- -- -- UU -- -- -- -- -- -- --
  70: -- -- -- -- -- -- -- --
  ```

  ```bash
  $ timedatectl
                 Local time: Sat 2021-06-19 20:17:08 CDT
             Universal time: Sun 2021-06-20 01:17:08 UTC
                   RTC time: Sun 2021-06-20 01:17:09
                  Time zone: America/Chicago (CDT, -0500)
  System clock synchronized: yes
                NTP service: active
            RTC in local TZ: no
  ```

  ```bash
  ls /dev/*i2c*
  /dev/i2c-0  /dev/i2c-10  /dev/i2c-11 
  
  # NOTE: This is likely an errant result of the RPi4's I2C Multiplexer*
  # Follow-up required.
  ```

  > \* REF:  [Re: dtoverlay i2c0 - kernel troubles 5.4.59-v7l+](https://www.raspberrypi.org/forums/viewtopic.php?t=284036#p1720835) 


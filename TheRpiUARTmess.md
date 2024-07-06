## The UART Mess (Someone should be shot for this!)

> ***Sometimes - in some places - the RPi documentation is just great!  In other places it sucks so bad that it makes you wonder why you even bother with this wee shite!*** 

The *Raspberry Pi UART documentation* belongs to the *latter* category. 

First: UARTs are not particularly difficult to understand... especially if they're actually UARTs, and not some leftover cells in the chip that have been pressed into service - as if driving square pegs in round holes. To be honest, I don't know ***how*** the chip hardware came to be allocated, but reading through [the explanatory documentation](https://www.raspberrypi.com/documentation/computers/configuration.html#pl011-and-mini-uart) - it sounds like it was done by ***drunken sailors***. 

And [the entirety of the "official documentation" on the UART](https://www.raspberrypi.com/documentation/computers/configuration.html#configure-uarts) is a tortured exercise trying to make sense of the hardware allocation (done by the drunk sailors) in a series of arcane configuration steps suggesting that the firmware was designed by the handmaidens of those same sailors. **I do not get it**!  Would it not have been better to document a few UART functions, list those, and have a few overlays to implement them?? Why must users consider details such as: *"... [how] to use a fixed VPU core clock frequency"*, *"... particular deficiencies of the mini UART compared to a PL011"*, *"[how] to enable `earlycon` support"*, *"[do you need to] re-enable `serial1` by setting ... values in `config.txt`"* This *must be* some form of insanity!  

My objective ***seemed*** simple enough: I wanted to connect two RPi's via UART connection. I need one of my RPi to act as a *console server* to the other one - IOW, a backup for when WiFi, Ethernet or SSH doesn't work - or when a Pi won't boot. Well... ***FUCK!!*** I've wasted an entire day trying to get this to work; *schmucking* around in the arcane details in the documentation. Instead of this misery, why couldn't they have created something like this - a line in `config.txt` that offers this: 

```
dtoverlay=uart_console_server
# -- OR --
dtoverlay=uart_console_client
```

... and a single paragraph of documentation stating the required wiring connections?

But no... instead we must try to get inside the brains of the drunken sailors and their firmware handmaidens to... set up a UART console?! Well - alright then - let's get to it. 

Before we begin, we should clearly define what is meant by the term ***'UART Console Server'***. TBH, this is a term I *fabricated* after I began writing this, and AFAIK it has no meaning outside this *recipe*. Nevertheless, it serves a purpose, and hopefully helps the reader make sense of this. 

In this recipe, I will be using a RPi 4B as my *UART Console Server*, and a RPi 0W as the device I intend to view/control through the *UART Console Server*... I guess we could call the RPi 0W the ***'UART Console Client'***. IOW, the Console Server will initiate the UART connection to the Console Client. In this arrangement, the Console Server is a *"healthy"* host, whereas the Console Client may have some issues that we are trying to diagnose. The serial port merely represents another access point in the event that WiFi/Ethernet/SSH are inoperable.

## I. UART configuration for setting up UART Console Server

We've gotta' start somewhere. After reading several *blogs* and *"How-Tos"* trying to clear the fog from the *"official documentation"*, I elected to start with what turned out to be [a really decent "How-To" on RPi UARTs from AB Electronics](https://www.abelectronics.co.uk/kb/article/1035/serial-port-setup-in-raspberry-pi-os). As a bonus, there's also a companion article on using a [*"Loopback Test"*](https://www.abelectronics.co.uk/kb/article/1110/serial-port-loopback-test) to verify the wiring and configuration of the UARTs. *These documents struck me as an entirely reasonable approach!* Let's step into it:  

### 1. Which fuckin' UART?

The"How-To" article by AB Electronics has a [clear discussion](https://www.abelectronics.co.uk/kb/article/1035/serial-port-setup-in-raspberry-pi-os) of the tradeoffs between the "mini UART" and the "PL011 UART"... *I wonder why they couldn't say this in the "official documentation"?*. There is also a very clear recommendation from ABE: 

> ***We recommend using the PL011 UART controller when a reliable data  connection, power consumption, and processor speed are priorities.***

### 2. Use the PL011 UART!

By *default* the PL011 UART is mapped to support the Bluetooth module.  Consequently, there's some *re*-configuration required. We'll address the loss of the Bluetooth UART in the sequel. For now, our priority is getting the UART Console Client and Server working together.

*  Step 1: Edit `/boot/config.txt` (or `/boot/firmware/config.txt` in 'bookworm') & add 1 line at the end of the file: 

   ```
    dtoverlay=disable-bt
   ```

*  Step 2: Disable the `systemd` `hciuart.service`:

   ```bash
    $ sudo systemctl disable hciuart.service
   ```

*  Step 3: Clean up any previous configuration changes you may have made:

   *  Step through your `/boot/config.txt` file, and remove/*comment out* anything related to UART configuration that you may have made previously; e.g. `enable_uart=1` 
   *  Run `raspi-config`, select item **'3. Interface Options'** in the first screen, and in the next screen select **'I6 Serial Port'**. 
      *  When you are asked the question, "Would you like a login shell to be accessible over serial?", select the **`<No>`** answer.
      *  When you are asked the question, "Would you like the serial port hardware to be enabled?", select the **`<Yes>`** answer. 
      *  Before leaving `raspi-config`, you must **confirm** two statements: "The serial login shell is disabled" and "The serial interface is enabled" by selecting **`<Ok>`**. 
      *  If you've changed anything from prior settings, `raspi-config` will ask to `reboot`.  

   *  Even if `raspi-config` doesn't ask to `reboot`, you can go ahead and `reboot` now to cover the change(s) to `/boot/config.txt` and the `systemd` change to `disable hciuart.service`. 
   *  In case you are wondering why you **declined** making the login shell accessible, recall that we are now configuring the Console Server... i.e. we declined **because** the serial port of the Console Server will be used to control other devices (e.g. the RPi 0W; the *client*). 


### 3. Run the "Loopback Test"

Running the Loopback Test requires two things: 

 *  **1. Wiring:** 

​	***NOTE: Issue a `sudo halt` to the RPi, and remove power before making wiring connections.***

​	On the 40-pin header, connect [pins 8 (GPIO 14) & 10 (GPIO 15)](https://pinout.xyz/pinout/pin8_gpio14/) together with a jumper wire. 

​	*Yes - you are simply shorting the Transmit (Tx) and Receive (Rx) pins of the UART together!* 

 *  **2. Software:** 

      Use `minicom` for this; install it if you haven't already: 

      ```bash
       $ sudo apt update
       ...
       $ sudo apt install minicom
      ```


With wiring and software in place, we're ready to run the *Loopback Test*. Enter the following command:  

```bash
$ minicom -b 115200 -D /dev/ttyAMA0
```

Which should create a `minicom` screen in your terminal window that looks like this: 

```
Welcome to minicom 2.8

OPTIONS: I18n
Port /dev/ttyAMA0, 07:01:54

Press CTRL-A Z for help on special keys

```

If you see the screen above, the *Loopback Test* is running! Now type something... `hello world!` will do fine. You'll see whatever you type "echo'd" in the screen. If you hit the return key, you'll (probably) move the cursor to the beginning of the same line you just typed. If you want to type more, enter `ctrl-a` + `e` from the keyboard to toggle the `linefeed` option. 

So - if you can type in the `minicom` screen, and see your keystrokes `echoed`, ***Congratulations!*** You have passed the *Loopback Test*. It's not an *impressive* test, but it does confirm that your UART is configured properly, and wired properly... key steps in the right direction. 

## II. UART configuration for the Console Client

This part of the setup closely follows that for the Console Server, so we needn't be as verbose. We'll use the PL011 UART as we did on the Console Server, but will configure it ***with*** the UART login shell accessible. We'll replace the *Loopback Test* with *inter-Pi* comms, and so will make our UART wiring interconnects between the two RPi headers. 

### Use the PL011 UART (for the Console Client)

As with the Console Server, there's some (*re*-)configuration required as the PL011 UART is **not** the default UART.  The steps are ***similar*** (not identical) to those for the Console Server:

*  **Step 1:** Edit /boot/config.txt & add 1 line at the end of the file: 

   ```
    dtoverlay=disable-bt
   ```

*  **Step 2:** Disable the `systemd` `hciuart.service`:

   ```bash
    $ sudo systemctl disable hciuart.service
   ```

*  **Step 3:** Clean up any previous configuration changes you may have made:

   *  Step through your `/boot/config.txt` file, and remove/*comment out* anything related to UART configuration that you may have made previously; e.g. `enable_uart=1` 
   *  Run `raspi-config`, select item '3. Interface Options' in the first screen, and in the next screen select 'I6 Serial Port'. 
      *  If you are asked the question, "Would you like a login shell to be accessible over serial?", select the **`<Yes>`** answer.
      *  If you are asked the question, "Would you like the serial port hardware to be enabled?", select the **`<Yes>`** answer. 
      *  Before leaving `raspi-config`, you must **confirm** "The serial login shell is ***enabled***" and "The serial interface is enabled" by selecting **`<Ok>`**. 
      *  If you've changed anything from prior settings, you'll be asked to `reboot`.  

   *  Even if `raspi-config` doesn't ask, you can go ahead and `reboot` now to cover the change(s) to `/boot/config.txt` and the `systemd` change to `hciuart.service`. 
   *  In case you are wondering why you **accepted** the option to make the login shell accessible, recall that we are now configuring the Console ***Client***... i.e. we accepted **because** the serial port of the Console ***Client*** will be used to provide control to another device connected via UART (e.g. the RPi 4B; the *Server*).


### Make the Wiring Connections Between the RPis

***NOTE: Issue a `sudo halt` to both UART Console Client and Server RPis, and remove power from both before making wiring connections.***

We're skipping the *Loopback Test* here b/c it's not particularly informative, and can cause `minicom` to hang. Instead, we'll make the actual wiring connections ***between the two RPis*** to enable UART comms. 

Three wiring interconnections are required; use three jumper wires to mate the hardware/headers between the *UART Console Client* and *Server* RPis: 

| Jumper | Console Server (RPi 4B) Pin/GPIO        | Console Client (RPi Zero W) Pin/GPIO  |
| :----: | --------------------------------------- | ------------------------------------- |
|   1    | from: Header Pin 6 (GND)                | to: Header Pin 6 (GND)                |
|   2    | from: Header Pin 8 (GPIO 14 / UART Tx)  | to: Header Pin 10 (GPIO 15 / UART Rx) |
|   3    | from: Header Pin 10 (GPIO 15 / UART Rx) | to: Header Pin 8 (GPIO 14 / UART Tx)  |

IOW, we simply *cross-connect* the UART Transmit (Tx)  and UART Receive (Rx) pins between the two RPis. 

### Start UART Connection From Console Server to Console Client 

Let's see if our wiring connections and configuration are working as we hope: 

 *  **Step 1:** Re-start the *Console Server* (RPi 4B) by plugging the power cord into its USB connector. Once the Console Server has booted, make an SSH connection from a terminal (on your PC/Mac). Log in to the Console Server, and start `minicom`: 

   ```bash
    $ minicom -b 115200 -D /dev/ttyAMA0
    
    # the minicom screen appears:
    Welcome to minicom 2.8
    
    OPTIONS: I18n
    Port /dev/ttyAMA0, 07:01:54
    
    Press CTRL-A Z for help on special keys
   ```

 *  **Step 2:** Re-start the Console Client (RPi Zero W) by plugging the power cord into its USB connector, and *you should* observe the console messages streaming into the `minicom` screen on the Console Server (RPi 4B). These messages document the `boot` process, and conclude with a login prompt: 

   ```bash
    [    0.000000] Booting Linux on physical CPU 0x0
    [    0.000000] Linux version 6.1.21+ (dom@buildbot) (arm-linux-gnueabihf-gcc-8 (Ubuntu/Linaro 8.4.0-3ubuntu1) 8.4.0, GNU ld (GNU Binutils for Ub3
    [    0.000000] CPU: ARMv6-compatible processor [410fb767] revision 7 (ARMv7), cr=00c5387d
    [    0.000000] CPU: PIPT / VIPT nonaliasing data cache, VIPT nonaliasing instruction cache
    [    0.000000] OF: fdt: Machine model: Raspberry Pi Zero W Rev 1.1
    [    0.000000] random: crng init done
    [    0.000000] Memory policy: Data cache writeback
    [    0.000000] Reserved memory: created CMA memory pool at 0x17c00000, size 64 MiB
    [    0.000000] OF: reserved mem: initialized node linux,cma, compatible id shared-dma-pool
    [    0.000000] Zone ranges:
    [    0.000000]   Normal   [mem 0x0000000000000000-0x000000001bffffff]
    [    0.000000] Movable zone start for each node
    [    0.000000] Early memory node ranges
    [    0.000000]   node   0: [mem 0x0000000000000000-0x000000001bffffff]
    [    0.000000] Initmem setup node 0 [mem 0x0000000000000000-0x000000001bffffff]
    
    ...
    
    [   12.135526] systemd[1]: Finished Load Kernel Module configfs.
    [   12.192365] systemd[1]: modprobe@drm.service: Succeeded.
    [   12.265342] systemd[1]: Finished Load Kernel Module drm.
    [   12.329089] systemd[1]: modprobe@fuse.service: Succeeded.
    [   12.400901] systemd[1]: Finished Load Kernel Module fuse.
    [   12.475183] systemd[1]: Finished File System Check on Root Device.
    [   12.525276] systemd[1]: Finished Load Kernel Modules.
    [   12.655860] systemd[1]: Mounting FUSE Control File System...
    [   12.846814] systemd[1]: Mounting Kernel Configuration File System...
    [   13.048461] systemd[1]: Started File System Check Daemon to report status.
    [   13.186867] systemd[1]: Starting Remount Root and Kernel File Systems...
    [   13.376585] systemd[1]: Starting Apply Kernel Variables...
    [   13.519681] systemd[1]: Started Journal Service.
    
    Raspbian GNU/Linux 11 raspberrypi0w ttyAMA0
    
    raspberrypi0w login:
   ```

### In Closing...

This setup seems to be working as hoped. We now have a Console Server that is properly configured to **initiate** console connections via UART, and we have configured a Console Client that will respond. The Console Server has full access to the Console Client's *shell* - same as in an SSH session. 

The OS version installed on both Client and Server in this recipe was 'bullseye', but this recipe also works (as of today anyway) for 'bookworm' hosts. 

### Addendum: *"Early Console Support"* 

Before closing this segment on the UART Console Client, I'll call your attention to one additional feature that *may* come in handy:  You can read about *"Early Console Support"* in the [*"official documentation"*](https://www.raspberrypi.com/documentation/computers/configuration.html#enabling-early-console-for-linux). It seems to work, and is easy enough to add, but in my experience didn't make a huge difference in the quantity of boot messages... perhaps b/c my client was a RPi Zero W? 

You may wish to add "Early Console Support" to your client configuration. I see no reason not to add it - as long as it causes no grief. In my case, for the RPi Zero W, I added the following string to `/boot/cmdline.txt`:

```
earlycon=pl011,mmio32,0x20201000 

# Which made my full /boot/cmdline.txt file as follows: 

earlycon=pl011,mmio32,0x20201000 console=serial0,115200 console=tty1 root=PARTUUID=e62e6ca0-02 rootfstype=ext4 fsck.repair=yes rootwait
```



## REFERENCES:

1. [Serial Port setup in Raspberry Pi OS Bookworm](https://www.abelectronics.co.uk/kb/article/1035/serial-port-setup-in-raspberry-pi-os); a clear explanation from AB Electronics 
1. [Serial Port Loopback Test](https://www.abelectronics.co.uk/kb/article/1110/serial-port-loopback-test); loopback test setup from AB Electronics 
1. [A Tutorial on `minicom`](https://derrekito.github.io/Minicom-tutorial/) 
1. [*"Official"* documentation on Raspberry Pi UART Configuration](https://www.raspberrypi.com/documentation/computers/configuration.html#configure-uarts); massively confusing IMHO 
1. [Setting Up UART Serial Communication between Raspberry Pis](https://scribles.net/setting-up-uart-serial-communication-between-raspberry-pis/); a piece fm Scribles
1. [Enabling UART on Raspberry Pi: A Step-by-Step Guide](https://raspberrytips.com/enable-uart-on-raspberry-pi/); fm the "RaspberryTips guy" (didn't help me) 
1. [Raspberry Pi pinout](https://pinout.xyz/#); very useful! 




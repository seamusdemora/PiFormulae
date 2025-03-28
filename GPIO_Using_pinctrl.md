## Using 'pinctrl' for GPIO input and output

This *recipe* is for building and using the latest version of `pinctrl` on a `bullseye` (or `bookworm`) system. As cautioned by *"The Raspberries"* in their documentation `pinctrl` is a potentially useful *adjunct* in our *testing, experimentation and troubleshooting* with our RPi systems. 

I have a different take on this advice: 

>  IMHO, their advice is based on some sort of *perverted deference* to the **Kernel God**... yes, I'm referring to Linus Torvalds. Some of you will wonder why I utter such blasphemies... allow me to explain my reasoning: First, Linus Torvalds deserves a lot of credit for creating the Linux kernel, but he has become incredibly *wealthy and powerful* as a result of his work. Mr. Torvalds derives much of his wealth from "donations" supplied by industry - the companies that make and sell the thousands of devices the Linux kernel controls. This is simply "*business as usual*" in the OpenSource world! 
>
>  If you don't see things the same as I do - that's fine - we're all entitled to believe what we choose to believe. But in this case I find the `pinctrl` utility a *straightforward and easy to use* utility for controlling GPIO resources. Further, my systems are not encumbered with hardware or software that makes use of `libgpiod`... For those of you who don't know:  `libgpiod` is the *official, sanctioned tool* for GPIO manipulation under the Linux kernel. So - yeah - another source of revenue for Mr. Torvalds. 

That said, let's get on with the business at hand: using `pinctrl`. 

### Installation:

`pinctrl` is not available as a "package" that can be installed using `apt`. But its installation is straightforward and simple... in a nutshell, git clone the repo, then build and install it. Details follow:

```bash
$ cd
# install the prerequisites using 'apt': 
$ sudo apt update
$ sudo apt install git cmake device-tree-compiler libfdt-dev
# ...
$ git clone https://github.com/raspberrypi/utils 
$ cd utils/pinctrl
$ cmake .
$ make
$ sudo make install
[100%] Built target pinctrl
Install the project...
-- Install configuration: ""
-- Installing: /usr/local/bin/pinctrl
-- Installing: /usr/local/share/bash-completion/completions/pinctrl
$
```

If you see the same results as shown above for `sudo make install`, `pinctrl` is now installed on your system, and ready for use. 

### Preparation:

Read the fine documentation: 

*  The [README.md](https://github.com/raspberrypi/utils/tree/master/pinctrl#readme) file 

*  ```
   $ pinctrl help     # or 'pinctrl help | less' to view in your pager
   ```

As `pinctrl` ***bypasses*** the kernel, review your system (*esp `/boot/firmware/config.txt`*) to verify there are no conflicts with GPIO pins you plan to use with `pinctrl`. 

### A note re the use of 'sudo' with 'pinctrl' 

Before going further, I'll note that despite what [the documentation](https://github.com/raspberrypi/utils/tree/master/pinctrl#readme) says, it does not seem that `root` is required to run any of the `pinctrl` commands. I ***suspect*** that the actual requirement is that your user be a member of the group `gpio`. This has been my experience on my `bookworm Lite` systems...  YMMV. 

### Using 'pinctrl' to control GPIO *output* 

Controlling GPIO is more fun if you have [**blinkenlights**](https://hackaday.com/2025/01/11/blinkenlights-first-retrocomputer-design/) to watch :)  Here's how to make a simple and neat *blinkenlight* for your experimentation:  

![blikenlight2](/Users/jmoore/Documents/GitHub/PiFormulae/pix/blikenlight2.png)

With this *blinkenlight*, we will use a GPIO pin that is adjacent to a GND pin on the 40-pin header. There are [several candidates](https://pinout.xyz/pinout/pin37_gpio26/); we chose GPIO 26 (header pins 37 & 39) as it is easy to find, and typically not *conflicted* as other GPIOs used for common functions such as I2C, SPI, UART, etc. You will need to assemble this respecting the [anode & cathode pins](https://www.westfloridacomponents.com/blog/led-basics-how-to-tell-which-lead-is-positive-or-negative/) on the LED, and you will need a 330 Ohm resistor. I soldered the resistor to the LED anode lead (**+**) so that is the end that is connected to GPIO 26 (header pin 37); the cathode (**-**) lead goes to GND (header pin 39). 

Connect your *blinkenlight* to header pins 37 & 39 of your Raspberry Pi, and we'll take *baby steps* to see how easy it is to use the `pinctrl` software interface in `bash`. When using GPIO pins as outputs, we will make use of the `op` (output) option with `pinctrl`. The typically-used options with `op` are `dh` (drive hi) and `dl` (drive lo). : 

```bash
$ pinctrl get 26                    # check status of GPIO 26
26: ip    -- | lo // GPIO26 = input 

$ pinctrl set 26 op                 # set GPIO 26 to be an output instead of an input 

$ pinctrl get 26                    # verify GPIO 26 is now an output
26: op -- -- | lo // GPIO26 = output

$ pinctrl set 26 dh                 # set GPIO 26 to 'drive high' (dh); LED ILLUMINATES! 

$ pinctrl lev 26                    # checks GPIO 26 'logic level'
1                                   # '1' for 'high'; '0' for 'lo (low)'

```

Wasn't that fun?  :)  If your *blinkenlight* didn't illuminate, check its construction, and make sure it's connected to the proper header pins. You might also verify the 'level'  (`lev`) for GPIO 26 is '1' - as shown above. 

Next we'll do everything we did with *baby steps* above in a single command. Oh... note that after boot, GPIOs are set as `inputs` - afterwards, you should check to make sure. 

```bash
# immediately after boot...
$ pinctrl set 26 op dh           # set GPIO 26 as output, and 'drive high'; LED ILLUMINATES!
```

While LEDs are a rather trite use case, hopefully the reader can appreciate that there are many applications where driving GPIO pins 'hi' and 'lo' can be applied. In addition, there are many more applications where using GPIO as an **input** is useful. We'll look at a couple of examples in the next section.  

### Using 'pinctrl' with GPIO *input*

Using GPIO as an input is slightly more complicated than using it as an output. Inputs ***may*** require use of the in-built ***pull resistors***. Without going off on a tangent to discuss hardware design, I'll provide a link to an introductory post on [**pull-up and pull-down resistors**](https://www.circuitbasics.com/pull-up-and-pull-down-resistors/), and a [***search page***](https://duckduckgo.com/?t=ffab&q=pull+up+and+pull+down+resistrs+in+electronics&ia=web) where you can find more details.  

We'll need another prop for the GPIO input examples that follow. As inputs are often switches, I'll use my ***ugly toggle switch*** shown below: 

![uglytogglesw2](/Users/jmoore/Documents/GitHub/PiFormulae/pix/uglytogglesw2.png)

I like this *ugly toggle switch* because it has lots and lots of [contact bounce](https://www.allaboutcircuits.com/textbook/digital/chpt-4/contact-bounce/)... it's a good switch to use for testing purposes! Note the addition of the .01uF capacitor in the figure above; this eliminates most of the contact bounce. Just for grins, you may want to disconnect the capacitor from your *ugly toggle switch*, and observe the reaction while running the `pinctrl poll` example below. 

Let's get back to using `pinctrl` to handle GPIO inputs. For the examples that follow, I've connected the *ugly toggle switch* between **GPIO 25** and **GND** - header pins 20 & 22. There is no "polarity" with a toggle switch, so just connect one lead to header pin 20, and the other lead to header pin 22. ***One more thing:*** If you can, **toggle your *ugly toggle switch* to be OPEN before you connect it**. If that's too difficult, don't worry, but you will need to pay attention to the results below!

The `pinctrl` option for designating a GPIO as ***input*** is `ip`. The options for designating ***pull*** for GPIO inputs are as follows: **`pu`** for pull-up, **`pd`** for pull-down and **`pn`** for no pull at all. Let's take *baby steps* again : 

```bash
$ pinctrl get 25                    # check status of GPIO 25
25: ip    -- | lo // GPIO25 = input

$ pinctrl set 25 pu                 # set a pull-up on GPIO25

$ pinctrl get 25                    # get the state of GPIO 25
25: ip    -- | hi // GPIO25 = input # GPIO 25 is "hi"

$ pinctrl lev 25                    # get "logic level" of GPIO 25
1                                   # logic level of GPIO 25 is '1' (aka "hi")

$ pinctrl set 25 pn                 # set "no pull" on GPIO 25

$ pinctrl lev 25                    # get "logic level" of GPIO 25
1                                   # NOTE! logic level remains at '1' !

$ pinctrl set 25 pd                 # set a pull-down on GPIO 25

$ pinctrl lev 25                    # get "logic level" of GPIO 25
0                                   # NOTE: logic level changes to '0' after 'pd' ! 

$ pinctrl set 25 pu                 # return to a pull-up on GPIO 25

$ pinctrl lev 25
1                                   # NOTE: logic level changes to '1' after 'pu'

# Now - "flip" the toggle switch to the opposite position from that used above,
# and check the "level" ('lev') again:

$ pinctrl lev 25
0                                   # NOTE --- NOTE --- NOTE --- NOTE --- NOTE --- NOTE
                                    # If I put you to sleep with these baby steps, you may
                                    # have missed what happened here! When we toggled the
                                    # switch to the CLOSED position, the result was that the
                                    # pull-up resistor in GPIO 25 was connected to GROUND. 
                                    # This brought the "level" ('lev') on GPIO 25 to a '0' !
```

Apologies to the "***pull [cognoscenti](https://www.merriam-webster.com/dictionary/the%20cognoscenti)***" readers :)  Hopefully you've gotten the gist of how `pinctrl` works with inputs, and how to set pulls. If you are among the *cognoscenti*, you're now wondering how to make use of a GPIO input... ***IOW***, given that the input state of a GPIO changes - how do we detect that, and make use of that state change in our code???  Please see the next section for my answer. 

### Using 'pinctrl' with the 'poll' option 

I'll try to pick up the pace a bit in this last section. If you read every word of the sparse documentation, you may have noticed that [this document](https://github.com/raspberrypi/utils/tree/master/pinctrl#readme) referenced a `poll` option. There's nothing else said about the `poll` option - which is *surprising*. However, the script below uses the `poll` option of `pinctrl` to do something that ***may be*** useful. Please open an editor on your RPi, and enter the following simple script. 

```bash 
#!/usr/bin/env bash

tcnt=0
/usr/bin/pinctrl poll 25 | while read pcout; do
    state=$(echo "$pcout" | grep -Eo 'hi|lo')
    case "$state" in
        hi)
            echo -e "$state\t\tGPIO25 is "hi" - nothing to do"
            ;;
        lo)
            tcnt=$((tcnt+1))
            echo -e "$state\t$tcnt\tGPIO25 is "lo" - get busy!"
            ;;
    esac
done
```

After saving the script in your home folder, run it as follows:

```bash
$ cd
$ chmod 755 ~/sw-state.sh 
$ ./sw-state.sh           # note that this script does not "return to the prompt"
                          # after you enter 'control+c' from the keyboard

```

While `sw-state.sh` is running, toggle your *ugly toggle switch* a few times, and note the output in the terminal: 

```
$ ./sw-state.sh
lo	1	GPIO25 is lo - get busy!
hi		GPIO25 is hi - nothing to do
lo	2	GPIO25 is lo - get busy!
hi		GPIO25 is hi - nothing to do
lo	3	GPIO25 is lo - get busy!
```

If you did not add the capacitor (debounce filter) you may see a lot more output than shown above! These additional outputs simply reflect the switch contacts "slapping around" before they finally settle out to a steady state. 

Let's make one minor modification before closing this recipe...  I couldn't think of a clever application, so I've just made use of the fact that we still have the *blinkenlight* connected on GPIO 26:

```bash 
#!/usr/bin/env bash

tcnt=0
pinctrl set 26 op
/usr/bin/pinctrl poll 25 | while read pcout; do
    state=$(echo "$pcout" | grep -Eo 'hi|lo')
    case "$state" in
        hi)
            echo -e "$state\t\tGPIO25 is "hi" - off with blinkenlight"
            pinctrl set 26 dl
            ;;
        lo)
            tcnt=$((tcnt+1))
            echo -e "$state\t$tcnt\tGPIO25 is "lo" - blinkenlight ON!!"
            pinctrl set 26 dh
            ;;
    esac
done
```

And it does what we expect: when the *ugly toggle switch* is CLOSED (such that current flows through the pullup), the  *blinkenlight* is turned ON, and when the switch is OPEN (no current flows), *blinkenlight* is turned OFF. Hopefully, readers will conjure more imaginative applications for this simple script. 



### REFERENCES:

1.  [A history of GPIO usage on Raspberry Pi devices, and current best practices](https://pip.raspberrypi.com/categories/685-whitepapers-app-notes/documents/RP-006553-WP/A-history-of-GPIO-usage-on-Raspberry-Pi-devices-and-current-best-practices.pdf) 
2.  [How to use "pinctrl poll" in bash script?](https://forums.raspberrypi.com/viewtopic.php?t=380943) - Unbelievable...
3.  Given the failures of `raspi-gpio` & `libgpiod`, it's odd there aren't more references on `pinctrl` 

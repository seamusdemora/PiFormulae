## Is `udev` brain-damaged - *or does it hate `hwmon`*?

As of 2015 (nearly 10 years ago!) over half the code in the Linux kernel concerns itself with *"devices"*. 

I've been worrying over an issue for the past few days, and doing some reading in an effort to find a solution. The statement above was taken from a [**really good article** in LWN written by Neil Brown](https://lwn.net/Articles/645810/). It's one of the many "postings" I've read on the subject of `udev`, `sysfs` and *"devices"*. 

Unfortunately for all of us, there don't seem to be many **really good articles** on the subject of `udev, sysfs & i2c devices`! In fact, I'll opine that far too much of the documentation is the completely brain-dead products of wastrels. For some objective evidence to support that opinion, I'll suggest that you do a search on [***linux hwmon subsystem***](https://duckduckgo.com/?t=ffab&q=linux+hwmon+subsystem&ia=web). When I did my search, the ["Linux hwmon Subsystem Wiki"](https://hwmon.wiki.kernel.org/) appeared in the very first spot in my search results. I tried following the advice in the [FAQ](https://hwmon.wiki.kernel.org/faq) under **Installation and Management**. That dismal experience led me to post this issue on the `lm-sensor` GitHub site: [Is `lm-sensors` completely useless - or am I doing something wrong?#502](https://github.com/lm-sensors/lm-sensors/issues/502). If they haven't deleted it yet, you might get a laugh :)  

So now you know what my opinion is of much (not all) of the [*corpus*](https://www.merriam-webster.com/dictionary/corpus) of Linux documentation on the subject of   `udev, sysfs & i2c devices`. And it's just as Neil Brown described it in his article; the fundamental problem is a lack of clear definitions of the terminology used. Is *computer science* an oxymoron? How would the real sciences have gotten on with such sloppy habits? 

### OK - rant over, let's get down to cases:

I had a problem with [this recipe](SHT3X_T&H_Sensor.md)! The problem was that the folder containing the 'sht3x' sensor data (temperature & humidity) ***changed names*** after a `reboot`, or if another sensor was added. An inconsistent device folder name meant that my script would need to `grep` (or `find`) the new folder location at each invocation - or cache it in `/tmp`. This was a [*"shell game"*](https://en.wikipedia.org/wiki/Shell_game) I did not want to play! 

I found an article titled ['Rules on how to access information in sysfs'](https://www.kernel.org/doc/html/latest/admin-guide/sysfs-rules.html) published as an element of documentation for the Linux kernel. The article was reasonably straightforward AFAICT - except that some of the "rules" made no sense to me (that terminology problem again). But there was also this:

> To minimize the risk of breaking users of sysfs, which are in most cases low-level userspace applications, with a new kernel release, the users of sysfs must follow some rules to use an as-abstract-as-possible way to access this filesystem. *<u>The current udev and HAL programs already implement this and users are encouraged to plug, if possible, into the abstractions these programs provide instead of accessing sysfs directly</u>.*

And so I launched into reading about `udev`. I'd heard of it, but had never actually *used* it (big difference!). I've listed below some *"How-To"* references for `udev` that I found useful, but in fairly short order I had cobbled together a `.rule` file. Following is my initial result at a `.rules` file: 

```
ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="sht3x", KERNELS=="0-0044", SUBSYSTEMS=="i2c", SYMLINK+="i2c_sht3x"
```

For those who've never *mucked* around w/ `udev`, the "rule" consists mainly of **match keys** and **assignment keys**. In general,  **match keys** use the `==` test to determine a *match*, and **assignment keys** use `=` or `+=` to designate something that is to be done in the event of a *match*. *NB: This is a gross simplification, but hopefully communicates the basic idea of the "rule"*. 

You might be wondering, *"where did you get all of this jargon for the rule?"*, and you would be right to wonder! The answer is I asked for it with this command:

```bash
$ udevadm info --attribute-walk --path=/sys/bus/i2c/devices/0-0044/hwmon/hwmon3
```

I won't clutter this recipe with the output of this command (it's fairly verbose), but I've posted a couple of samples at [pastebin](https://pastebin.com/u/seamusdemora/1/b9sATeVz) that you can review if you'd like. The terms/parameters chosen for the **match keys** were mostly *trial-and-error*, but I had some examples to use as *go-bys*. 

I tested the rule (following [this idea](https://opensource.com/article/18/11/udev#comments)) by replacing the `SYMLINK`  **assignment key** with a command to run a shell script that wrote to a file. The rule file was named **`/etc/udev/rules.d/80-local.rules`** 

```
ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="sht3x", KERNELS=="0-0044", SUBSYSTEMS=="i2c", RUN+="/bin/sh -c 'echo "success" > /tmp/udev_test.txt'"
```

This *actually worked*, which told me I was probably on the right track. At least I knew my **match keys** were filtering *some thing* out of the stream, and I thought it likely it was the *right thing* based on the parameters.

I changed my rule again to restore the `SYMLINK+="i2c_sht3x"`  **assignment key**, and I had great confidence that I would find a symlink named `i2c_sht3x` in my `/dev`  folder after the next `reboot`. *But I was disappointed...* No such symlink appeared. I spent a fruitless couple of hours searching for an explanation. Then it occurred to me to try *some thing else* - the following rule was put in place, and ***IT WORKED***:  

#### THE WORKING RULE:

See the [complete, fully-commented `80-local.rules` file here in the `source` folder.](source/80-local.rules)  

```
ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="sht3x", KERNELS=="0-0044", SUBSYSTEMS=="i2c", RUN+="/bin/sh -c 'ln -s /sys$devpath /dev/hwmon_sht3x'"
```

As I write this, I still do not know why the `SYMLINK+="i2c_sht3x"`  **assignment key** did not work. However, I do have some confidence in the **WORKING RULE**. I hope you'll try it, and would like to get your feedback. 



### REFERENCES: 

1. [An introduction to Udev: The Linux subsystem for managing device events](https://opensource.com/article/18/11/udev) 
2. [Writing udev rules](http://www.reactivated.net/writing_udev_rules.html); a bit dated, but still useful! 
3. [Monitor Device Events in Linux](https://www.baeldung.com/linux/monitor-device-events); a Baeldung article
4. [Scripting with udev](http://jasonwryan.com/blog/2014/01/20/udev/); if you need to invoke `systemd` from `udev` 
5. [The Linux Hardware Monitoring kernel API - Linux Kernel documentation](https://www.kernel.org/doc/html//v6.8-rc3/hwmon/hwmon-kernel-api.html); i.e. what is `hwmon`? 
6. [Linux I2C Sysfs - Linux Kernel documentation](https://www.kernel.org/doc/html/latest/i2c/i2c-sysfs.html) 
7. [Rules on how to access information in sysfs - Linux Kernel documentation](https://www.kernel.org/doc/html/latest/admin-guide/sysfs-rules.html) 
8. [How to instantiate I2C from the userspace](https://erlerobotics.gitbooks.io/erle-robotics-erle-brain-a-linux-brain-for-drones/content/en/tutorials/i2c.html) 
9. [Naming and data format standards for sysfs files - Linux Kernel documentation](https://www.kernel.org/doc/html/latest/hwmon/sysfs-interface.html) 
10. [kernel.org/doc/Documentation/hwmon/sysfs-interface](https://www.kernel.org/doc/Documentation/hwmon/sysfs-interface); could this be any more disorganized?  

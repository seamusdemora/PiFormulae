## Why is my SSH session [*"sluggish"*](https://www.merriam-webster.com/dictionary/sluggish) ? 

### (a.k.a. *How to disable WiFi power saving*)

Energy (or power) saving *can be* a worthwhile goal... Or, it can be a moronic waste of time and effort by OCD nerds, [industry consortiums](https://www.wi-fi.org/system/files/Power%20Saving%20Features%20Highlights.pdf) bent toward *political correctness*, out-of-touch academics and other idiots on the fringe of sanity. For me - my *"engineering brain"* has only one question when the subject of energy conservation comes up: ***How much energy are we going to save?*** (here's [one answer](https://www.howtogeek.com/775520/should-you-leave-your-wi-fi-router-and-modem-on-all-the-time/) to that Q)

That seems an entirely reasonable question to me. The simple truth is that resources will be expended to achieve these energy savings, and if the energy savings cannot "cover the cost" of the investment, then we are on a [*fool's errand*](https://www.merriam-webster.com/dictionary/fool%27s%20errand). I'll venture to guess that owing to the current surplus of fools today, they are engaged in  far too many errands already - we certainly don't need more! 

I became interested in this subject of **"WiFi Power Saving"** while investigating the cause of the ["laggy](https://www.merriam-webster.com/dictionary/laggy) performance" I saw in SSH sessions between my Mac and several of my Raspberry Pis. I was shocked to learn that *somewhere along the line* the default "power save" option has been changed to "Yes" (i.e. wifi power saving is enabled). 

I've not yet completed my investigation, but through elimination it currently appears that a kernel driver(s) is the culprit. This is *even more amazing*... I can see some logic for "WiFi Power Saving" in battery-powered devices, but its practical applicability to mains-powered devices is (or should be) near zero. I have no statistics, but imagine the "mainline" Linux kernel is used in far more mains-powered than battery-powered applications. Could it be that Linux kernel development is on a  *fool's errand*? I just don't know yet. 

I'll belay this line of discussion for now; I imagine most are interested in how to cure this malfeasance than how it came to be.

But make no mistake: the **default** setting for `power_save` in (at least) the two most recent OS releases ('bullseye', 'bookworm') is ***enabled***. This is easily confirmed as follows: 

```bash
iw wlan0 get power_save 
# you'll get one of two responses:
Power save: on
# --OR--
Power save: off
```

Of my 4 RPi systems that are either 'bullseye' or 'bookworm', all 4 had `Power save: on`. (And I sure as hell didn't set it :-)  

### How to "permanently" disable WiFi `power_save`: 

There are two (2) methods: 

1. use the root `crontab`:

   ```bash 
   $ sudo crontab -e
   # add the following line at the bottom of the root crontab:
   @reboot /usr/sbin/iw wlan0 set power_save off > /home/<user>/power_save_log.txt 2>&1
   # substitute a valid folder/user name for '<user>' above
   ```

2. use Network Manager's `nmcli`:

   ```bash
   $ sudo nmcli con mod preconfigured wifi.powersave disable
   ```

   Note that this works only for the `preconfigured` connection profile (i.e. `/etc/NetworkManager/system-connections\preconfigured.nmconnection`); if you create other profiles, you will need to apply it there as well. 

---

### References for Further Reading:

1. [Power Save Methods](https://howiwifi.com/2020/06/25/power-save-methods/) : An overview of several WiFi Power Save schemes since 1997.
2. [Under the hood: Wi-Fi power save](https://www.networkworld.com/article/828943/network-security-under-the-hood-wi-fi-power-save.html) : 2007 Network World article by Joanie Wexler
3. [Should You Leave Your Wi-Fi Router & Modem on All the Time?](https://www.howtogeek.com/775520/should-you-leave-your-wi-fi-router-and-modem-on-all-the-time/) : The $ cost of energy considered!
4. [Increasing device power efficiency](https://www.wi-fi.org/system/files/Power%20Saving%20Features%20Highlights.pdf) : From a politically-motivated industry consortium
5. [How does WMM-Power Save work?](https://www.wi-fi.org/knowledge-center/faq/how-does-wmm-power-save-work) : Some details on WMM
6. [Wi-Fi power conservation: Standards and beyond](https://www.networkworld.com/article/803934/network-security-wi-fi-power-conservation-standards-and-beyond.html) : yes... way beyond 💤  
7. [The Low-Power Advantage of Wi-Fi 6/6E: TWT Explained](https://www.renesas.com/us/en/blogs/low-power-advantage-wi-fi-66e-twt-explained) : once again - for *battery-powered* devices 
8. [How do you educate and engage users on WiFi power saving options and benefits?](https://www.linkedin.com/advice/0/how-do-you-educate-engage-users-wifi-power-saving-options) : propaganda!
9. Articles I Did Not See: WiFi energy usage vs Harry & Megan's private jet energy usage  :)
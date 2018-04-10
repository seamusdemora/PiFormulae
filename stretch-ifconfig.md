If you're anywhere short of [omniscience](https://en.wikipedia.org/wiki/Omniscience), you may mistakenly try to use some of the networking utilities and config files that were in use prior to the release of "**stretch**". For example, you may have mistakenly tried to use `ifupdown` to enable or disable your interfaces... you may have noted that **`ifupdown`** is still included in the distribution - it just doen't <u>**do**</u> anything. The `man` page is still in the distribution - which may add to your confusion, perhaps even caused you to wonder if you're too thick to use simple utilities provided in the distro. Similarly, **`ifplugd`** is still in the distro (altho' not in an executable path), but at least the `man` page has been pulled. I could go on, but the rant isn't worth expenditure of additional effort. 

So, here's how to bring interfaces up and down in "**stretch**" using the tools included in the distribution:

`sudo ifconfig wlan0 down`   ... to bring your wifi interface down 

`sudo ifconfig wlan0 up`   ... to bring your wifi interface up

more to follow...

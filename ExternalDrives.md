Why?

The Raspberry Pi 3B+ has 4 USB 2.0 ports, and external drives can be useful for all sorts of things.

Since I deploy my RPi's in headless mode, and I'm a Mac user, the approach on this page reflects that. Another decision I've made that drives some elements of the approach here is my choice to use the exFAT file system on external drives connected to the RPi. I've chosen exFAT for the simple reasons that: a) it's supported by Linux, MacOS and Windows, and b) it doesn't have the confining limits on file size that FAT & FAT32 do. If you want to use another filesystem, [@wjglenn](https://twitter.com/wjglenn) has written a [good article in How-To Geek reviewing the tradeoffs between the most widely-used filesystems](https://www.howtogeek.com/73178/what-file-system-should-i-use-for-my-usb-drive/). If you're on board with that, let's get into the details: 

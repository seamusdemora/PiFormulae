## How Do I Connect an External Drive to a Raspberry Pi?

#### And Why Would I Want to Do This?
    
    1. The Raspberry Pi 3B+ has 4 USB 2.0 ports, and 
    2. external drives can be useful for all sorts of things:
        * local backup of RPi files, or a 'disk image' of the entire SD card
        * file sharing with your Mac, PC or another RPi 
        * reduce wear on your SD card 
        * thumb drives are cheap 

Since I deploy my RPi's in headless mode, and I'm a Mac user, the approach on this page reflects that. Another decision I've made that drives some elements of the approach here is my choice to use the exFAT file system on external drives connected to the RPi. I've chosen exFAT for the simple reasons that: a) it's supported by Linux, MacOS and Windows, and b) it doesn't have the limits on file size that FAT & FAT32 do. If you want to use another filesystem, [@wjglenn](https://twitter.com/wjglenn) has written a [good article in How-To Geek reviewing the tradeoffs between the most widely-used filesystems](https://www.howtogeek.com/73178/what-file-system-should-i-use-for-my-usb-drive/). If you're on board with all of that, let's get into the details: 


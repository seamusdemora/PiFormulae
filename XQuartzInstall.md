download & install XQuartz (https://www.xquartz.org/) on Mac

start XQuartz

ssh -Y pi@raspberrypi123.local

verify that the file ~/.Xauthority is present (https://www.raspberrypi.org/forums/viewtopic.php?t=161412) (https://www.raspberrypi.org/documentation/remote-access/ssh/unix.md)

sudo raspi-config [enable camera]

sudo apt-get install idle3 

sudo apt-get install python3-picamera

idle3 &  (see screenshot)

FROM THE RPI DOCS: "Note that the camera preview only works when a monitor is connected to the Pi, so remote access (such as SSH and VNC) will not allow you to see the camera preview"

WTF,O???

How do I see the pics?

#!/usr/bin/python

http://picamera.readthedocs.io/en/release-1.0/quickstart.html

-or-

raspistill -o image003.jpg


# Do things with the "Pi Camera":

I thought that setting up X on my Mac would allow me to to "preview" the PiCamera output in XQuartz, but then I ran across this statement: 

    FROM THE RPI DOCS: "Note that the camera preview only works when a monitor is connected to the Pi, 
    so remote access (such as SSH and VNC) will not allow you to see the camera preview"

So... WTFO?!?  How do I see the pics?

Several ways are possible, but as "live view" or "streaming" isn't available from the RPi, perhaps the most convenient way is to mount a network drive in RPi that my Mac also has mounted. Once that drive is mounted, use it as the destination for pictures and video from the RPi. Once that's set up, following are some methods for getting output from the PiCamera: 

## 1. Using Python 

  [There are reasonably thorough docs covering the PiCamera](http://picamera.readthedocs.io/en/release-1.0/quickstart.html)

  Here's a simple Python script that outputs a single picture: 
  
    #!/usr/bin/python


## 2. From the command line


    raspistill -o image003.jpg


* [convert the H.264 format videos to MP4](https://www.raspberrypi.org/documentation/usage/camera/raspicam/raspivid.md)

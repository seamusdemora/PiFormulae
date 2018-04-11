# Do things with the "Pi Camera":

I thought that setting up X on my Mac would allow me to to "preview" the PiCamera output in XQuartz, but then I ran across this statement: 

    FROM THE RPI DOCS: "Note that the camera preview only works when a monitor is connected to the 
    Pi, so remote access (such as SSH and VNC) will not allow you to see the camera preview"

So... WTFO?!?  How do I see the pics?

Several ways are possible, but perhaps the quickest/easiest way is to mount a network drive in RPi that my Mac also has mounted. Once that drive is mounted, use it as the destination for pictures and video from the RPi. Once that's set up, following are some methods for getting output from the PiCamera: 

## 1. Using Python 

   Here's a simple Python script that outputs a single 640x480 picture: 
   
    #!/usr/bin/python

    import picamera
    import time

    with picamera.PiCamera() as camera:
	   camera.resolution = (640, 480)
	   camera.start_preview()
	   time.sleep(2)
	   camera.capture('foopic.png')
	   camera.stop_preview()

There's a lot more you can do in Python... the [API gives you a lot of control, and there are reasonably thorough docs covering the PiCamera](http://picamera.readthedocs.io/en/release-1.0/quickstart.html)

## 2. From the command line

You can get photos/snapshots or videos easily and quickly with the following commands; the bad news is no `man` pages :(  However, there's a [page on the .org's website that gives a seemingly complete rundown](https://www.raspberrypi.org/documentation/raspbian/applications/camera.md). 

`  raspistill -o image003.jpg`  (substitute a filename and format of your choosing of course) 

`  raspivid -o mymovie.h264 -t 10000`   (creates a 10,000 msec/10 sec video)

And there's one more bit of bad news for video producers: the only video format available is H.264, and it's not widely used - at least there aren't many apps that will play it directly. However, there is some support for bridging that gap. You can [convert the H.264 format videos to MP4 using `MP4Box`.](https://www.raspberrypi.org/documentation/usage/camera/raspicam/raspivid.md)

Oddly, installed (it looks huge) and used as follows: 

    sudo apt-get install -y gpac
    MP4Box -add mymovie.h264 mymovie.mp4



## 3. Focusing PiCamera

[It's the focus, stupid!](https://en.wikipedia.org/wiki/It%27s_the_economy,_stupid) OK, so I realize that for £24 you can't expect a pro-quality DSLR. But this PiCamera (and the people in the Raspberry Pi organization that make decisions and profit from its sales) is not quite [up to snuff](https://dictionary.cambridge.org/dictionary/english/up-to-snuff)! I'll belay my rant for another day, but here's what you need to know: 
#### `TURN THE FOCUS RING FULLY CCW AS YOU'RE FACING THE CAMERA` 

## 4. Streaming

I've not had time to actually try streaming myself. Until I do, following are a few URLs with some information that may be useful: 

* [a post on the StackExchange forum, How to stream video from Raspberry Pi...](https://raspberrypi.stackexchange.com/questions/23182/how-to-stream-video-from-raspberry-pi-camera-and-watch-it-live)

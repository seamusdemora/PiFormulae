## Building libgpiod-ver2.1 on a *bullseye* system

This *recipe* is for building the latest version of `libgpiod` on a `bullseye` system (aka `.oldstable`). 

1. The tarball is obtained as follows: 

	```bash
	$ curl -o libgpiod-2.1.tar.gz 'https://git.kernel.org/pub/scm/libs/libgpiod/libgpiod.git/snapshot/libgpiod-2.1.tar.gz'
	```

2. Some tools are needed: 

	```bash
	$ sudo apt install tar gzip build-essential autoconf
	```

​	You may have all of these, but getting them now will avoid errors later on. 

3. Un-tar the d/l file

  ```bash
  $ tar xf libgpiod-2.1.tar.gz
  ```

4. Check out the un-tarred folder & review the README:

  ```bash
  $ cd libgpiod-2.1
  $ less README
  ```

5. Do some more reading: The Linux [Program Library HOWTO](https://tldp.org/HOWTO/Program-Library-HOWTO/shared-libraries.html). 

  ```bash
  ```

6. Before `make && make install`, explore the filesystem where the old/existing (ver 1.6 as I write this) libraries are kept, and make notes:

  ```bash
  $ whereis libgpiod
  libgpiod: /usr/lib/arm-linux-gnueabihf/libgpiod.a /usr/lib/arm-linux-gnueabihf/libgpiod.so 
  # now we know where things are kept... let's visit:
  $ ls -l /usr/lib/arm-linux-gnueabihf | less
  
  # you may want to copy & paste this to a file for subsequent reference:
  $ ls -l /usr/lib/arm-linux-gnueabihf | grep libgpiod
  
  -rw-r--r--  1 root root    32258 Dec 20  2020 libgpiod.a
  -rw-r--r--  1 root root   139276 Dec 20  2020 libgpiodcxx.a
  lrwxrwxrwx  1 root root       20 Dec 20  2020 libgpiodcxx.so -> libgpiodcxx.so.1.1.1
  lrwxrwxrwx  1 root root       20 Dec 20  2020 libgpiodcxx.so.1 -> libgpiodcxx.so.1.1.1
  -rw-r--r--  1 root root    66976 Dec 20  2020 libgpiodcxx.so.1.1.1
  lrwxrwxrwx  1 root root       17 Dec 20  2020 libgpiod.so -> libgpiod.so.2.2.2
  lrwxrwxrwx  1 root root       17 Dec 20  2020 libgpiod.so.2 -> libgpiod.so.2.2.2
  -rw-r--r--  1 root root    25912 Dec 20  2020 libgpiod.so.2.2.2
  ```

7. **DETOUR !!   ====>  (JUMP TO STEP 10)**

8. From the `README` in Step 4. above, review the steps for building the library: 

  ```bash
  # ./autogen.sh --enable-tools=yes --prefix=<install path>
  $ pwd
  /home/pi/libgpiod-2.1
  $ ./autogen.sh --enable-tools=yes --prefix=/usr/lib/arm-linux-gnueabihf
  autoreconf: Entering directory `.'
  autoreconf: configure.ac: not using Gettext
  autoreconf: running: aclocal --force -I m4
  aclocal: warning: couldn't open directory 'm4': No such file or directory
  autoreconf: configure.ac: tracing
  autoreconf: configure.ac: not using Libtool
  autoreconf: running: /usr/bin/autoconf --force
  configure.ac:203: error: Unexpanded AX_ macro found. Please install GNU autoconf-archive.
        If this token and others are legitimate, please use m4_pattern_allow.
        See the Autoconf documentation.
  autoreconf: /usr/bin/autoconf failed with exit status: 1 
  
  # bummer!
  ```

9. Try installing the `install GNU autoconf-archive`:

  ```bash
  $ sudo apt install autoconf-archive
  
  ...
  
  autoreconf: automake failed with exit status: 1
  
  # bummer!   Try following advice/suggestions in error message
  ```

10. **END DETOUR** 

11. As I learned in the DETOUR, there are some steps that must be completed prior to successful compilation. I should have read `/usr/share/doc/libgpiod-dev/README.gz` first. This is the *"RPi Version"* of the more generic `README` file in `./libgpiod-2.1`, and it contains ***important exceptions & additions*** including this : 

	>Recent kernel headers are also required for the GPIO user API definitions. For the exact version of kernel headers required, please refer to the configure.ac contents. 
	
	But what are *recent kernel headers*? `configure.ac` doesn't provide any guidance. So, we'll have to rely on *guesswork*... (actually, install them all). 
	
	```bash
	$ zless /usr/share/doc/libgpiod-dev/README.gz
	$ apt-cache search linux-headers 
	# ... and at the end of that list: 
	raspberrypi-kernel-headers - Header files for the Raspberry Pi Linux kernel
	# following more trial and error, install the following packages:
	$ sudo apt install raspberrypi-kernel-headers autoconf-archive libtool help2man
	#
	# now ready to go to work
	$ cd /home/pi/libgpiod-2.1
	$ pwd
	/home/pi/libgpiod-2.1
	$ ./autogen.sh --enable-tools=yes --prefix=/usr/lib/arm-linux-gnueabihf  --enable-gpioset-interactive
	# ...
	config.status: executing libtool commands
	$ make
	$ sudo make install
	```
	
12. There have been a few changes to `/usr/lib/arm-linux-gnueabihf`, but the ***new*** tools and `man` pages **have not** been moved into place - which means that the freshly-compiled stuff is floating around the filesystem somewhere!  Actually this freshly-compiled stuff  is in folders ***under***  `/usr/lib/arm-linux-gnueabihf`, but some **manual intervention** is needed to **temporarily** **upgrade** the binaries and the `man` pages. 

	```bash
	$ sudo mkdir /usr/bin/old-gpio
	$ sudo mv /usr/bin/gpio?* /usr/bin/old-gpio   #for subsequent restoration if needed
	$ cd /usr/lib/arm-linux-gnueabihf
	$ pwd
	/usr/lib/arm-linux-gnueabihf
	$ sudo cp -a ./bin/gpio* /usr/bin   # cp new gpiod tools where needed: /usr/bin
	# and we need the new man pages, so ... 
	$ export MANPATH="/usr/lib/arm-linux-gnueabihf/share/man:$(manpath)"
	#
	# NOTE: you should probably add the `export MANPATH` definition above into 
	# ~/.profile if you plan on using it for any length of time; i.e.
	$ echo -e '\nexport MANPATH="/usr/lib/arm-linux-gnueabihf/share/man:$(manpath)"' >> ~/.profile
	```
	
	In addition to the `./bin` and `./share` folders (above), there were two other folders created under `/usr/lib/arm-linux-gnueabihf`: `./lib`, and `./include`.  These folders contain the `libgpiod.so` binary, and the `gpiod.h` header file needed to compile apps using the new ver 2.1 library. Let's take care of those now: 
	
	```bash
	$ sudo mkdir /usr/lib/arm-linux-gnueabihf/old-libgpiod
	$ sudo mv /usr/lib/arm-linux-gnueabihf/libgpiod* /usr/lib/arm-linux-gnueabihf/old-libgpiod 
	$ sudo cp ~/libgpiod-2.1/include/gpiod.h /usr/include
	$ sudo cp -a /usr/lib/arm-linux-gnueabihf/lib/libgpiod.* /usr/lib/arm-linux-gnueabihf
	$ ls -l /usr/lib/arm-linux-gnueabihf | grep libgpiod.*
	-rw-r--r--  1 root root   164256 Dec 20 02:46 libgpiod.a
	-rwxr-xr-x  1 root root      957 Dec 20 02:46 libgpiod.la
	lrwxrwxrwx  1 root root       17 Dec 20 02:46 libgpiod.so -> libgpiod.so.3.1.0
	lrwxrwxrwx  1 root root       17 Dec 20 02:46 libgpiod.so.3 -> libgpiod.so.3.1.0
	-rwxr-xr-x  1 root root   114436 Dec 20 02:46 libgpiod.so.3.1.0
	drwxr-xr-x  2 root root     4096 Dec 21 04:06 old-libgpiod
	```
	
	Which looks like everything is accounted for...
	
	

### And that concludes this recipe - for now.








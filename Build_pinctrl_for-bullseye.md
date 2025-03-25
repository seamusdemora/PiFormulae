## Building 'pinctrl' on a *bullseye* or *bookworm* system 

This *recipe* is for building the latest version of `pinctrl` on a `bullseye` (or `bookworm`) system (aka `.oldstable`). `pinctrl` is a potentially useful adjunct in our testing and experimentation with `libgpiod`. 

1. `pinctrl` is a member of the [`utils` repo](https://github.com/raspberrypi/utils/tree/master) at the Raspberry Pi GitHub site. For reasons that are not clear to me, cloning this repo is a *two-step* process: 

   - Go to the [GitHub site](https://github.com/raspberrypi/utils/tree/master), and **"fork"** the 'utils' repo to your GitHub account


   - From your RPi, execute a `git clone https://github.com/seamusdemora/utils` 

     note: you should use **your** clone, not mine, as I'm unlikely to keep mine updated) 

2. Get some tools: 

   ```bash
   $ sudo apt update
   $ sudo apt install cmake device-tree-compiler libfdt-dev
   ```

3. Build it following the instructions in the GitHub repo

   ```bash
   $ cd ~/utils/pinctrl
   $ cmake .
   $ make
   $ sudo make install
     ...
     -- Installing: /usr/local/bin/pinctrl
     ...
   $ pinctrl help | less    # to access the documentation 
   ```



### And that concludes this recipe - for now.




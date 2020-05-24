**Q:** I need some details on the GPIO (General Purpose Input Output) pins on the Raspberry Pi for a project I've undertaken. However, as I understand it, significant pieces of the Raspberry Pi hardware design are considered "proprietary", and consequently, the documentation is not available. What are the *"definitive sources"* for GPIO documentation? Is the GPIO documentation "complete"? 

**A:** The "definitive sources" of documentation on the Raspberry Pi are published by the [Raspberry Pi Foundation](https://en.wikipedia.org/wiki/Raspberry_Pi_Foundation) on the [RPi documentation website](https://www.raspberrypi.org/documentation/), and on the [RPi GitHub documentation page](https://github.com/raspberrypi/documentation). The GPIO documentation is part of this overall web-based repository, and it is augmented by several documents that provide additional details. Raspberry Pi's documentation on the GPIO is mostly contained in, or available through, the following URLs: 

- [The "Usage" documentation](https://www.raspberrypi.org/documentation/usage/gpio/README.md) 
- [The Hardware documentation](https://www.raspberrypi.org/documentation/hardware/raspberrypi/gpio/README.md) 
- [The Supplementary documentation](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2835/README.md), incl the [BCM2835 *"System on a Chip"* documentation](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2835/BCM2835-ARM-Peripherals.pdf) 
- [There is also an "errata sheet" on the BCM2835 maintained by eLinux](https://elinux.org/BCM2835_datasheet_errata), several pertain to GPIO details. 
- [The Raspberry Pi Compute Module Data Sheet](https://github.com/raspberrypi/documentation/blob/master/hardware/computemodule/datasheets/rpi_DATA_CM_2p0.pdf) 

There is an extensive set of documentation then, published or referenced by "The Foundation". However, there is more that's outside that set of documentation. The following is not intended to be a comprehensive list, but will be updated from time to time as new sources are identified: 

- [An extract from BCM2835 full data sheet; Gert van Loo, 2-August-2012](https://www.scribd.com/doc/101830961/GPIO-Pads-Control2)  <sup>1</sup> 
- [A C header file w/ macros & masks for GPIO](https://www.scribd.com/document/296129270/bcm2835-h) 
- [GPIO Library: `pigpio`](http://abyz.me.uk/rpi/pigpio/) 
- [GPIO Library: `wiringPi`](http://wiringpi.com/) 
- [Other GPIO Libs; listed here with sample code in many languages (C, C#, Ruby, Perl, Python, shell, etc)](https://elinux.org/RPi_GPIO_Code_Samples) 





------

REFERENCES & NOTES:

1. While the provenance of this document is not completely known, it *clearly shows* there are GPIO functions that are not included in The Foundation's "official documentation". 
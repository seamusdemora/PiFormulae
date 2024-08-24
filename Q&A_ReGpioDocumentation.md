**Q:** I need some details on the GPIO (General Purpose Input Output) pins on the Raspberry Pi for a project I've undertaken. However, as I understand it, significant pieces of the Raspberry Pi hardware design are considered "proprietary", and consequently, the documentation is not available. What are the *"definitive sources"* for GPIO documentation? Is the GPIO documentation "complete"? 

<!---
**A:** Definitive sources of GPIO documentation for the Raspberry Pi computers are published by the "Raspberry Pi Organization"; this organization has now become [a complex web of charitable and for-profit organizations](https://en.wikipedia.org/wiki/Raspberry_Pi#Origins_and_company_history). The financial success of "The Organization" coupled with their desire/need to maintain proprietary interest in the hardware and firmware has, unfortunately, led to less documentation rather than more. That is not intended to be a negative or judgmental statement; it merely reflects my observations and interactions with "The Organization" over a period of years. And it is not intended to suggest that the volume and quality of the documentation is insufficient for most usage. Clever people are still making inroads and discoveries! 

-->

**A:** The "definitive sources" of documentation on the Raspberry Pi are published by the [Raspberry Pi Foundation](https://en.wikipedia.org/wiki/Raspberry_Pi_Foundation) on the [RPi documentation website](https://www.raspberrypi.org/documentation/), and on the [RPi GitHub documentation page](https://github.com/raspberrypi/documentation). The GPIO documentation is part of this overall web-based repository, and it is augmented by several documents that provide additional details. Raspberry Pi's documentation on the GPIO is mostly contained in, or available through, the following URLs: 

- [The "Usage" documentation](https://www.raspberrypi.org/documentation/usage/gpio/README.md) 
- [The GPIO documentation](https://www.raspberrypi.org/documentation/hardware/raspberrypi/gpio/README.md)
- [The Hardware documentation](https://www.raspberrypi.org/documentation/hardware/raspberrypi/) (which is a bit inconsistent in places) includes:  
  - the [BCM2837B0, a.k.a. the Broadcom processor used in Raspberry Pi 3B+ and 3A+](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2837b0/README.md) (no PDF)
  - the [BCM2711, a.k.a. the Broadcom processor used in Raspberry Pi 4B](https://www.raspberrypi.org/documentation/hardware/raspberrypi/bcm2711/rpi_DATA_2711_1p0.pdf) (PDF)
- [There is also an "errata sheet" on the BCM2835 maintained by eLinux](https://elinux.org/BCM2835_datasheet_errata), several pertain to GPIO details. The data on this eLinux site is a bit out-of-date last checked, but may still be useful. 
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

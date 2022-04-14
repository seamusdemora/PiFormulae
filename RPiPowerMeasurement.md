## Measuring Power Consumption of the Raspberry Pi



[Power](https://en.wikipedia.org/wiki/Power_(physics)) - in this case [Electrical Power](https://en.wikipedia.org/wiki/Electric_power) - is a measure of the energy transferred/consumed per unit of time. The unit of measure for power is called a *watt*, and is defined by the product of voltage and current. For the dc/time-invariant case: 

### P = V × I

Measuring the RPi's power consumption requires the *physical quantities* of [**voltage**](https://en.wikipedia.org/wiki/Volt) and [**current**](https://en.wikipedia.org/wiki/Electric_current) be measured at the RPi's input terminals. Power consumption may be *calculated* in software, but its voltage and current must be *measured* with a [transducer](https://en.wikipedia.org/wiki/Transducer). The transducer's function is to convert a physical quantity to **data** that the software can read and use to make the calculations. 

### Off-the-shelf Power Measurement 

In addition to general-purpose instruments such as voltmeters and ammeters, there are a huge number of *USB gadgets* that measure current, voltage and power. A [quick Internet search](https://duckduckgo.com/?q=USB+power+meter&t=ffnt&iax=images&ia=images) reveals many of these, mostly available from the usual outlets. At least [one of these devices has a Bluetooth interface](https://www.makerhawk.com/products/makerhawk-um25c-usb-tester-bluetooth-usb-meter-type-c-current-meter-usb-power-meter-dc-24-000v-5-0000a-usb-cable-tester-1-44-inch-color-lcd-multimeter-voltage-tester-usb-load-qc-2-0-qc-3-0) that may be used to fetch readings from the device for recording or analysis purposes. Otherwise, they mostly all display the data on a small screen in a similar fashion as the device below. 

![usb-power-meter](/Users/jmoore/Documents/GitHub/PiFormulae/pix/usb-power-meter.jpg)

### DIY measurement

This will require more effort. 

Let's start with measuring voltage: The analog input of an "Analog-to-Digital Converter" (ADC) may be wired to the power input. The voltage readings are (typically) transferred to the CPU for processing via a serial port - SPI or I2C. This is reasonably straightforward, and there are many hardware and software examples available online. 

Measuring voltage is *"non-invasive"* in that it only requires a wiring connection from the ADC analog input to an existing contact on the RPi. Current measurement is a different animal... current **flows**, and if you want to measure the flow, you must **break** the connection coming into the board, and insert your ammeter there. Yeah - a bit messy. One way to build a prototype is with a USB breakout board.  [This one would work](http://elabguy.com/datasheet/USB3.1-CM-CF-V3A%20Rev1.0.pdf); it provides access to all of the wiring in a USB-C cable connection. 

[![USB C breakout board][2]][2]

Now that we've got a point to insert the ammeter, we must choose the type of ammeter to use. We'll limit ourselves here to two alternatives, [although there are others](https://en.wikipedia.org/wiki/Hall_effect#The_Corbino_effect): 

1. a current shunt 

2. a Hall Effect sensor

What are the primary specifications to consider in selecting an ammeter? 

   * For a Raspberry Pi, a measurement range of 0-5 Amps will be sufficient  
   * The current sensor should not cause a **significant** voltage drop 

With respect to current shunt vs Hall Effect, one trade-off is that the current shunt (a small resistance) will reduce the voltage delivered to the RPi, whereas the Hall Effect device will be (almost) too small to measure. 

[Allegro Microsystems' ACS712](https://www.allegromicro.com/en/Products/Sense/Current-Sensor-ICs/Zero-To-Fifty-Amp-Integrated-Conductor-Sensor-ICs/ACS712) uses Hall Effect technology to measure current over a claimed range of 0 - 50 amps with an effective series resistance of only 1.2x10<sup>-3</sup>𝛀. It may also be purchased as a sensor module from various vendors, similar to the picture below: 

[![Hall Effect Ammeter][3]][3]

Perhaps a larger consideration in choosing the voltmeter and ammeter is the integration effort. [Texas Instruments' INA260](https://www.ti.com/lit/ds/symlink/ina260.pdf?ts=1605660546405) measures current with an integrated shunt resistor, and will also serve as a voltmeter. Both voltage and current readings are transferred over a single I<sup>2</sup>C interface. DIY power measurement could scarcely be any easier - and [coding examples are available from numerous sources](https://duckduckgo.com/?t=ffnt&q=INA260+source+code+examples&ia=web). The INA260 is said to measure 0-15 Amps, with a shunt resistance of 2x10<sup>-3</sup>𝛀. This equates to a voltage drop of approximately 2 mV at the RPi input terminals - only 800𝛍V more than the Hall Effect device. 

[![enter image description here][4]][4]

The [INA260 is also available as a sensor module](https://learn.adafruit.com/adafruit-ina260-current-voltage-power-sensor-breakout) to simplify hardware integration:

[![enter image description here][5]][5]


[1]: https://i.stack.imgur.com/RclyT.jpg
[2]: https://i.stack.imgur.com/Ryd9H.jpg
[3]: https://i.stack.imgur.com/kT44B.jpg
[4]: https://i.stack.imgur.com/uQjRL.png
[5]: https://i.stack.imgur.com/kvFXx.jpg
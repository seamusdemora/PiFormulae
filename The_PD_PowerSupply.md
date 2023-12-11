Each new model of RPi ["pushes the envelope"](https://www.merriam-webster.com/wordplay/push-the-envelope-idiom-space-aeronautics-origin) in terms of the amount of power it draws over a USB electrical interface. The RPi 4 was spec'd to require up to 15 watts: 3 Amps at 5 Volts. Three (3) Amps was at or near the ["ragged edge"](https://www.merriam-webster.com/dictionary/on%20the%20ragged%20edge) of the current-carrying capacity for the power wiring in a USB-C cable - typically 22 or 24 AWG. Now, the RPi 5 is spec'd to require 5 Amps. 

How do they do this? Are they violating USB "standards", or have they somehow compromised the performance of their new RPi 5 for the sake of retaining a USB power interface?

My analysis follows:



---

AFAIK, RPi.com has violated no USB standards - [since the RPi4](https://raspberrypi.stackexchange.com/a/105819/83790)  (⊙<sub>∆</sub>⊙).

Instead, it is the standards themselves which have changed. Specifically, the latest addition to the line of **"Official"** power supplies is the [*"Raspberry Pi 27W USB-C Power Supply"*](https://datasheets.raspberrypi.com/power-supply/27w-usb-c-power-supply-product-brief.pdf), which provides up to 5A current at +5.1V. This supply may have been accommodated by the *new-ish* **Power Delivery (PD)** additions to the USB standard that were announced back in 2019. 

You might wonder what's in this new PD standard - the *details*, IOW To answer that, there is a ["Developer's" Briefing](https://www.usb.org/sites/default/files/D2T2-1%20-%20USB%20Power%20Delivery.pdf), and there is a specification document - [embedded in this .zip file](https://www.usb.org/sites/default/files/USB%20PD%20R3.2%20V1.0_1.zip). These are both *interesting* documents for different reasons. The **briefing** comes across as a product of fevered minds plotting to take over the world. The **specification** document is 1,113 pages, including 7 full pages (double column) listing the "Contributors". The companies listed as "Contributors" give you clues that this is all motivated by money. Now when you look at the USB cable you bought from Amazin' for $8-$10 with the official "logo" stamped on it, you can understand what's going on. 

Lest readers become confused wrt my *agenda*, let me say that as a career engineer, I do not consider myself a Luddite.  But as a former [capitalist pig](https://www.urbandictionary.com/define.php?term=Capitalist%20Pig) myself, I also recognize the faint smell of greed also. Instead of forking over $12 for the new PD supply, I personally would be just as pleased with a simple [barrel connector](https://en.wikipedia.org/wiki/Coaxial_power_connector) that brings 12V (or 5V) to the RPi. Anyway - back to business. 

After perusing the 1,113-page specification, I found nothing that fully answered the *"how do they do it"* question. However, I did find a section titled **"4.4 Power and Ground"** in yet another document (the "USB Type-C Cable & Connector Specification", see REF #1 below) that details limits on the *"maximum allowable cable IR drop"*. This is useful, but still doesn't answer the question. But the [*"product brief"* on the new 27W supply](https://datasheets.raspberrypi.com/power-supply/27w-usb-c-power-supply-product-brief.pdf) discloses the following: 

>Cable: 1.2m 17AWG, white or black 

Wow... 17AWG. Consulting a [wire table](https://www.powerstream.com/Wire_Size.htm) we see that 17AWG has a resistance of 16.60992 ohms/km. This gives us a total *wire resistance* for the 1.2m power supply of: 

>R<sub>wire</sub> = 1.2m * 1km/1000m * 16.60992 = 0.01993190 ≅ 0.02 ohms   

Which yields a voltage drop of ~ 0.1 V at 5A, but this excludes contact resistance. Per para 3.7.8.1 of the document at REF 1, that is limited by specification to `50 mΩ`. With a 'captive' cable, we double this figure (instead of quadruple) to obtain the total contact resistance (supply & GND return) of 100 mΩ. This gives us:

>V<sub>drop</sub> = ( R<sub>wire</sub> + R<sub>contact</sub> ) * 5 Amps = 0.12 * 5 = 0.6 V 

And since the new 27W supply is rated at 5.1V, that leaves us just a wee bit shy of the 4.63V "low voltage threshold" imposed by the PMIC:

>5.1V - 0.6V = 4.5V  

So - that is how they (RPi.com) "did it". *Technically*, they didn't use ***any*** of the new PD specification - other than the fact that the PD spec now recognizes/allows the higher amperage. The two 17AWG wires helped, but they could not quite [turn the trick](https://idioms.thefreedictionary.com/turn+the+trick) with that amount of contact resistance. But as you can see from the calculations, they do get *very close*. 

And so we're asked to pay $12 for a 27W supply that may not ***quite*** avoid Low Voltage warnings at full load, and still operates on *"the ragged edge"*. Nevertheles, this supply does have some added features - uh, I mean ***profiles*** - such as several different operating voltages: `9V @ 3A; 12V @ 2.25A; and 15V @ 1.8A. But of course these features/profiles provide ***no additional utility*** for the RPi 5. 

In closing, I cannot help but wonder what motivates RPi.com to cling to their "power via USB" policy. Given RPi.com's fixation on functional austerity in the name of keeping their board costs low, it  seems to me that barrel connectors would offer both cost and performance advantages?  

What do **you** think? Leave a comment in the "Issues" if you like.

### REFERENCES:

1. Section 4.4 of the document *"USB Type-C 2.3 Release 202310 2/USB Type-C Spec R2.3 - October 2023.pdf"*, which is [embedded in this document bundle](https://www.usb.org/sites/default/files/USB%20Type-C%202.3%20Release%20202310.zip) 
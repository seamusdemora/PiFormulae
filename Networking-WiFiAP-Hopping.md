## New Life!
This _useful_ recipe had become *irrelevant* under 'NetworkManager' - the replacement for `dhcpcd` designated by _"The Raspberries"_ when the 'bookworm' version of the OS was released. But after more than 2 years of 'NetworkManager', I find it simply **too arcane and convoluted** for daily use - my daily use at least. Consequently, I am returning to a simpler method of networking - sometimes called `ifupdown`, or just `networking`. If you're interested in shucking 'NetworkManager' for a reliable and much simpler alternative, you can read more [in this recipe](https://github.com/seamusdemora/PiFormulae/blob/master/Networking-aSimplerAlternative.md). As a *bonus incentive*, this recipe - which uses `wpa_supplicant` - remains viable, and useful! 

## Switching Between WiFi Access Points

I came across an interesting question on the RPi SE recently. The question solicited an approach to accessing multiple WiFi networks/Access Points in an *automated* fashion; i.e. no `reboot` or manual intervention required. I'd never tried this before, but the idea intrigued me. I cobbled together an answer. Unfortunately, I don't have access to an environment that allows for full verification of my approach, and so I am posting it here for a couple of reasons:

1. To get a bit wider distribution - in the hope that perhaps an interested reader may give this a whirl & provide some negative feedback toward verification and improvement
2. As a solicitation for potential applications... for example, a mobile *drive-by* remote sensor data collection - farms, wildlife, inaccessible areas, etc. *'Pie-in-the-sky'* stuff I suppose, but remote sensing has interested me since I worked on a [`TinyOS`](https://en.wikipedia.org/wiki/TinyOS) application for [combat casualty care](https://en.wikipedia.org/wiki/Battlefield_medicine) years ago. 

What follows is mostly the [answer I posted to RPi SE](https://raspberrypi.stackexchange.com/a/136933/83790). I'll augment this based on interest, and availability of resources: 

### Summary:

"Simultaneous" WiFi connections are possible only with hardware & drivers that support it. AFAIK, there is no available RPi hardware that does. 

A "sequential" solution is possible, and illustrated below. This solution employs the `wpa_cli` app (part of `wpa_supplicant`) to rotate WiFi AP priorities using `set network <id> priority <n>` followed by a `reassociate` to switch to the higher priority network id/AP. This is a rather obtuse approach IMHO, but necessary to avoid the `select_network` option that disables the other networks. 

### Simultaneous connection to 2 or more Wi-Fi access points:

[As I understand it](https://unix.stackexchange.com/a/470484/286615), this requires both an interface (hardware) and a driver that supports dual-channel management. Assuming this is good information (and I feel it is) the `iw list` command will inform whether or not your system currently supports "simultaneous connections". 

On my RPi (a 3B+ running bullseye), my result is shown below, and as expected. The `<=1` output effectively means that the "simultaneous" option is not available on my 3B+.

```
$ iw list | grep -A 4 'valid interface combinations'
	valid interface combinations:
		 * #{ managed } <= 1, #{ P2P-device } <= 1, #{ P2P-client, P2P-GO } <= 1,
		   total <= 3, #channels <= 2
		 * #{ managed } <= 1, #{ AP } <= 1, #{ P2P-client } <= 1, #{ P2P-device } <= 1,
		   total <= 4, #channels <= 1
```

 [Vivek Gite's blog post](https://www.cyberciti.biz/faq/linux-find-wireless-driver-chipset/) may guide you in a search for a USB NIC that supports "simultaneous". 

### Sequential WiFi AP connections:

The [**REFERENCES**](#references) below may provide some useful background on this 'sequential' process. The 'sequential' solution works - this statement based on my experiments, the REFERENCES below and [other research](https://duckduckgo.com/?q=linux+wpa_supplicant+switch+between+wifi+networks). The caveat being that the APs used in my experiments were configured, and are administered by me. The procedure is outlined below in two steps: 

   1. Declare both networks in `/etc/wpa_supplicant/wpa_supplicant.conf`  
      I've created this  `wpa_supplicant.conf` file as a *typical* example :  

   ```
   ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
   update_config=1

   country=GB

   network={
      ssid="MyWiFiAP"
      psk="mypasswd"
   }

   network={
      ssid="MyIoTAP"
      psk="mypasswd2"
   }
   ```

   2. The  *interactive mode*  of `wpa_cli` is used below; know that all of these commands may be written as *stand-alone* commands, suitable for scripting:

   ```bash 
   $ wpa_cli 
   
   #  ... # preliminaries...

   > list_networks
   network id / ssid / bssid / flags
   0	MyWiFiAP	any	[CURRENT]
   1	MyIoTAP 	any 
   # The above result shows the two SSIDs configured in wpa_supplicant.conf  

   > get_network 1 priority
   0
   > get_network 0 priority
   0
   # The above results show the *priority* of the two SSID/network ids (0 & 1)  

   > set_network 1 priority 2
   OK 
   # Assign a higher priority to network id 1 (MyIoTAP) 

   > reassociate
   OK  
   ... a series of CTRL_EVENTS are listed ...
   # Connect to the higher priority network (MyIoTAP) 

   > list_networks
   network id / ssid / bssid / flags
   0	MyWiFiAP	any
   1	MyIoTAP 	any	[CURRENT] 
   # after `reassociate`, connection has moved to higher priority network/SSID  

   # to restore the original connection to MyWiFiAP: 
   # use the `set_network` priority commands above, 
   # follow that with another `reassociate`
   # Note: when priorities of all networks are equal, 
   # wpa_supplicant defaults to the one with the strongest signal  

   > quit
   # terminates the wpa_cli interactive session  

   $ 
   ```
And that's it... the `alternate/sequential wifi connections` process. You should verify this works with your network configuration *manually* as I've shown above. Once verified, you may use the equivalent *stand-alone* commands to automate the process in a script - or experiment with [`wpa_cli` running in *daemon* mode](https://wiki.archlinux.org/title/Wpa_supplicant#wpa_cli_action_script). Once you've got this working, the *next step* may be to [read all about `iw`](https://wireless.wiki.kernel.org/en/users/documentation/iw), enhance the crude script here, deposit your WiFi APs in your area of interest, put your RPi in your car or bike, and go collect some data. 

---
### REFERENCES:

1. RE: [`wlan0` vs. `p2p-dev-wlan0`](https://forums.raspberrypi.com/viewtopic.php?t=224576#p1377173) 
2. [ArchWiki `wpa_supplicant` documentation](https://wiki.archlinux.org/title/Wpa_supplicant#Connecting_with_wpa_cli) 
3. `man wpa_cli` on your RPi  
4. [`iw` for Wireless Linux ](https://wireless.wiki.kernel.org/en/users/documentation/iw)
5. [Linux Find Wireless WiFi Driver Chipset Information](https://www.cyberciti.biz/faq/linux-find-wireless-driver-chipset/) 













### REFERENCES: 

1. [Q&A: Connecting RPI Zero W2 to different Wi-Fi AP simultaneously or sequentially](https://raspberrypi.stackexchange.com/questions/136923/connecting-rpi-zero-w2-to-different-wi-fi-ap-simultaneously-or-sequentially) 

# PiFormulae

This is a collection of ***recipes*** for using and maintaining a [*Raspberry Pi* - or ***RPi***](https://en.wikipedia.org/wiki/RPi). The entries in the table below link to some of the "How-To" guides in this ***repo***(*sitory*), and other pages with potentially useful information. Admittedly, that's a low bar for inclusion, but feel free to peruse anything that strikes you as potentially useful. 

Most importantly, feel free to ***contribute***… [GitHub explains](https://guides.github.com/activities/forking/) how to create a fork of this repo, or there's a good (and v. brief) [YouTube video that explains the process](https://www.youtube.com/watch?v=f5grYMXbAV0), and why you'd want to fork a repo. If you find an error in this repo, or feel any of these *recipes* could be improved, there are (at least) two ways to contribute:

1. [Fork this repository](https://guides.github.com/activities/forking/) to your GitHub account. Once it's in your account, make your modifications, then submit a ["Pull Request"](https://help.github.com/en/articles/about-pull-requests). 
2. Create an Issue in this repo. GitHub explains [how to create an issue](https://help.github.com/en/articles/creating-an-issue), and [how to open an issue directly from the "code"](<https://help.github.com/en/articles/opening-an-issue-from-code>). Both approaches get to the same place eventually. 

**New users note**: In an effort to head off potential confusion, remember that [git](<https://git-scm.com/>) and [GitHub](https://github.com/) are ***not*** the same thing! Briefly, ***git*** is a version control system (a protocol), while ***GitHub*** is a commercial entity that uses ***git***, and adds supporting features including the web-based UI (user interface) and documentation in [Markdown](https://en.wikipedia.org/wiki/Markdown) format. 

You can use ***git*** directly from the RPi command line to create or update a GitHub repository! [Tom Hombergs has created a tutorial on how to do this](https://reflectoring.io/github-fork-and-pull/), and GitHub offers these [training resources](https://try.github.io/). Finally (and importantly), you should know that ***GitHub*** is not the only commercial entity offering ***git*** support services: [***GitLab***](https://about.gitlab.com/) is another resource to consider. [Some GitHub users have worried](https://www.theverge.com/2018/6/18/17474284/microsoft-github-acquisition-developer-reaction) that [Microsoft's $7.5 Billion purchase of GitHub](https://blogs.microsoft.com/blog/2018/10/26/microsoft-completes-github-acquisition/) would bring unwelcome changes. Having alternatives is always a good thing. 

<table class="minimalistBlack">
<thead>
<tr>
<th width="35%">Repo Files</th>
<th width="65%">Description</th>
</tr>
</thead>
<tbody>
  <tr>
    <td>Recent addition: <a href="https://github.com/seamusdemora/PiFormulae/blob/master/ForAnyoneWhoOwnsARaspberryPiZero-2-3.md">For Raspberry Pi models Zero, 2 and 3</a>.
    </td>
    <td>This recipe shows how to effectively remove the <code>rpi-eeprom</code> package using the <code>equivs</code> tool. Why?... Why not - if you don't have an EEPROM, why do you have a package called <code>rpi-eeprom</code>?
    </td>
  </tr>
  <tr>
		<td>Recent addition: An <a href="InPlaceUpgrade-FromBookwormToTrixie.md">"In Place" upgrade from 'bookworm' to 'trixie'</a></td>
		<td>A simpler way to upgrade your 'bookworm' systems to 'trixie'</td>
	</tr>
  <tr>
    <td>Recent addition: <a href="FilesystemConversionFromExt4ToBtrfs.md">Run RPi OS with the 'btrfs' fiesystem</a>
    </td>
    <td>Take advantage of the 'btrfs' file system's ability to create 'snapshots', and easily recover from your "big mistakes".
    </td>
  </tr>
  <tr>
    <td><a href="PWM-onRPi_5.md">Access & control PWM on RPi 5 easily.</a>  
    </td>
    <td>Having problems getting PWM working on RPi 5? Here's a <em>simple</em> way to set that up using <code>sysfs</code> & 3 lines of <code>bash</code> code.
    </td>
  </tr>
  <tr>
    <td>There are three (3) recipes for Bluetooth audio on <em>bookworm Lite</em>: <a href="Bluetooth-AudioForBookwormLite.md">1</a>, <a href="Bluetooth-UpgradeRPiBtHardware.md">2</a>, <a href="Bluetooth-UsingBackportsForPipewire.md">3</a>
    </td>
    <td>Thanks to <code>pipewire</code>, <code>backports</code> and a hardware <em>"upgrade"</em> users now have at least three choices for <em>reliable</em> Bluetooth audio for the 'Lite'/"<em>headless</em>" version of the Raspberry Pi OS. See the Recipes (1 - 3) for Details.
      <p><b><i>Note: The "hitch" in Recipe <a href="Bluetooth-UsingBackportsForPipewire.md#Sequel">3</a> has been resolved.</i></b>
      </p>
    </td>
  </tr>
  <tr>
    <td><a href="https://github.com/seamusdemora/PiFormulae/blob/master/TheRpiUARTmess.md">The Raspberry Pi UART mess</a></td>
    <td>A <em>rant</em>, followed by a recipe for setting up a UART console client and server pair</td>
  </tr>
  <tr>
    <td><a href="https://github.com/seamusdemora/PiFormulae/blob/master/Is_udev_brain-damaged.md">Is <code>udev</code> brain-damaged, or does it hate hwmon?</a>
    </td>
    <td>A <code>udev</code> solution to an issue with the <a href="SHT3X_T%26H_Sensor.md">SHT3X Temperature/Humidity Sensor</a>... with a <i>detour</i>!
    </td>
  </tr>
  <tr>
    <td><a href="SHT3X_T%26H_Sensor.md">Using the SHT3X Temperature/Humidity Sensor on RPi</a>
    </td>
    <td>No Programming Required! We use the <code>sysfs</code> interface to simplify access to these ubiquitous sensors.</td>
  </tr>
  <tr>
    <td><a href="SluggishSSH-aCure.md">Stop sluggish SSH performance over WiFi</a>
    </td>
    <td>Disable a poorly-implemented WiFi <code>power_save</code> feature in <code>brcmfmac</code> that has been enabled by default!
    </td>
  </tr>
<tr>
<td><a href="Build_pinctrl_for-bullseye.md">Use RPi's `pinctrl` to control GPIO pins</a></td>
  <td>Controlling GPIO pins has always been a key capability for Raspberry Pi users. But GPIO control has been jeopardized lately; this due to a convergence of two factors: 1. the Linux kernel has "outlawed" `sysfs` access to GPIO, and 2. the dreadful failure of the Linux kernel's chosen replacement for `sysfs`: `libgpiod`. The `pinctrl` package, developed within the RPi organization, offers respite from the Linux kernel's machinations. `pinctrl` offers fast, lightweight access to the GPIO. 
  </td>
</tr>
<tr>  
  <td></td>
  <td></td>
</tr>
<tr>
<td><a href="ExternalDrives.md">Mount an external drive</a></td>
<td>This recipe will walk through the steps needed to mount an external drive on a RPi, and explain in some detail what the commands do, and why they are necessary.</td>
</tr>
<tr>
<td><a href="FileShare.md">Share Files on RPi over the network using Samba</a></td>
  <td>This recipe continues the <a href="ExternalDrives.md">External Drives</a> recipe to share files and folders over your network.</td>
</tr>
<tr>  
  <td><a href="CreatingRationalMusicLibrary.md">RPi file server for a music library</td>
  <td>This recipe builds on the two recipes above to create a rational, portable file server for a music library</td>
</tr>  
<tr>  
  <td></td>
  <td></td>
</tr>
<tr>
  <td><a href="EmailForRPi.md">Setting up email on the RPi</a></td>
  <td>Earlier versions of RPi OS included email as a standard feature in the Lite distribution. This recipe will allow you to easily restore that.</td>
</tr>
<tr>  
  <td></td>
  <td></td>
</tr>
<tr>
<td><a href="XQuartzInstall.md">How to do Python development on your RPi from your Mac</a></td>
<td>For Python coders: I use <a href="https://www.xquartz.org/">XQuartz</a> as the X11 app on my Mac to run <a href="https://docs.python.org/3/library/idle.html">IDLE</a> on my Raspberry Pi in headless mode. This is an easy-to-follow guide to setting that up.</td>
</tr>
<tr>  
  <td><a href="UseGitOnRPiToGitHub.md">Use `git` to sync your RPi projects with GitHub</a></td>
  <td>Here's how to use `git` from your RPI's CLI to keep your projects synced with your GitHub repo</td>
</tr>
<tr>  
  <td></td>
  <td></td>
</tr>
<tr>  
  <td><a href="WhatHardwareAndSoftwareVersionRaspberryPi.md">What's my RPi hardware, and what version of Raspbian am I running?</a></td>
  <td>If you've got more than one of these things, your recollection may fail occasionally. But your system always knows the correct answer!</td>
</tr>
<tr>  
  <td></td>
  <td></td>
</tr>
<tr>
<td><a href="PackageMaintenance.md">My recipe for installing and updating software</a></td>
<td>It seems there are many different ideas about how to install and update apps on the RPi. This is an area I am still researching, but this recipe shows how I do it now.</td>
</tr>
<tr>
<td><a href="https://github.com/seamusdemora/PiFormulae/blob/master/SwDefRadio.md"> Software Defined Radio applications for the Raspberry Pi</a></td>
<td>This isn't even a skeleton yet, and there's very little if anything of any use here now (except a nice picture of the gorgeous Hedy Lamarr). I've got some interest in this area, and will update going forward.</td>
</tr>
<tr>
<td><a href="https://github.com/seamusdemora/PiFormulae/blob/master/CheckPiTemperature.md"> Get Operating Temperatures of Raspberry Pi: GPU, CPU, PMIC</a></td>
<td>Various methods of reading the operating temperature explained</td>
</tr>
<tr>
<td><a href="https://github.com/seamusdemora/PiFormulae/blob/master/fsckForRaspberryPi.md">Using `fsck` to check & repair your filesystem</a></td>
<td>The recommended way to invoke `fsck` on each boot, and where to find the log entries created</td>
</tr>
<tr>
<td><a href="https://github.com/seamusdemora/PiFormulae/blob/master/CanNotLoginToMyRPi.md">I've Broken Something, and I Can't Login to my RPi</a></td>
<td>Oooops! It happens to everyone - you've screwed up, and can't login. This may help.</td>
</tr>
</tbody>
</table>





------

OTHER REFERENCES: 

###### 1.  [Jessica Lord's website](http://jlord.us/) has some interesting ideas on using GitHub - including  [fork-n-go](http://jlord.us/forkngo/). 

<!---

 HIDDEN STUFF FOLLOWS:

```
<tr>
<td>Link text here</td>
<td>Explanatory text here</td>
</tr>
```

—>

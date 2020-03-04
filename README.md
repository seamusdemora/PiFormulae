# PiFormulae

This is a collection of ***recipes*** for using and maintaining a [*Raspberry Pi* - or ***RPi***](https://en.wikipedia.org/wiki/RPi). The entries in the table below link to some of the "How-To" guides in this ***repo***(*sitory*), and other pages with potentially useful information. Admittedly, that's a low bar for inclusion, but feel free to [peruse any or all of the pages in the repo](https://github.com/seamusdemora/PiFormulae) as well. 

Most importantly, feel free to ***contribute***… [GitHub explains](https://guides.github.com/activities/forking/) how to create a fork of this repo, or there's a good (and v. brief) [YouTube video that explains the process](https://www.youtube.com/watch?v=f5grYMXbAV0), and why you'd want to fork a repo. If you find an error in this repo, or feel any of these *recipes* could be improved, there are (at least) two ways to contribute:

1. [Fork this repository](https://guides.github.com/activities/forking/) to your GitHub account. Once it's in your account, make your modifications, then submit a ["Pull Request"](https://help.github.com/en/articles/about-pull-requests). 
2. Create in Issue in this repo. GitHub explains [how to create an issue](https://help.github.com/en/articles/creating-an-issue), and [how to open an issue directly from the "code"](<https://help.github.com/en/articles/opening-an-issue-from-code>). Both approaches get to the same place eventually. 

**Note to new users**: In an effort to head off potential confusion, remember that [git](<https://git-scm.com/>) and [GitHub](https://github.com/) are ***not*** the same thing! Briefly, ***git*** is a version control system (a protocol), while ***GitHub*** is a commercial entity that uses ***git***, and adds features including the web-based UI (user interface) and documentation in [Markdown](https://en.wikipedia.org/wiki/Markdown) format ( ***git<sup>+</sup>*** ). In fact, you can use ***git*** directly from the RPi command line to update a GitHub repository! [Tom Hombergs has created a tutorial on how to do this](https://reflectoring.io/github-fork-and-pull/), and GitHub offers these [training resources](https://try.github.io/). Finally (and importantly), you should know that ***GitHub*** is not the only commercial entity offering ***git<sup>+</sup>***: [***GitLab***](https://about.gitlab.com/) is another resource to consider, perhaps especially so now that [Microsoft has incorporated GitHub](https://blogs.microsoft.com/blog/2018/10/26/microsoft-completes-github-acquisition/) into its empire. [Some GitHub users worry](https://www.theverge.com/2018/6/18/17474284/microsoft-github-acquisition-developer-reaction) this $7.5 Billion deal could be detrimental. 

<table class="minimalistBlack">
<thead>
<tr>
<th width="35%">Repo Files</th>
<th width="65%">Description</th>
</tr>
</thead>
<tbody>
<tr>
<td><a href="ReadMeFirst.md">First steps...</a></td>
  <td>An approach to setting up a Raspberry Pi in "headless" mode, from setting up your microSD card to your first login over SSH, and then on to <code>raspi-config</code> to complete your initial setup.</td>
</tr>
<tr>
<td><a href="FindMyPi.md">Find the IP address of a RPi</a></td>
  <td>This is potentially useful for those running their RPi in "headless mode". You can use this to find the IP address of your RPi, and having the address, initiate the necessary SSH connection to communicate with it. Note that this may be unnecessary for Mac users, or other PCs, that employ <a href="https://en.wikipedia.org/wiki/Zero-configuration_networking">zero configuration networking.</a>  <a href="http://ommolketab.ir/aaf-lib/6429sutwymieo6db64h8t0tbavz3z7.pdf">PDF Book</a></td>
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
<td><a href="PiCameraAntics.md">Using the Pi Camera</a></td>
<td>The Pi Camera is a popular accessory, but it does have some "quirks". This is a work in progress for using the Pi Camera from the command line; some of the examples may be useful to someone who's getting started.</td>
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
  <td><a href="UsefulShellTricks.md">Potentially useful ideas for the CLI</a></td>
  <td>You need to learn how to use the shell (or go back to Windows). Here's a small sample of tips & tricks I've accumulated.</td>
</tr>
<tr>  
  <td><a href="WhatHardwareAndSoftwareVersionRaspberryPi.md">What's my RPi hardware, and what version of Raspbian am I running?</a></td>
  <td>If you've got more than one of these things, your recollection may fail occasionally. But your system always knows the correct answer!</td>
</tr>
<tr>  
  <td><a href="MyCrontabDoesntWork.md">`cron` is straightforward to use if you know its limitations</a></td>
  <td>Most failures with `cron` are caused by not understanding these limitations.</td>
</tr>
<tr>  
  <td><a href="WhatIsCronEnvironment.md">What is <code>cron</code>'s <i>environment</i>?'</a></td>
  <td>A fair question! It's easy to say, "cron's environment is different than your user environment.", but <b>what is its environment?</b> This is a simple script that will tell you.</td>
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
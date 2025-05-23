# Some useful shell tricks:

## Table of contents

*  ### bash *particulars* 

   *  [Reload `bash` or `zsh` `.profile` without restarting shell](#refresh-shell-configuration-without-restarting) 
   *  [Sequential shell command execution](#sequential-shell-command-execution) 
   *  [The Shell Parameters of bash](#the-shell-parameters-of-bash) 
   *  [*Command substitution*; assign shell command output to a variable](#assign-shell-command-output-to-a-variable-in-bash) 
   *  [*Shell parameter expansion*; some examples](#shell-parameter-expansion) 
   *  [Shell variables: UPPER case, lower case, or SoMeThInG_eLsE...?](#shell-variables-what-is-the-best-naming-convention) 
   *  [Using your shell command history](#using-your-shell-command-history) 
   *  [Permission issues with redirects (`>`, `>>`)](#permission-issues-when-using-redirection) 
   *  [What happens to `stderr` when one command is piped to another?](#how-to-pipe-the-stderr-of-one-command-to-another) 
   *  [Comment an **entire block of code** in a shell script](#comment-an-entire-block-of-code) 
   *  [Testing things in bash](#testing-things-in-bash) 

*  ### System information

   *  [How do I tell my system to tell me about my system: OS, Kernel, Hardware, etc](#tell-me-about-my-system) 
   *  [How do I see my *environment*?](#how-do-i-see-my-environment) 
   *  [What is my "Kernel Configuration"?](#what-is-my-kernel-configuration) 
   *  [How much time is required to boot your system?](#how-much-time-is-required-to-boot-your-system) 

*  ### File operations

   *  [What do file and directory permissions mean?](#file-and-directory-permissions) 
   *  [Clear the contents of a file without deleting the file](#clear-the-contents-of-a-file-without-deleting-the-file) 
   *  [List all directories - not files, just directories](#list-all-directories---not-files-just-directories) 
   *  [Pitfalls of parsing `ls`](#pitfalls-of-parsing-ls) 
   *  [Access `.gz` compressed log files easily](#access-compressed-log-files-easily) 
   *  [Filename expansion; a.k.a. "globbing"](#filename-expansion-aka-globbing) 
   *  [Change the modification date/time of a file](#change-the-modification-date-of-a-file) 
   *  [Verify a file system is mounted with `findmnt` - *before trying to use it*!](#verify-file-system-is-mounted) 
   *  [How to move or copy a file without accidentally overwriting a destination file](#move-or-copy-a-file-without-accidentally-overwriting-a-destination-file) 
   *  [Using `dirname`, `basename` & `realpath`](#using-dirname-basename-and-realpath) 
   *  [Format an SSD w/ `f2fs` filesystem and mount it](#how-to-format-and-mount-an-ssd-for-use-in-rpi) 
   *  [How to make a loop mount in `/etc/fstab`](#how-to-make-a-loop-mount-in-fstab) 
   *  [How to create and extract `tar` and `.tgz` files](#tar-files-and-compressed-tar-files) 

*  ### Date and time Operations

   *  [Get a date-time stamp for a log](#get-a-date-time-stamp-for-a-log) 
   *  [★★How to deal with *"Unix time"* when using `date`](#using-date-to-deal-with-unix-time) 
   *  [Is my system clock being updated properly?](#what-about-my-rtc-settings-and-timedatectl) 

*  ### String manipulation

   *  [String manipulation with bash](#string-manipulation-with-bash) 
   *  [Know the Difference Between `NULL` and an Empty String](#the-difference-between-null-and-empty-strings) 

*  ### Finding things on your system

   *  [Using `which` to find commands](#using-which-to-find-commands) - *accurately!* 
   *  [Searching command history](#searching-command-history) 
   *  [Some options with `grep`](#some-options-with-grep) 
   *  [Filtering `grep` processes from `grep` output](#filtering-grep-processes-from-grep-output); *separating the wheat from the chaff* 
   *  [Finding pattern matches: `grep` or `awk`?](#finding-pattern-matches-grep-or-awk) 
   *  [Find what you need in that huge `man` page](#find-what-you-need-in-that-huge-man-page) 
   *  [Where did I put that file? - it's *somewhere* in my system](#that-file-is-somewhere-in-my-system) 

*  ### Using Bluetooth 

   *  [Bluetooth](#bluetooth) 

*  ### Networking 

   *  [Using `socat` to test network connections](#using-socat-to-test-network-connections) 
   *  [What's the IP address of my Raspberry Pi? - How to find **all** RPi on the local network](#finding-all-rpi-on-the-local-network) 

*  ### Using GPIO

   *  [Useful tools for GPIO hackers](#useful-tools-for-gpio-hackers-raspi-gpio-and-pinctrl) 

*  ### Process management

   *  [Background, nohup, infinite loops, daemons](#background-nohup-infinite-loops-daemons) 
   *  [Process management using <kbd>ctrl</kbd>+<kbd>z</kbd>, `fg`, `bg` & `jobs`](#process-management-jobs-fg-bg-and-ctrl-z) 

*  ### RPi specific 

   *  [So you want to remove `rpi-eeprom` package & save 25MB?](#want-to-remove-the-rpi-eeprom-package-to-save-25mb-tough-shit-say-the-raspberries) 
   
   *  [Disable CPU cores for power saving](#disable-cpu-cores-for-power-saving) 
   
   *  [`raspi-config` from the command line?](#raspi-config-from-the-command-line) 
   
*  ### Miscellaneous

   *  [Using the default editor `nano` effectively](#using-the-default-editor-nano-effectively) 
   *  [The power of `less`](#the-power-of-less) 
   *  [What version of `awk` is available on my Raspberry Pi?](#what-version-of-awk-is-available-on-my-raspberry-pi) 
   *  [Download a file from GitHub](#download-a-file-from-github) 
   *  [Use the `at` command for scheduling](#how-to-use-the-at-command-for-scheduling) 
   *  [Should I use `scp`, or `sftp`?](#scp-vs-sftp) 
   *  [How to search GitHub](#how-to-search-github) 

   

*  ### [REFERENCES:](#references) 

---

## Tell me about my system

### Hardware model: 

Stored in `/proc/cpu` for single-CPU RPi:

```
$ cat /proc/cpuinfo 
processor	: 0
model name	: ARMv6-compatible processor rev 7 (v6l)
BogoMIPS	: 697.95
Features	: half thumb fastmult vfp edsp java tls
CPU implementer	: 0x41
CPU architecture: 7
CPU variant	: 0x0
CPU part	: 0xb76
CPU revision	: 7

Hardware	: BCM2835
Revision	: 0010
Serial		: 000000003e3ab978
Model		: Raspberry Pi Model B Plus Rev 1.2
```

#### OR, on a 4B:

```
$ cat /proc/cpuinfo 
processor	: 0
model name	: ARMv7 Processor rev 3 (v7l)
BogoMIPS	: 108.00
Features	: half thumb fastmult vfp edsp neon vfpv3 tls vfpv4 idiva idivt vfpd32 lpae evtstrm crc32
CPU implementer	: 0x41
CPU architecture: 7
CPU variant	: 0x0
CPU part	: 0xd08
CPU revision	: 3

... repeat for processor	: 1, processor	: 2, processor	: 3

Hardware	: BCM2711
Revision	: b03111
Serial		: 100000006cce8fc1
Model		: Raspberry Pi 4 Model B Rev 1.1
```

#### OR, on a 5B:

```
$cat /proc/cpuinfo
processor       : 0
BogoMIPS        : 108.00
Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 atomics fphp asimdhp cpuid asimdrdm lrcpc dcpop asimddp
CPU implementer : 0x41
CPU architecture: 8
CPU variant     : 0x4
CPU part        : 0xd0b
CPU revision    : 1

... repeat for processors 1, 2 & 3

Hardware        : BCM2835
Revision        : c04170
Serial          : 6b71acd964ee2481
Model           : Raspberry Pi 5 Model B Rev 1.0
```

#### OR, an abbreviated report

```
$ cat /proc/cpuinfo | awk '/Model/' 
Model		: Raspberry Pi 4 Model B Rev 1.1
```

### Kernel version: 

```bash
$ man uname        # see options & other usage info

# RPi B+ (buster)
$ uname -a
Linux raspberrypi1bp 5.10.63+ #1496 Wed Dec 1 15:57:05 GMT 2021 armv6l GNU/Linux

# RPi 3B+ (bullseye)
$ uname -a
Linux raspberrypi3b 5.10.92-v7+ #1514 SMP Mon Jan 17 17:36:39 GMT 2022 armv7l GNU/Linux

# RPi 4B: (buster)
$ uname -a
Linux raspberrypi4b 5.10.63-v7l+ #1496 SMP Wed Dec 1 15:58:56 GMT 2021 armv7l GNU/Linux
```

### OS version:

This works on RPi OS, but may not work on distros that are not Debian derivates. But if it works, it's useful: 

```bash
$ man lsb_release   # print distribution-specific info; see manual for options, usage

$ lsb_release -a
No LSB modules are available. # note that lsb itself may not be installed by default
Distributor ID:	Raspbian
Description:	Raspbian GNU/Linux 11 (bullseye)
Release:	11
Codename:	bullseye
```

### hostnamectl:

```bash
$ hostnamectl     # p/o systemd, see man hostnamectl for options & usage info
   Static hostname: raspberrypi3b
         Icon name: computer
        Machine ID: be49a9402c954d689ba79ffd5f71ad67
           Boot ID: 986ab27386444b52bddae1316c5e1ee1
  Operating System: Raspbian GNU/Linux 11 (bullseye)
            Kernel: Linux 5.10.92-v7+
      Architecture: arm
```

### MAC address:

```bash
ethtool --show-permaddr eth0    # for the Ethernet adapter 
ethtool --show-permaddr wlan0   # for the WiFi adapter 
```

### IP address: 

There are *several* ways to get the IP address: 

```bash
#1:★ $ hostname -I
#2:  $ hostname --all-ip-addresses 
#3:  $ ip route get 8.8.8.8
#4:  $ ip route get 8.8.8.8 | awk '{print $7; exit}'
#5:  $ ip addr                   # general, all devices
#6:  $ ip -4 -o addr show wlan0  # specific device (e.g. 'wlan0')
#7  :$ ip -4 -o addr show wlan0 | awk '{print $4; exit}'
#8:  $ ifconfig
```

### `vcgencmd` tool

The `vcgencmd` tool can report numerous details from the VideoCore GPU. See `man vcgencmd`, and the ["official documentation"](https://www.raspberrypi.com/documentation/computers/os.html#vcgencmd) for details. For a list of all available commands under `vcgencmd`, do `vcgencmd commands`:
   * set_logging,
   * bootloader_config,
   * bootloader_version,
   * cache_flush,
   * codec_enabled,
   * get_mem,
   * get_rsts,
   * measure_clock,
   * measure_temp,
   * measure_volts,
   * get_hvs_asserts,
   * get_config,
   * get_throttled,
   * pmicrd,
   * pmicwr,
   * read_ring_osc,
   * version,
   * readmr,
   * otp_dump (which has its own special [section in the docs](https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#otp-register-and-bit-definitions)),
   * pmic_read_adc,
   * power_monitor

### Bluetooth info (maybe better off not knowing? see [Bluetooth](#Bluetooth))

```bash
$ hciconfig -a
hci0:	Type: Primary  Bus: UART
	BD Address: D8:3A:DD:A7:B2:00  ACL MTU: 1021:8  SCO MTU: 64:1
	UP RUNNING
	RX bytes:5014 acl:0 sco:0 events:438 errors:0
	TX bytes:66795 acl:0 sco:0 commands:438 errors:0
	Features: 0xbf 0xfe 0xcf 0xfe 0xdb 0xff 0x7b 0x87
	Packet type: DM1 DM3 DM5 DH1 DH3 DH5 HV1 HV2 HV3
	Link policy: RSWITCH SNIFF
	Link mode: PERIPHERAL ACCEPT
	Name: 'raspberrypi5'
	Class: 0x000000
	Service Classes: Unspecified
	Device Class: Miscellaneous,
	HCI Version: 5.0 (0x9)  Revision: 0x17e
	LMP Version: 5.0 (0x9)  Subversion: 0x6119
	Manufacturer: Cypress Semiconductor (305)
```

---
[**⋀**](#table-of-contents)

## Permission Issues When Using Redirection

The `redirection` operators (**`>`** and **`>>`**) are incredibly useful tools in the shell. But, when they are used to redirect output from a command to a file requiring `root` privileges, they can leave a user scratching his head. Consider this example: 

   ```bash
   $ sudo printf "Houston, we have a problem!" > /etc/issue.net
   -bash: /etc/issue.net: Permission denied
   ```

Most who encounter this for the first time are baffled... "WTF?! - why does this not work? I can open the file with an editor - I can edit and save... WTF?!"

The problem is obvious once it's explained, but the solutions may vary. The **problem** in the example above is that there are actually two commands being used: `printf` whis is propelled by `sudo`, and the redirect **`>`** which is **not** propelled by `sudo`.  And of course you don't actually need `sudo` to execute a `printf` command, but you do need `sudo` to write to `/etc/issue.net`. What to do? None of the answers are particularly *elegant* IMHO, but they do work: 

1. If you put the example command in a shell script, and run the script with `sudo`, you won't a problem. This due to the fact that every command in the script - including redirects - will run with `root` privileges. Another way to consider the issue is this: It's only an issue when using the command sequence from the shell prompt. Feel better? 

2. Similar to #1, you can spawn a new *sub-shell* using the `-c`option to process a command (ref `man sh`). This is best explained as follows: 

   ```bash
   $ sudo sh -c 'printf "Houston, we have a problem!" > /etc/issue.net'
   # --OR--
   $ sudo bash -c 'echo "Houston, we have a problem!" > /etc/issue.net'
   ```

   You will find this succeeds when executed from a shell prompt. 

3. The final option (for this recipe at least) is to use the `tee` command instead of the redirect: 

   ```bash
   $ printf "Houston, we have a problem!" | sudo tee /etc/issue.net
   # OR: If you don't want the output to print on your terminal: 
   $ printf "Houston, we have a problem!" | sudo tee /etc/issue.net > /dev/null
   ```

If you're interested, this [Q&A on SO](https://stackoverflow.com/questions/82256/how-do-i-use-sudo-to-redirect-output-to-a-location-i-dont-have-permission-to-wr) has much more on this subject.  
[**⋀**](#table-of-contents) 

## Refresh shell configuration without restarting

There are two user-owned files that control many aspects of the `bash` shell's behavior - uh, *interactive shells, that is*: `~/.profile` & `~/.bashrc`. Likewise for `zsh`, the `~/.zprofile` & `~/.zshrc`. There will be occasions when changes to these files will need to be made in the current session - without exiting one shell session, and starting a new one. Examples of such changes are changes to the `PATH`, or addition of an `alias`. 


```zsh
$ source ~/.profile       # use this for bash 
$ source ~/.bashrc        #        "
% source ~/.zprofile      # use this for zsh 
% source ~/.zshrc         #        " 
# OR ALTERNATIVELY: 
$ . ~/.profile            # use for bash + see Notes below 
$ . ~/.bashrc             #        "
% . ~/.zprofile           # use for zsh + see Notes below 
% . ~/.zshrc              #        "
```

>> **Note 1:** The [dot operator](https://ss64.com/bash/source.html); `.` is a synonym for `source`. Also, it's POSIX-compliant (`source` is not).

>> **Note 2:** Additions and removals from `~/.bashrc` behave differently: If something is **removed** from `~/.bashrc`, this change will **not** take effect after *sourcing* `~/.bashrc` (i.e.  `. ~/.bashrc`).  
>
>> For example: Add a function to `~/.bashrc`: `function externalip () { curl http://ipecho.net/plain; echo; }`. Now *source* it with `. ~/.profile`. You should see that the function now works in this session. Now remove the function, and then *source* it again using `. ~/.profile`. The function is still available - only restarting (log out & in), or starting a new shell session will remove it.

[**⋀**](#table-of-contents)

## Clear the contents of a file without deleting the file

```bash
$ > somefile.xyz			# works in bash
# -OR-
% : > $LOGFILE				# works in zsh
# -OR-
$ truncate -s 0 test.txt		# any system w/ truncate
# -OR-
$ cp /dev/null somefile.xyz     	# any system
```
[**⋀**](#table-of-contents)  

## List all directories - not files, just directories

```bash
$ find . -type d   # list all dirs in pwd (.)
```

> > Note In this context the *'dot'* `.` means the `pwd` - not the [dot operator](https://ss64.com/bash/source.html) as in the [above example](#reload-bashs-profile-without-restarting-shell).

[**⋀**](#table-of-contents)

## Pitfalls of parsing `ls`

In some cases, you can *get away with* parsing and/or filtering the output of `ls`, and in other cases you cannot. I've spent an inordinate amount of time trying to filter the output of `ls` to get only hidden files - or only hidden directories. `ls` seems very *squishy* and unreliable in some instances when trying to get a specific, filtered list... [ref Wooledge](http://mywiki.wooledge.org/ParsingLs). 

I try to keep discussion on the topics here *brief*, but don't always succeed. In a sincere effort to avoid verbosity here, I'll close with a few *bulleted* bits of guidance: 

* `find` is more reliable than `ls` for tailored lists of files & folders; learn to use it - esp. in scripting. 
* Much has been written ([e.g.](https://unix.stackexchange.com/questions/44754/listing-with-ls-and-regular-expression)) on using `bash` PATTERNs, and enabling various *extensions* through `shopt` to filter/parse `ls` output. AIUI, the "PATTERNs" are not *regular expressions*, but an [extended type of *file globbing*](https://www.linuxjournal.com/content/pattern-matching-bash). I've not found that reliably effective, but I've not put much time & effort into it. 
* `ls` has a *long form* (the `-l` option); the default being the *short form*. I generally favor the long form (***me*** - a *data junkie*?). To illustrate my *squishy* claim w.r.t. listing *only* hidden files, I've found these work: 
  * For the *short form*:  `ls -A | grep '^\.'`; Note the *caret* `^` operator; used to get the line beginning?
  * For the *short form*:  `ls -d1 -- \.*`; An example of *"glob patterns"* 
  * For the *long form*:  `ls -Al | grep " \."` ;   Note the *space* in the pattern; alternative: `\s`  

[**⋀**](#table-of-contents)

## Sequential shell command execution 

Sometimes we want to execute a series of commands, but only if all previous commands execute successfully. In this case, we should use **`&&`** to join the commands in the sequence: 

```bash
cd /home/auser && cp /utilities/backup_home.sh ./ && chown auser ./backup_home.sh
```

At other times we want to execute a series of commands regardless of whether or not previous commands executed successfully. In that case, we should use **`;`** to join the commands in the sequence:

```bash
cp /home/pi/README /home/auser; rsync -av /home/auser /mnt/BackupDrv/auser_backup/
```
[**⋀**](#table-of-contents) 

## Get a date-time stamp for a log 

It's often useful to insert a date-time stamp in a log file, inserted in a string, etc. Easily done w/ `date` using [*command substitution*](https://bash.cyberciti.biz/guide/Command_substitution): 

```bash
echo $(date) >> mydatalog.txt   # using `echo` inserts a newline after the date & time 
# log entry will be in this format: Tue Mar 24 04:28:31 CDT 2020 + newline
echo $(date -u)                 # `-u` gives UTC 

# if you need to log the time in a specific time zone, 
# see '/usr/share/zoneinfo/posix' for a list, and then (for example): 
echo $(TZ=CST6CDT date)       # for US CST/Central DST
# --OR--
echo $(TZ=Portugal date)      # for Portugal -> ../Europe/Lisbon
```

If you need more control over the format, use `printf` w/ `date`:

```bash
printf '%s' "$(date)" >> mydatalog.txt	# no newline is output
# log entry will be in this format: Tue Mar 24 04:28:31 CDT 2020 
printf '%s\n' "$(date)" >> mydatalog.txt	# newline is output
```

There are numerous options with the `date` command. Check `man date`, or peruse this [*Lifewire* article 'How to Display the Date and Time Using Linux Command Line'](https://www.lifewire.com/display-date-time-using-linux-command-line-4032698) - it lists *all* of the format options for displaying the output of `date`. 

[**⋀**](#table-of-contents)

## String manipulation with bash 

It's often useful to manipulate string variables in bash. These websites have some examples: [website 1](https://www.tutorialkart.com/bash-shell-scripting/bash-string-manipulation-examples/); [website 2](https://www.thegeekstuff.com/2010/07/bash-string-manipulation/). The [Wooledge Wiki](https://mywiki.wooledge.org/BashFAQ/100#How_do_I_do_string_manipulations_in_bash.3F) is a bit more advanced, and a trove of string manipulation methods available in `bash`. [Section 10.1 of the Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/string-manipulation.html) is another comprehensive source of information on string manipulation. For example:

```bash
$ str1="for everything there is a "
$ str2="reason"
$ str3="season"
$ echo $str1$str2; echo $str1$str3
for everything there is a reason
for everything there is a season
```
[**⋀**](#table-of-contents) 

## Testing things in bash 

Testing the equality of two strings is a common task in shell scripts. You'll need to watch your step as there are numerous ways to screw this up! Consider a few examples: 

```bash
$ string1="Anchors aweigh"
$ string2="Anchors Aweigh"
$ if [[ $string1 == "Anchors aweigh" ]]; then echo "equal"; else echo "not equal"; fi
equal
$ if [ "$string1" == "Anchors aweigh" ]; then echo "equal"; else echo "not equal"; fi
equal
$ if [ "$string1" = "Anchors aweigh" ]; then echo "equal"; else echo "not equal"; fi
equal

# but if you forget something; e.g.

$ if [ $string1 == "Anchors aweigh" ]; then echo "equal"; else echo "not equal"; fi
-bash: [: too many arguments
not equal
# BOOM! no quotes "" - you crash and burn :) 

$ [ "$string1" = "Anchors aweigh" ] && echo equal || echo not-equal
equal 
$ [ "$string1" -eq "Anchors aweigh" ] && echo equal || echo not-equal
-bash: [: Anchors aweigh: integer expression expected
not-equal
# BOOM! `-eq` is for numbers, not strings - you crash and burn :) 

$ [ "$string1" = "$string2" ] && echo equal || echo not-equal
not-equal 
$ [[ $string1 = $string2 ]] && echo equal || echo not-equal
not-equal 
$ [[ ${string1,,} = ${string2,,} ]] && echo equal || echo not-equal
equal
# NOTE! this case-conversion only works in bash v4 & above
 
```

So much *arcanery* here, and limited *portability*. Here are a list of references peculiar to this one small problem: [SO Q&A 1](https://stackoverflow.com/questions/3265803/bash-string-equality), [SO Q&A 2](https://stackoverflow.com/questions/2600281/what-is-the-difference-between-operator-and-in-bash/2601583#2601583), [*Linuxize*](https://linuxize.com/post/how-to-compare-strings-in-bash/), [UL Q&A 1](https://unix.stackexchange.com/questions/306111/what-is-the-difference-between-the-bash-operators-vs-vs-vs), [SO Q&A 3](https://stackoverflow.com/questions/20449543/shell-equality-operators-eq), [SO Q&A 4](https://stackoverflow.com/questions/1728683/case-insensitive-comparison-of-strings-in-shell-script). AFAIK there's no *unabridged* reference for string manipulation in `bash`, but section [**'10.1. Manipulating Strings'** of the **'Advanced Bash-Scripting Guide'**](https://tldp.org/LDP/abs/html/string-manipulation.html) comes reasonably close. And the [Other Comparison Operators](https://tldp.org/LDP/abs/html/comparison-ops.html) section from [Chap 7 of Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/tests.html) is not to be missed :)  

Ever wonder why some `test`s use single brackets: **`[ ]`** & other use double brackets: **`[[ ]]`** ? Here's a very [succinct answer](https://stackoverflow.com/a/13542854/5395338).  

**What about *null strings*?**

At the risk of [going overboard](https://idioms.thefreedictionary.com/go+overboard), we'll cover testing for ***null strings*** also. Know these two characters have a special meaning within a test construct for strings: 

>-z		string is *null*, that is, has zero length. 
>
>-n		string is not *null.*  

Consider the possibility that a shell variable has not been defined; for example let's imagine a variable named `CaptainsOrders` - a variable to which we, perhaps, failed to assign a value through oversight. Now let's further imagine that `CaptainsOrders` is to be tested in an `if-then-else` construct. If we were careless, we might create that construct as follows:

```bash
if [ "$CaptainsOrders" = "Anchors aweigh" ]
then
   echo "We sail at dawn tomorrow"
else
   echo "We remain in port"
fi  
```

That might be unfortunate - that might get you [*Court-martialed*](https://en.wikipedia.org/wiki/Courts-martial_of_the_United_States), and it certainly would cause your superiors to question your competence as a `bash` programmer! But having been enlightened by this tutorial, you would be prepared for someone's failure to enter a value for `CaptainsOrders`: 

```bash
$ [ -z "$CaptainsOrders" ] && echo 'Sound the alarm!!!' || echo "Proceed as planned"
Sound the alarm!!!
```

You might also learn something of the difference between *single quotes* `''`, and *double quotes* `""`.  

[**⋀**](#table-of-contents)  

## Assign shell command output to a variable in `bash` 

Sometimes you need the output of a shell command to be *persistent*; assign it to a variable for use later. This is known as [**command substitution**](https://bash.cyberciti.biz/guide/Command_substitution). Consider the case of a *tmp file* you've created. Here's how: 

```bash
$ $ WORKFILE=$(mktemp /tmp/ssh_stats-XXXXX)
$ echo $WORKFILE
/tmp/ssh_stats-BiA5m
```

Within this session (or script) `$WORKFILE` will contain the location of your *tmp file*. [<sup>*ref*</sup>](https://pupli.net/2022/03/assign-output-of-shell-command-to-variable-in-bash/)  

[**⋀**](#table-of-contents)  

## The Shell Parameters of `bash`

`bash` has two types of [*parameters*](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameters): positional parameters and special parameters. They are the *odd-looking* variables you may have seen in scripts, such as: `$0`, `$1`, `$@`, `$?`, etc.  But they come in very handy, and you should learn to use them. The [Bash Reference Manual](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html) isn't as informative as it could be, but there are better explanations available that include examples: [positional parameters](https://www.thegeekstuff.com/2010/05/bash-shell-positional-parameters/), [special parameters](https://www.thegeekstuff.com/2010/05/bash-shell-special-parameters/).  

[**⋀**](#table-of-contents)  

## The Difference Between Null and Empty Strings

At least in `bash`, a null string ***is*** an empty/zero-length string; in other words, ***there is no difference***. In `bash`, a string (e.g. `my_string`) can be tested to determine if it is a null/empty string as follows: 

```bash
#!/usr/bin/env bash
# some processing has taken place, and now...
if [ -z "$my_string" ]
then
   echo "ERROR: NULL 'my_string'; script execution aborted" 1>&2
   exit 1
else
   echo "No error - march on"
fi
echo "Completed if-then-else test for shell variable my_string"
```

A couple of References: [Examples from nixCraft](https://www.cyberciti.biz/faq/bash-shell-find-out-if-a-variable-has-null-value-or-not/), and [a Q&A from Linux SE](https://unix.stackexchange.com/a/524492/286615).  

[**⋀**](#table-of-contents)  

## How do I see my *environment*?

In most distros, both `env` and `printenv` output the environment in which the command is entered. In other words, the `env`/`printenv` output in `sh` will be different than in `zsh` and different in `cron`, etc. And as is typical, the output may be `piped` to another program, redirected to a file, etc, etc.

For special cases, `set` is a *bultin* that's rather complex ([see the documentation](https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin)). Used with no options, it lists the names and values of ***all*** shell variables, environment variables and even functions - huge amount of output.

```zsh
% printenv 
% # OR #
% env          # to view in the terminal 
% # OR #
% set | less   # HUGE output! pipe to less to view in the pager
```

[**⋀**](#table-of-contents)  

## Shell variables: What is the Best Naming Convention?

For purposes of this recipe, *"shell variables"* refers to variables that are local in scope; i.e. not *"environment variables"* ([REF](https://unix.stackexchange.com/questions/222913/bash-shell-vs-environment-variable)). I've always used upper-case characters & underscores when I need to create a *"shell variable"*. Yes - I use the *same* *convention* for "shell variables" as is used for "environment variables".  I adopted this *convention* years ago because I read somewhere that lower-case variable names could easily be confused with commands. This was very true for me, esp during early learning days. At any rate, it made sense at the time & I've stuck with it for many years. 

But *"change is the only constant"* as the saying goes, and I wanted to verify that my adopted convention remains *in bounds*.  I've been unable to find a *standard* (e.g. POSIX) that prescribes a convention for "shell variables", but I've found there are certainly differences in *opinion*. Here's a summary of my research: 

* From Stack Overflow, this Q&A has some [interesting opinions and discussion](https://stackoverflow.com/questions/673055/correct-bash-and-shell-script-variable-capitalization) - well worth the read IMHO. 
* From a HTG post: [How to Work with Variables in Bash](https://www.howtogeek.com/442332/how-to-work-with-variables-in-bash/) : 

> A variable name cannot start with a number, nor can it contain spaces.  It can, however, start with an underscore. Apart from that, you can use  any mix of upper- and lowercase alphanumeric characters. 

* This NEWBEDEV post [Correct Bash and shell script variable capitalization](https://newbedev.com/correct-bash-and-shell-script-variable-capitalization) contains some good suggestions, including the use of ***"snake case"***  (all lowercase and underscores) for "shell variables". The post is well-written, and informative, but rather opinionated. The author refers to something called   *"internal shell variables"* which isn't well-defined, but specifically recommends lower case/*snake case* for *"shell variables"*. He also refers to a POSIX standards document, but it is **soft** on the upper vs. lower case conventions. 
* This post [Bash Variable Name Rules: Legal and Illegal](https://linuxhint.com/bash-variable-name-rules-legal-illegal/) is also quite opinionated, but without reference to anything except what the author refers to as *"good practice"*:

> The variable name must be in the upper case as it is considered good practice in bash scripting. 

#### Summary: 

I've found no reliable reference or relevant standard that recommends against the use of the `upper-case characters & underscore` convention. As I understand it the *opinions* favoring  `lower-case characters & underscore`  are based on claims that  [`"this convention avoids accidentally overriding environmental and internal variables"`](https://stackoverflow.com/a/673940/5395338).  However, it is not possible to change an *"environment variable"* using the assignment operator `=`  <sup>[REF 1](https://unix.stackexchange.com/a/74634/286615), [REF 2](https://stackoverflow.com/a/1506185/5395338), [REF 3](https://www.digitalocean.com/community/tutorials/how-to-read-and-set-environmental-and-shell-variables-on-linux#setting-shell-and-environmental-variables)</sup>. In addition, there's a rather straightforward method of testing a "shell variable" to ensure it is not an "environment variable" using the shell *built-in* `set` command: 

```bash
# For this example, suppose we consider using MAILCHECK as a shell variable:
$ set | grep MAILCHECK
MAILCHECK=60
# whoops! better try something else:
$ set | grep CHECK_MAIL
$
# OK - that will work
```

For now, I will remain *skeptical* that ***"snake case"*** or any other case-related ***convention*** holds a compelling advantage over others. [Do let me know](https://github.com/seamusdemora/PiFormulae/issues) if you feel differently, or find a broadly used standard (e.g. POSIX).

**To be clear:** The term *"shell variables"* is ambiguous. I have adopted one definition here that fits my objectives for this recipe, but do not suggest that there is only one definition. In fact, the GNU Bash Reference Manual uses an entirely different definition for [Shell Variables](https://www.gnu.org/software/bash/manual/bash.html#Shell-Variables).  

[**⋀**](#table-of-contents)  

## File and directory permissions

>**File permissions:**   
>
>r = read the contents of the file; value: `4`; binary: `100`  
>w = modify the file; value `6`; binary: `110`  
>x = run the file as an executable; value `7`; binary: `111`  

> **Directory permissions:**  
>
> r = list the contents of the directory  
> w = delete or add a file in the directory  
> x = `cd` into the directory

To modify file or directory permissions, the `chmod` command is used. Perhaps the *simplest* usage of `chmod` is to express the permissions as numeric values; e.g. `chmod 644 /path/to/file`. This perhaps makes more sense if we take the `644` permissions one digit at a time (6, 4, 4); for a **file** : 

-  `6` : file "owner" permission; expressed as binary: `110`  =>  permission to write (modify) the file
-  `4` : file "group member" permission; expressed as binary: `100`
-  `4` : "everyone else" permission; expressed as binary: `100`

IOW, each user entity (owner, group member, everyone else) has his permissions set by an octal (0-7) code. The *"everyone else"* designation refers to users who are **not** the owner, and **not** a group member. 

Perhaps the most frequent need for `chmod` is to declare a *script* file as *executable*. For example, you have written a script - `helloworld.sh`, and now you want to ***run*** that script. Before you can run  it, the script file must be marked as executable: 

```bash
$ chmod 755 helloworld.sh
$ ./helloworld.sh
Hello World!
$
```

But there are many other situations where `chmod` could (and should) be used. An example I encountered recently was *uniformly* setting all file and folder permissions in a "music library" I created. The library was sourced from various locations: an old Windows machine, and even older NAS drive, YouTube downloads, etc, etc. It was a *mess*! Complicating this was of course the fact that file and folder permissions mean different things, and they should not be set the same. Here's a useful technique to remember: 

```bash
# first - set all folder permissions so any user can access all music in the library
# this means setting folder permissions to include "execute" privileges
# we use 'find' with the '-exec' option to identify & set permissions for all folders

$ find /path/to/dir -type d -exec chmod 755 {} + 

# second - set all file permissions so any user can read all music, only the owner can change the files

$ find /path/to/dir -type f -exec chmod 644 {} +
```

Finally - you might be wondering why the command to manipulate permissions is called `chmod`. Consulting [wikipedia](https://en.wikipedia.org/wiki/Chmod), provides the answer to that question: 

>  `chmod` is a shell command for changing access permissions (and *flags*) of files and directories/folders. The name is short for ***ch**ange **mod**e* where ***mode*** refers to the permissions and flags collectively.

[**⋀**](#table-of-contents)

## Using `which` to find commands

For `zsh` users: You've installed a package - but where is it? The `which` command can help, but there are some things you *need to know*: 

* `which` relies on a *cache* to provide its results; this *cache* may not be *timely* or current.
* To *refresh* the *cache*, run `rehash` or `hash -r`.
* There are *subtle differences* depending on your shell; `which` is a *built-in* for `zsh`, and a *discrete command* in `bash` 

In `bash`, `which` is a *stand-alone* command instead of a *builtin*.  Consequently `hash -r` is not needed to get timely results from`which`.  

[**⋀**](#table-of-contents)  

## Using your shell command history

For those of us who don't have a [photographic memory](https://en.wikipedia.org/wiki/Eidetic_memory), our shell **command history** is very useful.  Our primary objective in this brief segment is to gain some understanding of how the command history works.  Once this is understood, the configuration of command history becomes more clear, and allows us to use it with greater effect - to *tailor* it for how we work. 

The Figure below is intended to show the relationship between the *two different mechanisms* used by `bash` for storing **command history**. The dashed lines and arrows show the **"flow"** between the **"file history"**, and the **"session histories"**:

* Each *session* maintains its own unique history; it contains only commands issued in that session.
* When a session is ended, or its history filled to capacity, its history "flows" into the *file history*.
* A *session history* is deleted when the session is closed.
* The *file history* is an *aggregation* of all of a user's session histories. 
* The *file history* is a permanent record, typically stored in `~/.bash_history`.
* When a new session is launched, commands from the *file history* "flow in" to fill the *session history*.
* In summary, command histories "flow" in both directions between the *file history* & *session histories*.

![commandhistory2](pix/commandhistory-bash.png)

There are [numerous variables and commands (*built-ins*)](https://www.gnu.org/software/bash/manual/html_node/Using-History-Interactively.html) that control the behavior of the command history, and there are [numerous guides and recommendations](https://duckduckgo.com/?t=ffnt&q=how+to+configure+bash+command+history&ia=web) on how to configure the command history.  But you must understand ***how the command history works*** to make informed decisions about how to configure yours. 

 [T. Laurenson's blog post on `bash` history](https://www.thomaslaurenson.com/blog/2018/07/02/better-bash-history/), and his [command history configuration script](https://gist.github.com/thomaslaurenson/ae72d4b4ec683f5a1850d42338a9a4ab) are excellent IMHO. However, my command history configuration is different; I don't need (or want) my session histories merged immediately; I prefer they remain unique for the duration of that session. For me, this makes a command recall quicker and simpler as I tend to use different sessions for different tasks. 

 The semantics for configuring the `bash` command history options are covered in some of the [REFERENCES](#command-history), and here in [this section of the `bash` manual](https://www.gnu.org/software/bash/manual/html_node/Using-History-Interactively.html). If you're just starting with the command history, there may be some benefit to a brief perusal to appreciate the scope of this component of `bash`. If your objective is to gain some proficiency, your time will be well-spent in conducting some experiments to see for yourself how  a basic set of variables and commands affect command history behavior.

*What if you use a shell other than `bash`?* While some aspects of the command history are *shell-dependent*, they have more in common than they have differences. An [overview of the command history](https://github.com/seamusdemora/seamusdemora.github.io/blob/master/CommandHistoryIntro-zsh.md) - from a `zsh` perspective - is provided in another section of this repo.  

[**⋀**](#table-of-contents)  

## Searching command history

Paragraph [8.2.5 Searching for Commands in the History](https://www.gnu.org/software/bash/manual/html_node/Searching.html) in the [GNU Bash manual](https://www.gnu.org/software/bash/manual/) is probably the authoritative source for documentation of the search facility. But even they don't have *all the tricks*! We'll get to that in a moment, but I'd be remiss if I didn't take a moment to point out the value of reading the documentation... in this case, perhaps start with [8.2 Readline Interaction](https://www.gnu.org/software/bash/manual/bash.html#Readline-Interaction). You'll get more out of the effort.

***Anyway - back to command history searching:***

Many of you will already know that you can invoke a (*reverse*) search of your command history by typing <kbd>control+r</kbd> (`^r`) at the `bash` command prompt. You may also know that typing <kbd>control</kbd>+<kbd>g</kbd> (`^g`) will gracefully **terminate** that search. GNU's Bash manual also points out that a forward search may also be conducted using <kbd>control</kbd>+<kbd>s</kbd>. But if you've tried the forward search, you may have found that it doesn't work! And so here's *the trick* alluded to above: 

```bash
# add the following line(s) to ~/.bashrc:

# to support forward search (control-s)
stty -ixon
```

The reason <kbd>control</kbd>+<kbd>s</kbd> doesn't work is that it *collides* with `XON`/`XOFF` flow control (e.g. in Konsole). So the solutions are: **1.)** bind the forward search to another key, or **2.)** simply **disable**  `XON`/`XOFF` flow control using `stty -ixon`. And don't forget to `source ~/.bashrc` to load it. 

Finally, if you still have questions, I can recommend this [blog post from Baeldung](https://www.baeldung.com/linux/bash-using-history-efficiently) on the subject.  

[**⋀**](#table-of-contents)  

## Access compressed log files easily

If you ever find yourself rummaging around in `/var/log`... Maybe you're *'looking for something, but don't know exactly what'*.  In the `/var/log` file listing, you'll see a sequence of `syslog` files (and several others) arranged something like this: 

```
-rw-r----- 1 root        adm    3919 Jan 17 01:38 syslog
-rw-r----- 1 root        adm  176587 Jan 17 00:00 syslog.1
-rw-r----- 1 root        adm   11465 Jan 16 00:00 syslog.2.gz
-rw-r----- 1 root        adm   19312 Jan 15 00:00 syslog.3.gz
-rw-r----- 1 root        adm    4893 Jan 14 00:00 syslog.4.gz
-rw-r----- 1 root        adm    5398 Jan 13 00:00 syslog.5.gz
-rw-r----- 1 root        adm    4472 Jan 12 00:00 syslog.6.gz
-rw-r----- 1 root        adm    4521 Jan 11 00:00 syslog.7.gz
```

The `.gz` files are compressed with `gzip` of course - but **how to view the contents?**  There are some tools to make that job a little easier.  `zgrep` and `zless` are the most useful in my experience, but `zdiff` and `zcat` are also there if you need them. Note that these "`z`" utilities will also handle *non-compressed* files, but don't be tempted to use them as a substitute since not all options are available in the "`z`" version. For example, `grep -R` doesn't translate to `zgrep`. 

As a potentially useful example, consider listing all of the `Under-voltage` warnings in `/var/log/syslog*`. Note that the `syslog*` *filename expansion / globbing* will get **all** the syslog files - compressed or uncompressed. Since there may be quite a few, piping them to the `less` pager won't clutter your screen: 

```bash
$ zgrep voltage /var/log/syslog* | less
```

If you want daily totals of `Under-voltage` events, use the `-c` option: 

```bash
$ zgrep -c voltage /var/log/syslog*
/var/log/syslog:0
/var/log/syslog.1:8
/var/log/syslog.2.gz:3
/var/log/syslog.3.gz:5
/var/log/syslog.4.gz:4
/var/log/syslog.5.gz:10
/var/log/syslog.6.gz:0
/var/log/syslog.7.gz:0
```

Or weekly totals of  `Under-voltage` events: 

```bash
$ zgrep -o voltage /var/log/syslog* | wc -l
30
```

Still more is possible if you care to pipe these results to `awk`.  

[**⋀**](#table-of-contents)  

## Filename expansion; a.k.a. "globbing"

The astute reader might have noticed the syntax from above:

`$ zgrep -c voltage /var/log/syslog*`

What does that *asterisk* (`*`) mean; what does it do? 

It's one of the more powerful [idioms](https://en.wikipedia.org/wiki/Programming_idiom) available in `bash`, and extremely useful when working with files. Consider the alternatives to instructing `bash` to loop through all the files with `syslog` in their filename. Read more about its possibilities, and study the examples in the [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/globbingref.html).  

[**⋀**](#table-of-contents)  

## Using the default editor `nano` effectively

I was writing this section in conjunction with an [answer in U&L SE.](https://unix.stackexchange.com/a/634503/286615)  Why?... I felt the [project documentation](https://www.nano-editor.org/dist/v2.8/nano.html) left something to be desired. A search turned up [HTG's *"Guide to Nano"*](https://www.howtogeek.com/howto/42980/the-beginners-guide-to-nano-the-linux-command-line-text-editor/), and more recently this post: [*"Getting Started With Nano Text Editor"*](https://itsfoss.com/nano-editor-guide/).  `nano` doesn't change rapidly, but perhaps the *timeless* method for finding documentation on `nano` is to [find a descriptive *term*, and do your own search](https://duckduckgo.com/?q=nano+text+editor+user+guide&t=ffab&atb=v278-1&ia=web)? 

This is all well & good, but the sources above do not answer nano's ***burning question***: 

> The help screen in nano (^G) lists many options, but using most of them requires one to know what key represents `M`- the *"meta key"*... what is the "meta key"?

* On macOS, `M`- the *"meta key"* - is the <kbd>esc</kbd> key 
* On Linux & Windows(?), `M`- the *"meta key"* - is the <kbd>Escape</kbd> key

Another useful item is `nano`'s **configuration file** - `~/.nanorc`. Here's what I put in mine:
```bash
$ cat ~/.nanorc
set tabsize 4
set tabstospaces
```

[**⋀**](#table-of-contents)  

## Some Options with `grep`

`grep` has many variations which makes it useful in many situations. We can't cover them all here (not even close), but just to whet the appetite: 

* `grep` can return TRUE/FALSE: `grep -q PATTERN [FILE]`; `0` if TRUE, `non-zero` if FALSE
* `grep` can return the matching object only: `grep -o PATTERN [FILE]` instead of the entire line
* `grep` can return everything that ***does not match*** the search term by using the `-v` option
* you can `pipe` the output of a command to `grep`:  `cat somefile.txt | grep 'Christmas'` 
* you can combine grep with redirection... ***if you do it correctly***: 

     ```bash
      $ rsync -av /src/foo/ /dest/bar | grep --line-buffered "search term" > somefile.log 
      #                                 ^^^^^^^^^^^^^^^^^^^^
     ```

* `grep` can process a [`Here String`](https://linux.die.net/abs-guide/x15683.html):  `grep PATTERN <<< "$VALUE"`, where  `$VALUE` is expanded & fed to `grep`. 
* `grep`*'s* `PATTERN` may be a literal string, or a regular expression; e.g. to find **IPv4 ADDRESSES** in a file: 

```bash
    sudo grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" /etc/network/interfaces
```
   >*NOTE: This is not an exact match for an IP address, only an approximation, and may occasionally return something other than an IP address. An [exact match](https://www.regextester.com/22) is available here.*
   >

* `grep` can search through multiple files for a match; e.g. to recursively search through all files in the `pwd` :
  
     ```bash
     $ grep -rni "my search string" *
     README.md:6:my search string
     test.txt:1:my search string
     ^^^^^^^^ ^ ^^^^^^^^^^^^^^^^
        |     |         |________ 3rd field - the matched string
        |     |__________________ 2nd field - the line # containing the matching string
        |________________________ 1st field - the filename that contains a match
     
     ```


[**⋀**](#table-of-contents)  

## Filtering `grep` processes from `grep` output

`grep` provides a very useful filter in many situations. However, when filtering a list of *processes* using `ps`, `grep` introduces an annoying artifact: its output also includes the `grep` process that is filtering the output of `ps`. This is illustrated in the following example: 

```bash
$ ps aux | grep cron
root       357  0.0  0.1   7976  2348 ?        Ss   16:47   0:00 /usr/sbin/cron -f
pi        1246  0.0  0.0   7348   552 pts/0    S+   18:46   0:00 grep --color=auto cron
```

Removal of this artifact can be accomplished in one of two ways: 

```bash
$ #1: use grep -v grep to filter grep processes
$ ps aux | grep name_of_process | grep -v grep 
root       357  0.0  0.1   7976  2348 ?        Ss   16:47   0:00 /usr/sbin/cron -f 
$ #2: use a regular expression instead of a string for grep's filter
$ ps aux | grep [n]ame_of_process 
```

[**⋀**](#table-of-contents)  

## Finding pattern matches: `grep` or `awk`?

While researching this piece, I came across [this Q&A](https://stackoverflow.com/questions/4487328/match-two-strings-in-one-line-with-grep) on Stack Overflow. As I read through the answers, I was surprised that some experienced users answered the question incorrectly! As I write this (Feb 2022), there are at least six (6) answers that are wrong - including one of the *most highly voted* answers.  I can't guess why so many upvoted incorrect answers, but the question is clear: `Match two strings in one line with grep?`; confirmed in the body of the question. 

But *the point* here is not to chide for incorrect answers. The SO Q&A serves only to *underscore* the point  that it pays to consider which tool (`awk` or `grep` in this case) is "best" for the job.  "Best" is of course subjective, so here I attempt to *illustrate the alternatives by example*, and the reader may decide the *best* answer for himself. Before the example, let's review the mission statements of awk & grep from their man pages: 

* `man grep`: ***print lines that match patterns***; for details see [GNU grep online manual](https://www.gnu.org/software/grep/manual/) 
* `man awk`: ***pattern scanning and processing language***; for details see [GNU awk/gawk online manual](https://www.gnu.org/software/gawk/manual/) 

So - `awk`'s ***processing*** adds significant scope compared to that of `grep`. But for the business of *pattern matching*, it is not necessary to bring all of that additional scope to bear on the problem. Let me explain: An `awk` statement has two parts: a ***pattern***, and an associated ***action***. A key feature of `awk` is that the ***action*** part of a statement **may be omitted**. This, because in the absence of an explicit action, `awk`'s ***default action*** is `print`.  Alternatively, [`awk`'s **basic** function](https://www.gnu.org/software/gawk/manual/gawk.html#Getting-Started)  is to search text for patterns; this is `grep`'s **only** function. 

Finally, know that AWK is a language, `awk` is an implementation of that language, and there are [several implementations](https://unix.stackexchange.com/a/29583/286615) available. Also know that there are far more implementations of grep - which is an [acronym - explained here](https://linuxhandbook.com/what-is-grep/). There are also wide variations in the various grep implementations, as you may notice from reading the previously cited [SO Q&A](https://stackoverflow.com/questions/4487328/match-two-strings-in-one-line-with-grep), and many other Q&A on grep usage. 

Before beginning with the examples, I'll introduce the following file - used to verify the accuracy of the commands in the examples shown in the table below: 

```bash
 $ cat -n testsearch.txt
     1	just a random collection on this line
     2	string1 then some more words string2 #BOTH TARGETS
     3	string2 blah blah blub blub noodella #ONLY TARGET2
     4	#FROM 'Paradise Lost':
     5	They, looking back, all the eastern side beheld
     6	Of Paradise, so late their happy seat,
     7	Waved over by that flaming brand; the gate
     8	With dreadful faces thronged and fiery arms.
     9	Some natural tears they dropped, but wiped them soon;
    10	The world was all before them, where to choose
    11	Their place of rest, and Providence their guide.
    12	They, hand in hand, with wandering steps and slow,
    13	Through Eden took their solitary way.
    14	string1 this line contains only one #ONLY TARGET1
```

And here are the examples. All have been tested using the file `testsearch.txt`, on Debian bullseye using **GNU grep ver 3.6**, and **GNU Awk 5.1.0, API: 3.0 (GNU MPFR 4.1.0, GNU MP 6.2.1)**. 

<table class="minimalistBlack">
<thead>
<tr>
<th width="48%"><code><center><b>grep</b></center></code></th>
<th width="2%">RES</th>
<th width="48%"><code><center><b>awk</b></center></code></th>
<th width="2%">RES</th>
</tr>
</thead>
<tbody>
<tr>
  <td colspan="4"><center><b>Ex. 1:</b> Print line(s) from the file/stream that contain <b><code>string1</code> AND <code>string2</code></b></center></td>
</tr>
<tr>
  <td colspan="4"><center><i>Correct Output (<b>RES</b>) is Line #2 Only:</i><b><code>      "string1 then some more words string2 #BOTH TARGETS"      </code></b></center></td>
</tr>
<tr>
  <td><code><small>grep 'string1' testsearch.txt | grep 'string2'</small></code></td>
  <td><center>Yes</center></td>
  <td><code><small>awk '/string1/ && /string2/' testsearch.txt</small></code></td>
  <td><center>Yes</center></td>
</tr>
<tr>
  <td><code><small>grep -P '(?=.*string1)(?=.*string2)' testsearch.txt</small></code></td>
  <td><center>Yes</center></td>
  <td></td>
  <td></td>
</tr>
<tr>
  <td><code><small>grep 'string1\|string2' testsearch.txt</small></code></td>
  <td><center>No</center></td>
  <td></td>
  <td></td>
</tr>
<tr>
  <td><code><small>grep -E "string1|string2" testsearch.txt</small></code></td>
  <td><center>No</center></td>
  <td></td>
  <td></td>
</tr>
<tr>
  <td><code><small>grep -e 'string1' -e 'string2' testsearch.txt</small></code></td>
  <td><center>No</center></td>
  <td></td>
  <td></td>
</tr>
</tbody>
</table>  

[**⋀**](#table-of-contents)  

## What version of `awk` is available on my Raspberry Pi?

Know first that (*mostly*) because RPiOS is a *Debian derivative*, its *default AWK* is `mawk`. `mawk` has been characterized as having only *basic features*, and being *very fast*. This seems a reasonable compromise for the RPi; in particular the *Zero*, and the older RPis.  But here's an [*odd thing*](https://github.com/ploxiln/mawk-2): the release date for the `mawk` package in `buster` was 1996, but the release date for the `mawk` package in `bullseye` was in Jan, 2020. And so the version included in your system depends on the OS version; i.e. Debian 10/`buster`, or Debian 11/`bullseye`.  You can get awk's version # & other details as follows: 

```bash
$ cat /etc/debian_version
10.11
$ awk -W version
mawk 1.3.3 Nov 1996, Copyright (C) Michael D. Brennan
...
```

 ```bash
 $ cat /etc/debian_version
 11.2
 $ awk -W version
 mawk 1.3.4 20200120
 Copyright 2008-2019,2020, Thomas E. Dickey
 Copyright 1991-1996,2014, Michael D. Brennan
 ...
 ```

* From the [`buster` list of packages](https://packages.debian.org/buster/amd64/allpackages): 

   >[mawk](https://packages.debian.org/buster/amd64/mawk) (1.3.3-17+b3)

* From the [`bullseye` list of packages]()

   >[mawk](https://packages.debian.org/bullseye/amd64/mawk) (1.3.4.20200120-2) 

And of course, since `gawk` has been in the RPiOS package repository for a while, installing that is also an option. The `update-alternatives` utility can make the changes necessary to make `gawk` the default for `awk`. Once `gawk` is declared the default for `awk`, you can confirm that as follows: 

```bash
$ awk -W version
GNU Awk 4.2.1, API: 2.0 (GNU MPFR 4.0.2, GNU MP 6.1.2)
Copyright (C) 1989, 1991-2018 Free Software Foundation.
...
```

Know that version 5 of `gawk` is available in `bullseye`'s package repo, but the `buster` repo is limited to version 4. ICYI, the [LWN article](https://lwn.net/Articles/820829/) mentioned in the [References](#using-awk-for-heavy-lifting) goes into some detail on the feature differences between `gawk` ver 4 & ver 5.  

[**⋀**](#table-of-contents)  

## That file is somewhere in my system

Sometimes, *finesse* is over-rated. Sometimes things get misplaced, and you need to find it quickly. A feeling of panic may be creeping upon you due to impending schedule deadlines - or whatever the reason. These examples should help if you can remember anything at all about the filename - or its contents. And as always, refer to the appropriate `man` page on your system for up-to-date and appropriate details. 

#### You remember something (word, word-segment, phrase) that's in the file:

```bash
# search `/etc` recursively for filenames containing lines beginning w/ string 'inform'
# search a named path recursively for filenames & line nos matching the whole word 'mypattern'
# piping to pager 'less' avoids clutter in your terminal
# use 'sudo' to read "root-restricted" files; e.g. -rw-r--r-- 1 root root

$ sudo grep -rlI '/etc' -e '^inform' | less -N     # '-N' gets line numbers in 'less'
$ grep -rlnw '/path/you/choose/' -e 'mypattern'
# some useful options:
# -i : case-insensitive
# -I : do not search binary files
# -R : recursive, follow symlinks; -r : recursive, do not follow symlinks
# -n : output the line number
# -l : show the file name
#
# other examples:
# include ONLY files ending in .bash or .sh
$ grep --include=\*.{bash,sh} -rl '/home/pi/scripts' -e "shazam" 
# exclude named sub-directories from the search
$ grep --exclude-dir={network,cron*} -rl '/etc' -e "goober" 

```
#### You remember/know the file name, or some portion of it: 

Other times, the file you need to find is binary, or maybe you don't recall any of its contents, but you do recall part of the filename. In this situation, `find` may be the right tool.  Keep in mind that *recursion* is "free" when using `find`, but you can limit the depth of the recursion. See `man find` for the details; this may get you started: 

```bash
# search from the named path, '-type d' is a directory/folder,  '-name' is case-sensitive
$ find /some/path -type d -name "*doright*"  
# search from the 'pwd' (.), '-type f' is a file,  '-iname' is case-insensitive, pipe output to 'less' pager
$ find . -type f -iname "*money*" | less
```

[**⋀**](#table-of-contents)  

## Find what you need in that huge `man` page:

Not a *shell trick* exactly, but ***useful***: Most systems use the *pager* named `less` to display `man` pages in a terminal. Most frequently, `man` pages are consulted for a reference to a *specific* item of information - e.g. the meaning of an *argument*, or to find a particular section. `less` gives one the ability to search for words, phrases or even single letters by simply entering `/` from the keyboard, and then entering a *search term*. This search can be made much more *effective* with the addition of a [*regular expression*](https://www.regular-expressions.info/quickstart.html) or *regex* to define a *pattern* for the search. This is best explained by examples: 

* find the list of `flags` in `man ps`:

​        Entering `/flags` in `less` will get you there eventually, but you'll have to skip through several irrelevant matches. Knowing that the list of possible `flags` is at the beginning of a line suggests that a *regex* which finds a match with flags at the beginning of a line preceded by whitespace. Calling upon our mastery of *regex* suggests that the search expression should be *anchored* at the beginning of a line, followed by 0 or more spaces or tabs preceding our keyword `flags` will do the job; i.e.:  **`/^[ \t]*flags`**

* find the syntax of the `case` statement in `bash`: 

​         Again, as we are looking to match a term at the beginning of a line, use the **`^`** anchor, followed by the *whitespace* character class repeated 1 or more times **`[ \t]+`**, followed by the search term `case`. In this search, we'll look for matches having whitespace *after* the regex also:  **`/^[ \t]+case[ \t]+`**  

[**⋀**](#table-of-contents)  

## Useful tools for GPIO hackers: `raspi-gpio` and `pinctrl`

`raspi-gpio` was a useful tool for those interested in working with RPi's GPIO. It's said to be *deprecated* now, but is still included in all standard RPi distros through 'bookworm' - even in the `Lite` distro. The [apparent reason](https://github.com/RPi-Distro/raspi-gpio) for the *deprecation* of `raspi-gpio` is that it does not (cannot) support RPi5. Presumably, `raspi-gpio` will continue to work on all other RPi models, but it seems unlikely that further development effort will go into it. 

The replacement for GPIO hacking is now `pinctrl` - available [from "The Raspberries" GitHub](https://github.com/raspberrypi/utils/blob/master/pinctrl/README.md), and the subject of a ["recipe" here](https://github.com/seamusdemora/PiFormulae/blob/master/GPIO_Using_pinctrl.md) from yours truly. Note that "The Raspberries" have embedded a "disclaimer" in `pinctrl help`: 

>WARNING! pinctrl set writes directly to the GPIO control registers
ignoring whatever else may be using them (such as Linux drivers) -
it is designed as a debug tool, only use it if you know what you
are doing and at your own risk!

Readers will have to *digest* this warning in the context of the Linux kernel's entry in the *"GPIO Race"* - `libgpiod`. For me personally, it's not much of a race... while I've not tried the `libgpiod` library itself, I did a [fair and thorough evaluation](https://github.com/seamusdemora/PiFormulae/blob/master/Testing-libgpiod-ver2.1.md#25-summary---step-2-simple-libgpiod-testing-using-an-led-) of the so-called `libgpiod tools`. And the fact that the [self-designated promoter](https://forums.raspberrypi.com/search.php?keywords=&terms=all&author=warthog618&sc=1&sf=all&sr=posts&sk=t&sd=d&st=0&ch=300&t=0&submit=Search) of `libgpiod` is a cocky, overbearing, shit-for-brains idiot doesn't help :)  

And we should not fail to mention the [**`gpio` directive**](https://www.raspberrypi.com/documentation/computers/config_txt.html#gpio) that may be placed within your `config.txt` file! Fortunately, the `gpio` directive uses options that closely resemble those of `raspi-gpio` and `pinctrl`. Interestingly,  `gpio` directives in `config.txt`  `gpio` **can be overridden by `pinctrl`**. Even more interestingly, the  [`gpio` directive documentation](https://www.raspberrypi.com/documentation/computers/config_txt.html#gpio) does not include the warning/disclaimer found in `pinctrl help`  :)  *wonder what that means?* 

[**⋀**](#table-of-contents)  

## `raspi-config` from the command line?

You've probably used the "graphical" (*ncurses* -based) version of `raspi-config` that you start from the command line, and then navigate about to make configuration changes to your system. ***However***, you may also use `raspi-config` from the command line. This feature isn't well-documented (or well-understood), and even the [GitHub repo for `raspi-config`](https://github.com/RPi-Distro/raspi-config) doesn't have anything to say about it - actually, it says nothing about everything :P  [This blog post](https://pi3g.com/2021/05/20/enabling-and-checking-i2c-on-the-raspberry-pi-using-the-command-line-for-your-own-scripts/) seems to be the best source of information for now.  

[**⋀**](#table-of-contents)  

## Background, nohup, infinite loops, daemons

It's occasionally useful to create a program/script that runs continuously, performing some task. Background, nohup and infinite loops are all *ingredients* that allow us to create [*daemons*](https://en.wikipedia.org/wiki/Daemon_(computing)) - very useful actors for accomplishing many objectives. Here's a brief discussion of these ingredients, and a brief example showing how they work together: 

* ***infinite loop:*** this is a set of instructions that run continuously by default; instructions that are executed repetitively until stopped or interrupted. In a literary sense, the infinite loop could be characterized as the daemon's beating heart. 

  The infinite loop provides the framework for a task that should be performed continuously; for example a *software thermostat* that monitors your home temperature, and turns a fan ON or OFF depending upon the temperature.  Infinite loops may be set up in a number of different ways; see the [references](#scripting-with-bash) below for details. Since our topic here is *shell tricks*, we'll use the most common `bash` implementation of an infinite loop - the `while` condition. 

  Shown below is a complete, functional program (though not quite useful) that will be *daemon-ized* in the sequel, illustrating the simplicity of this recipe. You may copy and paste these 5 lines of code into a file on your RPi, save it as `mydaemond`, and make it *executable* (`chmod 755 mydaemond` ): 

  ```bash
    #!/usr/bin/env bash
    while :
    do
      echo "Hello, current UTC date & time: $(date -u)"
      sleep 60
    done
  ```

* ***background (`&`) and `nohup`:*** `nohup` is a *"command invocation modifier"* , and the ampersand symbol **`&`** is a *"control operator"* in `bash`.  These obscure, but powerful instructions are covered in the [GNU documentation for `bash`](https://www.gnu.org/software/bash/manual/bash.html#Lists) (**`&`**), and [GNU documentation for core utilities - `coreutils`](https://www.gnu.org/software/coreutils/manual/coreutils.html#nohup-invocation) (**`nohup`**).  Used together, they can  *daemon-ize* our simple script: **`&`** will free your terminal/shell session for other activities by causing the script to run in the ***background***, and **`nohup`** allows it to continue running after your terminal or shell session is ended.  To paraphrase Dr. Frankenstein, [*"**It's alive!**"*](https://www.youtube.com/watch?v=xos2MnVxe-c). 

  Let's play Dr. Frankenstein for a moment, and bring `mydaemond` to life from our terminal: 
  
  ```bash
    $ chmod 755 mydaemond
    $ nohup ./mydaemond &
    [1] 14530
    $ nohup: ignoring input and appending output to 'nohup.out'
    $ logout
  ```
  
  Note the output: `[1] 14530`; this line informs us primarily that the *process id (PID)* of `mydaemond` is `14530`. The next line tells us what we already knew from reading the [`nohup` documentation](https://www.gnu.org/software/coreutils/manual/coreutils.html#nohup-invocation) - or `man nohup`: the default case is to redirect all stdout to the file `nohup.out`.  
  
  The `logout` command ends this terminal session: the interactive shell from which `mydaemond` was launched - the *parent* process of `mydaemond`- no longer exists.  Linux doesn't normally *orphan* processes, and as of now `mydaemond` has been adopted; its *new parent process* has PID `1`.  In Linux, PID 1 is reserved for `init` - a generic name for what is now called `systemd`. [*mind blown*](https://www.youtube.com/watch?v=5GZcCLfeH28) 
  
  This can all be confirmed by launching a new terminal/login/SSH connection. Once you've got a new terminal up, there are at least two ways to confirm that  `mydaemond` is still "alive": 
  
  1. Monitor `nohup.out` using `tail -f` as shown below:
  
  ```bash
    $ tail -f nohup.out 
    Hello, current UTC date & time: Tue 15 Mar 01:13:52 UTC 2022
    Hello, current UTC date & time: Tue 15 Mar 01:14:52 UTC 2022
    # ... etc, etc
  ```
  
  2. Ask `ps` for a report:
  
    ```bash
    $ ps -eo pid,ppid,state,start,user,tpgid,tty,cmd | grep "^14530"
    14530     1 S 01:13:51 pi          -1 ?        /bin/sh ./mydaemond
    ```
  
    `ps` is the more informative method. This may look complicated, but it's not. We've eschewed the *old* BSD syntax for the standard syntax. The `-o` option (`man ps`, `OUTPUT FORMAT CONTROL` section)  allows one to create a customized report using keywords defined in the  `STANDARD FORMAT SPECIFIERS` section. Note the `ppid` (parent PID) is `1`, corresponding to `systemd`'s PID, the `start` time at `01:13:51`, the `user` name `pi`, `tpgid` of `-1` means not attached to a TTY, same as `tty`=`?` and finally the issuing command `cmd` of `./mydaemond`. All matching with actual history. For another view, try the command `pstree -pua`; the *tree* shows `mydaemond` as a *branch* from the `systemd` *trunk*.

* ***OK, but how do I stop `mydaemond`? :*** `mydaemond` has been instructional, but it has now served its purpose. To free up the resources it is now consuming, we must `kill` the process, and remove the contents of the `nohup.out` file: 

   ```bash
   $ kill 14530
  $ # confirm kill
  $ ps -e | grep ^14530
  $ # 'rm nohup.out' to remove the file; alternatively, empty file without removing it 
  $ > nohup.out   # empty the file
  ```
  
  And that's it.
  

[**⋀**](#table-of-contents)  

## Bluetooth

***Having Bluetooth Issues?***
If you spend a week or so chasing Bluetooth problems on a Linux system, you begin to wonder: "Does Bluetooth on Linux just suck?" Unfortunately, I think the answer may be, "Yes, it does suck... at least on my Raspberry Pi systems."  I finally got fed up, and took the problem to the Raspberry Pi GitHub sites:

* First: in the [RPi-Distro repo](https://github.com/RPi-Distro/repo/issues/369), where I was told this was a "Documentation issue", and should be filed in the Documentation repo.  
* Second: in the [Documentation repo](https://github.com/raspberrypi/documentation/issues/3585#event-12354374925), where I was told it was **not** a Documentation issue - it was a software (RPi-Distro) issue! 

IOW - I got *the run-around*! And it gets worse: Apparently I have been *banned from posting in the RPi-Distro repo for life*! You see "The Raspberries" at their worst, and over-the-top British arrogance in these exchanges. 

However: I [**have made some progress**](https://github.com/seamusdemora/PiFormulae/tree/master) - see the recipes that begin with the word '**Bluetooth**'. And I'm happy to say that *most* of the Bluetooth issues have been resolved! There are currently three (3) recipes dealing with Bluetooth audio for RPi Lite systems: 

1. [Raspberry Pi Zero 2W; 'bookworm' Lite OS](https://github.com/seamusdemora/PiFormulae/blob/master/Bluetooth-UsingBackportsForPipewire.md) : This recipe focuses on a `pipewire`-based solution, where the `pipewire` installation was taken from Debian's bookworm backports tree - instructions are in the recipe. This installation has since been returned to the `stable` tree where it is running `pipewire ver 1.2.4`. It has been extremely reliable; although I did run into a hitch removing it from the `backports` tree. 
2. [Raspberry Pi 3A+; 'bookworm' Lite OS](https://github.com/seamusdemora/PiFormulae/blob/master/Bluetooth-AudioForBookwormLite.md): This is a slightly older recipe, but remains valid. It began with an installation of the [`bluez-alsa` repo](https://github.com/Arkq/bluez-alsa), and then moved on to `pipewire`. The `pipewire` installation was from Debian's stable tree; it began with version `0.3.65`, and was later upgraded via `apt` to version `1.2.4`. And so this installation ***wound up*** at the same place as the Zero 2W installation. This recipe also contains instructions for setting up a modified `systemd getty@tty1.service`; I feel this is a worthwhile modification. 
3. [Raspberry Pi 3A+ "Bluetooth Hardware Upgrade"](https://github.com/seamusdemora/PiFormulae/blob/master/Bluetooth-UpgradeRPiBtHardware.md): I decided to try a "Bluetooth hardware upgrade"; i.e. a Bluetooth "USB dongle" to replace the built-in Raspberry Pi Bluetooth hardware. It's relatively inexpensive, it's easily configured, and it has worked extremely well in my RPi 3A+ bookworm system with `pipewire`.  

I suppose I would be remiss if I failed to point out the value of ***persistence*** in reaching this point of Bluetooth Bliss with my *Lite* systems...  HOWEVER  you should be aware of certain [*'Bluetooth Bullshit'*](https://github.com/seamusdemora/PiFormulae/blob/master/Bluetooth-AudioMythsDispelled.md) wrt more "advanced" usage (e.g. the so-called A2DP Profile). Keep your expectations for Bluetooth audio quality in check - [as I learned here](https://gitlab.freedesktop.org/pipewire/wireplumber/-/issues/798). 

[**⋀**](#table-of-contents) 

## Change the modification date of a file

From time-to-time, we all need to make adjustments to the modification date/time of a file(s) on our system. Here's an easy way to do that: 

```bash
$ touch -d "2 hours ago" <filename> 
# "2 hours ago" means two hours before the present time
# and of course you can use seconds/minutes/days, etc
```

If OTOH, you want to change the modification time **relative to the file's current  modification time**, you can do that as follows: 

```bash
$ touch -d "$(date -R -r <filename>) - 2 hours" <filename> 
# "- 2 hours" means two hours before the current modification time of the file
# Example: subtract 2 hours from the current mod time of file 'foo.txt':
$ touch -d "$(date -R -r foo.txt) - 2 hours" foo.txt
```

[**⋀**](#table-of-contents)  

## Using 'date' to deal with 'Unix time'

Those of you who have administration chores involving use of ["Unix time"](https://en.wikipedia.org/wiki/Unix_time) may appreciate this. This trick has been *"hiding in plain sight"* for quite a while now, but it can come in very handy when needed. In my case, I was dealing with the `wakealarm` setting for a Real-Time Clock; I use it to turn one of my Raspberry Pi machines ON and OFF. The `wakealarm` settings must be entered/written to `sysfs` in *Unix time* format; i.e. seconds from the epoch. The problem was trying to figure out how many seconds will elapse from the time I `halt` until I want to wake up 22 hours and 45 minutes later? Yes - I can multiply, but I'm also ***lazy*** :)   **How do I do this?** 

`man date` tells us that the format key for Unix time is `%s`:
>%s     seconds since 1970-01-01 00:00:00 UTC

So if I need to calculate the `wakealarm` time for 10 hours from now, I can do that as follows (this one is fairly simple): 
```bash
alarm=$(/usr/bin/date '+%s' -d "+ 10 hours")
...
$ echo $alarm
1723629537
```
Now, suppose I want to make a log entry indicating what time `wakealarm` is set for? Mmmm - ***not*** simple!

... But it can be done like so...

```bash
echo "$(date -d "@$alarm" +'%c')"
Wed 14 Aug 2024 09:58:57 UTC
```
So *"the trick"* is to precede the variable (`$alarm` in this case) with the `@` symbol! [The documentation is hidden here!](https://www.gnu.org/software/coreutils/manual/html_node/Seconds-since-the-Epoch.html)  

[**⋀**](#table-of-contents)

## Process Management: `jobs`, `fg`, `bg` and 'Ctrl-Z'

Let's assume you have started a long-running job from the shell: `fg-bg.sh` 

```bash
#!/usr/bin/env bash

# this script runs a continuous loop to provide a means to test Ctrl-Z, fg & bg
# my $0 is 'fg-bg.sh'

while :
do
    echo "$(date): ... another 60 seconds have passed, and I am still running" >> /home/pi/fg-bg.log
    sleep 60
done
```
Now let's start this script in our terminal:
```bash
$ ./fg-bg.sh

# This process is running in the *foreground*, and you have lost access to your terminal window (no prompt!)
```

Now, enter <kbd>ctrl</kbd><kbd>z</kbd> from your keyboard & watch what happens: 

```bash
$ ./fg-bg.sh
^Z
[1]+  Stopped                 ./fg-bg.sh
$
# Note the prompt has returned, and 'fg-bg.sh' has been stopped/halted/suspended - no longer running
```

Now, let's suppose we want to *re-start* `fg-bg.sh`, but we want to run it in the **background** so it doesn't block our terminal: 

```bash
$ ./fg-bg.sh
^Z
[1]+  Stopped                 ./fg-bg.sh
$ bg
[1]+ ./fg-bg.sh & 
# Note that 'fg-bg.sh' has been re-started in the background (see the '&'),
# And the command prompt has been restored. Confirm that 'fg-bg.sh' is running:
$ jobs
[1]+  Running                 ./fg-bg.sh &
$ 
```

Now, let's suppose that we want to monitor the output of `fg-bg.sh`; i.e. monitor `/home/pi/fg-bg.log` to check some things; we know that we can use `tail -f` to do that: 

```bash
$ ./fg-bg.sh
^Z
[1]+  Stopped                 ./fg-bg.sh
$ bg
[1]+ ./fg-bg.sh & 
$ jobs
[1]+  Running                 ./fg-bg.sh &
$ tail -f /home/pi/fg-bg.log
Tue 20 Aug 19:09:37 UTC 2024: ... another 60 seconds have passed, and I am still running
Tue 20 Aug 19:10:37 UTC 2024: ... another 60 seconds have passed, and I am still running
Tue 20 Aug 19:11:37 UTC 2024: ... another 60 seconds have passed, and I am still running

```

OMG - another process has taken our command prompt away! Not to worry; simply enter <kbd>ctrl</kbd><kbd>z</kbd> from your keyboard again, and then run `jobs` again:

```bash
$ ./fg-bg.sh
^Z
[1]+  Stopped                 ./fg-bg.sh
$ bg
[1]+ ./fg-bg.sh & 
$ jobs
[1]+  Running                 ./fg-bg.sh &
$ tail -f /home/pi/fg-bg.log
Tue 20 Aug 19:09:37 UTC 2024: ... another 60 seconds have passed, and I am still running
^Z
[2]+  Stopped                 tail -f /home/pi/fg-bg.log
$ jobs
[1]-  Running                 ./fg-bg.sh &
[2]+  Stopped                 tail -f /home/pi/fg-bg.log
$ 
```

Note that `fg-bg.sh` ***continues to run in the background***, and that `tail -f /home/pi/fg-bg.log` has now been stopped - thus restoring our command prompt. So cool :) 

So hopefully you can now see some uses for  <kbd>ctrl</kbd><kbd>z</kbd>, `fg`, `bg` and `jobs`. But you may be wondering, *"How do I stop/kill these processes when I'm through with them?"* Before answering that question, note the `jobs` output; the numbers `[1]` and `[2]` are *job ids* or *job numbers*. We can exercise control over these processes through their *job id*; e.g.:

```bash
$ jobs
[1]-  Running                 ./fg-bg.sh &
[2]+  Stopped                 tail -f /home/pi/fg-bg.log
$ kill %1
pi@rpi3a:~ $ jobs
[1]-  Terminated              ./fg-bg.sh
[2]+  Stopped                 tail -f /home/pi/fg-bg.log
pi@rpi3a:~ $ kill %2

[2]+  Stopped                 tail -f /home/pi/fg-bg.log
pi@rpi3a:~ $ jobs
[2]+  Terminated              tail -f /home/pi/fg-bg.log
pi@rpi3a:~ $ jobs
pi@rpi3a:~ $
# ALL GONE  :)
```

One final note: You can also use the ***job id*** to control `fg` and `bg`; for example if you had suspended a job using  <kbd>ctrl</kbd><kbd>z</kbd>, put it in the ***background*** (using `bg`) as we did above, you could also return it to the foreground using `fg %job_id`. 

[**⋀**](#table-of-contents) 

## Download a file from GitHub

OK - so not as easy as you might think - at least not for all pages/files. For example, I needed to update my pico Debug Probe with the latest firmware recently. The URL was given as follows: 

> https://github.com/raspberrypi/debugprobe/releases/tag/debugprobe-v2.0.1

There are several files listed on the page; I needed the one named `debugprobe.uf2`, but after trying various iterations of `curl`, `wget`, `git clone`, etc I was becoming frustrated. But here's what worked: 

```bash
$ wget "https://github.com/raspberrypi/debugprobe/releases/download/debugprobe-v2.0.1/debugprobe.uf2?raw=True" -O /home/pi/debugprobe.uf2
```

[**⋀**](#table-of-contents) 

## Verify file system is mounted

I've had the *occasional* problem with the `/boot/firmware` `vfat` filesystem somehow becoming ***un-mounted*** on my RPi 5. I've *wondered* if it has something to do with my use of an NVMe card (instead of SD), or the [NVMe Base (adapter) I'm using](https://shop.pimoroni.com/products/nvme-base?variant=41219587178579). I have no clues at this point, but I have found a competent tool to help me troubleshoot the situation whenever it occurs: [`findmnt`](https://www.man7.org/linux/man-pages/man8/findmnt.8.html).  WRT documentation and usage explanations for `findmnt`, I found three (3) very good "How-Tos": 

* This [post from Baeldung](https://www.baeldung.com/linux/bash-is-directory-mounted) ranks as a *model of clarity* IMHO; the following are also quite good:
* [How to Use the findmnt Command on Linux](https://www.howtogeek.com/774913/how-to-use-the-findmnt-command-on-linux/) from 'How-To Geek', and
* [findmnt Command Examples](https://linuxhandbook.com/findmnt-command-guide/) from the Linux Handbook. 

As Baeldung explains, `findmnt` is fairly subtle... it has a lot of capability that may not be apparent at first glance. All that said, my ***initial*** solution was a `bash` script that uses `findmnt`, and a `cron` job: 

The script:

   ```bash 
      #!/usr/bin/env bash
      # My $0 is bfw-verify.sh; I am run from the root crontab
      if findmnt /boot/firmware >/dev/null; then
         # note we depend upon $? (exit status), so can discard output
         echo "/boot/firmware mounted"
      else
         echo "/boot/firmware is NOT mounted"
         # we correct the issue as follows:
         mount /dev/nvme0n1p1 /boot/firmware
         # can test $? for success & make log entry if desired
      fi
   ```

The `cron` job; run in the `root crontab`: 

```
   0 */6 * * * /usr/local/sbin/bfw-verify.sh >> /home/pi/logs/bfw-verify.log 2>&1
```

This approach would seem to have wide applicability in numerous situations; for example: *verifying that a NAS filesystem is mounted before running an `rsync` job*. However, it *may fall short* for trouble-shooting a mysterious un-mounting of the `/boot/firmware` file system; the next script attempts to address that *shortcoming*. 

Another feature of `findmnt` that is better than using the simple script above in a `cron` job is **the `--poll` option**.  `--poll` causes `findmnt` to continuously monitor changes in the `/proc/self/mountinfo` file. Please don't ask me to explain what the `/proc/self/mountinfo` file actually is - I cannot explain it :)  However, you may trust that when `findmnt --poll` uses it, it will contain all the system's mount points. Rather than get into the theoretical/design aspects of this, I'll present what I hope is a ***useful recipe*** for `findmnt --poll`; i.e. *how to use it to get some results*. Without further ado, here's a `bash` script that monitors *mounts* and *un-mounts* of the `/boot/firmware` file system: 

```bash
#!/usr/bin/env bash
# My $0: 'pollmnt.sh'
# My purpose:
#   Start 'findmnt' in '--poll' mode, monitor its output, log as required

POLLMNT_LOG='/home/pi/pollmnt.log'

/usr/bin/findmnt -n --poll=umount,mount --target /boot/firmware |
while read firstword otherwords; do
    case "$firstword" in
        umount)
            echo -e "\n\n $(date +%m/%d/%y' @ '%H:%M:%S:%3N) ==========> case: umount" >> $POLLMNT_LOG
            sleep 1
            sudo dmesg --ctime --human >> $POLLMNT_LOG
            ;;
        mount)
            echo -e "\n\n $(date +%m/%d/%y' @ '%H:%M:%S:%3N) ==========> case: mount" >> $POLLMNT_LOG
            sleep 1
            sudo dmesg --ctime --human | grep nvme >> $POLLMNT_LOG
            ;;
        move)
            echo -e "\n\n $(date +%m/%d/%y' @ '%H:%M:%S:%3N) ==========> case: move" >> $POLLMNT_LOG
            ;;
        remount)
            echo -e "\n\n $(date +%m/%d/%y' @ '%H:%M:%S:%3N) ==========> case: remount" >> $POLLMNT_LOG
            sudo dmesg --ctime --human | grep nvme >> $POLLMNT_LOG
            ;;
        *)
            echo -e "\n\n $(date +%m/%d/%y' @ '%H:%M:%S:%N) ==========> case: * (UNEXPECTED)" >> $POLLMNTLOG
            ;;
    esac
done
```

#### REFERENCES: *(that may come in handy)*

* [How to Check Mount Point in Linux: A Step-by-Step Guide](https://bytebitebit.com/operating-system/linux/how-to-check-mount-point-in-linux/) 

* [listmount() and statmount()](https://lwn.net/Articles/950569/); LWN article

* [A search for *'linux /proc/self/mountinfo file'*](https://duckduckgo.com/?q=linux+%2Fproc%2Fself%2Fmountinfo+file&t=ffab&df=y&ia=web) 

* [Linux man page on `proc`](https://www.man7.org/linux/man-pages/man5/proc.5.html) 

[**⋀**](#table-of-contents)  

<!---

## How to "roll back" an `apt upgrade`

This looks fairly difficult... In fact, I've not actually done it yet - but I'm bound to try as I think it may be the best salvation for a problem that has cropped up. This is not even a "recipe" yet - it's only a few URLs that have turned up in my research. I'm listing the URLs now (with a few notes), and will return to finish this up once I've been through the process. The URLs: 

* [A search: 'debian reverse an apt upgrade'](https://duckduckgo.com/?t=ffab&q=debian+reverse+an+upt+upgrade&ia=web) 
* [Debian's wiki on Rollback](https://wiki.debian.org/RollbackUpdate) - not too helpful
* [Downgrading a Package via apt-get](https://itsfoss.com/downgrade-apt-package/) - if a downgrade works? dtd 2023; Potentially Useful! 
* [How To Downgrade Packages To A Specific Version With Apt](https://www.linuxuprising.com/2019/02/how-to-downgrade-packages-to-specific.html) - dtd 2019; Potentially Useful 
* [Put a 'hold' on packages](https://www.cyberciti.biz/faq/apt-get-hold-back-packages-command/) - fm nixCraft; Potentially useful **after** the rollback! 
* [Rollback an apt-get upgrade if something goes wrong on Debian](https://www.cyberciti.biz/howto/debian-linux/ubuntu-linux-rollback-an-apt-get-upgrade/) - fm nixCraft
* [Q&A on SE: Can I rollback an apt-get upgrade if something goes wrong?](https://unix.stackexchange.com/questions/79050/can-i-rollback-an-apt-get-upgrade-if-something-goes-wrong) - old & not particularly useful 

[**⋀**](#table-of-contents)  

-->

## `scp` vs. `sftp`

I've used them both for a while, but to be honest, I've never given much thought to the differences. I always followed a "canned example" when I needed to transfer a file, but never considered that there might be differences worth much thought. I was *probably wrong* about that; here's a brief rundown: 

#### `scp`

```bash
   # FROM: local  TO: remote
   $ scp local-file.xyz remote-user@hostname:/remote/destination/folder
   # EXAMPLE:
   $ scp pitemp.sh pi@rpi5-2:/home/pi/bin
   # RESULT: local file 'pitemp.sh' is copied to remote folder 'home/pi/bin' on host 'rpi5-2'
   # -------------------------------------
   # FROM: remote  TO: local
   $ scp remote-user@hostname:/remote/folder/remote-file.xyz /local/folder 
   # EXAMPLE:
   $ scp pi@rpi5-2:/home/pi/bin/pitemp.sh  pitemp.sh ~/bin 
   # RESULT: remote file 'home/pi/bin/pitemp.sh' on host rpi5-2 is copied to local folder '~/bin'
```

And so we see that `scp` transfers are specified ***completely*** from the command invocation. There are *numerous* options; see `man scp` for details - and here's a brief, but informative [blog post](https://linuxize.com/post/how-to-use-scp-command-to-securely-transfer-files/) that summarizes the more noteworthy options. 

#### `sftp` 

```bash
# CONNECT TO ANOTHER HOST:
$ sftp remote-user@hostname
# EXAMPLE:
$ sftp pi@rpi2w
Connected to rpi2w.
sftp> 
# YOU ARE AT THE `sftp` COMMAND PROMPT; YOU MUST KNOW SOME COMMANDS TO PROCEED!
sftp> help
Available commands:
# ... THE LIST CONTAINS APPROXIMATELY 33 COMMANDS THAT ARE AVAILABLE! 
sftp> cd /home/pi/bin
sftp> pwd
Remote working directory: /home/pi/bin
sftp> ls
dum-dum.sh  pitemp.sh
sftp> lcd ~/bin
sftp> lpwd
Local working directory: /home/pi/bin
sftp> lls
pitemp.sh
sftp> get dum-dum.sh
Fetching /home/pi/bin/dum-dum.sh to dum-dum.sh
sftp> lls
dum-dum.sh  pitemp.sh
sftp> quit
$ 
# RESULT: remote file 'home/pi/bin/dum-dum.sh' on host rpi2w is copied to local folder '/home/pi/bin'
```

#### Comparison:

`scp` is said to be faster (more efficient) than `sftp` (not tested it myself). Both `scp` and `sftp` are built on SSH's authentication and encryption. 

Here's what I feel is the *key tradeoff* between `scp` and `sftp`: 

> `scp` is simple and *succinct*; 
>
> OTOH ``sftp` *might* be considered more *versatile* . 

Personally, I feel `sftp` is better-suited to a situation where perhaps many files in several folders needed to be transferred in both directions between two hosts. But then, that's what `rsync` does so well. This explains why `scp` is my "go-to" for limited file transfers. 

[**⋀**](#table-of-contents)  

## Want to remove the `rpi-eeprom` package to save 25MB? ***"Tough shit"***, *say The Raspberries*

If you have a Raspberry Pi model Zero, 1, 2 or 3, you have no need for the `rpi-eeprom` package.  It's useful ***only*** on the RPi 4 and RPi 5 because they are the only two models with... **EEPROM**!  But if you try to use `apt` to remove (or purge) `rpi-eeprom`, you'll find that `rpi-eeprom` has been carelessly (stupidly?) packaged in such a way that several useful utilities will be swept out with it! 

On my system ('bookworm-Lite, 64-bit'), there are 27 additional packages identified by `apt` that will also be removed - either directly, or through `sudo apt autoremove` . These packages include: 

* `iw`
* `rfkill`
* `bluez` 
* `device-tree-compiler` 
* `dos2unix`
* `pastebinit`
* `uuid`
* `pi-bluetooth`
* `raspi-config`

Recognize any of these  :)  ?  

When I discovered this, I posted an [issue on RPi's `rpi-eeprom` repository at GitHub](https://github.com/raspberrypi/rpi-eeprom/issues/622); I initially *assumed* there *must* be a good reason for this, and my initial post reflected that assumption. Afterwards, there was [one comment that acknowledged the issue](https://github.com/raspberrypi/rpi-eeprom/issues/622#issuecomment-2440878446), and indicated a change should be made. And then the *shit-storm* started. Most of the rest of the comments from *The Raspberries* were either arrogant, condescending, false, a waste of time - or all of the above. 

The apparent "leader" of this repo - ***Chief Know-Nothing*** - weighed in saying that the `rpi-eeprom` package needed a [*"bit of polish"*](https://github.com/raspberrypi/rpi-eeprom/issues/622#issuecomment-2443663005), but indicated that it was a low priority. (I guess Chiefs are v. busy at RPi?)  When I called the *"bit of polish"* remark a [gross understatement](https://www.collinsdictionary.com/dictionary/english/gross-understatement), my comment was deleted, ***and*** I was ***banned for life from all raspberrypi repos!***  **:)**  Giving *censorship privileges* to those whose job is software maintenance seems strange & risky management policy to me, but perhaps the thinking is *"these are all bright, responsible Cambridge lads - they know how to behave"*? 

Anyway - until *Chief Know-Nothing* is compelled to move on this, there's not much to do. One could use `apt-mark` to "pin" packages for non-removal... There are also some relevant Q&A that discuss how to handle this situation with the help of `dpkg` and `aptitude` : [1](https://unix.stackexchange.com/a/780901/286615), [2](https://askubuntu.com/a/32899/831935), [3](https://unix.stackexchange.com/a/183007/286615), [4](https://www.baeldung.com/linux/apt-uninstall-dpkg-deb-package). However, AIUI, all of these will ultimately depend upon the party that prepared the packages having some minimal level of competence.  And given the messy state of these packages now, I tend to doubt *Chief Know-Nothing* has that level of competence. 

 [**⋀**](#table-of-contents)  

## Move or copy a file without accidentally overwriting a destination file

In the course of *doing things* on my systems, I occasionally need to 'move' (`mv`), 'copy' (`cp`), or 'install' (`install`) files and/or folders from one location to another. And occasionally, I will ***screw up*** by accidentally over-writing (effectively deleting) a file (or folder) in the destination. Fortunately, the folks responsible for GNU software have developed **'command options'** for avoiding these ***screw-ups***. 

Among these 'command options' are `-n, --no-clobber`, `-u, --update`, and `-b, --backup`. In many cases, the `-b, --backup` option has some compelling advantages over the other options. Why? When using `cp`, `mv` or `install` in a script, the objective is to ***get the job done*** without any ***screw-ups***. That's what the `backup` options do. The `noclobber` and `update` options may prevent the screw-ups, but they don't get the job done. 

[The `backup` option documentation on GNU's website](https://www.gnu.org/software/coreutils/manual/html_node/Backup-options) is very good. Any unanswered questions may be explored with a bit of testing. So let's try the `backup` options to get a feel for how they work: 

```bash
$ ls -l ~/
-rw-r--r-- 1 pi   pi   14252 Mar  4  2023  paradiselost.txt
drwxr-xr-x 4 pi   pi    4096 Nov 25 04:35  testthis
$ ls -l ~/testthis
-rw-r--r-- 1 pi pi 14252 Nov 25 04:48 paradiselost.txt

# Note the difference in mod times of the two files; 
# i.e. the files are different, but have the same name

$ cp -a paradiselost.txt ~/testthis
$ ls -l ~/testthis
-rw-r--r-- 1 pi pi 14252 Mar  4  2023 paradiselost.txt

# The file has been "over-written" by an older version!
# IOW - a **screw-up**! 
# Let's reset & try with a 'backup' option

$ ls -l ~/testthis
-rw-r--r-- 1 pi pi 14252 Nov 25 05:08 paradiselost.txt
$ cp -ab paradiselost.txt ./testthis
$ ls -l ~/testthis
-rw-r--r-- 1 pi pi 14252 Mar  4  2023 paradiselost.txt
-rw-r--r-- 1 pi pi 14252 Nov 25 05:08 paradiselost.txt.~1~

# We see that the **original** file (Nov 25 mod) has been 'backed up';
# i.e. a '.~1~' has been appended to the file name. Using the '-b' 
# option gives the same result as: '--backup=numbered' option.

```

This is ideal for use in automated scripts as it *does the safe thing*; i.e. *doesn't overwrite potentially important files*. The documentation is [here (for `cp`)](https://www.gnu.org/software/coreutils/manual/html_node/cp-invocation.html#cp-invocation), and [here (for the `backup` options specifically)](https://www.gnu.org/software/coreutils/manual/html_node/Backup-options)

The `-b, --backup` option is (AFAIK) available only in GNU's coreutils versions of `cp` and `mv`. As usual Apple sucks, or is [**bringing up the rear**](https://idioms.thefreedictionary.com/bring+up+the+rear), by eschewing the newer GPL licensing terms...  **HOWEVER**, there are options for Apple/macOS users: [MacPorts](https://www.macports.org/) offers the `coreutils` package, or possibly through one of the [other macOS package managers](https://www.slant.co/topics/511/~best-mac-package-managers).  

 [**⋀**](#table-of-contents)  

## Using `socat` to test network connections

This is a rather simple-minded application of the rather sophisticated utility called [`socat`](http://www.dest-unreach.org/). In the context of this recipe, *testing a network connection* means that we wish to verify that a network connection is available before we actually use it. You might wonder, "How could that be useful?"... and that's a fair question. I'll answer with an example: 

Example: Verify a NAS file server is online before starting a local process.

Let's say that we have a `cron` job named `loggit.sh` scheduled to run `@reboot` on HOST1. `loggit.sh` reads data from a number of sensors, and logs that data to the NAS_SMB_SRVR. HOST1 and  NAS_SMB_SRVR are connected over our local network. And so, before HOST1 begins writing the sensor data to NAS_SMB_SRVR, we want to ensure that the network connection between them is operational. 

We will use `socat` in `loggit.sh` to verify the network connection is viable: 

```bash
...
# 	test network connection to NAS using SMB protocol
while :
do
	  socat /dev/null TCP4:192.168.1.244:445 && break
	  sleep 2
done
...
# send sensor data to log files on NAS_SMB_SRVR
```

Let's break this down: 

*  the `socat` command is placed in an infinite `while` (or `until`) loop w/ a 2 sec `sleep` per iteration
*  `socat` uses a SOURCE DESTINATION format:
*  `/dev/null` is the SOURCE (HOST1); 
*  `TCP4:192.168.1.244:445` is the DESTINATION (`protocol:ip-addr:port` for NAS_SMB_SRVR)
*  if `socat` can establish the connection (i.e. `$? = 0`), we use `break` to exit the loop 

`socat` is a versatile & sophisticated tool; in this case it provides a reliable test for a network connection **before** that connection is put into use.

 [**⋀**](#table-of-contents)  

## Using `dirname`, `basename` and `realpath`

In one sense, `dirname` and `basename` perform **opposite functions**! 

-  `dirname` is said to: `strip last component from file name`
-  `basename` is said to `strip directory <and optionally suffix> from filenames` 
-  `realpath` is said to `print the resolved, absolute file name`

For example, if you had a variable describing a full, complete, unambiguous file specification for `myfile.txt`, and you wanted just the folder name (perhaps as a destination for other files), `dirname` would give you this without grep, regex, etc: 

```bash
$ THE_FILE="/home/pi/scripts/myfile.txt"
$ dirname "$THE_FILE"
/home/pi/scripts
```

OTOH, if you needed only the filename (without the folder), `basename` is your ticket: 

```bash
$ THE_FILE="/home/pi/scripts/myfile.txt"
$ basename "$THE_FILE"
myfile.txt
```

And `realpath` serves to *"fill in the void"* between `dirname` and `basename`; for example if you are *buried* in a distant, remote folder (e.g. in the dreaded `sysfs` :) , and you need the full path of a file in that folder :

```bash
$ pwd
/sys/class/gpio/gpiochip512
$ realpath label
/sys/devices/platform/soc/3f200000.gpio/gpio/gpiochip512/label

# potentailly a lifesaver if you're writing a script!
```

 [**⋀**](#table-of-contents)  

## Shell parameter expansion

>  What's this? ... *"shell parameter expansion"* - why should I care? 

This was, more or less, my attitude until I saw how it could solve a problem I created. I won't spend a huge amount of time & effort on this section - there are other sources for that. Instead, I'll cover a few of what I feel are the more interesting uses. 

*  Consider a "`cron` job" scheduled from a `crontab` that resembles this: 

     ```
      RUN_BY_CRON="TRUE"
      0 12 * * * /home/user1/scriptX.sh
     ```

     Next, consider the executable `scriptX.sh`:

     ```bash
      #!/usr/bin/bash
      set -u         # aka set -o nounset
      ...
      if [[ $RUN_BY_CRON = "TRUE" ]]; then
          LOGFILE="/mnt/NAS-server/MyShare"
      fi
      ...
      # IOW, our script needs to set parameters on the basis 
      # of whether or not it was launched by `cron`
     ```

    Finally, consider what happens when you run this script from the CLI (your terminal):

     ```bash
      $ ./scriptX.sh
      ./scriptX.sh: line ?: RUN_BY_CRON: unbound variable
     ```

     The environment variable was not inherited from `cron` because the script was not run from `cron`! Consequently, `RUN_BY_CRON` is an "unbound variable" (aka "unset"), and the script simply will not run. 

     ***Here's the solution offered by shell parameter expansion:***

     ```bash
      #!/usr/bin/bash
      set -u         # aka set -o nounset
      RUN_BY_CRON="${RUN_BY_CRON-""}"        # or, RUN_BY_CRON="${RUN_BY_CRON-"FALSE"}" if you prefer!
      if [[ $RUN_BY_CRON = "TRUE" ]]; then
          LOGFILE="/mnt/NAS-server/MyShare"
      fi
      ...
     ```

     **_PROBLEM SOLVED!_** As explained by the [GNU documentation](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html):

     >  **${parameter:-word}**
      >
      >  If parameter is unset or null, the expansion of word is substituted.  Otherwise, the value of parameter is substituted.
      >
      >  When not performing substring expansion, using the form described [above] <s>below</s> (e.g., ‘:-’), Bash tests for a parameter that is unset ***or*** null. Omitting the colon results in a test only for a parameter that is unset. Put another way, if the colon is included, the operator tests for both parameter’s existence and that its value is not null; if the colon is omitted, the operator tests only for existence.
    
     IOW, the parameter expansion allows us to set a default value for the `RUN_BY_CRON` variable. Note that in this case, it is the ***only<sup>1</sup>*** solution because setting `RUN_BY_CRON` to "FALSE" would override the environment variable passed to our script from `cron`. 

     <sub>**Note 1:** OK - not the "only" solution, but certainly the "easiest"!</sub> 

*  Next consider calculating the length of a string. The *"traditional"* method for doing that is:

     ```bash
      MYSTRING="0123456789"
      echo $MYSTRING | wc -c
      10
     ```

     but "Parameter Expansion" can simplify that a bit:

     ```bash
      MYSTRING="0123456789"
      echo ${#MYSTRING}
      10
     ```

*  Finally, consider the frequently-performed task of getting a substring (from a longer string); something we might use `grep -o`, `sed`, `awk` or `cut` to accomplish - or perhaps something more complicated as in the following example: 

     Let's assume an application that performs a backup of an important file; e.g. a PasswordSafe database file: `mypwsafe.psafe3`. Let's further assume that we make a decision on the need to backup on the basis of the MD5 signature of the file. Let's look at how this might work: In this first code segment we calculate the MD5 signature of the file, and save the result to another file for subsequent comparison

     ```bash
      #!/usr/bin/bash
      set -u
      pwdbfile="/home/mine/safes/mypwsafe.psafe3"
      # use 'md5sum' to calculate the MD5 signature & write the result to a file
      md5sum "$pwdbfile" > "/home/mine/safes/md5check.txt"
     ```

     Some time later, we will need to verify if the `pwdbfile` has been updated/changed by its user. One way to do that might be: 

     ```bash
      #!/usr/bin/bash
      set -u
      md5vfile="/home/mine/safes/md5check.txt"
      pwdbfile="/home/mine/safes/mypwsafe.psafe3"
      if [ "$(md5sum -c "$md5vfile" | rev | cut -c 1-2) | rev" != "OK" ]; then
          # "!= OK" means the pwdbfile has been changes; therefore make a backup
      fi
      #
      # Note the '-c' option in 'md5sum' returns a long string ending with a [non-] confirmation:
      # '32 char MD5 hash'  'string with filename'  'OK'
      # Confirmation of a positive match ----------> ^^
    ```
    
    We can do this a bit more efficiently using "Parameter Expansion"; note that the expansion `${res: -2}` is equivalent to:
    > `| rev | cut -c 1-2) | rev`
    
     ```bash
      #!/usr/bin/bash
      set -u
      md5vfile="/home/mine/safes/md5check.txt"
      pwdbfile="/home/mine/safes/mypwsafe.psafe3"
      if res="$(md5sum -c "$md5vfile")" && [[ ${res: -2} != "OK" ]]; then
          # "!= OK" means the pwdbfile has been changes; therefore make a backup
      fi
     ```




I'll close with a couple of References:

-  The GNU `bash` documentation on [shell parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html) 
-  A blog from 'LinuxConfig' on [shell parameter expansion](https://linuxconfig.org/introduction-to-bash-shell-parameter-expansions).  

 [**⋀**](#table-of-contents)  

## Comment an entire block of code

If you are working on a script, and you need to ***"comment out"*** more than 2 or 3 lines of code, the example below provides a quick and easy way to do that: 

```bash
#!/usr/bin/bash
echo "last line before comment block"
: <<'COMMENT'
	# code you don't want to execute follows:
	if [[ $var != "someval"]]; then
		echo "burn it down"
		rm *
	fi
	... and on, and on, and on ...
	# final line to be excluded
COMMENT
echo "first line after comment block"
```

Take careful note: 

*  The ***commented-out block*** begins with: **`: <<'COMMENT'`** and ends with **`COMMENT`**. 
*  The "key word" **`COMMENT`** can be any word, **but** must not appear anywhere else in the file! 
*  This works with `bash`; does not work with `zsh`; untested in other shells. 

This is one of several clever (and some not-so-clever) methods described in [this Q&A](https://stackoverflow.com/questions/947897/block-comments-in-a-shell-script). 

 [**⋀**](#table-of-contents)  

## Disable CPU cores for power saving

This will be a *quickie* :)  I'm using a Pi Zero 2W for an off-grid project. I don't need the 4-core CPU, and I can't afford the extra power consumption, so I needed a way to disable some of the cores. That's pretty easy to do as it turns out: 

```bash
$ sudo nano /boot/firmware/cmdline.txt		# open file for editing, and then make one change:

FROM:
console=serial0,115200 console=tty1 root=PARTUUID=....
TO: 
console=serial0,115200 console=tty1 maxcpus=1 root=PARTUUID= 

$ sudo reboot
```

Of course this is completely reversible if you need more *"horsepower"* from the CPU; just remove the `maxcpus=X` item from `cmdline.txt`. 

 [**⋀**](#table-of-contents) 

## What is my "*Kernel Configuration*"?

Occasionally, you will need to know how your Linux kernel is "configured"; i.e. with what ***options*** was your kernel compiled? These options are defined by variables that *look like* environment variables - but they are not *environment variables* - at least not in the sense of `printenv`. I ran across [this informative post](https://www.baeldung.com/linux/kernel-config) recently, and finally learned how to answer that question. 

As it turns out, for Raspberry Pi 'bookworm' kernels at least, there may be only one way to learn *"how was my kernel configured?"*. **For example**, I wanted to know if my kernel had been compiled with the `CONFIG_RTC_SYSTOHC` variable; [this variable](https://www.thegoodpenguin.co.uk/blog/keeping-track-of-time-with-systemd/) instructs the kernel to update the RTC (*hardware clock*) time from the system time at [11 minute intervals](https://github.com/torvalds/linux/blob/v5.16-rc2/kernel/time/ntp.c#L501). I *reasoned* that this variable was set on the RPi5 (which now includes a hardware RTC), but was completely uncertain as to whether it was set on systems having an *after-market* RTC added - or no RTC at all. 

```bash
$ cat /boot/config-$(uname -r) | grep -i CONFIG_RTC_SYSTOHC
 --
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0" 
# As it turns out, this option is set on all RPi; whether they have an RTC installed or not. 

# If you want to know how many kernel config variables there are; this will give an estimate:

$ cat /boot/config-$(uname -r) | grep -vc ^$ 
```

And of course this command will ferret out any kernel configuration option; it's not limited to any option(s) in particular. You can browse *all of them* by piping the `cat` output to `less` instead of `grep`. 

 [**⋀**](#table-of-contents) 

## What about my RTC settings and `timedatectl`?

[REF: previous post](#what-is-my-kernel-configuration)... I couldn't resist digging into this [business of time](https://www.scientificamerican.com/article/a-chronicle-of-timekeeping-2006-02/) a bit deeper :)  I wondered if the *'Kernel Configuration'* option (`CONFIG_RTC_SYSTOHC`) was actually acted upon by the kernel? ...[some call me *skeptical*](https://unix.stackexchange.com/questions/791197/how-to-confirm-that-the-kernel-is-or-is-not-updating-the-hwclock-rtc) 

```bash
# LET'S "GO FISHING" WITH 'dmesg' ... 
#    if your system is RPi5, you will get this response: 
#    ^^^^^^^^^^^^^^^^^^^^^^
$ dmesg | grep "system clock"
[    1.593066] rpi-rtc soc:rpi_rtc: setting system clock to 2025-02-15T23:17:45 UTC (1739661465)

#    if your system is NOT RPi5, you will get a different response:
#    ^^^^^^^^^^^^^^^^^^^^^^^^^^
#    if your system does not have an RTC, the response will be 'null'
#    if the system does have an RTC, you will get a different response -
#    in this case from a RPi 3A+: 

$ dmesg | grep "system clock"
[   21.377058] rtc-ds1307 0-0068: setting system clock to 2025-02-16T02:09:01 UTC (1739671741)
```
<sub>**Post script:** According to a linux maintainer, `ds1307` is the ***driver name*** for several RTCs that were once built by ***D**allas **S**emiconductor*.  Note however, that the RPi `device tree` and entries in `config.txt` use the specific part name instead of the generic `ds1307`; e.g. `ds3231`. </sub> 

Which is all *well and good*, but isn't there a better way (better than *fishing* with `dmesg`) to verify that our system is actually updating the system time? **Yes, there is; in fact there are two other ways:**

```bash
# Method 1:
$ adjtimex -p
 status: 24577
$ echo $[24577 & 64]
0
$  # where '0' means "it's working"

# Method 2:
$ sudo perf stat -e rtc:rtc_set_time
# ... let it run for 11 minutes or more, and then stop it using ctrl-c
 Performance counter stats for 'system wide':
                 2      rtc:rtc_set_time
    1106.122845035 seconds time elapsed
$

# notes: install 'adjtimex' and 'perf' as follows
$ sudo apt update
$ sudo apt install linux-perf
$ sudo apt install adjtimex
# see 'man ...' for details :)
```

>  #### In conclusion then:

 `dmesg` , the `adjtimex` and  `perf` outputs above all confirm that ***the 'Kernel Configuration' option is in fact acted upon by the kernel***!

One other comment before closing this: As noted previously, the **RPi 5** has an in-built RTC, *but it's not a particularly accurate unit*. The only specification I could find appeared in this [RPi forum post](https://forums.raspberrypi.com/viewtopic.php?t=356991#p2139525), and was given as ***"50 ppm typical"***. Compare this figure to the [DS3231 RTC spec](https://www.analog.com/media/en/technical-documentation/data-sheets/DS3231.pdf) of: 2 ppm, or the [RV-3028 RTC](https://www.microcrystal.com/fileadmin/Media/Products/RTC/Datasheet/RV-3028-C7.pdf): 1 ppm. This is quite a difference in specifications! 

 [**⋀**](#table-of-contents) 

## How much time is required to boot your system?

As they say, *"There's an app for that!"*.  In this case, the app is `systemd`, or more specifically `systemd-analyze`, or actually `systemd-analyze time`. You can read all about the options in `man systemd-analyze`, and [this article in RedHat's documentation](https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/9/html/using_systemd_unit_files_to_customize_and_optimize_your_system/optimizing-systemd-to-shorten-the-boot-time_working-with-systemd#optimizing-systemd-to-shorten-the-boot-time_working-with-systemd) is also worth reading (RedHat being the *creator* of `systemd`). Two other options for `systemd-analyze` that seem interesting are `blame` and `critical-chain`. This *app* can *help* you reduce your system's boot time... Unfortunately - as is the case with most things associated with `systemd` - the path to efficiency is not straightforward! Here's a small demonstration from one of my **RPi-5** systems to illustrate:   

```bash
$ systemd-analyze time
Startup finished in 3.149s (kernel) + 9.320s (userspace) = 12.470s
multi-user.target reached after 2.016s in userspace. 

# some time later, after a couple of reboots :

$ systemd-analyze time
Startup finished in 3.158s (kernel) + 1.901s (userspace) = 5.059s
multi-user.target reached after 1.874s in userspace.
```

What's responsible for this big change in boot time?  The change is mostly in 'userspace', but that still affects the `multi-user.target` - generally held to be when the system is "available for use". No changes were made to the system's configuration; I'm at a loss... 

While this *seems worthwhile*, I'm [not yet sold on it](https://idioms.thefreedictionary.com/be+sold+on+something). Why? Three things: ***first***, as shown above, the results vary randomly between `reboot`s; ***second*,** the results are inconsistent between identical models (RPi 5 for example) that are *seemingly* identically configured; and ***third***, results are inconsistent even between the same unit... depending *apparently* upon the order in which `systemd` services are enabled or disabled. I suspect this *inconsistency* can be attributed to the [*flakiness*](https://idioms.thefreedictionary.com/flakiness) of the conditions built into the `systemd` units themselves... it's a jungle in there! But for now, that's only speculation - maybe the consistency will improve with my understanding? 

 [**⋀**](#table-of-contents) 

## How to use the `at` command for scheduling 

`man at` is wonderfully succinct in its **DESCRIPTION** of `at` : 

>  **at      executes commands at a specified time**. 

Rather than blether on about details, I'll just explain how I use `at`.  I use `at` as a *"reminder service"* to tell me when I need to get off the computer, and go interact with the real world in some way. For example, as I began writing this topic, I entered the following command into my [Bluetooth-enabled Raspberry Pi](./Bluetooth-AudioForBookwormLite.md):  

```bash
$ at -f ~/getoffyourass.sh now +30 minutes
```

What does this do?

`30 minutes` from `now` the script named `getoffyourass.sh` will execute. The `getoffyourass.sh` script is simply as follows: 

```bash
#!/usr/bin/bash
mpg123 -q /home/pi/offyourasspotatoboy.mp3
```

The mp3 file is a recording I made that instructs me that, "Your time is up; get off your ass - now!". I get a chuckle when I hear this "friendly" reminder, and I know it's time to get out of the chair & do "something else".  That concludes this installment; here's a [good reference](https://linuxize.com/post/at-command-in-linux/) on how to use `at` for ***your*** purposes. OK, gotta' run - time's up. 

 [**⋀**](#table-of-contents) 



## Finding all RPi on the local network

This used to be a recipe, but it looked a bit lost, and out-of-date as a separate recipe. It's been moved here.

You may find yourself in a situation where you don't know the IP address of your RPi. This can easily happen for any one of several reasons. Here's a procedure to find it; we use `arp` to do this, but we'll also need some help from `ping`. You can read all about [Address Resolution Protocol (ARP)](https://en.wikipedia.org/wiki/Address_Resolution_Protocol) in this Wikipedia article. Just a couple of things to point out:

*  ARP is restricted to a single subnetwork & cannot be routed beyond that subnet. If your local network is (for example) `192.168.25.0/24` `arp` will search all addresses in that subnet. If you have a 2nd local network (for example) `192.168.1.0/24`, an `arp` search launched in the first subnet will not search the  `192.168.1.0/24` subnet - and *vice-versa*. This is typically not a restriction for most users, but worth mentioning to avoid confusion.
*  When you run `arp` on a host (Windows/macOS/Linux/Unix), it only reports other hosts ***who have made a "recent" connection*** to the "`arp` host". This is because the `arp` command searches the "ARP cache" of the "`arp` host" for IP/MAC addresses, and the "ARP cache" is *volatile* (refreshed periodically). This is why we "need some help from `ping`" for `arp` to tell us about **all** RPi on the local network. 

I guess that's enough theory... let's get down to business in two steps: 

1.  Issue a `ping` to every IP address on your local subnet; we'll assume that subnet is `192.168.1.0/24` for this example:

      ```bash
         $ echo 192.168.1.{1..254} | xargs -n1 -P0 ping -c1 | grep "bytes from"  # add a pipe to 'less' to avoid terminal clutter 
        
        64 bytes from 192.168.1.1: icmp_seq=0 ttl=64 time=2.635 ms
        64 bytes from 192.168.1.115: icmp_seq=0 ttl=64 time=32.199 ms
        64 bytes from 192.168.1.148: icmp_seq=0 ttl=64 time=11.932 ms
        ...
        64 bytes from 192.168.1.193: icmp_seq=0 ttl=64 time=270.611 ms
        64 bytes from 192.168.1.132: icmp_seq=0 ttl=64 time=372.720 ms
        64 bytes from 192.168.1.188: icmp_seq=0 ttl=32 time=611.825 ms
        64 bytes from 192.168.1.185: icmp_seq=0 ttl=64 time=673.579 ms
      ```

2.  Now that your ARP cache is refreshed by `ping`, it contains a record of every active host on your subnet.  We're now prepared to run `arp`. We use `grep` to filter the results of the `arp` command based on the [**OUI** code](https://en.wikipedia.org/wiki/Organizationally_unique_identifier) - which is part of the [**MAC** address](https://en.wikipedia.org/wiki/MAC_address). The OUI codes for RPi continue to proliferate as "The Raspberries" continue morphing their organization... there was only one OUI in the beginning; now there are four!  

      ```bash
        arp -a | grep -i "b8:27:eb\|dc:a6:32\|2c:cf:67\|d8:3a:dd"  # note: '\' used to "escape" the "OR" token '|'
        
        rpi4b.local (192.168.1.144) at dc:a6:32:2:f0:96 on en0 ifscope [ethernet]
        rpi3a.local (192.168.1.148) at b8:27:eb:c:75:a7 on en0 ifscope [ethernet]
        rpi2w3.local (192.168.1.175) at 2c:cf:67:ae:2b:1 on en0 ifscope [ethernet]
        rpi2w.local (192.168.1.185) at d8:3a:dd:a9:71:94 on en0 ifscope [ethernet]
        rpi2w2.local (192.168.1.193) at d8:3a:dd:87:a0:2a on en0 ifscope [ethernet]
        rpi5-2.local (192.168.1.221) at d8:3a:dd:bf:71:c3 on en0 ifscope [ethernet]
        raspberrypi5.local (192.168.1.223) at d8:3a:dd:a7:b1:fe on en0 ifscope [ethernet]
      ```
    
    ***One final thing to note here :*** Every host in the list above contains a reference to `en0` and `ethernet` This, despite the fact that each and every one of the RPi listed above connect to the network via WiFi, **and** the "`arp` host" for this command is a macbook - also connected via wifi.   **Not to worry!**  ***The IP addresses themselves are correct, despite the fact the device is wrong***. At least some of the reasons for this are discussed in this [old LWN article](https://lwn.net/Articles/45373/); other reasons may include the 2008 vintage `arp` command on my Mac.

 [**⋀**](#table-of-contents) 



## How to format and 'mount' an SSD for use in RPi

If you're using a SSD (as a mass storage/auxiliary drive) in one of your RPi projects, you will realize some benefits by formatting it properly (with the `f2fs` or `ext4` filesystem), and taking other measures that will improve the performance and reliability of this particular type of drive. Here's my **"seven step approach to SSD use"**: 

1.  In this case, the *first step* was to **write a `udev` rule**. I found the `udev` rule was *necessary* for **persistence** in properly mounting the SSD on the RPi 3B+ I used for this exercise: `Raspberry Pi 3 Model B Plus Rev 1.4`.  This `udev` rule made things *easier and better* for me, but ***you may find that you do not need it***. In either case you're free to try without it (skip to Step 2). The utility of this `udev` rule ***might*** be due to the fact that the 3B+ does not support [**UASP**](https://en.wikipedia.org/wiki/USB_Attached_SCSI) (USB Attached SCSI Protocol); I really don't know for sure, **but**... 

   *  I do know how to determine if your USB-SSD connection is being handled by UASP, or by the older, slower [USB "Bulk Only Transport" (BOT) protocol](https://www.usb.org/sites/default/files/usbmassbulk_10.pdf); following are the results from my RPi 3B+.  The last line in the output says, *"You've got the old, slow BOT protocol"*. And I'm OK with that for my application; in this case as a *"music file"* server : 

      ```bash 
      # when plugged into a USB 2 port of an RPi 3B+:
      $ lsusb -t
      /:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=dwc_otg/1p, 480M
          |__ Port 1: Dev 2, If 0, Class=Hub, Driver=hub/4p, 480M
              |__ Port 1: Dev 3, If 0, Class=Hub, Driver=hub/3p, 480M
                  |__ Port 1: Dev 4, If 0, Class=Vendor Specific Class, Driver=lan78xx, 480M
                  |__ Port 2: Dev 13, If 0, Class=Mass Storage, Driver=usb-storage, 480M
      ```

      Compare this against the result from an RPi 5 when the SSD is plugged into one of the USB 3 (blue tongue) slots. Here, the last line says, *"You've got the new, fast UASP protocol"*. Interestingly, it says *the same thing* if you plug it into one of the USB 2 (black tongue) slots - but the speed is `480M` instead of `5000M`. :

      ```bash
      # when plugged into a USB 3 port of theRPi 5:
      $ lsusb -t
      /:  Bus 04.Port 1: Dev 1, Class=root_hub, Driver=xhci-hcd/1p, 5000M
          |__ Port 1: Dev 2, If 0, Class=Mass Storage, Driver=uas, 5000M
          ...
      # when plugged into a USB 2 port of theRPi 5:
      /:  Bus 01.Port 1: Dev 1, Class=root_hub, Driver=xhci-hcd/2p, 480M
          |__ Port 2: Dev 2, If 0, Class=Mass Storage, Driver=uas, 480M
      ```

   *  But to proceed with the `udev` rule: We need some more information from `lsusb` to write the `udev` rule; we'll get that information by **plugging the SSD into a USB port** (don't `mount` it just yet), and running `lsusb`:   

      ```bash
      $ lsusb
      Bus 001 Device 007: ID 0781:556c SanDisk Corp. Ultra
      #==> NOTE ID string ↓↓↓↓↓↓↓↓↓↓↓↓ ----------------------------
      Bus 001 Device 011: ID 174c:55aa ASMedia Technology Inc. ASM1051E SATA 6Gb/s bridge, ASM1053E SATA 6Gb/s bridge, ASM1153 SATA 3Gb/s bridge, ASM1153E SATA 6Gb/s bridge
      # -----------------------------------------------------------
      Bus 001 Device 005: ID 0424:7800 Microchip Technology, Inc. (formerly SMSC)
      Bus 001 Device 003: ID 0424:2514 Microchip Technology, Inc. (formerly SMSC) USB 2.0 Hub
      Bus 001 Device 002: ID 0424:2514 Microchip Technology, Inc. (formerly SMSC) USB 2.0 Hub
      Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
      ```
      
      Note that this listing *does not show your SSD* - rather what is being reported is the USB-SATA adapter cable! If you don't recognize which device is your SSD adapter cable, you may need to un-plug it, run `lsusb` again, re-plug it, and compare the difference.  ***TAKE NOTE of the ID:*** **`ID 174c:55aa`**. 

   *  With the **ID** values in hand, we are ready to write the `udev` rule. Open your editor (e.g. `nano`) as follows, and enter the following line of text:

      ```bash
      $ sudo nano /etc/udev/rules.d/50-usb-ssd-trim.rules 
      # enter:
      ACTION=="add|change", ATTRS{idVendor}=="174c", ATTRS{idProduct}=="55aa", SUBSYSTEM=="scsi_disk", ATTR{provisioning_mode}="unmap" 
      # ID: 174c:55aa; 174c is 'idVendor'; 55aa is 'idProduct'
      ```
      
   *  Exit the editor **after saving** the `udev` rule. With the rule now "installed" you should **un-plug your SSD**... Then, **re-plug your SSD**... Then, **verify** that the "discard options" `DISC-GRAN` and `DISC-MAX` are non-zero:

      ```bash
      $ lsblk --discard /dev/sdX
      NAME   DISC-ALN DISC-GRAN DISC-MAX DISC-ZERO
      sdb           0      512B       4G         0
      └─sdb1        0      512B       4G         0
      ```

   *  If the preceding step did not show both *"discard options"* are non-zero, you should verify your SSD supports `TRIM`. Note that in this step, you are communicating with the SSD itself; ***not*** the cable, or software:
      
      ```bash
      $ sudo hdparm -I /dev/sdX | grep TRIM
      	   *	Data Set Management TRIM supported (limit 8 blocks)
      	   *	Deterministic read ZEROs after TRIM
      ```
      
      If you did not get both "discard options" as non-zero values, and the `hdparm` output shows no evidence of TRIM support, you may have a very odd or very old SSD. OTOH, each manufacturer is *unique*; for example [Crucial has this to say re TRIM](https://www.crucial.com/articles/about-ssd/what-is-trim): 
      
      >  Trim & Active Garbage Collection are useful tools that benefit the speed, function, & longevity of your SSD. But **if your operating system doesn't support Trim, it's not a disaster**. All Crucial SSDs are  designed and tested assuming that they will be used without Trim.  

2.  Format (re-format) the drive using the [`f2fs`](https://en.wikipedia.org/wiki/F2FS) (aka *"flash friendly file system"*) - or `ext4` : 

   ```bash
    # install the tools, and format the SSD
    $ sudo apt install f2fs-tools
    $ sudo mkfs.f2fs -f -d9 -l BlueSSD /dev/sdX1  
    # --OR, use ext4 filesystem instead of f2fs
    $ sudo mkfs.ext4 -L BlueSSD /dev/sda1
   ```

   *  Note any *exceptions*, and the *conclusion* in the command output; e.g. when `f2fs` was used:

     ```
      Info: This device doesn't support BLKSECDISCARD
      ...
      Info: format successful
     ```
     
      The lack of `BLKSECDISCARD` support appears frequently in [recent online sources](https://real-world-systems.com/docs/mkfs.f2fs.1.html) on `f2fs` formatting, but I've seen no comments or even a recognition of its presence. It appears to be *related to* a defect in the secure erase/wipe capability. It is a recent "kernel bug" that is [said to be "patched"](https://secalerts.co/vulnerability/CVE-2024-49994)... perhaps by disabling secure erase? I have chosen to ignore it for now. If it bothers you, I'd suggest you use `mkfs.ext4` to format - `ext4` will also give good performance with SSDs.  

3.  `mount`ing may be handled as follows: 

   *  from the command line (after running `lsblk --fs` to learn the device location): 

     ```bash
      $ sudo mkdir /mnt/bluessd
      $ sudo mount /dev/sdX1 /mnt/bluessd
     ```

   *  Add the following to `/etc/fstab` for a permanent automount: 

     ```
      LABEL=BlueSSD /mnt/bluessd f2fs defaults,nofail,noatime 0 0 
      # -- OR, for an ext4-formatted SSD: -- 
      LABEL=BlueSSD /mnt/bluessd ext4 defaults,nofail,noatime,discard 0 0
     ```

4.  *"TRIM"* the drive periodically to clean and optimize the filesystem by "trimming" empty data blocks. Once a week is ***probably*** sufficient for most RPi users; use the `fstrim` command for this:

   ```bash 
    $ sudo fstrim -v /mnt/bluessd
    /mnt/bluessd: 915.8 GiB (983318855680 bytes) trimmed  # initial run, later runs will vary
   ```

   *  If you're using an RPi OS, you will have a `systemd` service that takes care of running `fstrim` periodically for you. Use `systemctl` to check that the `fstrim` service is running as shown below.   Otherwise, you may want to create a small script, and execute the script from the `root crontab`; see `man fstrim` for a description of all the options. 

      ```bash
      $ systemctl status fstrim
      ○ fstrim.service - Discard unused blocks on filesystems from /etc/fstab
           Loaded: loaded (/lib/systemd/system/fstrim.service; static)
           Active: inactive (dead)
      TriggeredBy: ● fstrim.timer
             Docs: man:fstrim(8)
      ```

5.  ***IF*** you're planning on using a SSD as the "**primary**" drive in your RPi, you **may** also want to adjust its [*"swappiness"*](https://www.baeldung.com/linux/swap-space-settings); i.e. the propensity to *swap* between RAM and non-volatile storage (SSD in this case). You probably *do not* need to do this if (like me), your plans for the SSD are to use it for file storage; e.g. as a Samba share. If you're *wondering*, *"can/should I use the `f2fs` file system as my primary drive ..."* - [**here you go** - ***knock yourself out :)***](https://duckduckgo.com/?t=ffab&q=will+raspberry+pi+run+from+a+f2fs+format+drive&ia=web) 

   *  **But back to the business at hand:** You can check the *"swappiness"* value currently set for your system as follows: 

     ```bash
      $ cat /proc/sys/vm/swappiness 
      60
     ```

   *  Interestingly, for the RPi - which uses an SD card - the *"swappiness"* value is set to `60` - a value that *encourages* fairly frequent memory-SD swaps. But there are [important differences between SD cards and SSDs](https://www.maketecheasier.com/sd-card-vs-ssd/). Without getting carried away with this subject, ***if*** you're planning to use your SSD as the primary drive in your system, you may wish to consider **reducing** the *"swappiness level"* to preserve its life. *"Swappiness"* is a kernel parameter. It is set by adding/changing a line in `/etc/sysctl.conf` (e.g. `vm.swappiness=20`), and incorporated via `reboot` - or using `sysctl -p` from the command line at runtime.  

6.  Don't fail to apply the `noatime` option in your `/etc/fstab` `mount` for the SSD: 

     ```bash
     LABEL=BlueSSD /mnt/bluessd f2fs defaults,nofail,noatime 0 0  
      # -- OR, for an ext4-formatted SSD: -- 
      LABEL=BlueSSD /mnt/bluessd ext4 defaults,nofail,noatime,discard 0 0
     ```

   *  Why? Because left to itself, the kernel will update the last `atime` (read/access time) on each file on the SSD. Turns out this is rather a [complex operation](https://www.tiger-computing.co.uk/file-access-time-atime/); it reduces the life of our SSD, and we can live without it.  The `noatime` option is also used by default (and wisely) on the root partition ( `/` ) of our beloved SD cards. 

8.  The scheduler... I'm running out of gas here, and IMHO the kernel's I/O scheduler is not hugely important. If you feel differently, [you can take it up with "The Raspberries" yourself, but be prepared to get slapped around some for asking such an *impertinent* question](https://github.com/raspberrypi/linux/issues/3359#issuecomment-1410657002)... yes, they're a testy bunch :) At any rate, I think I did finally find where the system I/O scheduler setting was buried: 

   ```bash
    $ cat /sys/block/mmcblk0/queue/scheduler
    none [mq-deadline] kyber bfq             # looks like it's 'mq-deadline'
   ```

   *  It also seems that **every mounted block device** on my 'bookworm' system is set to this `mq-deadline` scheduler. And finally FWIW, it seems [there have been recent improvements to this scheduler](https://www.phoronix.com/news/MQ-Deadline-Scalability)! 

 [**⋀**](#table-of-contents) 



## How to make a loop mount in `fstab`

I use [RonR's image-utils](https://github.com/seamusdemora/RonR-RPi-image-utils) to perform backups of my RPi - it's an excellent backup utility! It creates a single raw image file that contains both partitions (`/` and `/boot/firmware`) of the SD card or NVME. These image files come in quite handy for a variety of uses... for example *experimenting* with different configurations, data recovery, etc. 

I've found that the easiest/most convenient way for me to work with these image files is to copy the raw image file to a USB storage device, `mount` the device on a Raspberry Pi, and then `loop mount` each partition separately. This gives me convenient RW access to the entire image. In the procedure below, we break out each partition as a  `loop device`, and `mount` both devices in `/etc/fstab`. 

We begin with a USB storage device that contains a raw image file named `example.img`. The USB device (`/dev/sda` in this example) is mounted at `/mnt/usb`. We have also created `mount` points on our RPi: `/mnt/usb/root`, and `/mnt/usb/boot`. 

#### Step 1: run `fdisk` to get the image layout:

We begin with a single image file created by `image-backup` (one of the scripts in `image-utils`); we'll call it `example.img`. Run `fdisk` to get the information needed for breakout and mounting.

```bash
fdisk -l ./example.img    # example.img has two partitions; a vfat & an ext4
Disk ./example.img: 2.69 GiB, 2889875456 bytes, 5644288 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x00f24f4c

Device         Boot  Start     End Sectors  Size Id Type
./example.img1        2048  526335  524288  256M  c W95 FAT32 (LBA)
./example.img2      526336 5644287 5117952  2.4G 83 Linux
```

#### Step 2: calculate `offset` & `sizelimit` for each partition, `mount` and verify:

We must calculate `offset` and `sizelimit` parameters for the `loop` mount, and they must be expressed in `bytes`, not `sectors` as provided by `fdisk`. `offset` corresponds to `Start`, and `sizelimit` corresponds to `Sectors`.  We *do the math*:  

*  `boot offset` = 2048 * 512 = 1048576
*  `boot sizelimit` = 524288 * 512 = 268435456
*  `root offset` = 526336 * 512 = 269484032
*  `root sizelimit` = 5117952 * 512 = 2620391424

With these calculations, we can create a loop mount for our `vfat` (`/boot/firmware`) partition, and another loop mount for our `root` ( `/` ) partition. 

```bash
$ sudo mount -o loop,offset=1048576,sizelimit=268435456 ./example.img /mnt/usb/boot 

$ sudo mount -o loop,offset=269484032,sizelimit=2620391424 ./example.img /mnt/usb/root
```

We can verify: 

```bash
$ lsblk --fs
NAME        FSTYPE FSVER LABEL       UUID                                 FSAVAIL FSUSE% MOUNTPOINTS
loop0       vfat   FAT32 boot        AAFD-EB1F                             203.1M    20% /mnt/usb/boot
loop1       ext4   1.0   rootfs      e7baf291-a31a-4f9c-8cbb-6e7dc7b00af4  374.3M    78% /mnt/usb/root
sda
└─sda1      exfat  1.0   SANDISK16GB 67EB-734A                              12.2G    18% /mnt/usb 
mmcblk0
├─mmcblk0p1 vfat   FAT32 bootfs      4EF5-6F55                             453.3M    11% /boot/firmware
└─mmcblk0p2 ext4   1.0   rootfs      ce208fd3-38a8-424a-87a2-cd44114eb820   52.2G     5% /
```



#### Step 3: "translate" mounts in Step 2 to `/etc/fstab` entries:

```
# mount -o loop,offset=1048576,sizelimit=268435456 ./example.img /mnt/boot 
# mount -o loop,offset=269484032,sizelimit=2620391424 ./example.img /mnt/root
# ---
UUID=67EB-734A /mnt/usb exfat defaults,nofail,noatime 0 0
/mnt/usb/example.img /mnt/usb/boot auto loop,offset=1048576,sizelimit=268435456,nofail  0 0
/mnt/usb/example.img /mnt/usb/root auto loop,offset=269484032,sizelimit=2620391424,nofail  0 0
```

Afterwards, you may `reboot` to test the new `fstab`, and run `lsblk --fs` to verify.



 [**⋀**](#table-of-contents) 



## The power of `less`

The `less` utility doesn't get enough credit. We're going to devote some space to it here. 

*  Open multiple files simultaneously with `less`:

      ```bash
      $ less file1, file2, file3
      # Q: OK... but what do I do with 3 files? 
      # A: You can "navigate" between these files using ':n' (next), or ':p' (previous)
      #    simply enter :n or :p in the "'less' command line"; i.e. just type ": n"; 
      #   'less' will figure out where it goes! 
      # BONUS: entering ':e file4' adds that file to others that are open!
      ```

*  Go to the bottom (or top) of the current open file: 

     ```
      type 'G' to go to the bottom, 'g' to go to the top 
     ```

*  "Colorized" text display in `less`

     I didn't know this was possible before reading [this Q&A](https://askubuntu.com/questions/482803/how-do-i-make-less-output-colors); the excellent answer shows us *"the way"*:

     ```bash
     "" $ ls -l --color=always | less -R 
      # good candidate for an alias in ~/.bashrc
     ```

 [**⋀**](#table-of-contents) 



## How to 'pipe' the 'stderr' of one command to another

If you've been using Linux/Unix very long at all, you have probably used a 'pipe' ( `|` ) to route the output of one command (on the left) to the input of another command (on the right); i.e.: 

```bash
$ command1 | command2
```

This works as we expect when the output of `command1` is exclusively in the `stdout` stream; i.e. when there are no errors in `command1`.  However, there are times when it's important to operate on output of `command1` that is in the `stderr` stream. Otherwise, the `stderr` output is silently ignored. How do we send `stderr` and `stdout` to `command2`? 

The answer is found in `man bash` (GNU bash, 5.2) following a search for 'pipe' or 'pipeline' where we find this: 

>If **`|&`** is used, command1's standard error, in addition to its standard output, is connected to command2's standard input through the  pipe; it is shorthand for **`2>&1 |`**. 

That gives us two options for sending both `stdout` and `stderr` of command1 to command2:

```bash
$ command1 |& command2
# -- OR --
$ command1 2>&1 | command2
```

If you want the opposite of the default (pipe `stdout` only); i.e. pipe ***only*** `stderr` to `command2`: 

```bash 
$ command1 2>&1 >/dev/null | command2
# --OR --
$ command1 2>&1 1>/dev/null | command2  # if you prefer specificity :)
```

[**⋀**](#table-of-contents) 



## How to search GitHub

Right - this has nothing to do with the `bash` shell, but I tought it needed to go somewhere. 

GitHub's documentation is comprehensive I guess, but IMHO not very easy to use. In particular, when searching for related **issues** or **discussions**, I can't seem to remember these little helpful "tidbits" that potentially make the search useful and productive. Here they are... in screenshot form: 

![github_searchterms](pix/github_searchterms.png)

[**⋀**](#table-of-contents) 



## tar files and compressed tar files

You may have heard the term *"**tar ball**"*; you might have wondered wtf? The "tar" in "tar ball" is an acronym for ***T**ape **AR**chive*, a term dating back to '60s-era IT. As it turns out, "tar balls" are still used today for distribution of software & media, and occasionally as a container for backups.  The `tar` manual describes it  as follows:

>tar is an archiving program designed to store multiple files in a single file (an archive), and  to  manipulate  such archives

Tarballs are also typically compressed, but they don't have to be.  Compressed "tarballs" typically use a file extension of `.gz`, `.tgz` or `.tar.gz`;  un-compressed tarballs use `.tar`.   We all need to know how to create them, and how to *retrieve* the contents of a tarball. 

*  To ***c***reate a *compressed* tarball:

      ```
      tar -czf <name of tarball>.tgz /path/to/source/folder
      ```

*  To e***x***tract and de-compress a compressed tarball

      ```
      tar -xzf <name of tarball>.tgz                            # extracts to 'pwd'
      tar -xzf <name of tarball>.tgz -C /path/to/dest/folder    # extracts to '-C path'
      ```
      

The minimal, essential options are: 

*  -c : create a tarball 
*  -x : extract a tarball
*  -z : compress (or de-compress when used in combo with -x) the tarball
*  -f : the file name to be created or extracted
*  -C : the directory to *Change* to before creating or extracting

I'll stop here - ***far short*** of the numerous options available for `tar`; start with `man tar` to learn more. 


[**⋀**](#table-of-contents) 

<!---

## systemd is "illogical"

Ran across an(*other*) example of perverted logic in the design of `systemd`, and thought I should mention it here. I ran across this while experimenting with `mpd` and `mpc`. I am occasionally getting this message:

```
$ mpc playlist | less
MPD error: Connection refused
```

Which seems a clear indication "the wheels have come off". I'm trying to write a script to automate some music playing, and realized this `MPD error` is something that needs to be "caught" - and corrected. And so I created the following functions in my `bash` script:

```bash
# THIS CODE SHOULD NOT BE USED "AS-IS"; 
# Read the entire note & make the "correction" shown below
#
srv="mpd.service"
function reset_mpd {
# ASSUME mpd.service has failed (ref "MPD error"), and 'restart':
    systemctl --user restart $srv
    sleep 2
# VERIFY mpd.service is now working/active; if not then EXIT for troubleshooting: 
    if ! systemctl --user -q is-active $srv; then        # bullshit!  :) 
        echo -e "at $(date) $srv is not active; (re-) start failed --- EXITING! ---" >> $log
        exit 1
    fi
}

function status_mpc {
    if [ "$(/usr/bin/mpc --quiet status 2>&1 | cut -c 1-9)" = "MPD error" ]; then
        reset_mpd     # call fn to restart mpd.service
    fi
} 

# ... doing mpc stuff ...

status_mpc 
```

So - I call `status_mpc` at various points in my script - to make sure nothing has failed (which seems to be a real problem with **`mpd`** in 'bookworm stable') . `status_mpc` "discovers" the failure, and calls `reset_mpd`. 

In `reset_mpd` I assume that `mpd` ***is*** the problem, and do a `restart` as the first step. Then, to verify that `mpd.service` has successfully restarted, I check it using `systemctl`'s `is-active` option, and  `exit` the script for manual troubleshooting... pretty straightforward - or so I thought.   

***However***, it turns out that the ***systemd-brain*** has decided that `is-active` ***does not mean that the service is actually active... even though it is!*** You can read the perversity of thinking in `man systemctl`. The solution that finally worked for me was to replace the `is-active` option with the `is-failed` option & **negate** the logic; i.e.:  

```
# DO NOT DO THIS! Why? 'systemd' lies!! 
if ! systemctl --user -q is-active $srv; then
# INSTEAD, YOU MUST DO THIS: 
if systemctl --user -q is-failed $srv; then
```

-->







<hr>


## REFERENCES:

### General guides to `bash`

1. [GNU's `bash` Reference Manual](https://www.gnu.org/software/bash/manual/) - in a variety of formats
1. [GNU's Core Utilities - 'coreutils'](https://www.gnu.org/software/coreutils/manual/) - in a variety of formats 
1. [Shell Builtin Commands](https://www.gnu.org/software/bash/manual/html_node/Shell-Builtin-Commands.html#Shell-Builtin-Commands) - an index to all the builtins
1. [Bash POSIX Mode](https://www.gnu.org/software/bash/manual/html_node/Bash-POSIX-Mode.html); a brief guide for using `POSIX mode` in `bash`   
1. [Baeldung's Linux Tutorials and Guides](https://www.baeldung.com/linux/list-programs-started-nohup) - excellent & searchable
2. [Wooledge's Bash Guide](http://mywiki.wooledge.org/BashGuide); can be puzzling to navigate, may be a bit dated, but still useful 
3. [How to find all the `bash` How-Tos on linux.com](https://www.linux.com/?s=bash) ; this really shouldn't be necessary!  
4. [commandlinefu.com - a searchable archive of command line wisdom](https://www.commandlinefu.com/commands/browse)  
5.  [*Cool Unix and Linux CLI Commands* - nearly 10,000 items!](https://www.scribd.com/doc/232825009/Cool-Unix-CLI) 
5.  [Assign Output of Shell Command To Variable in Bash](https://pupli.net/2022/03/assign-output-of-shell-command-to-variable-in-bash/); a.k.a. **command substitution**  

### The `~/.bashrc` & `~/.bash_profile` files

1. [Difference .bashrc vs .bash_profile (which one to use?)](https://www.golinuxcloud.com/bashrc-vs-bash-profile/); good explanation & good overview! 
2. [Q&A: What is the purpose of .bashrc and how does it work?](https://unix.stackexchange.com/questions/129143/what-is-the-purpose-of-bashrc-and-how-does-it-work) 
3. [Q&A: What is the .bashrc file?](https://superuser.com/questions/49289/what-is-the-bashrc-file) 
4. [What is Linux bashrc and How to Use It](https://www.routerhosting.com/knowledge-base/what-is-linux-bashrc-and-how-to-use-it-full-guide/)   
5. [Q&A: How to reload .bash_profile from the command line?](https://stackoverflow.com/questions/4608187/how-to-reload-bash-profile-from-the-command-line) 

### Functions and aliases 

1. [Q&A Setting up aliases in zsh](https://askubuntu.com/questions/31216/setting-up-aliases-in-zsh) and more. 
2. [How to Create and Remove alias in Linux](https://linoxide.com/linux-how-to/create-remove-alias-linux/) 
3. [The alias Command](http://www.linfo.org/alias.html) 
4. [Bash aliases you can’t live without](https://opensource.com/article/19/7/bash-aliases) 
5. [How to Create Aliases and Shell Functions on Linux](https://www.howtogeek.com/439736/how-to-create-aliases-and-shell-functions-on-linux/); aliases, functions & where they're saved. 
6. [Unix/Linux Shell Functions](https://www.tutorialspoint.com/unix/unix-shell-functions.htm) explained at ***tutorialspoint***. 
7. [Q&A: Alias quotation and escapes](https://raspberrypi.stackexchange.com/questions/111889/alias-quotation-and-escapes); aliases and functions - an example  

### Scripting with `bash`  

1. [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/index.html) - useful, but a bit out-of-date; 10 Mar 2014 when last checked
2. [Q&A: In a Bash script, how can I exit the entire script if a certain condition occurs?](https://stackoverflow.com/questions/1378274/in-a-bash-script-how-can-i-exit-the-entire-script-if-a-certain-condition-occurs)   
3. [Command Line Arguments in Bash](https://tecadmin.net/tutorial/bash-scripting/bash-command-arguments/) - a good, brief overview. 
4. [*How to Create & Use `bash` Scripts* - a very good tutorial by Tania Rascia](https://www.taniarascia.com/how-to-create-and-use-bash-scripts/)  
5. Passing arguments to bash:
   - [*How to Pass Arguments to a Bash Script*](https://www.lifewire.com/pass-arguments-to-bash-script-2200571) - an article on Lifewire.com. 
   - [*Parsing bash script options with `getopts`*](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/) - a short article by Kevin Sookocheff. 
   - [A small `getopts` tutorial](https://wiki.bash-hackers.org/howto/getopts_tutorial) (p/o the bash hackers wiki) 
   - [Q&A on StackOverflow: ](https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash) (How to get arguments with flags in `bash`)
6. [Q&A re use of the `shebang` line](https://unix.stackexchange.com/questions/517370/shebang-or-not-shebang)  
7. [Bash Infinite Loop Examples](https://www.cyberciti.biz/faq/bash-infinite-loop/) - infinite loops
8. [Bash Scripting – the `while` loop](https://www.geeksforgeeks.org/bash-scripting-while-loop/) - infinite loops
9. [How to loop forever in bash](https://www.networkworld.com/article/3562576/how-to-loop-forever-in-bash-on-linux.html) - infinite loops
10. [Create A Infinite Loop in Shell Script](https://tecadmin.net/create-a-infinite-loop-in-shell-script/) - infinite loops
11. [Infinite while loop](https://bash.cyberciti.biz/guide/Infinite_while_loop) - infinite loops
12. [Q&A: Terminating an infinite loop](https://unix.stackexchange.com/questions/42287/terminating-an-infinite-loop) - infinite loops
13. [Functions in bash scripting](https://ryanstutorials.net/bash-scripting-tutorial/bash-functions.php) from Ryan's Tutorials - a good and thorough overview w/ examples. 
14. [Q&A: Shell scripting: -z and -n options with if](https://unix.stackexchange.com/questions/109625/shell-scripting-z-and-n-options-with-if)  - recognizing *null strings* 
15. [Q&A re executing multiple shell commands in one line](https://stackoverflow.com/questions/13077241/execute-combine-multiple-linux-commands-in-one-line); sometimes you don't need a *script* **!** 
16. [*"Filename expansion"*; a.k.a. ***"globbing"***](https://tldp.org/LDP/abs/html/globbingref.html); what is it, and why should I care?  
17. [A GitHub repo of globbing](https://github.com/begin/globbing); odd choice for a repo methinks, but contains some useful info. 
18. [Globbing and Regex: So Similar, So Different](https://www.linuxjournal.com/content/globbing-and-regex-so-similar-so-different); some of the *fine points* discussed here. 
19. [Writing to files using `bash`.](https://linuxize.com/post/bash-write-to-file/) Covers redirection and use of `tee` 
20. Using *formatted* text in your outputs with `printf`: [REF 1](https://www.computerhope.com/unix/uprintf.htm), [REF 2](https://linuxhandbook.com/bash-printf/) - beats `echo` every time! 
21. [sh - the POSIX Shell ](https://www.grymoire.com/Unix/Sh.html#toc_Sh_-_the_POSIX_Shell_); from Bruce Barnett, aka Grymoire 
22. [How to Safely Exit from Bash Scripts](https://www.baeldung.com/linux/safely-exit-scripts); executing v. sourcing a script & role of exit v. return (Baeldung)

### Working with strings in `bash` 

1. [*The Geek Stuff*: Bash String Manipulation Examples – Length, Substring, Find and Replace](https://www.thegeekstuff.com/2010/07/bash-string-manipulation/) 
2. [*The Tutorial Kart*: bash string manipulation examples](https://www.tutorialkart.com/bash-shell-scripting/bash-string-manipulation-examples/) 
3. [Bash – Check If Two Strings are Equal](https://tecadmin.net/tutorial/bash/examples/check-if-two-strings-are-equal/) - learn to compare strings in a shell script by example. 
4. [Q&A: Replacing some characters in a string with another character](https://stackoverflow.com/questions/2871181/replacing-some-characters-in-a-string-with-another-character); using `tr` and [`bash` built-ins](http://tldp.org/LDP/abs/html/string-manipulation.html).
5. [Q&A: remove particular characters from a variable using bash](https://unix.stackexchange.com/questions/104881/remove-particular-characters-from-a-variable-using-bash); a variety of methods!
6. [Advanced Bash-Scripting Guide: Chapter 10.1. Manipulating Strings](http://tldp.org/LDP/abs/html/string-manipulation.html); details! 
7. [The Wooledge Wiki is a trove of string manipulation methods for `bash`](https://mywiki.wooledge.org/BashFAQ/100#How_do_I_do_string_manipulations_in_bash.3F).

### Using `grep` to find things

1. [Q&A Can grep return true/false or are there alternative methods?](https://unix.stackexchange.com/questions/48535/can-grep-return-true-false-or-are-there-alternative-methods).
2. [Q&A grep on a variable](https://unix.stackexchange.com/questions/163810/grep-on-a-variable).
3. [Grep OR – Grep AND – Grep NOT – Match Multiple Patterns](https://www.shellhacks.com/grep-or-grep-and-grep-not-match-multiple-patterns/); `grep -E "PATTERN1|PATTERN2" file`  
4. [How To find process information in Linux  -PID and more](https://linuxconfig.net/manuals/howto/how-to-find-out-the-pid-of-process-in-linux.html) 
5. [Q&A How do I find all files containing specific text on Linux?](https://stackoverflow.com/questions/16956810/how-do-i-find-all-files-containing-specific-text-on-linux) - a very popular Q&A w/ 50+ answers!
6. [The GNU grep manual](https://www.gnu.org/software/grep/manual/) - recommended by `man grep`! 

### Using `awk` for heavy lifting

1. [The state of AWK](https://lwn.net/Articles/820829/) - an *extensive* article in the May 2020 issue of LWN
1. [Learn AWK](https://www.tutorialspoint.com/awk/index.htm) - a comprehensive tutorial from *tutorialspoint.com*. 
2. [The GNU awk User's Guide](https://www.gnu.org/software/gawk/manual/gawk.html) - The Real Thing 
3. References explaining the many flavors of `awk`: 
   * [Q&A: Differences: gawk v. awk](https://unix.stackexchange.com/questions/29576/difference-between-gawk-vs-awk) 
   * [Q&A: Differences: gawk v. mawk](https://stackoverflow.com/questions/21289110/the-differences-between-gawk-and-mawk-column-width) (NOTE: Why `mawk` is RPiOS default) 
   * [AWK Vs NAWK Vs GAWK](https://www.thegeekstuff.com/2011/06/awk-nawk-gawk/) 
   * [Q&A: Differences: awk, mawk, gawk , nawk, busybox](https://unix.stackexchange.com/a/29583/286615) 
   * [AWK - the Wikipedia article](https://en.wikipedia.org/wiki/AWK) 


### Operators & special characters

1. [Q&A: What are the shell's control and redirection operators?](https://unix.stackexchange.com/questions/159513/what-are-the-shells-control-and-redirection-operators) 
2. [Redirect stderr to stdout, and redirect stderr to a file](https://www.cyberciti.biz/faq/redirecting-stderr-to-stdout/) - from nixCraft
3. [15 Special Characters You Need to Know for Bash](https://www.howtogeek.com/439199/15-special-characters-you-need-to-know-for-bash/) - a collection of useful bits and bobs from HTG 
4. [Linux - Shell Basic Operators](https://www.tutorialspoint.com/unix/unix-basic-operators.htm); a quick overview on a single page.
5. [Section 7.1. Test Constructs from Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/testconstructs.html); e.g. `[ ]` vs. `[[ ]]` - *testing* 
6. [Using Square Brackets in Bash: Part 1](https://www.linux.com/training-tutorials/using-square-brackets-bash-part-1/) ; what do these *brackets* `[]` do exactly?  
7. [Using Square Brackets in Bash: Part 2](https://www.linux.com/training-tutorials/using-square-brackets-bash-part-2/) ; more on *brackets* 
8. [All about {Curly Braces} in Bash](https://www.linux.com/topic/desktop/all-about-curly-braces-bash/) ; how do you expect to get on in life without `{}`?? 
9. [Section 7.2. File test operators from Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/fto.html); e.g. `test` if `regular` file w/ `-f`      
10. [Section 7.3. Other Comparison Ops from Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/comparison-ops.html); e.g. integers, strings, `&&`, `||`  
11. [How do I use sudo to redirect output to a location I don't have permission to write to?](https://stackoverflow.com/questions/82256/how-do-i-use-sudo-to-redirect-output-to-a-location-i-dont-have-permission-to-wr)  

### How `bash` finds executables; `which`, `type`, etc.

1. [Q&A: How do I clear Bash's cache of paths to executables?](https://unix.stackexchange.com/questions/5609/how-do-i-clear-bashs-cache-of-paths-to-executables) help with `which` & alternatives
2. [Q&A: Why isn't the first executable in my $PATH being used?](https://unix.stackexchange.com/questions/91173/why-isnt-the-first-executable-in-my-path-being-used) more help with `which` 
3. [Q&A: Why not use “which”? What to use then?](https://unix.stackexchange.com/a/626017/286615) more on `which`, alternatives & `hash` for cache updates 

### Command history

1. [How to Use Your Bash History in the Linux or macOS Terminal](https://www.howtogeek.com/howto/44997/how-to-use-bash-history-to-improve-your-command-line-productivity/); a *How-To-Geek* article 
2. [Q&A: Where is bash's history stored?](https://unix.stackexchange.com/questions/145250/where-is-bashs-history-stored); good insights available here!
3. [Using History Interactively - A bash User's Guide](https://www.gnu.org/software/bash/manual/html_node/Using-History-Interactively.html); from the good folks at GNU. 
4. [The Definitive Guide to Bash Command Line History](https://catonmat.net/the-definitive-guide-to-bash-command-line-history); not quite - but it's certainly worth a look. 
5. H[ow To Use Bash History Commands and Expansions on Linux](https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps); useful 
6. [Bash History Command Examples](https://www.rootusers.com/17-bash-history-command-examples-in-linux/); 17 of them at last count :) 
7. [Improved BASH history for ...](https://www.thomaslaurenson.com/blog/2018/07/02/better-bash-history/); a **MUST READ**; yeah - this one is good. 
8. [Using Bash History More Efficiently: HISTCONTROL](https://www.linuxjournal.com/content/using-bash-history-more-efficiently-histcontrol); from the Linux Journal
9. [Preserve Bash History in Multiple Terminal Windows](https://www.baeldung.com/linux/preserve-history-multiple-windows); from baeldung.com 
10. [7 Tips – Tuning Command Line History in Bash](https://www.shellhacks.com/tune-command-line-history-bash/); is good
11. [Working With History in Bash](https://macromates.com/blog/2008/working-with-history-in-bash/); useful tips for `bash` history 

### Miscellaneous

1. [Uses for the Command Line in macOS](https://osxdaily.com/category/command-line/)  - from OSX Daily 
2. [Deleting all files in a folder, but don't delete folders](https://superuser.com/questions/52520/delete-all-files-in-a-folder-without-deleting-directories-os-x) 
3. [Removing all files in a directory](https://unix.stackexchange.com/questions/12593/how-to-remove-all-the-files-in-a-directory) 
4. [Q&A re clever use of `xargs` ](https://unix.stackexchange.com/questions/518186/usage-of-touch-with-pipeline)  
5. [*Lifewire* article explains *How to Display the Date and Time Using Linux Command Line*](https://www.lifewire.com/display-date-time-using-linux-command-line-4032698) 
6. [Exit status of last command using PROMPT_COMMAND](https://unix.stackexchange.com/questions/519680/exit-status-of-last-command-using-prompt-command) (An interesting thing worth further study) 
7. [Q&A: How to convert HTML to text?](https://superuser.com/questions/673878/how-to-convert-html-to-text); short answer: `curl <html URL> | html2text`  
8. [Use `findmnt` to check if a filesystem/folder is mounted](https://www.baeldung.com/linux/bash-is-directory-mounted); `findmnt`  
9. [Q&A: How to create a link to a directory](https://stackoverflow.com/a/9587490/5395338) - I think he got it right! 
10. [How To Read And Work On Gzip Compressed Log Files In Linux](https://itsfoss.com/read-compressed-log-files-linux/) 
11. [Using anchor ^ pattern when using less / search command](https://unix.stackexchange.com/questions/684165/using-anchor-pattern-when-using-less-search-command); find what you need in that huge `man` page 
12. [Regular-Expressions.info: the premier regex website](https://www.regular-expressions.info/index.html) - really useful & detailed 
13. [Q&A: What key does `M` refer to in `nano`?](https://stackoverflow.com/a/26285867/5395338) 
14. [Wooledge on "Why you shouldn't parse the output of ls(1)"](http://mywiki.wooledge.org/ParsingLs) 
15. [Listing with `ls` and regular expression](https://unix.stackexchange.com/questions/44754/listing-with-ls-and-regular-expression) - related to the *Wooledge* reference above.
16. [Q&A: How can I change the date modified/created of a file?](https://askubuntu.com/questions/62492/how-can-i-change-the-date-modified-created-of-a-file) 
17. [GNU `bash` documentation on shell parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html) 
18. [A blog post on shell parameter expansion from 'LinuxConfig.org'](https://linuxconfig.org/introduction-to-bash-shell-parameter-expansions) 
19. [How to Optimize Linux for SSD](https://www.baeldung.com/linux/solid-state-drive-optimization) - a blog post from Baeldung 
20. [How and When to Change I/O Scheduler in Linux](https://thelinuxcode.com/change-i-o-scheduler-linux/) 
21. [MQ-Deadline Scheduler Optimized For Much Better Scalability](https://www.phoronix.com/news/MQ-Deadline-Scalability) 



---

<!---

for command history:

Note the session histories 1 through **n** in the Figure above, where **n** is the number of active sessions on a host. Typically, one session exists in each terminal window (or tab); it is an *instance* of the `bash` interactive shell.  For now, assume you have just installed your OS, and just launched your *first-ever* session on this machine (i.e. the file at `~/.bash_history` is empty). As you begin to type commands into your session, they will be recorded in your session history #1. When you have entered a certain number of commands   



An `awk` section? 

The structure of an `awk` program: 

```awk
#!/bin/awk -f
BEGIN {}  # Begin section
{}        # Loop section
END{}     # End section
```

There are (at least) two ways to execute an `awk` script: 

1. put `#!/bin/awk -f` on the first line & make the file executable (`chmod`)  
2. put the `awk` code in a file, and then: `awk -f my.awk life.csv >output.txt` 





REF:

1. [Q&A: How to run a .awk file?](https://stackoverflow.com/questions/9991858/how-to-run-a-awk-file) 

-->

<!---

For example, in the two runs above there were no differences in the enabled services - as determined by `systemctl list-unit-files --state=enabled`!  I suspect this *inconsistency* can be attributed to the [*flakiness*](https://idioms.thefreedictionary.com/flakiness) of the conditions built into the `systemd` units themselves... it's a jungle in there! But for now, that's only speculation - maybe the consistency will improve with my understanding? 


| pi@rpi5-2:~ $ systemctl list-unit-files --state=enabled | pi@rpi5-2:~ $ systemctl list-unit-files --state=enabled |
| ------------------------------------------------------- | ------------------------------------------------------- |
| **UNIT FILE      STATE  PRESET**                        | **UNIT FILE      STATE  PRESET**                        |
| adjtimex.service       enabled enabled                  | adjtimex.service       enabled enabled                  |
| apparmor.service       enabled enabled                  | apparmor.service       enabled enabled                  |
| avahi-daemon.service     enabled enabled                | avahi-daemon.service     enabled enabled                |
| bluetooth.service       enabled enabled                 | bluetooth.service       enabled enabled                 |
| console-setup.service     enabled enabled               | console-setup.service     enabled enabled               |
| cron.service         enabled enabled                    | cron.service         enabled enabled                    |
| dphys-swapfile.service    enabled enabled               | dphys-swapfile.service    enabled enabled               |
| e2scrub_reap.service     enabled enabled                | e2scrub_reap.service     enabled enabled                |
| fake-hwclock.service     enabled enabled                | fake-hwclock.service     enabled enabled                |
| getty@.service        enabled enabled                   | getty@.service        enabled enabled                   |
| hciuart.service        enabled enabled                  | hciuart.service        enabled enabled                  |
| keyboard-setup.service    enabled enabled               | keyboard-setup.service    enabled enabled               |
| networking.service      enabled enabled                 | networking.service      enabled enabled                 |
| rpi-display-backlight.service enabled  enabled          | rpi-display-backlight.service enabled  enabled          |
| rpi-eeprom-update.service   enabled enabled             | rpi-eeprom-update.service   enabled enabled             |
| ssh.service          enabled enabled                    | ssh.service          enabled enabled                    |
| sshswitch.service       enabled enabled                 | sshswitch.service       enabled enabled                 |
| systemd-pstore.service    enabled enabled               | systemd-pstore.service    enabled enabled               |
| systemd-timesyncd.service   enabled enabled             | systemd-timesyncd.service   enabled enabled             |
| triggerhappy.service     enabled enabled                | triggerhappy.service     enabled enabled                |
| udisks2.service        enabled enabled                  | udisks2.service        enabled enabled                  |
| wpa_supplicant.service    enabled enabled               | wpa_supplicant.service    enabled enabled               |
| avahi-daemon.socket      enabled enabled                | avahi-daemon.socket      enabled enabled                |
| triggerhappy.socket      enabled enabled                | triggerhappy.socket      enabled enabled                |
| nfs-client.target       enabled enabled                 | nfs-client.target       enabled enabled                 |
| remote-fs.target       enabled enabled                  | remote-fs.target       enabled enabled                  |
| apt-daily-upgrade.timer    enabled enabled              | apt-daily-upgrade.timer    enabled enabled              |
| apt-daily.timer        enabled enabled                  | apt-daily.timer        enabled enabled                  |
| dpkg-db-backup.timer     enabled enabled                | dpkg-db-backup.timer     enabled enabled                |
| e2scrub_all.timer       enabled enabled                 | e2scrub_all.timer       enabled enabled                 |
| fstrim.timer         enabled enabled                    | fstrim.timer         enabled enabled                    |
| logrotate.timer        enabled enabled                  | logrotate.timer        enabled enabled                  |
| man-db.timer         enabled enabled                    | man-db.timer         enabled enabled                    |
|                                                         |                                                         |
| 33 unit files listed.                                   | 33 unit files listed.                                   |



; for example, I was curious to know the effect of throwing `NetworkManager` overboard in favor of `ifupdown`. Here are some results from [that experiment](https://github.com/seamusdemora/PiFormulae/blob/master/Networking-aSimplerAlternative.md) on an RPi 5; first with `NetworkManager.service` disabled:

Now, after `enable`ing the `NetworkManager.service` , and re-booting, we run this again: 

-->



<!--- 

* [How to "roll back" an `apt upgrade`](#how-to-roll-back-an-apt-upgrade) (coming soon) 


But before we move on, let's take another look at the **RPi5**:

The RTC that *"The Raspberries"* included in the RPi5 was not a particularly good one ("good" being a DS3231 or RV3028). My systems are sometimes shut down for weeks (even months) at a time, and initializing the system clock to a "long ago" setting in a mediocre RTC doesn't strike me as *a great idea*. Consequently, I installed an [RV3028](https://www.microcrystal.com/en/products/real-time-clock-rtc-modules/rv-3028-c7) in my RPi5 (iaw [this recipe](https://github.com/seamusdemora/PiFormulae/blob/master/AddRealTimeClock.md)), and after a `reboot` checked `dmesg`, and the `/dev` folder: 

```bash
$ dmesg | grep "system clock" 
[    1.593066] rpi-rtc soc:rpi_rtc: setting system clock to 2025-02-15T23:17:45 UTC (1739661465)

$ ls -l /dev | grep rtc
lrwxrwxrwx 1 root root           4 Feb 15 23:17 rtc -> rtc0
crw------- 1 root root    252,   0 Feb 15 23:17 rtc0
crw------- 1 root root    252,   1 Feb 15 23:17 rtc1 

$ cat /boot/config-$(uname -r) | grep -i CONFIG_RTC_SYSTOHC
CONFIG_RTC_SYSTOHC=y
CONFIG_RTC_SYSTOHC_DEVICE="rtc0"
```

But this [does not add up](https://idioms.thefreedictionary.com/add+up) - the `dmesg` output is the same as it was before the RV3028 was installed!!

This is further confirmed as follows:

```bash 
$ sudo find /sys -type d -iname "*rtc*"
...
/sys/devices/platform/axi/1000120000.pcie/1f00074000.i2c/i2c-1/1-0052/rtc/rtc1
...
$ cat /sys/devices/platform/axi/1000120000.pcie/1f00074000.i2c/i2c-1/1-0052/rtc/rtc1/name
rtc-rv3028 1-0052
```

And so, it appears that as long as the RV3028 is `/dev/rtc1`, it will not be used to update the system clock **:(**   This sounds like a job for `udev`...

```bash
$ udevadm info -a -p /sys/class/rtc/rtc1 | grep "ATTR{name}"
    ATTR{name}=="rtc-rv3028 1-0052"
$ 
```

------------------

Not *unexpected*, but it does raise questions... like, *"which RTC is `dmesg` telling me about??"*. Trying to read the *hieroglyphics* is *dicey*, but I'll guess that `rtc0` is the *mediocre RTC supplied by "The Raspberries"*. If that's the case, it makes it quite difficult (impossible?) to have the RPi5 use the more accurate of the two RTCs connected to the system!  

Let's [get off the reservation](https://idioms.thefreedictionary.com/off+the+reservation) for a bit, and try an ***experiment***. I've got a `RPi Zero 2W` (no *Raspberry-supplied RTC*) that I use for an "off-grid" project. I've connected a DS3231 RTC via I2C. The applicable line from `config.txt` is as follows: 

```
dtoverlay=i2c-rtc,ds3231,i2c0,addr=0x68,wakeup-source
```

Let's make sure nothing shows up in `dmesg` re "system clock":

```bash
$ dmesg | grep "system clock"
[   21.309684] rtc-ds1307 0-0068: setting system clock to 2025-02-16T01:52:09 UTC (1739670729)
```

That's all about as [clear as mud](https://idioms.thefreedictionary.com/clear+as+mud). Why is the kernel's `dmesg` output proclaiming the system clock has been updated by an RTC whose overlay has been deleted? Let's not waste any more time wondering about this incompetence. 

Before we ponder this result any further, let's take a look inside our **RPi5**'s  `/dev` folder:

```bash
$ ls -l /dev | grep rtc
lrwxrwxrwx 1 root root           4 Feb 14 01:20 rtc -> rtc0
crw------- 1 root root    252,   0 Feb 14 01:20 rtc0
```
------------------
***Huh !?!?*** I have no `ds1307` clock in any of my systems! Furthermore, the following line appears in my `/boot/firmware/overlays/README` file: 

```
    [ The ds1307-rtc overlay has been deleted. See i2c-rtc. ]
```

and this line is in my `/boot/firmware/config.txt` file for the RPi Zero 2W:

```
    dtoverlay=i2c-rtc,ds3231,i2c0,addr=0x68,wakeup-source
```

>####  Question: So - what happened? Why is a ds1307 RTC reported?

>#### Answer: Linux/RPi Incompetence, lack of coordination, laziness or ...

Note carefully that the 2nd `dmesg` output string from above includes: `rtc-ds1307 0-0068`.  The **`0`** corresponds to the configured I2C bus, and the **`0068`** corresponds to the I2C address in use. This message is as [clear as mud](https://idioms.thefreedictionary.com/clear+as+mud), but if we look closelylikely reflects only a *"minor goof"*; i.e. something out-of-date, or overlooked. 

-->

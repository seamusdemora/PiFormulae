## Send and Receive e-mail on Raspberry Pi

I don't process much email on my Raspberry Pis. Perhaps that's why I missed the fact that the Lite distribution of RPi OS **no longer** includes any mail-related apps. The need for e-mail came up the other day, and so I launched an effort to install that capability. This recipe chronicles that effort. 

Since I didn't need much *e-mail firepower* I decided to install GNU's `mailutils` package. It lends itself to scripting, and I wanted to minimize the overhead of all of the *e-mail componentry*. After getting into the install, I was reminded of some things I'd forgotten... namely that there are several *components* involved in setting up email on a host system. A simplified view of the SMTP (that's *Simple* Mail Transport Protocol) is shown in the figure below - and this is just for ***sending*** email...  ***receiving*** email is covered by POP3, IMAP, etc. So much for **simple!** 

But let's not be deterred by the unknowns - what's the worst result possible from such experiments? 

<img src="pix/How-Emails-Are-Sent-via-SMTP.png" alt="The SMTP Soup">

**Figure 1: The SMTP Soup**<sup>[Figure source](https://mailtrap.io/blog/imap-vs-pop3-vs-smtp-email-protocols/)</sup> 



### Installing `mailutils` on Raspberry Pi OS, bookworm *"Lite"*:

```bash
sudo apt update && sudo apt -y instll mailutils
```

You'll see quite a lot of output from these commands. A quick scan reveals that `exim4` is being installed (*as the MTA?*), and then there's this line:

> Setting up exim4-daemon-light (4.96-15+deb12u2) ...

I take heart from the use of the word `-light`. That *suggests* that configuration of the MTA will take something less than a man-year of effort :/  .   I also wonder at the Raspberry Pi organization's selection of `exim` over `postfix` which is [considered by some a *better* alternative](https://mailtrap.io/blog/postfix-sendmail-exim/). Oh!... now I get it - [`exim` was developed at the University of Cambridge](https://manpages.debian.org/bullseye/exim4-daemon-light/exim4.8.en.html) - they're next-door neighbors with the RaspberryPi.com crowd. Well - I'm sorry RaspberryPi.com, but there will be no home-cooking here!  LOL 

Let's see if there's a tool to tell us what MTA is in use by our system... Turns out there is, because while `sendmail` is no longer in widespread use, it was the first MTA, and so is still used as the *de facto* MTA program in `usr/sbin`. We can use the `dpkg` command to learn what's been installed to respond to `/usr/sbin/sendmail` calls: 

```bash
$ dpkg --search /usr/sbin/sendmail
exim4-daemon-light: /usr/sbin/sendmail
# A-ha! home-cooking confirmed! 
```

All of the `update-alternatives` entries from the `mailutils` installation log refer to `/usr/bin/*.mailutils` scripts, so we'll **assume** for now that replacing `exim4-daemon-light` can be accomplished without *entanglements*. As it turns out, there is [another man page for  `exim4-daemon-light`](https://manpages.debian.org/bullseye/exim4-daemon-light/exim4.8.en.html) and [other potentially useful documentation](https://www.chiark.greenend.org.uk/doc/exim4/README.Debian.html), but unfortunately it also contains a mind-numbing array of options to deal with. That's too bad... wanting to use email on my RPi is not the same as wanting to wallow around in the muck and mire of endless details and SMTP minutiae. 

If **you** want to try `exim4-daemon-light`, you can start by running the debconf-driven configuration program as follows (after installing `mailutils` of course): 

```bash
$ dpkg-reconfigure exim4-config
```

I'll be taking a different route because I simply do not see the need for something this complex to provide email service for a single (or several) users from a Raspberry Pi! 



### Lightweight MTA alternatives to exim4 and postfix:

Some alternatives to `exim`/`postfix` (NB I'm not sure exactly what all of these actually do!?) :

- [dma](https://github.com/corecode/dma), a.k.a. DragonFly Mail Agent
- [msmtp](https://wiki.debian.org/msmtp) (+ an adjunct: [msmtp-mta](https://packages.debian.org/bookworm/msmtp-mta)); [msmtp homepage](https://marlam.de/msmtp/news/)  
- [nullmailer](https://wiki.debian.org/nullmailer); useful w systems not always online; laptops, intermittent ISP service 
- [ssmtp](https://packages.debian.org/bookworm/ssmtp); no maintained since 2019, but still popular & available 
- [extsmail](https://tratt.net/laurie/src/extsmail/); not *exactly* an MTA alternative
- esmtp; appears to be deprecated/not maintained since 2009

I'm not going to expend much effort analyzing these alternatives. I'll choose one based on [dead reckoning](https://en.wikipedia.org/wiki/Dead_reckoning). 

**I choose `msmtp`**.  

### Install, configure & test `msmtp`:

```bash
sudo apt update && sudo apt install msmtp msmtp-mta
```

Poking around afterwards: 

```bash
$ dpkg --search /usr/sbin/sendmail
msmtp-mta: /usr/sbin/sendmail

$ ls -la /usr/sbin | grep msmtp
lrwxrwxrwx  1 root root        12 Feb  5  2023 sendmail -> ../bin/msmtp 

$ man msmtp
# gives a good overview & suggestions for configuration
```

I'm going to use the sample config file `~/.msmtprc` from the [Baeldung blog](https://www.baeldung.com/linux/send-emails-from-terminal): 

``` 
# Default settings
defaults
auth    on
tls    on
tls_trust_file    /etc/ssl/certs/ca-certificates.crt
logfile ~/.msmtp.log
#
account    mail
host       smtp.gmail.com
port       587
from       somedude@gmail.com
user       somedude@gmail.com
password   d**************s

account default : mail
```

Now, testing: 

Using `msmtp`: 

```bash
echo -e "Subject: regardez moi\n\nSending regards from my RPI Terminal." | msmtp -a mail somedude@gmail.com
```

Using `mail`/`mailutils`; `-A` option designates attachment: 

```bash
mail -s "the subject is testing" -A message.txt somedude@gmail.com
```

This all works for me. FWIW, as shown in the `~/.msmtprc` file above, I am using my `gmail.com` account as the **external SMTP server**. *"The Trick"* for getting that to work is actually in two steps conducted from your Gmail accounts page: 

1. Enable 2FA 
2. Create an ***app password***; I followed [these instructions](https://aycd.io/blog/How-Setup-IMAP-2FA-App-Passwords-Gmail-Accounts) to do that.



### What's next? 

I suppose at some point, I will have to try setting up either the `exim` or `postfix` MTAs (maybe when I get my Raspberry Pi 5?). And I'll have to get a *"real"* email client (`neomutt`?) installed on the Pi for thos occasions when I need/want to send & receive email. So, that's all for now.



## REFERENCES: 

1. [Postfix vs. Sendmail vs. Exim](https://mailtrap.io/blog/postfix-sendmail-exim/); fm mailtrap.io; good article comparing several MTAs  
2. [Send Emails Using Bash](https://mailtrap.io/blog/bash-send-email/); fm mailtrap.io; decent article, but  ignore their cmts re Gmail
3. [Sending Emails From Terminal In Linux](https://www.baeldung.com/linux/send-emails-from-terminal); fm Baeldung; good, quick overview (recommended)
4. [Windows Subsystem for Linux: Tips and Tricks](https://medium.com/@mrsdrjim/windows-subsystem-for-linux-52dbf7d0052d); consider lightweight MTA `ssmtp` 
5. [mail](https://forums.raspberrypi.com/viewtopic.php?t=284760#p1723503); a discussion in the RPi forums, mailutils & smtp; some useful observations :) 
6. [Mail on Buster](https://forums.raspberrypi.com/viewtopic.php?f=28&t=244147#p1488916); another (older) discussion in the RPi forums; mailutils & smtp
7. [sSMTP - Simple SMTP](https://wiki.debian.org/sSMTP); no longer maintained; probably not a good choice
8. [Setup Exim4 to Send Email from Terminal With Raspberry PI (with examples)](https://peppe8o.com/setup-exim4-to-send-email-from-terminal-with-raspberry-pi-with-examples/) 
9. [msmtp](https://wiki.debian.org/msmtp); a better lightweight server, easy to configure 
10. [Q&A: Light  program (mini MTA?) for system mail](https://unix.stackexchange.com/questions/756861/light-program-mini-mta-for-system-mail-only-sending-relay-via-external-serve); brief comparison of lightweight smtp  
11. [Sending Email via Remote SMTP in Linux (SSMTP)](https://tecadmin.net/send-email-smtp-server-linux-command-line-ssmtp/) 
12. [Configure Postfix on Linux To Use Gmail SMTP Relay](https://computingforgeeks.com/configure-postfix-to-relay-emails-using-gmail-smtp/) 
13. [Send an email notification when a user logs into your raspberry pi via SSH](https://medium.com/@s0hax/send-an-email-notification-when-a-user-logs-into-your-raspberry-pi-via-ssh-487bfbeb8877) 
14. [Q&A: How to make crontab email me with output?](https://askubuntu.com/questions/536766/how-to-make-crontab-email-me-with-output) 
15. [Q&A: How is mail actually sent when I use the Linux "mail" command?](https://superuser.com/questions/384499/how-is-mail-actually-sent-when-i-use-the-linux-mail-command) 
16. [Q&A: install ssmtp in Debian buster](https://unix.stackexchange.com/questions/525235/install-ssmtp-in-debian-buster) 
17. [Q&A: Which option ("internet site", "internet with smarthost", "satellite system") should I choose in postfix configuration?](https://askubuntu.com/questions/1331555/which-option-internet-site-internet-with-smarthost-satellite-system-sh) 
18. [Mailutils smtp](https://mailutils.org/wiki/Mailutils_smtp) 
19. [Difference Between IMAP, POP3, and SMTP Email Protocols](https://mailtrap.io/blog/imap-vs-pop3-vs-smtp-email-protocols/) 
20. [A Search: 'is exim simple to configure'](https://duckduckgo.com/?q=is+exim+simple+to+configure&t=newext&atb=v369-1&ia=web) 
21. [A Search: 'configure exim4 for raspberry pi'](https://duckduckgo.com/?q=configure+exim4+for+raspberry+pi&t=newext&atb=v369-1&ia=web) 
22. [A Search: 'raspberry pi install & configure mailutils'](https://duckduckgo.com/?q=raspberry+pi+install+%26+configure+mailutils&t=newext&atb=v369-1&ia=web) 
23. [Package: mailutils-mda (1:3.15-4)](https://packages.debian.org/bookworm/mailutils-mda) 
24. [How to Setup IMAP, 2FA, and App Passwords on Gmail Accounts](https://aycd.io/blog/How-Setup-IMAP-2FA-App-Passwords-Gmail-Accounts) 

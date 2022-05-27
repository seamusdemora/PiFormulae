## Using Stow to install software

This *recipe* was the result of discovering that the version of `mtr` available on my *old-ish* `buster` system was out-of-date. Unfortunately, once a release transitions from `stable` to `oldstable`, packages aren't routinely updated. And even in the `stable` release, RPi packages typically lag behind their upstream sources more than I like. 

This isn't a complaint really - it's a statement of fact: ***building and maintaining the Debian packages used for RPi is a labor-intensive process!*** I am on the (*very*) low end of the learning curve for packaging, and it's not a high priority objective for me personally. But I digress... 

I discovered that `mtr` on my `buster` system was at 0.92, and the latest was 0.95. I didn't have days to spend (at my rate) updating the package, and so I began searching for alternatives. I could have just [cloned the upstream `mtr` repo, and built](https://github.com/traviscross/mtr), but I've learned this may lead to unpleasant surprises. Another way of saying, *"I love the quality of Debian packages, but they are a PITA to maintain"*. I began searching & shortly stumbled across [this informative Q&A on the U&L SE site](https://unix.stackexchange.com/questions/112157/how-can-i-install-more-recent-versions-of-software-than-what-debian-provides) that provided several alternatives. I rank them here in order of increasing difficulty: 

1. Stow: [A GNU utility](https://www.gnu.org/software/stow/manual/stow.html) for managing the installation of software packages.
2. Pragmatic packaging: The [Pragmatic Debian Packaging](https://vincent.bernat.ch/en/blog/2019-pragmatic-debian-packaging) Guide by Vincent Bernat; ver. 2019.
3. [Backporting](https://duckduckgo.com/?t=ffab&q=What+is+Debian+backporting&atb=v278-1&ia=web): Even [Debian recognizes the issues with aging packages](https://backports.debian.org/) & offers a solution.

This recipe focuses on `stow` - IMHO the simplest of the three alternatives for getting up-to-date packages for a minimum investment in time and effort. Like all things Unix/Linux, it only sounds difficult until you see how it's done. Here's what worked for me with a couple of tips to help avoid the traps: 

> **TIP 1:** directory positioning is all-important; executing the correct command from the wrong location leads to tears (well. OK - not tears, but frustration). 

1. Everything happens in `/usr/local`: the directory where locally compiled applications are installed by default — *to prevent them from mucking up the rest of the  system*. 
2. Let's have a look at `/usr/local` in `buster` before we start *mucking about* :) 

   ```bash
   ~ $ ls -l /usr/local
   total 32
   drwxr-xr-x 2 root root 4096 May 27  2020 bin
   drwxr-xr-x 2 root root 4096 May 27  2020 etc
   drwxr-xr-x 2 root root 4096 May 27  2020 games
   drwxr-xr-x 2 root root 4096 May 27  2020 include
   drwxr-xr-x 4 root root 4096 May 27  2020 lib
   lrwxrwxrwx 1 root root    9 May 27  2020 man -> share/man
   drwxr-xr-x 2 root root 4096 May 27  2020 sbin
   drwxr-xr-x 4 root root 4096 May 27  2020 share
   drwxr-xr-x 2 root root 4096 May 27  2020 src
   ```
3. Let's add a `git` folder - a place to house the repo(s) we'll clone & build: 

   ```bash
   ~ $ sudo mkdir /usr/local/git
   ~ $ sudo chown pi:pi /usr/local/git
   ```
4. Install `stow` if you don't have it already: 

   ```bash
   ~ $ sudo apt update
   ~ $ sudo apt install stow
   ```
5. Let's take another look at `/usr/local`; note the new folders `git` & `stow`: 

   ```bash
   ~ $ ls -l /usr/local
   total 40
   drwxr-xr-x 2 root root  4096 Sep 25  2019 bin
   drwxr-xr-x 2 root root  4096 Sep 25  2019 etc
   drwxr-xr-x 2 root root  4096 Sep 25  2019 games
   drwxr-xr-x 3 pi   pi    4096 May 26 13:25 git
   drwxr-xr-x 2 root root  4096 Sep 25  2019 include
   drwxr-xr-x 4 root root  4096 Sep 25  2019 lib
   lrwxrwxrwx 1 root root     9 Sep 25  2019 man -> share/man
   drwxr-xr-x 2 root root  4096 May 26 16:55 sbin
   drwxr-xr-x 6 root root  4096 Feb 17 16:54 share
   drwxr-xr-x 2 root root  4096 Sep 25  2019 src
   drwxrwsr-x 3 root staff 4096 May 26 16:39 stow
   ```
6. Clone the GitHub source repo in the `git` folder:

   ```bash
   ~ $ cd /usr/local/git
   /usr/local/git $ git clone https://github.com/traviscross/mtr.git
   ```

7. Move to the `mtr` folder & build iaw instructions from the [GitHub README](https://github.com/traviscross/mtr#readme) & `stow` SOP: 

   ```bash
   /usr/local/git $ cd mtr
   /usr/local/git/mtr $ /usr/local/git/mtr $ ./bootstrap.sh       # ref README
   /usr/local/git/mtr $ ./configure --prefix=/usr/local/stow/mtr  # 
   /usr/local/git/mtr $ make   # creates exe files mtr & mtr-packet; can test at this point
   /usr/local/git/mtr $ sudo make install # creates folder mtr in /usr/local/stow 
   ```

8. Create `stow` package: 

   ```bash
   /usr/local/git/mtr $ cd /usr/local/stow
   /usr/local/stow $ sudo stow mtr
   # what happened??
   /usr/local/stow $ ls -l /usr/local/sbin
   total 0
   lrwxrwxrwx 1 root root 20 May 26 16:55 mtr -> ../stow/mtr/sbin/mtr
   lrwxrwxrwx 1 root root 27 May 26 16:55 mtr-packet -> ../stow/mtr/sbin/mtr-packet 
   # stow has created links in /usr/local/sbin to the actual binaries in /usr/local/stow/mtr/sbin !! 
   # also created links in /usr/local/share/man/man8 to the man pages at /usr/local/stow/mtr/share/man/man8
   ```

9. Why is this *exciting*? 

   A. It's easy

   B. You don't have to remember where this stuff came from or how to remove it 

   C. You can remove the package from your PATH with `sudo stow -D mtr`; this removes the ***links*** - not the binaries or man pages in `/usr/local/stow/mtr`. If you're done with the entire package, you may delete the package folders in `/usr/local/stow/mtr`, and your `git` repo at `/usr/local/git/mtr`.

   All kinds of other options from here. For any `git` operations, first:  `cd /usr/local/git/mtr`; to clean the repo of non-tracked files: `git clean -i`;  sync the remote repo: `git pull`. After a `git` update, rebuild the package, and then `sudo stow -R mtr` to refresh all the links.

   See `man stow` for general guidance, or `info stow` for all the details - or [online](https://www.gnu.org/software/stow/manual/stow.html). 



---

## REFERENCES:

1. [How to install more recent versions of software than what Debian provides?](https://unix.stackexchange.com/questions/112157/how-can-i-install-more-recent-versions-of-software-than-what-debian-provides) Great Question & Answer!
2. [How to use GNU Stow to manage programs installed from source and dotfiles](https://linuxconfig.org/how-to-use-gnu-stow-to-manage-programs-installed-from-source-and-dotfiles) 
3. [Q&A: How can I install more recent versions of software than what Debian provides?](https://unix.stackexchange.com/questions/112157/how-can-i-install-more-recent-versions-of-software-than-what-debian-provides) 
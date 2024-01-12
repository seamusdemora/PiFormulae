

## Use 'git' on Raspberry Pi with GitHub

Most readers will be at least somewhat familiar with `git`.  `Git` is typically described with a phrase similar to the following: 

> Git is an open source distributed version control system

The [Wikipedia article on `Git`](https://en.wikipedia.org/wiki/Git) is an interesting read. I was surprised to learn that Linus Torvalds was the *original author* of `git`.   Yes - the same guy that was also the *original author* of the Linux kernel. It's been said that [necessity is the mother of invention](https://en.wikipedia.org/wiki/Necessity_is_the_mother_of_invention) - or as Plato put it, "our need will be the creator" - and this is precisely what happened with `git`. Torvalds **needed** a *distributed version control system* to manage development of the Linux kernel, and so he invented it.  

As demonstrated here, `git` has applicability beyond large, complex projects like kernel development - it's also useful on a small scale. And that is our objective with this recipe:  *Start small*, and learn by doing.

Before getting into some details, let's digress briefly to provide some background on `GitHub` - the other item that figures largely in this recipe.  There's also a [Wikipedia article on `GitHub`](https://en.wikipedia.org/wiki/GitHub) that provides some background and history. Not all of GitHub's history is commendable. It has been *weaponized* to a certain extent by *social extremists*, and its purchase by Microsoft in 2018 has not been entirely positive for the platform. Nevertheless, it remains the largest - and best known - remote repository, and perhaps most importantly remains a "free" service - at least for now. 

##### All that said, let's get to the "fun stuff"  :P

<!--- HIDDEN

##### Here are some ideas and procedures for using `git` on a RPi to interface with GitHub repositories. We use the [`PiPyMailer` repo](https://github.com/seamusdemora/PiPyMailer) as an example. PiPyMailer is run only on a Raspberry Pi, and so it makes sense to source it there.

##### Please note that this recipe is in a very messy state as of this commit!! My apologies for that. I am working toward a comprehensive revision in the hope that GitHub's interface and authentication mechanisms have stabilized. Most of the information is in here, but it's not organized as it should be to serve as a guide for the unitiated. Oh - there is one significant correction I need to make re the accuracy of the information currently in this *recipe*; RE ***"`gh`, the GitHub Command Line Interface"***: My opinion is: Don't waste your time with this. Unlike the GitHub Desktop, the GH CLI does not support a push from your RPi to GitHub. Yeah - would not have believed anyone thought this made sense, but [GitHub claims this is "by design"](https://github.com/cli/cli/discussions/3093#discussioncomment-2655776)!!  

---> 

### I. Initial Conditions: 

The following "initial conditions" are assumed: 


> * you have a github account - in this recipe, I use mine: `https://github.com/seamusdemora`. 
> * you have installed the `git` package on your Raspberry Pi (or equivalent hardware) 
> * you now have a file: `~/.gitconfig` ([ref](https://git-scm.com/book/en/v2/Customizing-Git-Git-Configuration)); you should review it; run this command (optional): 
>
>   ```bash
>   $ git config --global init.defaultBranch main   # or, 'master' instead of 'main'
>   ```
>
> * you have your files (code, instructions, documentation, etc) stored on your *local* host under a single directory: `~/pi-motd` in this example.  This is called your *repository*, or **repo**. 
> * you have *some* familiarity with the (extensive) system manuals provided with `git`; `man git` will list the various *man pages* supporting `git`; there are *many*. 
> * you wish to maintain a copy of your local repo on a *remote* server; i.e. you are familiar with [the pros and cons of services](https://duckduckgo.com/?t=ffnt&q=advantages+of+github&ia=web) provided by GitHub and similar providers.

These initial conditions may differ from your situation - or they may not. In either case you [should read this](https://www.sitereq.com/post/3-ways-to-create-git-local-and-remote-repositories) to help choose a *workflow* that fits your situation. OTOH, if that's too much to think about now, you can read [this](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup), and make adjustments as you go along. 

Before we begin, know that (N.B.) the [*semantics*](https://en.wikipedia.org/wiki/Semantics) of `git` and GitHub can be confusing. Do not despair! However you should be prepared to spend time to become at least slightly familiar the *vocabulary* of `git`.  Here's a [search to help you find introductory material](https://duckduckgo.com/?q=how+to+get+started+with+git&t=newext&atb=v369-1&ia=web) - you'll need to filter this to match your own tastes of course. I found this [*Atlassian Bitbucket* tutorial on `git`](https://www.atlassian.com/git/tutorials/learn-git-with-bitbucket-cloud) a useful resource at times, **but** that's not an "endorsement" or recommendation!  

### II. Authenticate your RPi host

When you set up your GitHub account, you'll need (among other things) a userid and a password. That allows **you** to access your GitHub account - but **not** your RPi host. Since August, 2021, GitHub no longer accepts account passwords for *computer host* authentication. There are [several methods](https://docs.github.com/en/authentication) that may be used for authentication, but for RPi - especially for *headless* RPi - SSH authentication may be the simplest. It's the only authentication method we'll cover here. 

In this case, RPi is the client, and GitHub is the server. SSH key generation is done on the *client*, and the process is similar to setting up RPi as an SSH server. The procedure is straightforward, but it is also *rigorous*!  I found GitHub's documentation for SSH auth both boring and incorrect/misleading, so here's mine - but you may certainly use GitHub's if it makes sense to you. 

##### 1. SSH Key Generation on the RPi:

```
NOTE: I opted for no passphrase, and the email address added under `-C` should be 
**your email address - as supplied to GitHub**. 

$ ssh-keygen -t ed25519 -f ed25519-gh -C "seamusdemora@gmail.com"
Generating public/private ed25519 key pair. 
...
```

##### 2. Edit the file `~/.ssh/config`:

```bash
# start your text editor; for example:
$ nano ~/.ssh/config 
# make the following entries appropriate for your situation:
Host github github.com/seamusdemora
    HostName github.com
    IdentityFile /home/git/.ssh/id_ed25519_gh
    User seamusdemora 
# save the file & exit the editor 
# note you may have other entries in 'config'; this one for github should "probably"  
# be first - at least this was my experience. 
```



##### 3. Add the ***public key*** (i.e. 'id_ed25519_gh.pub') to your GitHub account:

For this step, use both an SSH terminal window to the RPi, **and** a web browser connected to **your** GitHub account. 

* In the SSH terminal, show the public key on the CLI: 

```bash
$ less ~/.ssh/id_ed25519_gh.pub
ssh-ed25519 AAAABBBBCCCCDDDDEEEEFFFFG...LLMMMMNNNNOOOOPPPPQQQQ seamusdemora@gmail.com
```

* After logging in to your GitHub account: 

  * Click your profile picture in the upper, right-hand corner of the page, and select **`Settings`**. 

  * This will produce a list on the left-hand side of the page; from that list click **`SSH & GPG Keys`**. 

  * This will yield another page/dialog titled **SSH keys**; on the right, click the **`New SSH Key`** button. 

  * This will yield yet another dialog/page titled **Add new SSH Key**; choose a suitable **Title**, select `Authentication key` for **Key type**, and finally, **copy** the **entire string** from `less` in the SSH terminal window, and **paste** that string into the text field named **Key**. 

  * If you're so inclined, you may repeat the process just above to also create a `Signing key`.  
  * When you're finished, click the button labeled **`Add SSH key`** 


* The public key generated above should now be listed on the page titled **SSH keys**. 



##### 4. Finally, test your SSH authentication from your RPi command line:

```bash
~$ ssh -T git@github.com
Hi seamus! You successfully authenticated, but GitHub does not provide shell access.
```



##### 5. Each repo must declare itself as authorized for SSH authentication

And so ***this*** is where I felt that GitHub's documentation *left me stranded*. It failed to explain there is more to their SSH authentication than simply generating keys & storing them on your GitHub site. The omission becomes apparent when an attempt is made to - for example - `push` a commit from the RPi to the remote GitHub repo:

```bash
# F.A.I.L.U.R.E.:
$ cd pi-motd.git        # pi-motd.git is the folder containing the local 
                        # copy of my repository
$ git push --dry-run origin master
Username for 'https://github.com': seamusdemora    # Huh !?!? what's with Username?
Password for 'https://seamusdemora@github.com':    # Huh !?!? what's with Password?
remote: Support for password authentication was removed on August 13, 2021. Please use a personal access token instead.
remote: Please see https://github.blog/2020-12-15-token-authentication-requirements-for-git-operations/ for more information.
fatal: Authentication failed for 'https://github.com/seamusdemora/PiPyMailer/'
```

GitHub responded with prompts for `Username` & `Password` as if it were not aware its own administrators had deprecated password authentication. GitHub also declared itself ignorant of the fact that SSH keys had already been loaded! This seemed a spectacular failure to me at the time. Worse, no clues are given in the error report, or [the GitHub documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh) for a resolution. 

##### However...

After some research (mixed with much teeth-gnashing and swearing), ***the solution*** was found!  

> The 'remote origin' must be declared inside of each repo 

Without belaboring this any further, this is what must be done to enable SSH authentication for each of the local repos on your RPi. This command modifies the `.git/config` file (or in the case of a *bare*/"*server*" repo, just the `config` file): 

```bash
# S.U.C.C.E.S.S.:
# Point 1: Learn how to check the remote origin of a repo:
# From *inside* the repo, issue this command: 
$ git remote show origin
# --OR--
$ git remote -v
# If the remote origin is not what it should be... CHANGE IT: 
# 'git remote set-url origin git@github.com:gitusername/repository.git'
# NOTE THE SSH-LIKE PREFIX: 'git@github.com:'  THIS DEFINES SSH ACCESS

$ git remote set-url origin git@github.com:seamusdemora/pi-motd.git   # run from inside the repo

# And afterwards: 

$ git push --dry-run origin master
# will work fine!
```

### III. Push a repo on your RPi to a repo on your GitHub server 

With the Authentication of Part II now sorted, let's continue: 

##### 1. Create an empty, named repo on GitHub

* Log into your GitHub account from your browser. 
* In the top row, click the **Create new...** button, and select **New repository** 
* From the **New repository** creation page, enter a suitable **Repository name**; leave all other choices empty or unselected (i.e. README, .gitignore & license)
* Click the **Create repository** button - this creates an empty repository, and lands you on a page with lots of "helpful" GitHub instructions - ignore them for now, but leave the page open in a browser tab.

##### 2. Initialize the folder on your RPi containing your <code, documentation, etc> as a repo 

* In ***my case***, I began working on my "code" by copying the folder `/etc/update-motd.d` into my `/home/pi` folder. I added some files, did some testing, and when I got it like I wanted it, I simply went into the folder `/home/pi/pi-motd`, and initialized it using `git`: 

  ```bash
  $ git init
  Initialized empty Git repository in /home/pi/pi-motd/.git/
  ```

##### 3. Add & commit files to the new (empty) repository 

* Go through each step in detail: 

  ```bash
  $ cd ~/pi-motd
  $ git add -v *        # '*' = add all files in folder to repo, '-v' = verbose
  add '10-intro'
  add '10-uname'
  add '10-uname.moved'
  add '20-uptime'
  add '20-who.moved'
  add '30-temp'
  add '40-sdcard'
  add '50-network'
  add '55-osver'
  add '60-kernel'
  add '70-backup'
  add '75-imgutil'
  add '99-source'
  
  $ git commit -v -m "adding all files to empty repo"
  [master (root-commit) 332c66c] adding all files to empty repo
   14 files changed, 44 insertions(+)
   create mode 100755 10-intro
   create mode 100644 10-uname
   create mode 100644 10-uname.moved
   create mode 100755 20-uptime
   create mode 100644 20-who.moved
   create mode 100755 30-temp
   create mode 100755 40-sdcard
   create mode 100755 50-network
   create mode 100755 55-osver
   create mode 100755 60-kernel
   create mode 100755 70-backup
   create mode 100755 75-imgutil
   create mode 100755 99-sourc  
   
   # But this commit was a mistake, as it included some files that had been 
   # "effectively removed" by changing their mode from 755 (ex) to 644 (non-ex).
   # Correct this by doing a 'git rm --cached <>' to remove from repo, NOT from fs
   
   $ git rm --cached 10-uname 10-uname.moved 20-who.moved 
   [master 0b4b14f] removed 10-uname,10-uname.moved,20-who.moved from repo
   3 files changed, 6 deletions(-)
   delete mode 100644 10-uname
   delete mode 100644 10-uname.moved
   delete mode 100644 20-who.moved 
   
   # Just to make sure the 'rm --cached' files are no longer part of the repo:
   
   $ git ls-tree master --name-only
  10-intro
  20-uptime
  30-temp
  40-sdcard
  50-network
  55-osver
  60-kernel
  70-backup
  75-imgutil
  99-source
```

##### 3. 'push' your RPi-local repo to GitHub (THE PAYOFF) 

* At this point, the repo appears to be correct. All files were added & committed, then 3 were removed/un-committed. 

* Recalling the *lessons learned* from **Step** **II**-5 wrt `git remote set-url origin ...`, we are now ready to `push` the repo to GitHub using SSH authentication: 

* ```bash
  $ cd ~/pi-motd 
  $ git remote add origin git@github.com:seamusdemora/pi-motd.git # NOTE 'add' instead of 'set-url' 
  # 'add' to create a new remote; 'set-url' to make a change
  $ git branch -M master 
  $ git push -u origin master
  Enumerating objects: 17, done.
  Counting objects: 100% (17/17), done.
  Delta compression using up to 4 threads
  Compressing objects: 100% (13/13), done.
  Writing objects: 100% (17/17), 1.87 KiB | 1.87 MiB/s, done.
  Total 17 (delta 1), reused 0 (delta 0), pack-reused 0
  remote: Resolving deltas: 100% (1/1), done.
  To github.com:seamusdemora/pi-motd
   * [new branch]      master -> master
  branch 'master' set up to track 'origin/master'.
  $ 
  ```

* And you should now be able to [load the page for the pi-motd repo at GitHub in your browser](https://github.com/seamusdemora/pi-motd). Note that some of the [*niceties*](https://www.merriam-webster.com/dictionary/nicety) have been added: a 'README.md' file, a license file and a few other files that may be useful. 



### And that concludes this recipe - for now... 







<!--- 

HIDDEN

### III. Copy/clone your local repo to the remote

In other words, upload your local files to a named repository at GitHub

```bash
$ cd ~/PiPyMailer
$ git remote add origin https://github.com/seamusdemora/PiPyMailer
```



#### 1. From `man git-init`, the 4-step process to create your local repo:

>Start a new Git repository for an existing code base:  
  $ cd /path/to/my/codebase  
  $ git init      (1)  
  $ git add .     (2)  
  $ git commit    (3)  
  1. Create a /path/to/my/codebase/.git directory.  
  2. Add all existing files to the index.  
  3. Record the pristine state as the first commit in the history.  

#### 2. At this point you have a *local* repo ready for upload to GitHub: 

```bash
$ git remote add origin https://github.com/seamusdemora/dhcpcd5
```



1. @github.com, copy the URL of the repo to be cloned on RPi:
    `https://github.com/seamusdemora/PiPyMailer.git` 

2. in a terminal session to RPi, enter this: 
    `git clone https://github.com/seamusdemora/PiPyMailer.git`

  this should download the repo into a folder named `PiPyMailer` on RPi

3. `cd ./PiPyMailer`
   Alternatively, you can execute most `git` commands from *outside* the folder housing the repo by using the `-C` option; for example, to get `status` for the git repo PiPyMailer from another location: 
```bash
  git -C /path/to/PiPyMailer status
```
5. make your changes, test your code. when code is verified, proceed w/ next step
6. `git status` to review additions & changes; e.g.
    On branch master
    Your branch is up-to-date with 'origin/master'.
    Changes not staged for commit:
    	(use "git add <file>..." to update what will be committed)
    	(use "git checkout -- <file>..." to discard changes in working directory)

  	modified:   testmail2.py

  Untracked files:
  	(use "git add <file>..." to include in what will be committed)

  	change.crontab.txt
  	change.profile.txt

6. move modified file(s) to staging area:
    `git add testmail2.py`

7. move added file(s) to staging area
    `git add change.crontab.txt change.profile.txt` 

8. verify all required files are in staging area:
    `git status`

9. commit changes to the branch from which the local repo was cloned:
    `git commit`

10. edit the offered "COMMIT_EDITMSG" file

  1. NOTE 1: `git config --global content.editor "nano -w"` (wait for me to finish!)
  2. NOTE 2: you *must* add a non-commented line to the commit message

11. now that changes are "committed", they must be "pushed" to GitHub: 
      `git push origin master`

   If all goes well, you'll be prompted for GitHub userid & pswd, and changes will
   appear in the correct repo! 

14. If changes are made to your repo on GitHub, your local repository will need to be synced with your remote repository at GitHub. Here's how to do that: 

```
    git -C ~/path/my-local-repo pull https://github.com/my_github/my_repo master
```

16. If you *break sync* in your GitHub repo, [read this](https://github.com/seamusdemora/seamusdemora.github.io/blob/master/MacStuff.md#15-how-to-recover-a-bodged-git-repository). You can *break sync* in a local repo if you have multiple copies (e.g. on more than one local machine), and allow uncommitted changes to accumulate on two or more of these machines. Be careful - this can be **very messy**!  

### If You Make a Mistake

##### If you make mistakes in your local repo and you realize this *before* you commit (i.e. this will dispose of all un-committed changes, mistakes or not):

```bash
$ git reset --hard
# -OR- from outside your repo: 
$ git -C /path/to/PiPyMailer reset --hard
```

### Addendum:  `gh`, the GitHub Command Line Interface

The [GitHub CLI](https://github.com/cli/cli#readme) -  `gh` looks useful, and it can be installed on your RPi - even on a *headless* RPi. It's a bit different than many Linux tools - more like `git` - which seems entirely appropriate :)  I'll only cover the basics here - installation, and initial authentication. The rest you'll find in the online docs & `man gh` after installation: 

   ```bash
   $ # find the latest version:
   $ GITHUB_CLI_VERSION=$(curl -s "https://api.github.com/repos/cli/cli/releases/latest" | grep -Po '"tag_name": "v\K[0-9.]+')
   $ echo $GITHUB_CLI_VERSION
   2.8.0
   $ # use curl to fetch the .deb file for RPi (armv6):
   $ curl -Lo gh.deb "https://github.com/cli/cli/releases/latest/download/gh_${GITHUB_CLI_VERSION}_linux_armv6.deb"
   $ # ... curl output & download stats
   $ sudo dpkg -i gh.deb
   Selecting previously unselected package gh.
   (Reading database ... 50648 files and directories currently installed.)
   Preparing to unpack gh.deb ...
   Unpacking gh (2.8.0) ...
   Setting up gh (2.8.0) ...
   Processing triggers for man-db (2.9.4-2) ...
   $ $ gh --version
   gh version 2.8.0 (2022-04-13)
   https://github.com/cli/cli/releases/tag/v2.8.0 
   $ gh auth login 
   $ # at this point, you'll go through an interactive dialog from the CLI
   ```

If you're running *headless*, and prefer to use your SSH public key, the remainder of your initial login will go something like this. Note that I chose to `Login with a web browser` - which obviously doesn't exist on a headless RPi. Not to worry - just open a browser window on your lap/desk top host for the URL given, then copy and paste your one-time code (**not mine!**) into the browser window. It's all very *smooth*. 

Here's the balance of the dialog: 

   ```bash
   ? What account do you want to log into? GitHub.com
   ? What is your preferred protocol for Git operations? SSH
   ? Upload your SSH public key to your GitHub account? /home/pi/.ssh/id_ed25519.pub
   ? How would you like to authenticate GitHub CLI? Login with a web browser
   
   ! First copy your one-time code: ABCD-0123
   Press Enter to open github.com in your browser...
   ! Failed opening a web browser at https://github.com/login/device
     exec: "xdg-open,x-www-browser,www-browser,wslview": executable file not found in $PATH
     Please try entering the URL in your browser manually
   ✓ Authentication complete.
   - gh config set -h github.com git_protocol ssh
   ✓ Configured git protocol
   ✓ Uploaded the SSH key to your GitHub account: /home/pi/.ssh/id_ed25519.pub
   ✓ Logged in as seamusdemora 
   $ # verify all of this worked:
   $ gh auth status
   github.com
     ✓ Logged in to github.com as seamusdemora (/home/pi/.config/gh/hosts.yml)
     ✓ Git operations for github.com configured to use ssh protocol.
     ✓ Token: *******************
   $ # done!
   ```

 Thanks to the [Lindevs blog](https://lindevs.com/install-github-cli-on-raspberry-pi/?unapproved=687&moderation-hash=85abbd82976e95f8ede2a65c60883906#comment-687) for figuring out all of the hard stuff in this installation. And one final point: because `gh` is not in RPi's *official* distro, it won't be routinely updated with `apt`. To stay current, you can check the latest version number by running the command substitution for `GITHUB_CLI_VERSION` as shown above - you can *automate* this by creating a small `cron` job to check this for you. 

--->

---

### REFERENCES:

1. [Getting Started with Git](https://www.taniarascia.com/getting-started-with-git/) 
2. [Q&A: How to move a git repository into another directory and make that directory a git repository?](https://stackoverflow.com/questions/19097259/how-to-move-a-git-repository-into-another-directory-and-make-that-directory-a-gi) For shuffling things around! 
3. [From GitHub, instructions for configuring `git` ](https://help.github.com/en/github/getting-started-with-github/set-up-git); set username, cache password, use HTTPS or SSH to access a GitHub repo from `bash`.
4. [Q&A: How can I stage and commit all files, including newly added files, using a single command?](https://stackoverflow.com/questions/2419249/how-can-i-stage-and-commit-all-files-including-newly-added-files-using-a-singl) 
5. [Q&A: Pushing local changes to a remote repository](https://stackoverflow.com/a/7690136/5395338); this answer is relevant.
6. [Q&A: Discard all uncommitted changes, modified files, added files and non-added](https://stackoverflow.com/questions/55211312/discard-all-uncommitted-changes-modified-files-added-files-and-non-added) 
7. [Q&A: Revert to commit by SHA hash in Git? dup.](https://stackoverflow.com/questions/1895059/revert-to-a-commit-by-a-sha-hash-in-git); don't let this Q&A confuse you! [check this answer](https://stackoverflow.com/a/1895095/5395338).
8. [Q&A: How to reset local file to the most recent commit on GitHub?](https://stackoverflow.com/questions/42754381/how-to-reset-local-file-to-the-most-recent-commit-on-github); note [use of `git log`](https://stackoverflow.com/a/42754451/5395338).
9. [How do I revert a Git repository to a previous commit?](https://stackoverflow.com/questions/4114095/how-do-i-revert-a-git-repository-to-a-previous-commit); too much information? 
10. [Q&A: How to save username and password in GIT](https://stackoverflow.com/questions/35942754/how-to-save-username-and-password-in-git-gitextension) - a cacophony of answers! 
11. [How do I provide a username and password when running “git clone git@remote.git”?](https://stackoverflow.com/questions/10054318/how-do-i-provide-a-username-and-password-when-running-git-clone-gitremote-git) - more answers! 
12. [Git – Config Username & Password – Store Credentials](https://www.shellhacks.com/git-config-username-password-store-credentials/) - still more. 
12. [About authentication to GitHub](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/about-authentication-to-github)  - a child of [this page on Authentication](https://docs.github.com/en/authentication)
12. [Installing `gh` - GitHub's CLI - on Linux and BSD](https://github.com/cli/cli/blob/trunk/docs/install_linux.md) 
12. [How to install Github CLI on Linux](https://garywoodfine.com/how-to-install-github-cli-on-linux/) -  an alternative set of install instructions
12. [The GitHub CLI manual](https://cli.github.com/manual/) 

<!--- 

HIDDEN

---

Exported tabs from Chrome re git & GitHub: 

Moving a file to a new location - GitHub Help
https://help.github.com/en/github/managing-files-in-a-repository/moving-a-file-to-a-new-location

Syncing your branch - GitHub Help
https://help.github.com/en/desktop/contributing-to-projects/syncing-your-branch

Getting changes from a remote repository - GitHub Help
https://help.github.com/en/github/using-git/getting-changes-from-a-remote-repository

Adding a remote - GitHub Help
https://help.github.com/en/github/using-git/adding-a-remote

Set up Git - GitHub Help
https://help.github.com/en/github/getting-started-with-github/set-up-git

git - How do I create a folder in a GitHub repository? - Stack Overflow
https://stackoverflow.com/questions/12258399/how-do-i-create-a-folder-in-a-github-repository

git - Reset local repository branch to be just like remote repository HEAD - Stack Overflow
https://stackoverflow.com/questions/1628088/reset-local-repository-branch-to-be-just-like-remote-repository-head

git - How to reset local file to the most recent commit on GitHub? - Stack Overflow
https://stackoverflow.com/questions/42754381/how-to-reset-local-file-to-the-most-recent-commit-on-github

git - Discard all uncommitted changes, modified files, added files and non-added - Stack Overflow
https://stackoverflow.com/questions/55211312/discard-all-uncommitted-changes-modified-files-added-files-and-non-added

Revert to a commit by a SHA hash in Git? - Stack Overflow
https://stackoverflow.com/questions/1895059/revert-to-a-commit-by-a-sha-hash-in-git

--->

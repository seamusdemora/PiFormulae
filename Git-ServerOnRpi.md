## Operate a Git-Server on Raspberry Pi 
Let's set up a git server on a Raspberry Pi. This server will be a *private* server for tracking code and files generated on your local network - at least that's the scope of ***my git server***. Yours may be different.

### Designation of and Access to the Git-Server
Nothing special need be done to designate an RPi as a Git-Server. As long as it's got `git` installed, virtually any RPi is fit for this purpose. Simply choose one that's accessible to other hosts (RPi git-clients) on your network as the clients will need to make SSH connections to the Git-Server. Assuming you want to use public-key authentication, you'll need to copy public keys from git-clients to the git-server using `ssh-copy-id`. 

### The Situation
Let's assume we have an RPi w/ hostname `rpigitserver` as the **Git-Server**, and that we have another RPi w/ hostname `rpigitclient` as one of the clients. Let's also assume that the repository we wish to maintain source control over is called `etc-update-motd-d`; this is simply a descriptive name, and need not be the same name as git folder holding the same code on the client(s). 

### Set Up the Repositories on the host `rpigitserver`; i.e. the Git-Server
Rather than scattering the repositories about, we'll put all of our git repositories under a common folder that we'll name `~/git-srv`; sub-folders will designate the names of the individual repositories. 

```bash
$ hostname    # to get our bearings straight
rpigitserver
$ mkdir ~/git-srv
```

Next, create a sub-directory under `~/git-srv` to contain our first repository (`etc-update-motd-d`), and **initialize** this sub-directory as a `git` repository : 

```bash
$ hostname    # to get our bearings straight
rpigitserver
$ mkdir ~/git-srv/etc-update-motd-d.git   # NOTE that we added the file extension `.git`
$ cd ~/git-srv/etc-update-motd-d.git
$ git init --bare                         # NOTE '--bare' option
```
**And that's it... our Git-Server is alive!** 

###  From a (Git-)Client connect to the Git-Server to "source" the code we've developed

Now move to (one of) the git-clients: `rpigitclient`. Assume `rpigitclient` is the host on which we've been coding a set of scripts which comprise the project we'll call `motd-d`. Remember, the folder names on client and server need not match, although they certainly can match - if that is desired.

```bash
$ hostname    # to get our bearings straight
rpigitclient
$ ssh-copy-id pi@rpigitserver   # copy SSH pub key to `rpigitserver` ==> IF NECESSARY
$ cd ~/scripts/motd-d           # where the code for project motd-d is kept
$ git init                      # NOTE we did not use the `--bare` option!
$ git add <filenames>           # add the files which are to be tracked
$ git commit -m 'some-message'  # commit the files with a suitable/meaningful message
$ git remote add origin ssh://pi@rpigitserver/home/pi/git-srv/etc-update-motd-d.git
# ^ declares the designated folder on `rpigitserver` as the "remote origin"
$ git push -u ssh://pi@rpigitserver/home/pi/git-srv/etc-update-motd-d.git
# ^ "pushes" the previously `add`ed & `commit`ted files to the Git-Server (`rpigitserver`)
```
**At this point, we have uploaded the code stored in `~/scripts/motd-d` on the client machine to the repo called `etc-update-motd-d.git` on the Git-Server.** Things are moving right along :)



### Connect another git-client to clone the repo

Let's move to another git-client, and "clone" (copy) the repo from Git-Server (`rpigitserver`). Let's assume this client is also located on the host `rpigitserver`; this might be in a different user's home directory (or not). We do this to show how a "local" clone is accomplished. 

```bash
$ hostname    				# to get our bearings straight
rpigitserver
$ pwd
/home/developer				# 'developer' is a userid; i.e. not user pi
$ git clone pi@rpigitserver:/home/pi/git-srv/etc-update-motd-d.git
Cloning into 'etc-update-motd-d'...
  ...
Receiving objects: 100% (3/3), done.
$ ls -l
etc-update-motd-d.git
$
# i.e. executing `git clone` from `~/` creates/clones the repo in ~/etc-update-motd-d
```
#### ALTERNATIVELY, let's create that clone under a different directory; i.e. something other than `etc-update-motd-d.git`

```bash
$ hostname    # to get our bearings straight
rpigitserver
$ pwd
/home/developer
$ git clone pi@rpigitserver:/home/pi/git-srv/etc-update-motd-d.git  motd.git
Cloning into 'motd'...
  ...
Receiving objects: 100% (3/3), done.
```
Of course this `clone` operation can also be done on any remote host using a URL (e.g. SSH, or https). In either case, **We have now `clone`d a copy of our repo which may be used by another developer.** 



### Update Git-Server with changes made on `rpigitclient`

Now let's assume that development has been on-going on `rpigitclient`, and we are ready to `commit` the code, and upload that code to the Git-Server.  

Here's how that commit is done, and pushed to the **Git-Server**: 

```bash
$ hostname    # to get our bearings straight
rpigitclient
$ cd ~/scripts/motd-d
$ git add *		# git will add all *changed* files to the 'staging area' 
$ git commit -m 'added & modified several files'	# a very generic message. :)
[master 8ad2324] added & modified several files
 2 files changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 bar
 create mode 100644 foo
$ git push -u ssh://pi@rpigitserver/home/pi/git-srv/etc-update-motd-d.git
Enumerating objects: 4, done.
Counting objects: 100% (4/4), done.
Delta compression using up to 4 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (3/3), 293 bytes | 146.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0), pack-reused 0
To ssh://rpigitserver/home/pi/git-srv/etc-update-motd-d.git
   274b30b..8ad2324  master -> master
Branch 'master' set up to track remote branch 'master' from 'ssh://pi@rpigitserver/home/pi/git-srv/etc-update-motd-d.git'
$ 
```

**Our revised code has now been `commit`ed and `push`ed to the Git-Server.** 



### Update a Git-Client repo from the Git-Server

During the course of your work, you will occasionally need to update the repo on one or more of your Git-Clients. This is done as follows: 

```bash
$ hostname    # to get our bearings straight
rpigitclient
$ cd ~/scripts/motd-d
$ git branch --show-current
master        # or whatever the current branch is
$ git pull origin master
From ssh://rpigitserver/home/pi/git-srv/etc-update-motd-d
 * branch            master     -> FETCH_HEAD 
 ...
 $
```



### Create a working tree in our Git-Server repository

Recall that when we initialized our repository in `~/git-srv/etc-update-motd-d.git` on `rpigitserver`, we used the `--bare` option. Take a look now inside that folder; `ls -l` inside the repository. Next, go to a    `clone`d repo, and take a look inside that folder using `ls -l`. You will notice that there are some differences, the most obvious being that the files in the repo are ***not visible*** inside the  `~/git-srv/etc-update-motd-d.git` folder!  You can search for them if you like - but you won't find them. This is a result of using the `--bare` option in initialization - the file contents are in the repository, but the repository contains no "working tree". 

But now suppose we want to keep a working tree inside  `~/git-srv/etc-update-motd-d.git` ... how do we add that? As usual in `git`, there's a command for that: 

```bash
$ hostname    # to get our bearings straight
rpigitserver
$ cd ~/git-srv/etc-update-motd-d.git 
$ pwd
~/git-srv/etc-update-motd-d.git

# add the working tree under tha name 'motd-worktree'

$ git worktree add motd-worktree
$ ls -l ./motd-worktree
total 44
-rw-r--r-- 1 git git  65 Jan  3 02:19 10-intro
-rw-r--r-- 1 git git  41 Jan  3 02:19 20-uptime
-rw-r--r-- 1 git git  72 Jan  3 02:19 30-temp
-rw-r--r-- 1 git git 118 Jan  3 02:19 40-sdcard
-rw-r--r-- 1 git git  56 Jan  3 02:19 50-network
-rw-r--r-- 1 git git  56 Jan  3 02:19 55-osver
-rw-r--r-- 1 git git  41 Jan  3 02:19 60-kernel
-rw-r--r-- 1 git git 186 Jan  3 02:19 70-backup
-rw-r--r-- 1 git git 264 Jan  3 02:19 75-imgutil
-rw-r--r-- 1 git git 157 Jan  3 02:19 99-source

$ # note that in git, file modification times are lost in the 'ls' view - this is by design;
$ # change that with 'git restore-mtime' - run from the working tree (after it's installed)

$ sudo apt update && sudo apt install git-restore-mtime
$ cd ./motd-worktree && git restore-mtime && cd ..
$ ls -l  ./motd-worktree
total 44
-rw-r--r-- 1 pi pi  65 Dec 16 03:23 10-intro
-rw-r--r-- 1 pi pi  41 Dec 16 03:23 20-uptime
-rw-r--r-- 1 pi pi  72 Dec 16 03:23 30-temp
-rw-r--r-- 1 pi pi 118 Dec 16 03:23 40-sdcard
-rw-r--r-- 1 pi pi  56 Dec 16 03:23 50-network
-rw-r--r-- 1 pi pi  56 Dec 16 03:23 55-osver
-rw-r--r-- 1 pi pi  41 Dec 16 03:23 60-kernel
-rw-r--r-- 1 pi pi 186 Dec 15 02:53 70-backup
-rw-r--r-- 1 pi pi 264 Nov 30 06:58 75-imgutil
-rw-r--r-- 1 pi pi 157 Jan  2 01:22 99-source
$
```

**We now have a working tree in our once-bare git repository; we can *access/add/delete/update/commit* any of the files from this tree to the repository.** 





### And that concludes this recipe - for today.



## REFERENCES: 

1. [Chapter 2 - Git Basics](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository); highly recommended !

### Git Worktrees:

   1. [A search](https://is.gd/Bt6DlQ) 
   2. [git-worktree - Manage multiple working trees](https://git-scm.com/docs/git-worktree)
   3. [Q&A: fatal: This operation must be run in a work tree](https://stackoverflow.com/questions/9262801/fatal-this-operation-must-be-run-in-a-work-tree) 
   4. [Q&A: What would I use git-worktree for?](https://stackoverflow.com/questions/31935776/what-would-i-use-git-worktree-for)
   5. [Experiment on your code freely with Git worktree](https://opensource.com/article/21/4/git-worktree) 
   6. [Using Git Worktree to Master Git Workflow](https://www.hatica.io/blog/git-worktree/) 
   7. [Git Worktrees in Use](https://medium.com/ngconf/git-worktrees-in-use-f4e516512feb) 

### Git - list files in repo:

1. [Q&A: List files in local Git repo?](https://stackoverflow.com/questions/8533202/list-files-in-local-git-repo) - great answer! 
2. [How can I make git show a list of the files that are being tracked?](https://stackoverflow.com/questions/15606955/how-can-i-make-git-show-a-list-of-the-files-that-are-being-tracked) 1 good answer & 1 incorrect answer 
3. [Difference between a working tree and a repository in Git?](https://stackoverflow.com/a/76797811/22595851) the reason why the 'great answer' is great 

### git restore-mtime: 
1. [A search](https://is.gd/1GCkfQ)

2. [The GitHub repo for `restore-mtime`](https://github.com/MestreLion/git-tools/blob/main/git-restore-mtime)

3. [Restoring Timestamps in Git Repositories](https://tilburgsciencehub.com/building-blocks/collaborate-and-share-your-work/use-github/git-tools/)

4. Install via `sudo apt install git-restore-mtime`; run command via `git restore-mtime`  

5. [Debian `man git-restore-mtime`](https://manpages.debian.org/bookworm/git-restore-mtime/git-restore-mtime.1.en.html) 

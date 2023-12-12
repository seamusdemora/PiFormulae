## Operate a Git-Server on Raspberry Pi 
Let's set up a git server on a Raspberry Pi. This server will be a *private* server for tracking code and files generated on your local network - at least that's the scope of ***my git server***. Yours may be different.

### Designation of and Access to the Git-Server
Nothing special need be done to designate an RPi as a Git-Server. As long as it's got `git` installed, virtually any RPi is fit for this purpose. Simply choose one that's accessible to other hosts (RPi git-clients) on your network as the clients will need to make SSH connections to the Git-Server. Assuming you want to use public-key authentication, you'll need to copy public keys from git-clients to the git-server using `ssh-copy-id`. 

### The Situation
Let's assume we have an RPi w/ hostname `rpigitserver` as the **Git-Server**, and that we have another RPi w/ hostname `rpigitclient` as one of the clients. Let's also assume that the repository we wish to maintain source control over is called `etc-update-motd-d`; this is simply a descriptive name, and need not be the same name as git folders holding the same code on the client(s). 

### Set Up the Repositories on the host `rpigitserver`; i.e. the Git-Server
We'll put all of our git repositories under a common folder; sub-folders will designate the names of the individual repositories. 

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
$ git init --bare 
```
And that's it... our Git-Server is alive! 

###  From a git-client connect to the Git-Server to "source" the code we've been working on

Now move to (one of) the git-clients: `rpigitclient`. Assume `rpigitclient` is the host on which we've been coding a set of scripts which comprise the project we'll call `motd-d`. Remember, the folder names on client and server need not match, although they certainly can if that is desired.

```bash
$ hostname    # to get our bearings straight
rpigitclient
$ ssh-copy-id pi@rpigitserver   # copy SSH pub key to `rpigitserver` ==> IF NECESSARY
$ cd ~/scripts/motd-d           # where the code for project motd-d is kept
$ git init
$ git add <filenames>           # add the files which are to be tracked
$ git commit -m 'some-message'  # commit the files with a suitable/meaningful message
$ git remote add origin ssh://pi@rpigitserver/home/pi/git-srv/etc-update-motd-d.git
# ^ declares the designated folder on `rpigitserver` as the "remote origin"
$ git push -u ssh://pi@rpigitserver/home/pi/git-srv/etc-update-motd-d.git
# ^ "pushes" the previously `add`ed & `commit`ted files to the Git-Server (`rpigitserver`)
```
At this point, we have uploaded the code stored in `~/scripts/motd-d` on the client machine to the repo called `etc-update-motd-d.git` on the Git-Server.


### Connect another git-client to clone the repo 

Let's move to another git-client, and "clone" (copy) the repo from Git-Server (`rpigitserver`). Let's assume this client is also located on the host `rpigitserver`; this might be in a different user's home directory (or not). We do this to show how a "local" clone is accomplished. 

```bash
$ hostname    # to get our bearings straight
rpigitserver
$ pwd
/home/developer
$ git clone pi@rpigitserver:/home/pi/git-srv/etc-update-motd-d.git
Cloning into 'etc-update-motd-d'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.
$ ls -l
etc-update-motd-d.git
$
# i.e. executing `git clone` from `~/` creates/clones the repo in ~/etc-update-motd-d
```

### Update Git-Server with changes made on `rpigitclient`

To illustrate how to "complete the cycle", let's now assume that the developer on host `rpigitclient` has made some changes that he wishes to **commit** to the repo. Let's further assume that the changes involved the addition of two *working* files that will need to be further distributed and tested prior to release, and that the filenames of these *working* files are variations on the un-modified files. In other words, the new, added files might be named `foo_PROTO` and `bar_PROTO`.

Here's how that commit is done, and pushed to the **Git-Server**: 

```bash
$ hostname    # to get our bearings straight
rpigitclient
$ cd ~/scripts/motd-d
$ git add foo_PROTO bar_PROTO
$ git commit -m 'add PROTOTYPE scripts'
[master 8ad2324] add PROTOTYPE scripts
 2 files changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 bar_PROTO
 create mode 100644 foo_PROTO
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

And that concludes this recipe - for today.

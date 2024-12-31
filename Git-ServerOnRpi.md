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

###  Connect to the Git-Server fm a Git-Client & "source" the developed code

Now move to (one of) the git-clients: `rpigitclient`. Assume `rpigitclient` is the host on which we've been coding a set of scripts which comprise the project we'll call `motd-d`. Remember, the folder names on client and server need not match, although they certainly can match - if that is desired.

```bash
$ hostname    # to get our bearings straight
rpigitclient
$ ssh-copy-id pi@rpigitserver     # copy SSH pub key to `rpigitserver` ==> IF NECESSARY
$ cd ~/scripts/motd-d             # where the code for project motd-d is kept
$ git init                        # "initialize" the client repo; NOTE we did not use the `--bare` option!
Initialized empty Git repository in ...
$ git add <filenames> -OR- <.>    # add the files which are to be tracked; use '.' for all files
# This is a good time to run 'git status' - to see where we stand...
$ git status
On branch master

No commits yet

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)
	new file:   10-intro
	new file:   12-ckmount
     ...
	new file:   75-imgutil
	new file:   99-source
# ^ 'git status' reports we have a  number of files "staged", but nothing has yet been committed

$ git commit -m 'initial commit'    # commit the files with a suitable/meaningful message
[master (root-commit) 3503154] initial commit
 13 files changed, 55 insertions(+)
 create mode 100755 10-intro
 create mode 100755 12-ckmount
...
 create mode 100755 75-imgutil
 create mode 100755 99-source
# ^ 'git commit...' verifies the list of files committed
 
$ git remote add origin pi@rpigitserver:/home/pi/git-srv/etc-update-motd-d.git
# ^ declares the designated folder on `rpigitserver` as the "remote origin"
$ git push -u origin master
Enumerating objects: 15, done.
Counting objects: 100% (15/15), done.
...
 * [new branch]      master -> master
branch 'master' set up to track 'origin/master'.
# ^ "pushes" previously `add`ed & `commit`ted files to the Git-Server (or 'origin/rpigitserver`) repo 'master' branch

# Let's run 'git status' again:
$ git status
On branch master
Your branch is up to date with 'origin/master'.

nothing to commit, working tree clean
# ^ 'git status' confirms we've successfully updated the repo on 'rpigitserver'

# once the 'remote origin' has been established, future 'git push' operations *to* rpigitserver are simplified:
$ git push
# or, to pull/fetch updates *from* the server
$ git pull

# NOTE: If you need to make changes to the 'remote origin', it may be simpler to make those
# changes by manually editing the `./git/config` folder in your client repo.
```
**At this point, we have uploaded the code stored on the client machine in `~/scripts/motd-d` to the repo called `etc-update-motd-d.git` on the Git-Server.** Things are moving right along :) 

### Restore 'modification time' to files in the repo

You may have noticed (by running `ls -l`) that the working files in your repo have [modification 'date-times'](https://duckduckgo.com/?q=linux+file+modification+time&t=newext&atb=v369-1&ia=web) that don't reflect their **true** modification time. Weirdly (to me anyway), this is "by design"; maybe I've been looking at GitHub for too long? If you're *so inclined*, you can override this *odd* behavior. You'll need to install an "extra" app for it: `git-restore-mtime`. Here's how this works: 

```bash
$ hostname    # to get our bearings straight
rpigitclient
$ sudo apt update && sudo apt install git-restore-mtime  # NOTE 'git-restore-mtime'
$ cd ~/scripts/motd-d && git restore-mtime
12 files to be processed in work dir
Statistics:
         0.04 seconds
           36 log lines processed
            7 commits evaluated
            1 directories updated
           12 files updated
total 44 
```

### Connect another git-client to clone the repo

Let's move to another git-client, and "clone" (copy) the repo from Git-Server (`rpigitserver`). **Let's assume this client is also located on the host `rpigitserver`;** this might be in a different user's home directory (or not). We do this to show how a "local" clone is accomplished. 

```bash
$ hostname    				# to get our bearings straight
rpigitserver
$ pwd
/home/developer				# 'developer' is a userid; i.e. not user pi
$ git clone pi@rpigitserver:/home/pi/git-srv/etc-update-motd-d.git
Cloning into 'etc-update-motd-d'...
  ...
Receiving objects: 100% ... , done.

$
# i.e. executing 'git clone' from '/home/developer' creates/clones the repo in '/home/developer/etc-update-motd-d.git'
```
#### ALTERNATIVELY, let's create that clone under a different folder name; i.e. something other than `etc-update-motd-d.git`

```bash
$ hostname    # to get our bearings straight
rpigitclient2
$ pwd
/home/developer
$ git clone pi@rpigitserver:/home/pi/git-srv/etc-update-motd-d.git  motd
Cloning into 'motd'...
  ...
Receiving objects: 100% (3/3), done.
# We've cloned the repo into a folder named '/home/developer/motd'! 
```

### Update Git-Server with changes made on `rpigitclient`

Now let's assume that development has been on-going on `rpigitclient`, and the developer is ready to `commit` the code, and upload that code to the Git-Server.  This developer has been x-busy, and has added two files: `foo` and `bar`. 

Here's how that commit is done, and pushed to the **Git-Server**: 

```bash
$ hostname    # to get our bearings straight
rpigitclient
$ cd ~/scripts/motd-d
$ git add foo bar		# git will add all *changed* files to the 'staging area' 
$ git commit -m 'added files foo & bar, x-important!'
[master d27a3ae] added files foo & bar, x-important!
 2 files changed, 2 insertions(+)
 create mode 100644 bar
 create mode 100644 foo
$ git remote -v show		# verify the correct remote server URL is being used
origin	pi@rpigitserver/home/pi/git-srv/etc-update-motd-d.git (fetch)
origin	pi@rpigitserver/home/pi/git-srv/etc-update-motd-d.git (push) 
$ git push
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 4 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (4/4), 331 bytes | 331.00 KiB/s, done.
Total 4 (delta 1), reused 0 (delta 0), pack-reused 0
To ssh://raspberrypi5/home/git/git-srv/etc-update-motd-d.git
   55cd03b..d27a3ae  master -> master
Branch 'master' set up to track remote branch 'master' from 'origin'. 
# ^ done, mission accomplished
```

**Our revised code has now been `commit`ed and `push`ed to the Git-Server.** 


### Correct erroneous commit & push from `rpigitclient`

Unfortunately, you learn that the developer making these changes was a moron (it happens more frequently these days). You discovered your mistake when you pulled from the repo `motd.git`, and found two suspect files named `foo` and `bar`. You investigate, and [use `git rm`](https://stackoverflow.com/a/2047477/22595851) from the `rpigitclient` host to correct the problem: 

```bash
$ hostname    			# to get our bearings straight
rpigitclient
$ cd ~/scripts/motd-d
$ git rm foo bar		# you remove files from the repo
$ rm 'bar' 'foo'                # you remove files from the filesystem
$ git commit -m "remove files foo & bar added by Moronski" 
[master 95dea5d] remove files foo & bar added by Moronski
 2 files changed, 2 deletions(-)
 delete mode 100644 bar
 delete mode 100644 foo
$ git push 
Enumerating objects: 3, done.
Counting objects: 100% (3/3), done.
Delta compression using up to 4 threads
Compressing objects: 100% (2/2), done.
Writing objects: 100% (2/2), 248 bytes | 248.00 KiB/s, done.
Total 2 (delta 1), reused 0 (delta 0), pack-reused 0
To pi@rpigitserver:/home/pi/git-srv/etc-update-motd-d.git
   d27a3ae..95dea5d  master -> master
Branch 'master' set up to track remote branch 'master' from 'origin'. 
$ 
```

### Update a Git-Client repo from the Git-Server

During the course of your work, you will occasionally need to update the repo on one or more of your Git-Clients. This is done as follows: 

```bash
$ hostname    # to get our bearings straight
rpigitclient
$ cd ~/scripts/motd-d
$ git branch --show-current
master        # or whatever the current branch is
$ git pull
From pi@rpigitserver:/home/pi/git-srv/etc-update-motd-d
 * branch            master     -> FETCH_HEAD 
 ...
 $
```

### Create a working tree in our Git-Server repository

Recall that when we initialized our repository in `~/git-srv/etc-update-motd-d.git` on `rpigitserver`, we used the `--bare` option. Take a look now inside that folder; `ls -l` inside the repository. Next, go to a `clone`d repo, and take a look inside that folder using `ls -l`. You will notice that there are some differences, the most obvious being that the files in the **client repo** are **not visible** inside the **server repo** `~/git-srv/etc-update-motd-d.git` folder!  You can search for them if you like, but you won't find them ([unless you've read this](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)). This is a result of using the `--bare` option in initialization - the files and their contents are in the repository, but the repository contains no "working tree". 

But now suppose we want to create a working tree inside `~/git-srv/etc-update-motd-d.git` ... how do we add that? As usual in `git`, there's a command for that: 

```bash
$ hostname    # to get our bearings straight
rpigitserver
$ cd ~/git-srv/etc-update-motd-d.git 
$ pwd
~/git-srv/etc-update-motd-d.git

# add the working tree under tha name 'motd-worktree'
# we can access/add/delete/update/commit files from this tree

$ git worktree add motd-worktree
$ ls -l ./motd-worktree
total 44
-rw-r--r-- 1 git git  65 Jan  3 02:19 10-intro
-rw-r--r-- 1 git git  41 Jan  3 02:19 20-uptime
...
-rw-r--r-- 1 git git 264 Jan  3 02:19 75-imgutil
-rw-r--r-- 1 git git 157 Jan  3 02:19 99-source

# as there is no compelling reason to have a worktree in our 'bare' server repository,
# we'll just remove the working tree as follows: 

$ git worktree remove motd-worktree

# And now we're back to a 'bare' repo; a Git-Server
```

## A Summary of `git` Commands Used in This Recipe

| Client Objective: | `git` client command |
| ---- | ---- |
| Create (`clone`) a repo on a client: | `git clone <ssh://user@gitserver:/path/to/repo>` |
| &nbsp;&nbsp;&nbsp;&nbsp;*A L T E R N A T I V E  to `clone`* | 1. `mkdir mygitrepo && cd mygitrepo` |
| &nbsp; | 2. `git init` |
| &nbsp; | 3. `git remote add origin <user@gitserver:/path/to/repo>` |
| &nbsp; | 4. `git pull origin master` |
| Create an empty client repo - ***two steps***: | ↓↓↓↓↓ |
| &nbsp;&nbsp;&nbsp;1. create a folder & `cd` into it | `mkdir mygitrepo && cd mygitrepo`  |
| &nbsp;&nbsp;&nbsp;2. initialize the new git repo  | `git init` |
| Designate 'remote' ssh srv for client repo | `git remote add origin <user@gitserver:/path/to/repo>` |
| &nbsp;&nbsp;&nbsp;--- **ALTERNATIVELY :** | manually edit `</path/to/repo/.git/config>`
| Designate **GitHub** as the 'remote' | [see this recipe](https://github.com/seamusdemora/PiFormulae/blob/master/GitForRPi-GitHub.md) |
| Show the 'remote' in use for client repo | `git remote -v [show]` |
| Check the 'status' of the client repo | `git status` [see note](#an-explanatory-note-re-git-status) |
| Commit changes to a git client - ***two steps***: | ↓↓↓↓↓ |
| &nbsp;&nbsp;&nbsp;1. add new & changed files | `git add <file1 file2 etc>` -OR- `<.>` for all files |
| &nbsp;&nbsp;&nbsp;2. commit changes with a commit message | `git commit -m 'a commit message'`  |
| Get (show) the remote (server) used in a repo  | `git remote -v`  |
| ***INITIAL*** Push repo changes to ***"gitserver"*** | `git push -u origin master` |
| ***SUBSEQUENT*** Push repo changes to ***"gitserver"*** | `git push` |
| ***INITIAL*** Pull changes from ***"gitserver"*** | `git pull origin master` |
| ***SUBSEQUENT*** Pull changes from ***"gitserver"*** | `git pull` |
| Restore true mod. time to repo files - ***two steps*** | ↓↓↓↓↓ |
| &nbsp;&nbsp;&nbsp;1. install | `sudo apt install git-restore-mtime` |
| &nbsp;&nbsp;&nbsp;2. run from inside repo | `git restore-mtime` |


| Server Objective: | `git` server command |
| ---- | ----|
| Create an empty server repo - ***two steps***: | ↓↓↓↓↓ |
| &nbsp;&nbsp;&nbsp;1. create a folder & `cd` into it | `mkdir srvgitrepo && cd srvgitrepo` |
| &nbsp;&nbsp;&nbsp;2. initialize the new git repo | `git init --bare` |
| Create a "working tree" in git server repo | `git worktree add <srv-worktree>` |
| Designate GitHub as the 'remote' for worktree | See [this recipe](https://github.com/seamusdemora/PiFormulae/blob/master/GitForRPi-GitHub.md); perform from inside the worktree |
| Remove a "working tree" from git server repo | `git worktree remove <srv-worktree>` |

## An Explanatory Note Re: `git status`

You will note that using `git status` (e.g. in a client repo) may give you the ***"wrong answer"*** in some situations. For example:

   >One of my collaborators has informed me that he has made some `commits` to a repo that we use. I then *descend* into that repo (e.g. `cd blockead.git`), and run `git status`. That command will yield the following as *status*:

   ```bash
   ~blockhead.git $ git status
   On branch master
   Your branch is up to date with 'origin/master'.
   
   nothing to commit, working tree clean
   ```
   >WTFO?? I wonder what happened to those `commits` he said he made?

**_Now for the "explanation":_** [*Technically speaking*](https://english.stackexchange.com/questions/26185/usage-of-the-word-technically) this may not be the ***"wrong answer"***, but it is most certainly an _ambiguous and confusing answer_. There are [various explanations](https://duckduckgo.com/?t=ffab&q=why+does+%27git+status%27+report+up+to+date+when+it%27s+not&ia=web) available online, but they [_"boil down"_](https://idioms.thefreedictionary.com/boil+down+to) to this: 

>_"up-to-date"_ means "up-to-date" with the branch that my branch tracks... which in this case means "up-to-date" with the **local** `origin/master` branch

Inevitably, the authors of all (most) of these _explanations_ deny that this wording is a problem. I can only guess that they are afraid of offending someone... Well, I'm sorry, but I can't excuse such [_piss-poor_](https://idioms.thefreedictionary.com/piss-poor) use of the English language - even if it is `git`. But hey - this is called **open-source** software for a reason, and so I'll offer the following as a solution:

```bash
coming soon...
```

### And that concludes this recipe - for today.

<!---
you can hide shit in here :) 
-->

## REFERENCES:

1. [Chapter 2 - Git Basics](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository); highly recommended !

### Git Worktrees:

1. [A search](https://is.gd/Bt6DlQ) 
2. [The Git working tree, index and commit history explained by example](https://www.theserverside.com/video/Understand-the-Git-working-tree-status-command-for-easy-DVCS) 
3. [git-worktree - Manage multiple working trees](https://git-scm.com/docs/git-worktree)
4. [Q&A: fatal: This operation must be run in a work tree](https://stackoverflow.com/questions/9262801/fatal-this-operation-must-be-run-in-a-work-tree) 
5. [Q&A: What would I use git-worktree for?](https://stackoverflow.com/questions/31935776/what-would-i-use-git-worktree-for)
6. [Experiment on your code freely with Git worktree](https://opensource.com/article/21/4/git-worktree) 
7. [Using Git Worktree to Master Git Workflow](https://www.hatica.io/blog/git-worktree/) 
8. [Git Worktrees in Use](https://medium.com/ngconf/git-worktrees-in-use-f4e516512feb) 

### Git - list files in repo:

1. [Q&A: List files in local Git repo?](https://stackoverflow.com/questions/8533202/list-files-in-local-git-repo) - good answer  
2. [How can I make git show a list of the files that are being tracked?](https://stackoverflow.com/questions/15606955/how-can-i-make-git-show-a-list-of-the-files-that-are-being-tracked) 1 good answer & 1 [incorrect answer](https://stackoverflow.com/a/15606998/22595851) 
3. [Difference between a working tree and a repository in Git?](https://stackoverflow.com/a/76797811/22595851) is interesting... 

### git restore-mtime: 
1. [A search](https://is.gd/1GCkfQ)

2. [The GitHub repo for `restore-mtime`](https://github.com/MestreLion/git-tools/blob/main/git-restore-mtime)

3. [Restoring Timestamps in Git Repositories](https://tilburgsciencehub.com/building-blocks/collaborate-and-share-your-work/use-github/git-tools/)

4. Install via `sudo apt install git-restore-mtime`; run command via `git restore-mtime`  

5. [Debian `man git-restore-mtime`](https://manpages.debian.org/bookworm/git-restore-mtime/git-restore-mtime.1.en.html) 

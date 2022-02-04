

## Use `git` on Raspberry Pi with GitHub

##### Here are some ideas and procedures for using `git` on a RPi to interface with GitHub repositories. We use the [`PiPyMailer` repo](https://github.com/seamusdemora/PiPyMailer) as an example. PiPyMailer is run only on a Raspberry Pi, and so it makes sense to source it there.

### I. Initial Conditions:


> * you have a github account - in this example: `https://github.com/seamusdemora`. 
> * you have installed the `git` package on your Raspberry Pi
> * you have your files (code, instructions, documentation, etc) stored on your *local* host under a single directory - in this example `~/PiPyMailer`. This is called your *repository*, or **repo**.
> * you have a working familiarity with the (extensive) system manuals provided with `git`; `man git` will list the various *man pages* supporting `git`.
> * you wish to maintain a copy of your local repo on a *remote* server; i.e. you are familiar with [the pros and cons of services](https://duckduckgo.com/?t=ffnt&q=advantages+of+github&ia=web) provided by GitHub and similar providers.

Before we begin, know that the [*semantics*](https://en.wikipedia.org/wiki/Semantics) of `git` and GitHub can be confusing. You should be prepared to spend time to master the vocabulary; frustration and failure are the alternatives.  

### II. Authenticate your RPi host

From August 13, 2021, GitHub no longer accepts account passwords when authenticating Git operations. There are [several methods](https://docs.github.com/en/authentication) that may be used for authentication, but for RPi - especially for *headless* RPi - SSH authentication may be the simplest. 

In this case, RPi is the client, and GitHub is the server. SSH key generation is done on the *client*, and the process is the same as setting up RPi as an SSH server - except that the roles are reversed. The procedure is straightforward; 4 steps from start to finish: 

##### 1. SSH Key Generation on the RPi:

NOTE: I opted for no passphrase

```
$ ssh-keygen -t ed25519 -C "seamusdemora@gmail.com"
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/pi/.ssh/id_ed25519):
...
```

##### 2. Start the SSH agent, and add the public key:

NOTE: `ssh-agent` started here for [non-interactive authentication](https://www.cyberciti.biz/faq/how-to-use-ssh-agent-for-authentication-on-linux-unix/) 

```bash
$ eval "$(ssh-agent -s)"
Agent pid 7697
$ ssh-add ~/.ssh/id_ed25519
Identity added: /home/pi/.ssh/id_ed25519 (seamusdemora@gmail.com)
```



##### 3. Add the public key to a GitHub account:

For this step, use both an SSH terminal window to the RPi from a Mac/Windows/Linux system, and a web browser connected to a GitHub account. In the SSH terminal window, show the public key on the CLI: 

```bash
$ cat ~/.ssh/id_ed25519.pub
ssh-ed25519 AAAABBBBCCCCDDDDEEEEFFFFGGGGHHHHIIIIJJJJKKKKLLLLMMMMNNNNOOOOPPPPQQQQ seamusdemora@gmail.com
```

Login to your GitHub account: 

* click **`Settings`** next to your profile picture, click **`SSH & GPG Keys`** in the list of items, click the **`New SSH Key`** button - which will bring up the interface for adding & naming the key
* select & copy the public key string generated above beginning with `ssh-ed25519`, paste it into the `key` text area, and assign a name for this key in the browser window
* click the **`Add SSH Key`** button to refresh the browser window

The public key generated above should now be listed in the browser window. [See here for the latest details from GitHub.](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account) 

##### 4. Finally, test your SSH authentication from your RPi command line:

```bash
$ ssh -T git@github.com
The authenticity of host 'github.com (140.82.113.3)' can't be established.
ECDSA key fingerprint is SHA256:p2QAMXNIC1TJYWeIOttrVc98/R1BUFWu3/LiyKgUfQM.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'github.com,140.82.113.3' (ECDSA) to the list of known hosts.
Hi seamus! You successfully authenticated, but GitHub does not provide shell access.
```

Check the fingerprint above against [GitHub's ECDSA key fingerprint](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints): 

>`SHA256:p2QAMXNIC1TJYWeIOttrVc98/R1BUFWu3/LiyKgUfQM` (ECDSA) 

In the event of issues with this recipe, please refer to the [latest version of the instructions for configuring SSH Authentication for Linux clients](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) to GitHub. 

#### **Authentication should now be complete, allowing the user to - for example - submit updates from the authenticated RPi to the GitHub repo*.

### III. Copy/clone your local repo to the remote

In other words, upload your local files to a named repository at GitHub

```bash
$ cd ~/PiPyMailer
$ git remote add origin https://github.com/seamusdemora/PiPyMailer
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
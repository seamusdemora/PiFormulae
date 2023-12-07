## Operate a Git-Server on Raspberry Pi 
Let's set up a git server on a Raspberry Pi. This server will be a *private* server for tracking code and files generated on your local network - at least that's the scope of ***my git server***. Yours may be different.

### Designation of and Access to the Git-Server
Nothing special need be done to designate an RPi as a Git-Server. As long as it's got `git` installed, virtually any RPi is fit for this purpose. Simply choose one that's accessible to other hosts (RPi git-clients) on your network as the clients will need to make SSH connections to the Git-Server. Assuming you want to use public-key authentication, you'll need to copy public keys from git-clients to the git-server using `ssh-copy-id`. 

### Set Up the Repositories 
We'll put all of our git repositories in a common folder; sub-folders will designate the names of the individual repositories. 

```bash
mkdir ./git-srv
```

Next, create the first repository under `./git-srv`: 

```bash
mkdir ./git-srv/etc-update-motd-d.git
cd ./git-srv/etc-update-motd-d.git
git init --bare 
```

### Connect a git-client to source code to the server

Now move to one of the git-clients - the one you've been coding `etc-update-motd-d`. 

```bash
ssh-copy-id pi@rpigitserver   # if necessary
cd ./scripts/motd
git init
git add <filenames>
git commit -m 'some-message'
git remote add origin ssh://pi@rpigitserver/home/pi/git-srv/etc-update-motd-d.git
git push -u ssh://pi@rpigitserver/home/pi/git-srv/etc-update-motd-d.git 
```

### Connect another git-client to clone the repo 

Move to another git-client (or do it from the same one - in a different location) 

```bash
cd
git clone pi@rpigitserver:/home/pi/git-srv/etc-update-motd-d.git
Cloning into 'etc-update-motd-d'...
remote: Enumerating objects: 3, done.
remote: Counting objects: 100% (3/3), done.
remote: Compressing objects: 100% (3/3), done.
remote: Total 3 (delta 0), reused 0 (delta 0), pack-reused 0
Receiving objects: 100% (3/3), done.

# creates/clones a copy of the repo in folder ~/etc-update-motd-d
```

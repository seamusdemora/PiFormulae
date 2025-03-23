## Adding and Removing Users

You may go for years (as I have) without needing to add (or remove) a user from your Raspberry Pi. But chances are good that at some point, you will need to do this - if only to have an unprivileged user for testing. 

**WARNING:** There is far too much [**incorrect** guidance](https://www.tecmint.com/add-users-in-linux/) that may place highly in your search results. In the best case, this poor guidance will waste your time. At worst, it creates a mess that may get out of hand if not dealt with quickly. Here's the **correct** way to add a user for **RPi OS**, but note that this may vary with other distributions:

### `adduser`, or `useradd`... What's the difference?

1. Know the difference between `adduser` and `useradd`! 
2. Because **RPi OS** is a *derivative* of **Debian**, know that for **routine use**,  **`adduser`** is a *one-stop* command solution. It adds the user, prompts you to create a password, and creates a *ready-to-use* **`/home`** directory for the new user. ***Forget about `useradd`*** unless you need something *non-routine*; e.g. no `/home` directory, no login password, etc. Here's a preview in which we add a user named **stooge**: 

   ```bash
   $ sudo adduser stooge
   Adding user `stooge' ...
   Adding new group `stooge' (1001) ...
   Adding new user `stooge' (1001) with group `stooge' ...
   Creating home directory `/home/stooge' ...
   Copying files from `/etc/skel' ...
   New password:********         # <-- ENTER PASSWORD
   Retype new password:********  # <-- ENTER PASSWORD (CONFIRM)
   passwd: password updated successfully
   Changing the user information for stooge
   Enter the new value, or press ENTER for the default   # <-- ALL VALUES BELOW ARE OPTIONAL
   	Full Name []: Moe
   	Room Number []:
   	Work Phone []:
   	Home Phone []:
   	Other []:
   Is the information correct? [Y/n] Y
   ```

3. At this point, user `stooge` has been created, along with a matching group - also called `stooge`. User `stooge` can log in, has a home directory and other items a user needs to begin using the system. He can also login via SSH. 

### `deluser`, or `userdel`... What's the difference?  

As before, owing to its **Debian** heritage, **`deluser`** is the *go-to* command for **routine use** in removing a user account. Note that there may be much more work needed to remove a user account than there was creating it - but that depends on the circumstances. If you want a walk-through of the more comprehensive task of removing a user from your system, see the References below. For this recipe, only the actual user account deletion with **`deluser`** is covered, but if you take the time to review **`man deluser`** you'll see its options cover many tasks associated with account deletion. 

We'll use the hapless user `stooge` as an example again. Since user `stooge` wasn't a particularly productive user, it was decided not to backup or save any of his files: 

```bash
$ sudo deluser --remove-all-files stooge 
Looking for files to backup/remove ...
/usr/sbin/deluser: Cannot handle special file /dev/media1
... a long list of files `deluser` can't handle (see Ref. 3 below), and finally:
Removing files ...
Removing user `stooge' ...
Warning: group `stooge' has no more members.
Done.
```

All of the **noise** in the output - the `Cannot handle...` warnings are [apparently due to a harmless but annoying bug in `deluser`.](https://askubuntu.com/questions/627646/strange-output-when-deleting-user) 

### group membership can be expanded

1. By default, a "regular" user belongs only to the default group created when the user was added to the system. This may be checked as follows: 

   ```bash
   stooge@raspberrypi4b:~$ groups
   stooge
   ```

   Or, as another user (user `pi` for example): 

   ```bash
   pi@raspberrypi4b:~$ groups stooge
   stooge : stooge
   pi@raspberrypi4b:~$
   ```

2. A list of **all** groups in the system is in `/etc/group`. It may be useful to add the new user to additional groups (e.g. group `users`). This must be done in a particular way to **add** group memberships, otherwise you may inadvertently **replace** one group membership for another. This task will need to be done by a *privileged* user (`pi` in this case): 

   ```bash
   pi@raspberrypi3b:~ $ sudo usermod -a -G <groupname> <username>
   
   # to add user `stooge` to group `users`:
   
   pi@raspberrypi3b:~ $ sudo usermod -a -G users stooge
   ```

   See `man usermod` for details

   Another way to accomplish this (in Debian at least) is with the `adduser` command: 
   
   ```bash
   pi@raspberrypi3b:~ $ sudo adduser stooge users
   Adding user `stooge' to group `users' ...
   Adding user stooge to group users
   Done.
   ```

   **Know this:**
   
   > *Group membership additions **are not instantaneous**. Group membership of a user **only takes effect on the next login**.* 



### strange things re group `sudo` 

Sometimes it seems there are *other factors* at work. [This Q&A is an example](https://raspberrypi.stackexchange.com/a/138020/83790) of that; the OP seemed to have removed his user from group `sudo` properly, yet his user continued to have access to `sudo`?!  There are some unanswered questions, but as my hero said once, [*"new shit has come to light"*](https://www.youtube.com/watch?v=gbIv7W7rhx4). Specifically in the form of using commands `vigr` & `vigr -s` to edit the `/etc/group` and `/etc/gshadow` files, and`gpasswd` and other possibilities covered in [this U&L SE Q&A](https://unix.stackexchange.com/questions/29570/how-do-i-remove-a-user-from-a-group).



---

## References:

1. [The Debian Wiki: SystemGroups](https://wiki.debian.org/SystemGroups) 
2. [How to Delete a User on Linux (and Remove Every Trace)](https://www.howtogeek.com/656549/how-to-delete-a-user-on-linux-and-remove-every-trace/) - a How-To-Geek article 
3. [Q&A: Strange output when deleting user](https://askubuntu.com/questions/627646/strange-output-when-deleting-user) - indicates a harmless but annoying bug is responsible 
4. [How do I remove a user from a group?](https://unix.stackexchange.com/questions/29570/how-do-i-remove-a-user-from-a-group) - some alternatives
5. [Remove sudo privileges from a user (without deleting the user)](https://askubuntu.com/questions/335987/remove-sudo-privileges-from-a-user-without-deleting-the-user) - seems the accepted answer is wrong??
6. [Sudo user not in sudo group?](https://askubuntu.com/questions/828789/sudo-user-not-in-sudo-group) - is this related to the *mystery*?
7. [Sudo still works despite removing my user from group](https://raspberrypi.stackexchange.com/questions/138013/sudo-still-works-despite-removing-my-user-from-group) - THE mystery!

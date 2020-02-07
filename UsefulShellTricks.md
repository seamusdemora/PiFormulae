### Useful shell tricks: 

[1. Reload bash's .profile without restarting shell:](#1-reload-bash-s-profile-without-restarting-shell-)

[2. Clear the contents of a file without deleting the file:](#2-clear-the-contents-of-a-file-without-deleting-the-file-)

[3. List all directories (not files, just directories); [ref Q&A](https://unix.stackexchange.com/questions/518777/shell-script-to-test-ls-output-for-directories)](#3-list-all-directories--not-files--just-directories----ref-q-a--https---unixstackexchangecom-questions-518777-shell-script-to-test-ls-output-for-directories-)

[4. Sequential shell command execution:](#4-sequential-shell-command-execution-)

[REFERENCES:](#references-)

#### 1. Reload bash's .profile without restarting shell:


```
    $ source ~/.profile
    $ . ~/.profile
```

>  If something is **removed** from `~/.profile`, that change will **not** take effect after `. ~/.profile` reload. For example, add a function to `~/.profile`: `function externalip () { curl http://ipecho.net/plain; echo; }`, then `~/.profile` - IT WORKS. Now remove that function from `~/.profile`, then `. ~/.profile` again. The function is still available - only restarting (log out & in) will remove it. 

#### 2. Clear the contents of a file without deleting the file:

```bash
$ > somefile.xyz
$ truncate -s 0 test.txt
```

#### 3. List all directories (not files, just directories); [ref Q&A](https://unix.stackexchange.com/questions/518777/shell-script-to-test-ls-output-for-directories) 

```bash
$ find . -type d   # list all dirs in pwd (.)
```

#### 4. Sequential shell command execution: 
Sometimes we want to execute a series of commands, but only if all previous commands execute successfully. In this case, we should use **`&&`** to join the commands in the sequence: 

```bash
cd /home/auser && cp /utilities/backup_home.sh ./ && chown auser ./backup_home.sh
```
At other times we want to execute a series of commands regardless of whether or not previous commands executed successfully. In that case, we should use **`;`** to join the commands in the sequence:

```bash
cp /home/pi/README /home/auser; rsync -av /home/auser /mnt/BackupDrv/auser_backup/
```






<hr>

### REFERENCES:

1. [commandlinefu.com - a searchable archive of command line wisdom](https://www.commandlinefu.com/commands/browse) 
2. Passing arguments to bash:
   - [How to Pass Arguments to a Bash Script](https://www.lifewire.com/pass-arguments-to-bash-script-2200571) (An article on Lifewire.com) 
   - [Parsing bash script options with `getopts`](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/) (A short article by Kevin Sookocheff) 
   - [A small `getopts` tutorial](https://wiki.bash-hackers.org/howto/getopts_tutorial) (p/o the bash hackers wiki) 
   - [Q&A on StackOverflow: ](https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash) (How to get arguments with flags in `bash`)
3. [Deleting all files in a folder, but don't delete folders](https://superuser.com/questions/52520/delete-all-files-in-a-folder-without-deleting-directories-os-x) 
4. [Removing all files in a directory](https://unix.stackexchange.com/questions/12593/how-to-remove-all-the-files-in-a-directory) 
5. [Cool Unix and Linux CLI Commands - *nearly 10,000 items!*](https://www.scribd.com/doc/232825009/Cool-Unix-CLI) 
6. [Q&A re use of the `shebang` line](https://unix.stackexchange.com/questions/517370/shebang-or-not-shebang) 
7. [Q&A re clever use of `xargs` ](https://unix.stackexchange.com/questions/518186/usage-of-touch-with-pipeline)  
8. [Exit status of last command using PROMPT_COMMAND](https://unix.stackexchange.com/questions/519680/exit-status-of-last-command-using-prompt-command) (An interesting thing worth further study) 
9. [Q&A re executing multiple shell commands in one line]()
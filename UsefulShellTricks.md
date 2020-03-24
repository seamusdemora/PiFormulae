## Useful shell tricks:

#### Table of contents

* [Reload bash's .profile without restarting shell:](#reload-bashs-profile-without-restarting-shell)
* [Clear the contents of a file without deleting the file:](#clear-the-contents-of-a-file-without-deleting-the-file)
* [List all directories - not files, just directories:](#list-all-directories---not-files-just-directories)
* [Sequential shell command execution:](#sequential-shell-command-execution)
* [Get a date-time stamp for a log:](#get-a-date-time-stamp-for-a-log)
* [String manipulation with bash:](#string-manipulation-with-bash)
* [REFERENCES:](#references)



### Reload bash's .profile without restarting shell:


```
    $ source ~/.profile
    $ . ~/.profile
```

>  If something is **removed** from `~/.profile`, that change will **not** take effect after `. ~/.profile` reload. For example, add a function to `~/.profile`: `function externalip () { curl http://ipecho.net/plain; echo; }`, then `~/.profile` - IT WORKS. Now remove that function from `~/.profile`, then `. ~/.profile` again. The function is still available - only restarting (log out & in) will remove it. 

### Clear the contents of a file without deleting the file:

```bash
$ > somefile.xyz					# works in bash
# -OR-
% : > $LOGFILE						# works in zsh
# -OR-
$ truncate -s 0 test.txt	# any system w/ truncate
```

### List all directories - not files, just directories:

```bash
$ find . -type d   # list all dirs in pwd (.)
```

### Sequential shell command execution:

Sometimes we want to execute a series of commands, but only if all previous commands execute successfully. In this case, we should use **`&&`** to join the commands in the sequence: 

```bash
cd /home/auser && cp /utilities/backup_home.sh ./ && chown auser ./backup_home.sh
```
At other times we want to execute a series of commands regardless of whether or not previous commands executed successfully. In that case, we should use **`;`** to join the commands in the sequence:

```bash
cp /home/pi/README /home/auser; rsync -av /home/auser /mnt/BackupDrv/auser_backup/
```

### Get a date-time stamp for a log:

It's often useful to insert a date-time stamp in a log file, inserted in a string, etc. Easily done w/ `date`: 

```bash
echo $(date) >> mydatalog.txt   # using `echo` inserts a newline after the date & time 
# log entry will be in this format: Tue Mar 24 04:28:31 CDT 2020 + newline
echo $(date -u)                 # `-u` gives UTC 
```

If you need more control over the format, use `printf` w/ `date`:

```bash
printf '%s' "$(date)" >> mydatalog.txt	# no newline is output
# log entry will be in this format: Tue Mar 24 04:28:31 CDT 2020 
printf '%s\n' "$(date)" >> mydatalog.txt	# newline is output
```

There are numerous options with the `date` command. Check `man date`, or peruse this [*Lifewire* article 'How to Display the Date and Time Using Linux Command Line'](https://www.lifewire.com/display-date-time-using-linux-command-line-4032698). 

### String manipulation with bash:

It's often useful to manipulate string variables in bash. These websites have some examples: [website 1](https://www.tutorialkart.com/bash-shell-scripting/bash-string-manipulation-examples/); [website 2](https://www.thegeekstuff.com/2010/07/bash-string-manipulation/). For example:

```bash
$ str1="for everything there is a "
$ str2="reason"
$ str3="season"
$ echo $str1$str2; echo $str1$str3
for everything there is a reason
for everything there is a season
```





<hr>

### REFERENCES:

1. [commandlinefu.com - a searchable archive of command line wisdom](https://www.commandlinefu.com/commands/browse) 
2. Passing arguments to bash:
   - [*How to Pass Arguments to a Bash Script*](https://www.lifewire.com/pass-arguments-to-bash-script-2200571) - an article on Lifewire.com. 
   - [*Parsing bash script options with `getopts`*](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/) - a short article by Kevin Sookocheff. 
   - [A small `getopts` tutorial](https://wiki.bash-hackers.org/howto/getopts_tutorial) (p/o the bash hackers wiki) 
   - [Q&A on StackOverflow: ](https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash) (How to get arguments with flags in `bash`)
3. [Deleting all files in a folder, but don't delete folders](https://superuser.com/questions/52520/delete-all-files-in-a-folder-without-deleting-directories-os-x) 
4. [Removing all files in a directory](https://unix.stackexchange.com/questions/12593/how-to-remove-all-the-files-in-a-directory) 
5. [*Cool Unix and Linux CLI Commands* - nearly 10,000 items!](https://www.scribd.com/doc/232825009/Cool-Unix-CLI) 
6. [Q&A re use of the `shebang` line](https://unix.stackexchange.com/questions/517370/shebang-or-not-shebang) 
7. [Q&A re clever use of `xargs` ](https://unix.stackexchange.com/questions/518186/usage-of-touch-with-pipeline)  
8. [Exit status of last command using PROMPT_COMMAND](https://unix.stackexchange.com/questions/519680/exit-status-of-last-command-using-prompt-command) (An interesting thing worth further study) 
9. [Q&A re executing multiple shell commands in one line](https://stackoverflow.com/questions/13077241/execute-combine-multiple-linux-commands-in-one-line) 
10. [*Lifewire* article explains *How to Display the Date and Time Using Linux Command Line*](https://www.lifewire.com/display-date-time-using-linux-command-line-4032698) 
11. [*The Geek Stuff*: Bash String Manipulation Examples – Length, Substring, Find and Replace](https://www.thegeekstuff.com/2010/07/bash-string-manipulation/) 
12. [*The Tutorial Kart*: bash string manipulation examples](https://www.tutorialkart.com/bash-shell-scripting/bash-string-manipulation-examples/) 
13. [*How to Create & Use `bash` Scripts* - a very good tutorial by Tania Rascia](https://www.taniarascia.com/how-to-create-and-use-bash-scripts/) 
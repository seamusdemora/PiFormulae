## Useful shell tricks:

#### Table of contents

* [Reload bash's .profile without restarting shell:](#reload-bashs-profile-without-restarting-shell)
* [Clear the contents of a file without deleting the file:](#clear-the-contents-of-a-file-without-deleting-the-file)
* [List all directories - not files, just directories:](#list-all-directories---not-files-just-directories)
* [Sequential shell command execution:](#sequential-shell-command-execution)
* [Get a date-time stamp for a log:](#get-a-date-time-stamp-for-a-log)
* [String manipulation with bash:](#string-manipulation-with-bash)
* [Testing things in bash:](#testing-things-in-bash)
* [The Shell Parameters of bash](#the-shell-parameters-of-bash)
* [Some Options with `grep`](#some-options-with-grep) 
* [Know the Difference Between `NULL` and an Empty String](#know-the-difference-between-null-and-an-empty-string) 
* [How do I see my *environment*?](#how-do-i-see-my-environment) 
* [What do file and directory permissions mean?](#what-do-file-and-directory-permissions-mean) 
* [Using `which` to find commands](#using-which-to-find-commands) - *accurately!* 
* [Using your shell command history](#using-your-shell-command-history) 
* [Access compressed log files easily](#access-compressed-log-files-easily) 
* [Filename expansion; a.k.a. "globbing"](#filename-expansion-a-k-a-globbing)
* [REFERENCES:](#references)



### Refresh `zsh` or `bash`  configuration without restarting shell:

There are two user-owned files that control many aspects of the `bash` shell's behavior - uh, *interactive shells, that is*: `~/.profile` & `~/.bashrc`. Likewise for `zsh`, the `~/.zprofile` & `~/.zshrc`. There will be occasions when changes to these files will need to be made in the current session - without exiting one shell session, and starting a new one. Examples of such changes are changes to the `PATH`, or addition of an `alias`. 


```zsh
$ source ~/.profile				# use this for bash 
$ source ~/.bashrc        #        "
% source ~/.zprofile			# use this for zsh 
% source ~/.zshrc         #        " 
# OR ALTERNATIVELY: 
$ . ~/.profile						# use for bash + see Notes below 
$ . ~/.bashrc
% . ~/.zprofile						# use for zsh + see Notes below 
% . ~/.zshrc
```

>> **Note 1:** The [dot operator](https://ss64.com/bash/source.html); `.` is a synonym for `source`. Also, it's POSIX-compliant (`source` is not).

>> **Note 2:** Additions and removals from `~/.bashrc` behave differently: If something is **removed** from `~/.bashrc`, this change will **not** take effect after *sourcing* `~/.bashrc` (i.e.  `. ~/.bashrc`).  
>
>> For example: Add a function to `~/.bashrc`: `function externalip () { curl http://ipecho.net/plain; echo; }`. Now *source* it with `. ~/.profile`. You should see that the function now works in this session. Now remove the function, and then *source* it again using `. ~/.profile`. The function is still available - only restarting (log out & in), or starting a new shell session will remove it. 

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

> > Note In this context the *'dot'* `.` means the `pwd` - not the [dot operator](https://ss64.com/bash/source.html) as in the [above example](#reload-bashs-profile-without-restarting-shell). 

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

There are numerous options with the `date` command. Check `man date`, or peruse this [*Lifewire* article 'How to Display the Date and Time Using Linux Command Line'](https://www.lifewire.com/display-date-time-using-linux-command-line-4032698) - it lists *all* of the format options for displaying the output of `date`. 

### String manipulation with bash:

It's often useful to manipulate string variables in bash. These websites have some examples: [website 1](https://www.tutorialkart.com/bash-shell-scripting/bash-string-manipulation-examples/); [website 2](https://www.thegeekstuff.com/2010/07/bash-string-manipulation/). The [Wooledge Wiki](https://mywiki.wooledge.org/BashFAQ/100#How_do_I_do_string_manipulations_in_bash.3F) is a bit more advanced, and a trove of string manipulation methods available in `bash`. [Section 10.1 of the Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/string-manipulation.html) is another comprehensive source of information on string manipulation. For example:

```bash
$ str1="for everything there is a "
$ str2="reason"
$ str3="season"
$ echo $str1$str2; echo $str1$str3
for everything there is a reason
for everything there is a season
```

### Testing things in bash:

Testing the equality of two strings is a common task in shell scripts. You'll need to watch your step as there are numerous ways to screw this up! Consider a few examples: 

```bash
$ string1="Anchors aweigh"
$ string2="Anchors Aweigh"
$ if [[ $string1 == "Anchors aweigh" ]]; then echo "equal"; else echo "not equal"; fi
equal
$ if [ "$string1" == "Anchors aweigh" ]; then echo "equal"; else echo "not equal"; fi
equal
$ if [ "$string1" = "Anchors aweigh" ]; then echo "equal"; else echo "not equal"; fi
equal

# but if you forget something; e.g.

$ if [ $string1 == "Anchors aweigh" ]; then echo "equal"; else echo "not equal"; fi
-bash: [: too many arguments
not equal
# BOOM! no quotes "" - you crash and burn :) 

$ [ "$string1" = "Anchors aweigh" ] && echo equal || echo not-equal
equal 
$ [ "$string1" -eq "Anchors aweigh" ] && echo equal || echo not-equal
-bash: [: Anchors aweigh: integer expression expected
not-equal
# BOOM! `-eq` is for numbers, not strings - you crash and burn :) 

$ [ "$string1" = "$string2" ] && echo equal || echo not-equal
not-equal 
$ [[ $string1 = $string2 ]] && echo equal || echo not-equal
not-equal 
$ [[ ${string1,,} = ${string2,,} ]] && echo equal || echo not-equal
equal
# NOTE! this case-conversion only works in bash v4 & above
 
```

So much *arcanery* here, and limited *portability*. Here are a list of references peculiar to this one small problem: [SO Q&A 1](https://stackoverflow.com/questions/3265803/bash-string-equality), [SO Q&A 2](https://stackoverflow.com/questions/2600281/what-is-the-difference-between-operator-and-in-bash/2601583#2601583), [*Linuxize*](https://linuxize.com/post/how-to-compare-strings-in-bash/), [UL Q&A 1](https://unix.stackexchange.com/questions/306111/what-is-the-difference-between-the-bash-operators-vs-vs-vs), [SO Q&A 3](https://stackoverflow.com/questions/20449543/shell-equality-operators-eq), [SO Q&A 4](https://stackoverflow.com/questions/1728683/case-insensitive-comparison-of-strings-in-shell-script). AFAIK there's no *unabridged* reference for string manipulation in `bash`, but section [**'10.1. Manipulating Strings'** of the **'Advanced Bash-Scripting Guide'**](https://tldp.org/LDP/abs/html/string-manipulation.html) comes reasonably close. And the [Other Comparison Operators](https://tldp.org/LDP/abs/html/comparison-ops.html) section from [Chap 7 of Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/tests.html) is not to be missed :)

**What about *null strings*?**

At the risk of [going overboard](https://idioms.thefreedictionary.com/go+overboard), we'll cover testing for ***null strings*** also. Know these two characters have a special meaning within a test construct for strings: 

>-z		string is *null*, that is, has zero length. 
>
>-n		string is not *null.*  

Consider the possibility that a shell variable has not been defined; for example let's imagine a variable named `CaptainsOrders` - a variable to which we, perhaps, failed to assign a value through oversight. Now let's further imagine that `CaptainsOrders` is to be tested in an `if-then-else` construct. If we were careless, we might create that construct as follows:

```bash
if [ "$CaptainsOrders" = "Anchors aweigh" ]
then
   echo "We sail at dawn tomorrow"
else
   echo "We remain in port"
fi  
```

That might be unfortunate - that might get you [*Court-martialed*](), and it certainly would cause your superiors to question your competence as a `bash` programmer! But having been enlightened by this tutorial, you would be prepared for a someone's failure to enter a value for `CaptainsOrders`: 

```bash
$ [ -z "$CaptainsOrders" ] && echo 'Sound the alarm!!!' || echo "Proceed as planned"
Sound the alarm!!!
```

You might also learn something of the difference between *single quotes* `''`, and *double quotes* `""`.

### The Shell Parameters of `bash`

`bash` has two types of [*paramaters*](https://www.gnu.org/software/bash/manual/bash.html#Shell-Parameters): positional parameters and special parameters. They are the *odd-looking* variables you may have seen in scripts, such as: `$0`, `$1`, `$@`, `$?`, etc.  But they come in very handy, and you should learn to use them. The [Bash Reference Manual](https://www.gnu.org/savannah-checkouts/gnu/bash/manual/bash.html) isn't as informative as it could be, but there are better explanations available that include examples: [positional parameters](https://www.thegeekstuff.com/2010/05/bash-shell-positional-parameters/), [special parameters](https://www.thegeekstuff.com/2010/05/bash-shell-special-parameters/). 

### Some Options with `grep`

`grep` has many variations which makes it useful in many situations. We can't cover them all here (not even close), but just to whet the appetite: 

* `grep` can return TRUE/FALSE: `grep -q PATTERN [FILE]`; `0` if TRUE, `non-zero` if FALSE
* `grep` can return the matching object only: `grep -o PATTERN [FILE]` instead of the entire line
* you can `pipe` the output of a command to `grep`:  `cat somefile.txt | grep 'Christmas' 
* `grep` can process a [`Here String`](https://linux.die.net/abs-guide/x15683.html):  `grep PATTERN <<< "$VALUE"`, where  `$VALUE` is expanded & fed to `grep`. 
* `grep`*'s* `PATTERN` may be a literal string, or a regular expression; e.g. to find **IPv4 ADDRESSES** in a file: 

```bash
    sudo grep -E -o "([0-9]{1,3}[\.]){3}[0-9]{1,3}" /etc/network/interfaces
```

>*NOTE: This is not an exact match for an IP address, only an approximation, and may occasionally return something other than an IP address. An [exact match](https://www.regextester.com/22) is available here.* 

### Know the Difference Between `NULL` and an Empty String

`NULL` is nothing, an empty string is still a string, but it has zero length. You may need to experiment with that one to understand the difference. Here are some [examples from nixCraft](https://www.cyberciti.biz/faq/bash-shell-find-out-if-a-variable-has-null-value-or-not/).

### How do I see my *environment*?

```zsh
% printenv | less
```

### What do file and directory permissions mean?

>**File permissions:**   
>
>r = read the contents of the file  
>w = modify the file  
>x = run the file as an executable  

> **Directory permissions:**  
>
> r = list the contents of the directory, but not 'ls' into it  
> w = delete or add a file in the directory  
> x = move into the directory  

### Using `which` to find commands

For `zsh` users: You've installed a package - but where is it? The `which` command can help, but there are some things you *need to know*: 

* `which` relies on a *cache* to provide its results; this *cache* may not be *timely* or current.
* To *refresh* the *cache*, run `rehash` or `hash -r`.
* There are *subtle differences* depending on your shell; `which` is a *built-in* for `zsh`, and a *discrete command* in `bash` 

In `bash`, `which` is a *stand-alone* command instead of a *builtin*.  Consequently `hash -r` is not needed to get timely results from`which`. 

### Using your shell command history

For those of us who don't have a [photographic memory](https://en.wikipedia.org/wiki/Eidetic_memory), our shell **command history** may be very useful. Knowing how command history works, and how to configure its operation, allows us to use it with greater effect. While some aspects of the command history are *shell-dependent*, they have more in common than they have differences. An [overview of the command history](https://github.com/seamusdemora/seamusdemora.github.io/blob/master/CommandHistoryIntro-zsh.md) - from a `zsh` perspective - is provided in another section of this repo. The semantics for configuring the `bash` command history options are covered in some of the [REFERENCES](#references), and here in [this section of the `bash` manual](https://www.gnu.org/software/bash/manual/html_node/Using-History-Interactively.html). 

I had every intention of including a set of *adjustments* to the default behavior of the `bash` command history. But then I read [T. Laurenson's blog post on `bash` history](https://www.thomaslaurenson.com/blog/2018/07/02/better-bash-history/), and tried his [command history configuration script](https://gist.github.com/thomaslaurenson/ae72d4b4ec683f5a1850d42338a9a4ab); I'm still evaluating, but this is **quite** good. And I love that it's a script - it can be easily applied to all my hosts.

### Access compressed log files easily

If you ever find yourself rummaging around in `/var/log`... Maybe you're *'looking for something, but don't know exactly what'*.  In the `/var/log` file listing, you'll see a sequence of `syslog` files (and several others) arranged something like this: 

```
-rw-r----- 1 root        adm    3919 Jan 17 01:38 syslog
-rw-r----- 1 root        adm  176587 Jan 17 00:00 syslog.1
-rw-r----- 1 root        adm   11465 Jan 16 00:00 syslog.2.gz
-rw-r----- 1 root        adm   19312 Jan 15 00:00 syslog.3.gz
-rw-r----- 1 root        adm    4893 Jan 14 00:00 syslog.4.gz
-rw-r----- 1 root        adm    5398 Jan 13 00:00 syslog.5.gz
-rw-r----- 1 root        adm    4472 Jan 12 00:00 syslog.6.gz
-rw-r----- 1 root        adm    4521 Jan 11 00:00 syslog.7.gz
```

The `.gz` files are compressed with `gzip` of course - but **how to view the contents?**  There are some tools to make that job a little easier.  `zgrep` and `zless` are the most useful in my experience, but `zdiff` and `zcat` are also there if you need them. Note that these "`z`" utilities will also handle *non-compressed* files, but don't be tempted to use them as a substitute since not all options are available in the "`z`" version. For example, `grep -R` doesn't translate to `zgrep`. 

As a potentially useful example, consider listing all of the `Under-voltage` warnings in `/var/log/syslog*`. Note that the `syslog*` *filename expansion / globbing* will get **all** the syslog files - compressed or uncompressed. Since there may be quite a few, piping them to the `less` pager won't clutter your screen: 

```bash
$ zgrep voltage /var/log/syslog* | less
```

If you want daily totals of `Under-voltage` events, use the `-c` option: 

```bash
$ zgrep -c voltage /var/log/syslog*
/var/log/syslog:0
/var/log/syslog.1:8
/var/log/syslog.2.gz:3
/var/log/syslog.3.gz:5
/var/log/syslog.4.gz:4
/var/log/syslog.5.gz:10
/var/log/syslog.6.gz:0
/var/log/syslog.7.gz:0
```

Or weekly totals of  `Under-voltage` events: 

```bash
$ zgrep -o voltage /var/log/syslog* | wc -l
30
```

Still more is possible if you care to pipe these results to `awk`. 

### Filename expansion; a.k.a. "globbing"

The astute reader might have noticed the syntax from above:

`$ zgrep -c voltage /var/log/syslog*`

What does that *asterisk* (`*`) mean; what does it do? 

It's one of the more powerful [idioms](https://en.wikipedia.org/wiki/Programming_idiom) available in `bash`, and extremely useful when working with files. Consider the alternatives to instructing `bash` to loop through all the files with `syslog` in their filename. Read more about its possibilities, and study the examples in the [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/globbingref.html). 



<hr>


## REFERENCES:

### The `~/.bashrc` & `~/.bash_profile` files

1. [Difference .bashrc vs .bash_profile (which one to use?)](https://www.golinuxcloud.com/bashrc-vs-bash-profile/); good explanation & good overview! 
2. [Q&A: What is the purpose of .bashrc and how does it work?](https://unix.stackexchange.com/questions/129143/what-is-the-purpose-of-bashrc-and-how-does-it-work) 
3. [Q&A: What is the .bashrc file?](https://superuser.com/questions/49289/what-is-the-bashrc-file) 
4. [What is Linux bashrc and How to Use It](https://www.routerhosting.com/knowledge-base/what-is-linux-bashrc-and-how-to-use-it-full-guide/)   
5. [Q&A: How to reload .bash_profile from the command line?](https://stackoverflow.com/questions/4608187/how-to-reload-bash-profile-from-the-command-line) 

### Functions and aliases 

1. [Q&A Setting up aliases in zsh](https://askubuntu.com/questions/31216/setting-up-aliases-in-zsh) and more. 
2. [How to Create and Remove alias in Linux](https://linoxide.com/linux-how-to/create-remove-alias-linux/) 
3. [The alias Command](http://www.linfo.org/alias.html) 
4. [Bash aliases you can’t live without](https://opensource.com/article/19/7/bash-aliases) 
5. [How to Create Aliases and Shell Functions on Linux](https://www.howtogeek.com/439736/how-to-create-aliases-and-shell-functions-on-linux/); aliases, functions & where they're saved. 
6. [Unix/Linux Shell Functions](https://www.tutorialspoint.com/unix/unix-shell-functions.htm) explained at ***tutorialspoint***. 
7. [Q&A: Alias quotation and escapes](https://raspberrypi.stackexchange.com/questions/111889/alias-quotation-and-escapes); aliases and functions - an example  

### Scripting with `bash`  

1. [Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/index.html) - comprehensive  
2. [Command Line Arguments in Bash](https://tecadmin.net/tutorial/bash-scripting/bash-command-arguments/) - a good, brief overview. 
3. [*How to Create & Use `bash` Scripts* - a very good tutorial by Tania Rascia](https://www.taniarascia.com/how-to-create-and-use-bash-scripts/)  
4. Passing arguments to bash:
   - [*How to Pass Arguments to a Bash Script*](https://www.lifewire.com/pass-arguments-to-bash-script-2200571) - an article on Lifewire.com. 
   - [*Parsing bash script options with `getopts`*](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/) - a short article by Kevin Sookocheff. 
   - [A small `getopts` tutorial](https://wiki.bash-hackers.org/howto/getopts_tutorial) (p/o the bash hackers wiki) 
   - [Q&A on StackOverflow: ](https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash) (How to get arguments with flags in `bash`)
5. [Q&A re use of the `shebang` line](https://unix.stackexchange.com/questions/517370/shebang-or-not-shebang)  
6. [Bash Infinite Loop Examples](https://www.cyberciti.biz/faq/bash-infinite-loop/) 
7. [Functions in bash scripting](https://ryanstutorials.net/bash-scripting-tutorial/bash-functions.php) from Ryan's Tutorials - a good and thorough overview w/ examples. 
8. [Q&A: Shell scripting: -z and -n options with if](https://unix.stackexchange.com/questions/109625/shell-scripting-z-and-n-options-with-if)  - recognizing *null strings* 
9. [Q&A re executing multiple shell commands in one line](https://stackoverflow.com/questions/13077241/execute-combine-multiple-linux-commands-in-one-line); sometimes you don't need a *script* **!** 
10. [*"Filename expansion"*; a.k.a. ***"globbing"***](https://tldp.org/LDP/abs/html/globbingref.html); what is it, and why should I care?  
11. [A GitHub repo of globbing](https://github.com/begin/globbing); odd choice for a repo methinks, but contains some useful info. 
12. [Globbing and Regex: So Similar, So Different](https://www.linuxjournal.com/content/globbing-and-regex-so-similar-so-different); some of the *fine points* discussed here.

### General guides to `bash`

1. [GNU's `bash` Reference Manual](https://www.gnu.org/software/bash/manual/bash.html) 
2. [Wooledge's Bash Guide](http://mywiki.wooledge.org/BashGuide); can be puzzling to navigate, getting a bit dated, but still useful 
3. [How to find all the `bash` How-Tos on linux.com](https://www.linux.com/?s=bash) ; this really shouldn't be necessary!  
4. [commandlinefu.com - a searchable archive of command line wisdom](https://www.commandlinefu.com/commands/browse)  
5.  [*Cool Unix and Linux CLI Commands* - nearly 10,000 items!](https://www.scribd.com/doc/232825009/Cool-Unix-CLI) 

### Working with strings in `bash` 

1. [*The Geek Stuff*: Bash String Manipulation Examples – Length, Substring, Find and Replace](https://www.thegeekstuff.com/2010/07/bash-string-manipulation/) 
2. [*The Tutorial Kart*: bash string manipulation examples](https://www.tutorialkart.com/bash-shell-scripting/bash-string-manipulation-examples/) 
3. [Bash – Check If Two Strings are Equal](https://tecadmin.net/tutorial/bash/examples/check-if-two-strings-are-equal/) - learn to compare strings in a shell script by example. 
4. [Q&A: Replacing some characters in a string with another character](https://stackoverflow.com/questions/2871181/replacing-some-characters-in-a-string-with-another-character); using `tr` and [`bash` built-ins](http://tldp.org/LDP/abs/html/string-manipulation.html).
5. [Q&A: remove particular characters from a variable using bash](https://unix.stackexchange.com/questions/104881/remove-particular-characters-from-a-variable-using-bash); a variety of methods!
6. [Advanced Bash-Scripting Guide: Chapter 10.1. Manipulating Strings](http://tldp.org/LDP/abs/html/string-manipulation.html); details! 
7. [The Wooledge Wiki is a trove of string manipulation methods for `bash`](https://mywiki.wooledge.org/BashFAQ/100#How_do_I_do_string_manipulations_in_bash.3F).

### Using `grep` to find things

1. [Q&A Can grep return true/false or are there alternative methods?](https://unix.stackexchange.com/questions/48535/can-grep-return-true-false-or-are-there-alternative-methods).
2. [Q&A grep on a variable](https://unix.stackexchange.com/questions/163810/grep-on-a-variable).
3. [Grep OR – Grep AND – Grep NOT – Match Multiple Patterns](https://www.shellhacks.com/grep-or-grep-and-grep-not-match-multiple-patterns/); `grep -E "PATTERN1|PATTERN2" file`  

### Using `awk` for heavy lifting

1. [Learn AWK](https://www.tutorialspoint.com/awk/index.htm) - a comprehensive tutorial from *tutorialspoint.com*. 
2. [Q&A: Difference between gawk & awk](https://unix.stackexchange.com/questions/29576/difference-between-gawk-vs-awk); several *"flavors"* - choose your weapon! 

### Operators & special characters

1. [Q&A: What are the shell's control and redirection operators?](https://unix.stackexchange.com/questions/159513/what-are-the-shells-control-and-redirection-operators) 
2. [Redirect stderr to stdout, and redirect stderr to a file](https://www.cyberciti.biz/faq/redirecting-stderr-to-stdout/) - from nixCraft
3. [15 Special Characters You Need to Know for Bash](https://www.howtogeek.com/439199/15-special-characters-you-need-to-know-for-bash/) - a collection of useful bits and bobs from HTG 
4. [Linux - Shell Basic Operators](https://www.tutorialspoint.com/unix/unix-basic-operators.htm); a quick overview on a single page.
5. [Section 7.1. Test Constructs from Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/testconstructs.html); e.g. `[ ]` vs. `[[ ]]` - *testing* 
6. [Using Square Brackets in Bash: Part 1](https://www.linux.com/training-tutorials/using-square-brackets-bash-part-1/) ; what do these *brackets* `[]` do exactly?  
7. [Using Square Brackets in Bash: Part 2](https://www.linux.com/training-tutorials/using-square-brackets-bash-part-2/) ; more on *brackets* 
8. [All about {Curly Braces} in Bash](https://www.linux.com/topic/desktop/all-about-curly-braces-bash/) ; how do you expect to get on in life without `{}`?? 
9. [Section 7.2. File test operators from Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/fto.html); e.g. `test` if `regular` file w/ `-f`      
10. [Section 7.3. Other Comparison Ops from Advanced Bash-Scripting Guide](https://tldp.org/LDP/abs/html/comparison-ops.html); e.g. integers, strings, `&&`, `||`  

### How `bash` finds executables; `which`, `type`, etc.

1. [Q&A: How do I clear Bash's cache of paths to executables?](https://unix.stackexchange.com/questions/5609/how-do-i-clear-bashs-cache-of-paths-to-executables) help with `which` & alternatives
2. [Q&A: Why isn't the first executable in my $PATH being used?](https://unix.stackexchange.com/questions/91173/why-isnt-the-first-executable-in-my-path-being-used) more help with `which` 
3. [Q&A: Why not use “which”? What to use then?](https://unix.stackexchange.com/a/626017/286615) more on `which`, alternatives & `hash` for cache updates 

### Command history 

1. [How to Use Your Bash History in the Linux or macOS Terminal](https://www.howtogeek.com/howto/44997/how-to-use-bash-history-to-improve-your-command-line-productivity/); a *How-To-Geek* article
2. [Using History Interactively - A bash User's Guide](https://www.gnu.org/software/bash/manual/html_node/Using-History-Interactively.html); from the good folks at GNU. 
3. [The Definitive Guide to Bash Command Line History](https://catonmat.net/the-definitive-guide-to-bash-command-line-history); not quite - but it's certainly worth a look. 
4. H[ow To Use Bash History Commands and Expansions on Linux](https://www.digitalocean.com/community/tutorials/how-to-use-bash-history-commands-and-expansions-on-a-linux-vps); useful 
5. [Bash History Command Examples](https://www.rootusers.com/17-bash-history-command-examples-in-linux/); 17 of them at last count :) 
6. [Improved BASH history for ...](https://www.thomaslaurenson.com/blog/2018/07/02/better-bash-history/); **MUST READ**; yeah - this one is good. And as a [**BONUS...**](https://gist.github.com/seamusdemora/7211f77d3860d705d654234351d6b486) 
7. [Using Bash History More Efficiently: HISTCONTROL](https://www.linuxjournal.com/content/using-bash-history-more-efficiently-histcontrol); from the Linux Journal
8. [Preserve Bash History in Multiple Terminal Windows](https://www.baeldung.com/linux/preserve-history-multiple-windows); from baeldung.com 
9. [7 Tips – Tuning Command Line History in Bash](https://www.shellhacks.com/tune-command-line-history-bash/); is good
10. [Working With History in Bash](https://macromates.com/blog/2008/working-with-history-in-bash/); useful tips for `bash` history 

### Miscellaneous

1. [Uses for the Command Line in macOS](https://osxdaily.com/category/command-line/)  - from OSX Daily 
2. [Deleting all files in a folder, but don't delete folders](https://superuser.com/questions/52520/delete-all-files-in-a-folder-without-deleting-directories-os-x) 
3. [Removing all files in a directory](https://unix.stackexchange.com/questions/12593/how-to-remove-all-the-files-in-a-directory) 
4. [Q&A re clever use of `xargs` ](https://unix.stackexchange.com/questions/518186/usage-of-touch-with-pipeline)  
5. [*Lifewire* article explains *How to Display the Date and Time Using Linux Command Line*](https://www.lifewire.com/display-date-time-using-linux-command-line-4032698) 
6. [Exit status of last command using PROMPT_COMMAND](https://unix.stackexchange.com/questions/519680/exit-status-of-last-command-using-prompt-command) (An interesting thing worth further study) 
7. [Q&A: How to convert HTML to text?](https://superuser.com/questions/673878/how-to-convert-html-to-text); short answer: `curl <html URL> | html2text`  
8. [Use `findmnt` to check if a filesystem is mounted](https://unix.stackexchange.com/a/444553/286615); `findmnt` [explained further in this Q&A](https://stackoverflow.com/a/46025626/5395338).
9. [Q&A: How to create a link to a directory](https://stackoverflow.com/a/9587490/5395338) - I think he got it right! 
10. [How To Read And Work On Gzip Compressed Log Files In Linux](https://itsfoss.com/read-compressed-log-files-linux/) 


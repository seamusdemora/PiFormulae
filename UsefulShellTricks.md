Useful shell tricks

- Reload bash's .profile without restarting shell:


```
    $ source ~/.profile
    $ . ~/.profile
```

>  If something is **removed** from `~/.profile`, that change will **not** take effect after `. ~/.profile` reload. For example, add a function to `~/.profile`: `function externalip () { curl http://ipecho.net/plain; echo; }`, then `~/.profile` - IT WORKS. Now remove that function from `~/.profile`, then `. ~/.profile` again. The function is still available - only restarting (log out & in) will remove it. 

Clear the contents of a file without deleting the file:

```bash
$ > somefile.xyz
$ truncate -s 0 test.txt
```

List all directories (not files, just directories); [ref Q&A](https://unix.stackexchange.com/questions/518777/shell-script-to-test-ls-output-for-directories) 

```bash
$ find . -type d
```



- here's an unordered list item (1 line)
- here's another, with a "sub-bullet":
  - Sub-bullet 1 
  - Sub-bullet 2









REFERENCES:

1. [commandlinefu.com - a searchable archive of command line wisdom](https://www.commandlinefu.com/commands/browse) 
2. Passing arguments to bash:
   1. [How to Pass Arguments to a Bash Script](https://www.lifewire.com/pass-arguments-to-bash-script-2200571) (An article on Lifewire.com) 
   2. [Parsing bash script options with `getopts`](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/) (A short article by Kevin Sookocheff) 
   3. [A small `getopts` tutorial](https://wiki.bash-hackers.org/howto/getopts_tutorial) (p/o the bash hackers wiki) 
   4. [Q&A on StackOverflow: ](https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash) (How to get arguments with flags in `bash`)
3. [Deleting all files in a folder, but don't delete folders](https://superuser.com/questions/52520/delete-all-files-in-a-folder-without-deleting-directories-os-x) 
4. [Removing all files in a directory](https://unix.stackexchange.com/questions/12593/how-to-remove-all-the-files-in-a-directory) 
5. [Cool Unix and Linux CLI Commands - *nearly 10,000 items!*](https://www.scribd.com/doc/232825009/Cool-Unix-CLI) 
6. [Q&A re use of the `shebang` line](https://unix.stackexchange.com/questions/517370/shebang-or-not-shebang) 
7. [Q&A re clever use of `xargs` ](https://unix.stackexchange.com/questions/518186/usage-of-touch-with-pipeline)  
8. [Exit status of last command using PROMPT_COMMAND](https://unix.stackexchange.com/questions/519680/exit-status-of-last-command-using-prompt-command) (An interesting thing worth further study)
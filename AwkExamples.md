### Some `awk` Examples:

I've found  `awk` examples have been a big help to me. I'm adding these for myself, and others who *learn by example*. 

##### 1. Parse a stream from `journalctl` to extract SSH logins & logouts:

```bash
#!/usr/bin/env bash
WORKFILE=$(mktemp /tmp/ssh_stats-XXXXX)
journalctl --follow --since=now | awk -v fo=$WORKFILE '/sshd:session/ && /opened/ || /sshd:session/ && /closed/ {print $0 >> fo; fflush(); }'
```

   Notable: 

* pipe `journalctl` with `--follow`  to awk; works as a daemon or background job
* use of `-v` to pass the `bash` variable `$WORKFILE` to `awk`
* 4 pattern logic matching: `/pat1/ && /pat2/ || /pat3/ && /pat4/` to locate lines of interest 
* output redirect & append to file: `print $0 >> fo`
* force print cache to file immediately via `fflush()` 

##### 2. Counting matching records & placing the result to the shell variable:

```bash
PTS_CT=$(w | awk '/pi/ && /pts/ {count++} END{print count}')
if [ $PTS_CT -gt 0 ]
then
   <do something>
else
   <do something else>
fi
```

   Notable: 

* Line 1: The ability to store the output of a command into a variable is called **command substitution**, `variable=$(commands)` and it’s one of the most useful features of `bash`. 
* `[ comparison ]`is shorthand for the `bash` *built-in* `test` ; `-gt` is a *numerical* comparison 
* `count++` = increment the variable `count`; it is the *action* executed when the patterns match `pi` & `pts` in the same line/record.
* `END` is the command executed by `awk` after the last record is read.

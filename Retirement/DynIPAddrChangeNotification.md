Notification of changed dynamic (public) IP address 

1. Get my public IP address? 
2. Get my private (local) IP address? 
3. If the IP address has changed since the last reading, record the new value with a timestamp
4. Put this in a script; the argument will specify public or private
5. Put the script in a function, and place the function in .profile
6. Send notification of IP address changes to designated party via a) Apple iMessage, or b) GMail using Python. 

------

1. My public IP address is the IP that a remote host will see when you connect from behind your firewall/router/NAT. Following are known sources that will return your public IP address, and the method for extracting the IP address from the reply: 

​       Sources of IP address information: 

- http://whatismijnip.nl  : `curl -s http://whatismijnip.nl | cut -d " " -f 5` 
- http://whatismyip.akamai.com/  :  `curl -s http://whatismyip.akamai.com/ && echo`  <sup>2</sup>
- https://www.whatsmyip.org/ 
- https://www.whatismypublicip.com/ 
- http://ipecho.net/plain : `curl -s -w "\n" http://ipecho.net/plain` <sup>2</sup> 
- https://ifconfig.me/ : `curl ifconfig.me && echo` 

2. My private IP address is best obtained from `ip`. `ip` is current, maintained, and perhaps most importantly for scripting purposes, it produces a consistent & parsable output. In particular, `ip route`works on hosts with single or multiple interfaces, and/or route specifications. : 
```
$ ip route get 8.8.8.8 | awk '{ print $7; exit }'
```

3. We'll use a file named `watchip.sh.csv` as a database to save our results, and keep a log of when we detect IP address changes. We won't make an entry in the file unless there has been a change. We will record a change by appending the new IP address and a timestamp of our file. 

4. Read the last IP address in the out file as follows: 

```bash
lastip=$( tail -n 1 ~/watchip.sh.csv)  # NOTE: need awk to get IPADDR, not time

```

5. Get the time of the reading. Use [Unix time](https://en.wikipedia.org/wiki/Unix_time) to remove localization, and make diffs easier to calculate.
```bash
date +"%s
```
6. We'll use the "flags method" in `bash`. This will give us the ability to request either internal or external IP addr, and we'll get both if no argument is passed.  : 

```bash

```

------

REFERENCES/NOTES:

1. [How can I get my external IP address in a shell script?](https://unix.stackexchange.com/questions/22615/how-can-i-get-my-external-ip-address-in-a-shell-script) (See the final answer at the bottom of this page) 

2. [My answer on SE for finding private IP](https://askubuntu.com/a/1124395/831935) 

3. `&& echo` and the `curl` option `-w "\n"` accomplish the same purpose: add a newline to the `curl` output. This may be useful at the command line for example, but perhaps not everywhere. 

4. These are good candidates for function declarations in `~/.profile` ; for example:

   ```bash
   function externalip () { curl http://ipecho.net/plain; echo; }
   ```

5. [How to Pass Arguments to a Bash Script](https://www.lifewire.com/pass-arguments-to-bash-script-2200571) : Lifewire article; good explanation, but no good code samples

6. [How to get arguments with flags in Bash](https://stackoverflow.com/questions/7069682/how-to-get-arguments-with-flags-in-bash) : Good sample code fragments 

7. [Parsing command line arguments in `bash`](https://stackoverflow.com/a/14203146/5395338) : How to process the arguments; appears fairly comprehensive

8. [A `getopts` tutorial](https://wiki.bash-hackers.org/howto/getopts_tutorial) Required reading 

9. [Parsing bash script options with getopts](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/) 



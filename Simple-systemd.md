## Starting simple with 'systemd'

It has been said that users of modern Linux systems should be using `systemd` when they want to run a script as a *daemon*. I've always been a bit *edgy* when it comes to `systemd`, but I have to admit there may be some wisdom in this statement. So let's try something **simple** to start: 

1. Here's a script which is appropriately named. Save this file in your home directory as `donaught.sh`, and then do: **`chmod 755 donaught.sh`**. 

	```bash
   #!/usr/bin/env bash
   # donaught.sh is my $0
   # example systemd unit that does nothing
   declare -i i=0
   while true
   do
       ((i++))
       printf '%s\n' "$(basename $0) ain't doin nuthin; $i; $(date +"%F %T.%3N")" >> /home/pi/donaught.log
       sleep 300
       if [ $i -gt 288 ]; then
           > /home/pi/donaught.log
           i=0
       fi
   done
	```

2. Next, create a "unit file" for using `donaught.sh` with `systemd`. In your editor, create this, and save it as `/etc/systemd/system/donaught.service` :

	``` 
    [Unit]
    Description=donaught service
    After=network-online.target
     
    [Service]
    ExecStart=/home/pi/donaught.sh
    
    [Install]
    WantedBy=multi-user.target
	```

3. Finally, use `systemctl` (p/o `systemd`) to start and stop the `donaught service`: 

	```bash
	sudo systemctl start donaught
	# you can watch donaught "in action" using tail -f donaught.log
	# and when you get tired of that, just stop it
	sudo systemctl stop donaught
	```

4. If you want the service to start at boot time, enter this command from the terminal: 

	```bash
	sudo systemctl enable donaught 
	
	# to prevent the service from starting at the next boot:
	sudo systemctl disable donaught
	```





That's it for now; we'll try to find something more interesting soon. Perhaps something with libgpiod. 






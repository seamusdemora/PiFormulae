Why does my crontab not work? 

cron is simple in some respects, but enigmatic in others.



#### MFEI #1: the `cron` user has a different environment than you; specifically, the PATH env var is different

Solutions:

- use absolute path statements: `/home/user/scriptname.sh` instead of `scriptname.sh` or `./scriptname.sh` 
- be really clever, and set the `cron` user's environment:  [set env for cron](https://stackoverflow.com/questions/2229825/where-can-i-set-environment-variables-that-crontab-will-use); [run cron with existing env](https://unix.stackexchange.com/questions/27289/how-can-i-run-a-cron-command-with-existing-environmental-variables) ; [more info in this answer on SE](https://serverfault.com/a/337921/515728) ; [still more on SE](https://stackoverflow.com/questions/2135478/how-to-simulate-the-environment-cron-executes-a-script-with) 
- ask `cron` to tell you what `environment` it's using - [here's how to ask](WhatIsCronEnvironment.md).



#### MFEI #2: `cron` has no awareness of the state of other services when it starts. This is typically only an issue when using the `@reboot` facility

Solutions: 

- `sleep` before starting a script with service dependencies: 

```bash
@reboot ( /bin/sleep 30; /bin/bash /home/pi/startup.sh > /home/pi/cronjoblog 2>&1)
```



------

REFERENCES:

1. [The **crontab guru** will help you with your schedule specification](https://crontab.guru/#30_0,1,2,3_*_*_*) 
2. [`cron`, `crontab`... What are you talking about?](https://www.ostechnix.com/a-beginners-guide-to-cron-jobs/) 
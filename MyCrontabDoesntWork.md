Why does my crontab not work? 

cron is simple in some respects, but enigmatic in others.



MFEI #1: the `cron` user has a different environment than you; specifically, the PATH env var is different

Solutions:

- use absolute path statements:
- be really clever, and set the `cron` user's environment:  [set env for cron](https://stackoverflow.com/questions/2229825/where-can-i-set-environment-variables-that-crontab-will-use); [run cron with existing env](https://unix.stackexchange.com/questions/27289/how-can-i-run-a-cron-command-with-existing-environmental-variables) 



MFEI #2: `cron` has no awareness of the state of other services when it starts. This is typically only an issue when using the `@reboot` facility 

Solutions: 

- `sleep` before starting a script with service dependencies 
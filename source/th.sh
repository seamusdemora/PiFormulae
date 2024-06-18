#!/usr/bin/bash

# script name: th.sh; install at /usr/local/sbin
# This script reads the folder in 'sysfs' containing data from the sht3x t & h sensor
#
# An issue w/ this script was the sysfs location of the correct folder containing
# the "data files" for the sht3x sensor. The "sysfs" name/location of the folder
# could change following a reboot, or if other "hwmon" sensors were added/removed.
# This issue was addressed with a "udev" rule; the rule creates a symbolic link at
# "/dev/hwmon_sht3x" to the correct folder in "sysfs".
# The "udev" rule is located at "/etc/udev/rules.d/80-local.rules", and is:
#
# ACTION=="add", SUBSYSTEM=="hwmon", ATTR{name}=="sht3x", KERNELS=="0-0044", \
# SUBSYSTEMS=="i2c", RUN+="/bin/sh -c 'ln -s /sys$devpath /dev/hwmon_sht3x'"
#
# Consequently, the data used in this script is read from "/dev/hwmon_sht3x"
# instead of "/sys/devices/platform/soc/3f205000.i2c/i2c-0/0-0044/hwmon/hwmonX"

dev_fldr="/dev/hwmon_sht3x"

# check that $dev_fldr exists, that the file 'name' exists in it, and that the file contains 'sht3X'
if [ -d "$dev_fldr" ] && [ -f "$dev_fldr/name" ] && [ $(< "$dev_fldr/name") = "sht3x" ]; then
    dev_nm="sht3x"
else
    echo "ERROR fm $0: The folder: $dev_fldr - appears to be incorrect or missing."
    echo "Verify the sht3x sensor is wired correctly, and configured in config.txt"
    exit 1
fi

# Fahrenheit = (Celsius * 1.8) + 32
# read sht3x sensor's temperature & humidity data
denominator=1000
temp_c=$(< "$dev_fldr/temp1_input")
t_c=$(echo "scale=1; $temp_c / $denominator" | bc)
t_f=$(echo "scale=1; ($t_c * 1.8) + 32" | bc)
# echo -e "$t_c deg C\t$t_f deg F"

humid_r=$(< "$dev_fldr/humidity1_input")
h_r=$(echo "scale=1; $humid_r / $denominator" | bc)
# echo "$h_r per cent"

printf "$(date +%Y-%m-%d\ @\ %H:%M:%S); Temperature: %4.1f deg C, %5.1f deg F\tHumidity: %4.1f %% relative humidity\n" $t_c $t_f $h_r
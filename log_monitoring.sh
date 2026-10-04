#!/bin/bash 

# monitoring the logs manually

tail -f /var/log/application.log 

-f means continuolsy display new logs entries 

to find error/fatal message

grep -E "ERROR/FATAL" /var/log/application.log


# monitoring the logs Automation using shell script 

if grep -qE "ERROR/FATAL" /var/log/appication.log
then  
   echo "error found"
else 
   echo "error not found"
fi 

#!/bin/bash 

# manual steps for memory monitoring 

free -h---to check the memory deatils 
ps -eo pid,ppid,%cpu.%mem,cmd --sort=-%mem | head---will find which process consuming more memory 
ps -ef <pid>--it will give deatils which one consuming more memory 
i will investigate and delete unnecessary files and folders 

# Automaion

1. free -h 
2. 
  THERSHOLD=80
  mem_usage=$(free | awk '/Mem/ {printf(%.0f), $3/$2*100}')
  if [ $ $mem_usage -ge $THERSHOLD ]
  then 
    echo "warning: memory usage is $mem_usage"
  else 
    echo "memory usage is normal"
 fi

 crontab:
 chmod +x memory-monitoring.sh
 */30 * * * * /path/memory.monitoring.sh 

 

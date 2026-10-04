#!/bin/bash

# manually will check the cpu utilization
1. top-->will get cpu and memort deatils
2. ps -eo pid,ppid,%cpu,%mem,cmd --sort=-%cpu | head--->it will give top 10 consuming cpu process id
3. ps -ef <pid>---will get info who this process cpu got increas which command we used 
4. kill <pid>
    

# Now will check automation using shell script

1. top -bn1---->it will not give interactive mode
  if [ $? -eq 0 ]
  then
    echo "top command is executed abd got the cpu info"
  else 
    echo "top command execution is failed"
2. ps -eo pid,ppid,%cpu,%mem,cmd --sort=_%cpu | head
    if [ $? -eq 0 ]
    then
        echo "top 10 consuming got the process id info"
    else 
        echo " command execution is failed"

3. THERSHOLD=80%
   cpu_usage=$(top -bn1 | aws '/CPU/ {print int($2)}')

   if [ $cpu_usage -ge $THERSHOLD ]
   then 
     echo "warning..cpu usage is $cpu_usage%"
   else 
     echo "cpu usage is normal $cpu_usage"
   fi
   
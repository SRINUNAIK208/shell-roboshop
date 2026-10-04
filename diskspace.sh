#!/bin/bash

# Manuall check disk space

# first which file system consuming more space for that

# df -h---it will give all filesystem then i will find out which file system consuming for spcae
# for example /home is consuming more disk sapce then what i can do is
# du -sh /home/*  ----i will check in directory consuming in side the home 
# then i will investigate why it is consuming more space, then i will delete few un necassary files


# # Automation 

# for example i waht to check /home 

# for that 

THERSHOLD=1

DISK_USAGE=$(df -h | grep -v Filesystem)
while IFS=read line
do
   DISK=$(echo $line | awk '{print $5}' | tr -d '%')
   PATH=$(echo $line | awk '{print $6}')

   if [ $DISK -ge $THERSHOLD ]
  then 
    echo "$PATH: $DISK"
    echo "warning: disk uasage $DISK"
  else 
    echo "disk space is normal"
  fi
done
    

# done <<< $DISK_USAGE
# if [ $DISK_USAGE -ge $THERSHOLD ]
# then 
#   echo "warning: disk uasage $DISK_USAGE"
# else 
#   echo "disk space is normal"
# fi



# cronTab:
# you can run script manually or schedule it in crontab like run every 30 min for that give execution permission for this script 
# chmod +x diskspace.sh
# */30 * * * * /path/disksapce.sh


# interview question:

# why should disk space monitoring scrpt use a thereshold instead of alerting very time?

# using thereshold help reduce the unnecassary alerts, notification sent only when disl usage is high, then admin focus on issue that require immediate action
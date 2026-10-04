#!/bin/bash

# server may stop suddently, dick usage fill up or logs file size increased slowly, we have multiple server we can not go check manually at atime all server what we can do we write one shell script and run it

# check server is running or not

systemctl status nginx

if [ $? -eq 0 ]
then
  echo "nginx is running"
else 
  echo "nginx is not running"
fi 

# checking the process

PROCESS="nginx"

if pgrep $PROCESS > /dev/null
then 
  echo "$PROCESS is running"
else
  echo "$PROCESS is not running"
fi

# checking log file deleting 15 days old

files=$(find . -name '*.log' -mtime +15)
while IFS= read -r file
do 
  echo "$file"
  rm -rf "$file"
done <<< "$files"


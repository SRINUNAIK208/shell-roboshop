#!/bin/bash

USERID=$(id -u)

if [ $USERID -eq 0 ]
then 
  echo "user has root access.."
else 
  echo "user does not have root access..please switch to root user"
fi

files=$(find . -name "*.log" -mtime +14)

while IFS=read -r file 
do 
 echo "$file"
 rm -rf $file

done <<< "$files"

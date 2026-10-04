#!/bin/bash 
 USERID=$(id -u)

 LOGS_FOLDER="/var/log/shellscript"
 SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
 LOGS_FILE="$LOGS_FOLDER-$SCRIPT_NAME.log"
 mkdir -p $LOGS_FOLDER

 if [ $USERID -eq 0 ]
 then 
    echo "user has root access"
else 
    echo "user does not have root access...please switch to root user"
fi 
SOURCE_DIR=$1
DESTINATION_DIR=$2
DAYS=${3-14}

if [ -d $SOURCE_DIR ]
then  
  echo "source directory is exist"
else 
  echo "source directory is not exist..please provide source directory"
fi 

if [ -d $DESTINATION_DIR ]
then  
  echo "destination directory is exist"
else 
  echo "destination directory is not exist..please provide destination directory"
fi 

files=$(find $SOURCE_DIR -name "*.log" -mtime $DAYS)

if [ -z $files ]
then 
  echo "$files"
  TIMESTAMP=$(date +%y-%m-%d-%h-%s)
  ZIP_FILE=$DESTINATION_DIR-$TIMESTAMP.log
  echo "$files" | zip -@ $ZIP_FILE

  if [ -f $ZIP_FILE ]
  then 
    echo "zip file is created successfully"
  else 
    echo "zip file is not created"
  fi

  while IFS= read -r file
  do
    echo "$file"
    rm -rf "$file"
  done <<< "$files"


else 
   echo "file is empty"
fi



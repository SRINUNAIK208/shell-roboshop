#!/bin/bash 

USERID=$(id -u)


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo "$0" | cut -d "." -f1)
LOGS_FILE="$LOGS_FOLDER/$SCRIPT_NAME.logs"
SCRIPT_DIR=$PWD

mkdir -p /var/log/roboshop-logs

if [ $USERID -eq 0 ]
then 
  echo -e " $G user has root access...$N" | tee -a $LOGS_FILE
else 
  echo -e "$R user does not have root access....please switch to root user $N" | tee -a $LOGS_FILE
  exit 1
fi 


VALIDATION() {
    if [ $1 -eq 0 ]
    then 
       echo -e "$2 is...$G success $N" | tee -a $LOGS_FILE
    else 
       echo -e "$2 is...$R failed $N"  | tee -a $LOGS_FILE
    fi 
}


dnf module disable redis -y  &>>$LOGS_FILE
VALIDATION "$?" "redis disabled"

dnf module enable redis:7 -y &>>$LOGS_FILE
VALIDATION "$?" "redis enabled"


dnf install redis -y &>>$LOGS_FILE
VALIDATION "$?" "redis installed"

sed -i s/127.0.0.1/0.0.0.0 /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATION "$?" "set remote server"

sed -i s/protected-mode yes/protected-mode no /etc/redis/redis.conf &>>$LOGS_FILE
VALIDATION "$?" "set remote server"

systemctl enable redis &>>$LOGS_FILE
VALIDATION "$?" "redis enabled"

systemctl start redis &>>$LOGS_FILE
VALIDATION "$?" "redis started"




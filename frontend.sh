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

dnf module disable nginx -y &>>$LOGS_FILE
VALIDATION "$?" "disabled latest version"

dnf module enable nginx:1.24 -y &>>$LOGS_FILE
VALIDATION "$?" "Enabled version:20"

dnf install nginx -y &>>$LOGS_FILE
VALIDATION "$?" "install nginx"

systemctl enable nginx 
VALIDATION "$?" "enabled nginx"

systemctl start nginx 
VALIDATION "$?" "started nginx"

rm -rf /usr/share/nginx/html/*
VALIDATION "$?" "remove nginx defult"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATION "$?" "download nginx code"

cd /usr/share/nginx/html 
unzip /tmp/frontend.zip
VALIDATION "$?" "unzip the src code"


cp "$SCRIPT_DIR/nginx.conf" /etc/nginx/nginx.conf 
VALIDATION "$?" "copy the nginx conf file"

systemctl restart nginx 
VALIDATION "$?" "start nginx"


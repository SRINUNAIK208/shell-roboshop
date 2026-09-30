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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATION "$?" "disabled latest version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATION "$?" "Enabled version:20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATION "$?" "install nodejs"

id roboshop
if [ $? -eq 0 ]
then
  echo "$Y roboshop user alreday created...skip $N" &>>$LOGS_FILE
else

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATION "$?" "created roboshop system user"
fi

mkdir -p /app &>>$LOGS_FILE
curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
VALIDATION "$?" "Download the src code"

rm -rf /app/*
cd /app
unzip /tmp/user.zip &>>$LOGS_FILE
VALIDATION "$?" "unzip the src code"

npm install &>>$LOGS_FILE
VALIDATION "$?" "install dependencies"

cp "$SCRIPT_DIR/user.service" /etc/systemd/system/user.service &>>$LOGS_FILE
VALIDATION "$?" "created user service"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATION "$?" "daemon reload"

systemctl enable user &>>$LOGS_FILE
VALIDATION "$?" "enbled user"

systemctl start user &>>$LOGS_FILE
VALIDATION "$?" "start user"


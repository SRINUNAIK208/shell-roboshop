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
curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
VALIDATION "$?" "Download the src code"

unzip /tmp/catalogue.zip &>>$LOGS_FILE
VALIDATION "$?" "unzip the src code"

npm install &>>$LOGS_FILE
VALIDATION "$?" "install dependencies"

cp "$SCRIPT_DIR/catalogue.service" /etc/systemd/system/catalogue.service &>>$LOGS_FILE
VALIDATION "$?" "created catalogue service"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATION "$?" "daemon reload"

systemctl enable catalogue &>>$LOGS_FILE
systemctl start catalogue &>>$LOGS_FILE
VALIDATION "$?" "enbled and start catalogue"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGS_FILE
VALIDATION "$?" "setup mongo repo"

dnf install mongodb-mongosh -y &>>$LOGS_FILE
VALIDATION "$?" "install mongodb client"

mongosh --host mongodb.srinunayak.online </app/db/master-data.js &>>$LOGS_FILE

mongosh --host mongodb.srinunayak.online &>>$LOGS_FILE
VALIDATION "$?" "load the data"
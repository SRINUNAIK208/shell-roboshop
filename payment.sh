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



dnf install python3 gcc python3-devel -y &>>$LOGS_FILE
VALIDATION "$?" "install python"

id roboshop
if [ $? -eq 0 ]
then
  echo "$Y roboshop user alreday created...skip $N" &>>$LOGS_FILE
else

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATION "$?" "created roboshop system user"
fi

mkdir -p /app &>>$LOGS_FILE
curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATION "$?" "Download the src code"

unzip /tmp/payment.zip &>>$LOGS_FILE
VALIDATION "$?" "unzip the src code"

pip3 install -r requirements.txt &>>$LOGS_FILE
VALIDATION "$?" "install dependencies"


cp "$SCRIPT_DIR/payment.service" /etc/systemd/system/payment.service &>>$LOGS_FILE
VALIDATION "$?" "created shipping service"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATION "$?" "daemon reload"

systemctl enable payment &>>$LOGS_FILE
VALIDATION "$?" "enbled payment"

systemctl start payment &>>$LOGS_FILE
VALIDATION "$?" "start payment"


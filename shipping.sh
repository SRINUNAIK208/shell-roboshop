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



dnf install maven -y &>>$LOGS_FILE
VALIDATION "$?" "install maven"

id roboshop
if [ $? -eq 0 ]
then
  echo "$Y roboshop user alreday created...skip $N" &>>$LOGS_FILE
else

    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATION "$?" "created roboshop system user"
fi

mkdir -p /app &>>$LOGS_FILE
curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip 
VALIDATION "$?" "Download the src code"

rm -rf /app/*
cd /app
unzip /tmp/shipping.zip &>>$LOGS_FILE
VALIDATION "$?" "unzip the src code"

mvn clean package &>>$LOGS_FILE
VALIDATION "$?" "install dependencies"

mv target/shipping-1.0.jar shipping.jar 
VALIDATION "$?" "shipping folder moves to app dir"

cp "$SCRIPT_DIR/shipping.service" /etc/systemd/system/shipping.service &>>$LOGS_FILE
VALIDATION "$?" "created shipping service"

systemctl daemon-reload &>>$LOGS_FILE
VALIDATION "$?" "daemon reload"

systemctl enable shipping &>>$LOGS_FILE
VALIDATION "$?" "enbled shipping"

systemctl start shipping &>>$LOGS_FILE
VALIDATION "$?" "start shipping"


dnf install mysql -y &>>$LOGS_FILE
VALIDATION "$?" "mysql client is"

mysql -h mysql.srinunayak.online -uroot -pRoboShop@1 -e 'use cities' &>>$LOGS_FILE
if [ $? -eq 0 ]
then 
   echo -e "mysql data is already loaded...$Y skiiping $N"
else 
   mysql -h mysql.srinunayak.online -uroot -pRoboShop@1 < /app/db/schema.sql 
   mysql -h mysql.srinunayak.online -uroot -pRoboShop@1 < /app/db/app-user.sql 
   mysql -h mysql.srinunayak.online -uroot -pRoboShop@1 < /app/db/master-data.sql
fi

systemctl restart shipping  &>>$LOGS_FILE 
VALIDATION "$?" "restart the shipping"
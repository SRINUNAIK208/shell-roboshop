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

cp $SCRIPT_DIR/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATION "$?" "setup rabbitmq repo"

dnf install rabbitmq-server -y
VALIDATION "$?" "install rabbitmq"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
VALIDATION "$?" "enable and start rabbitmq"

rabbitmqctl add_user roboshop roboshop123
VALIDATION "$?" "add username and password for rabbitmq"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
VALIDATION "$?" "set permission for rabbitmq"
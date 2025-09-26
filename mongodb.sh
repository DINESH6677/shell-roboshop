#!/bin/bash
USER_ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGs_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE


if [ $USER_ID -ne 0 ];then
    echo -e" $R Error: you require root privileges $N" | tee -a $LOG_FILE
    exit 1
else
    echo -e " $G You are a root user proceed $N" | tee -a $LOG_FILE
fi

validate(){
    if [ $1 eq 0 ];then
        echo -e " $G $2 successfully $N " | tee -a $LOG_FILE
    else
        echo -e " $R ERROR: While executing so......$N  $Y skipping $N" | tee -a $LOG_FILE
    fi

}



cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
validate $? "mongorepo_added"

dnf install mongodb-org -y &>>$LOG_FILE
validate $? "mongodb_installed"

systemctl enable mongod &>>$LOG_FILE
validate $? "mongodb_enabled"

systemctl start mongod &>>$LOG_FILE
validate $? "mongodb_started"


sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
validate $? "Remote connection enabled"


systemctl restart mongod &>>$LOG_FILE
validate $? "mongodb_restarted"







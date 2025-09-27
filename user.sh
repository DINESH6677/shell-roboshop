#!/bin/bash
USER_ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGs_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

start_time=$(date +%s)
mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE


if [ $USER_ID -ne 0 ];then
    echo -e" $R Error: you require root privileges $N" | tee -a $LOG_FILE
    exit 1
else
    echo -e " $G Congrats You are a root user.so,you can proceed $N" | tee -a $LOG_FILE
fi

validate(){
    if [ $1 -eq 0 ];then
        echo -e " $G $2 successfully. $N " | tee -a $LOG_FILE
    else
        echo -e " $R ERROR: While executing so......$N  $Y skipping $N" | tee -a $LOG_FILE
    fi

}

dnf module disable nodejs -y &>>$LOG_FILE
validate $? "disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? "enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
validate $? "installing nodejs"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    validate $? Useradded
else
    echo -e " $Y user was already added $N"
fi

mkdir -p /app &>>$LOG_FILE
validate $? "Making directory"

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip  &>>$LOG_FILE
validate $? "downloading zip file"

cd /app  &>>$LOG_FILE
validate $? "changed directory"

unzip /tmp/user.zip &>>$LOG_FILE
validate $? "unzipping downloaded file"

cd /app  &>>$LOG_FILE
validate $? "changed directory to /app"

npm install  &>>$LOG_FILE
validate $? "downloading dependencies"

cp  $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOG_FILE
validate $? "created user service"

systemctl daemon-reload &>>$LOG_FILE
validate $? "daemon reloaded"

systemctl enable user  &>>$LOG_FILE
validate $? "enabled user"

systemctl start user &>>$LOG_FILE
validate $? "started user"
#!/bin/bash
USER_ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

LOG_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
SCRIPT_DIR=$PWD
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
MONGODB_HOST=mongodb.devopswithdinesh.shop

mkdir -p $LOG_FOLDER
echo -e " $Y Script started execution at: $(date) $N " | tee -a $LOG_FILE

if [ $USER_ID -ne 0 ];then
    echo -e " $R Error: you need root privileges to continue $N " | tee -a $LOG_FILE
    exit 1
fi

validate(){
    if [ $1 -ne 0 ]; then
        echo -e " $R ERROR: $2 is unsuccesful $N " | tee -a $LOG_FILE
    else
        echo -e " $G Successfully$N $Y$2$N $G Executed  $N " | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
validate $? Disbaled_Nodejs

dnf module enable nodejs:20 -y &>>$LOG_FILE
validate $? Enabled_Nodejs

dnf install nodejs -y &>>$LOG_FILE
validate $? Installing_Nodejs

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    validate $? Useradded
else
    echo -e " $Y user was already added $N"
fi

mkdir -p /app &>>$LOG_FILE
validate $? Directory_Created

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
validate $? Catalogur_zipfile_Downloaded

cd /app  &>>$LOG_FILE
validate $? Directory_Changed

rm -rf /app/* &>>$LOG_FILE
validate $? "Removing existing code"

unzip /tmp/catalogue.zip &>>$LOG_FILE
validate $? catalogue_Unzipped

cd /app &>>$LOG_FILE

npm install &>>$LOG_FILE
validate $? Dependencies_Installed

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service &>>$LOG_FILE
validate $? "Copy systemctl service"

systemctl daemon-reload &>>$LOG_FILE
validate $? Daemon_reloaded

systemctl enable catalogue &>>$LOG_FILE
validate $? Catalogue_Enabled

systemctl start catalogue &>>$LOG_FILE
validate $? Catalogue_Started

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOG_FILE
validate $? "Copy mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
validate $? Mongodb_Installed

INDEX=$(mongosh mongodb.devopswithdinesh.shop --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    validate $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue &>>$LOG_FILE
validate $? "Restarted catalogue"
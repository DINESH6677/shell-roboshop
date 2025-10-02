#!/bin/bash
USER_ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGs_FOLDER/$SCRIPT_NAME.log"

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

dnf module disable redis -y &>>$LOG_FILE
validate $? "disabled redis"

dnf module enable redis:7 -y &>>$LOG_FILE
validate $? "Enabled redis"

dnf install redis -y  &>>$LOG_FILE
validate $? "Installed redis"

sed -i -e s'/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf  &>>$LOG_FILE
validate $? "Remote access" # we are using 2 -e because we are changing multiple things in a file 

systemctl enable redis &>>$LOG_FILE
validate $? "Enabled Redis" 

systemctl start redis &>>$LOG_FILE
validate $? "Started Redis" 

end_time=$(date +%s)
Total_time=$(($end_time - $start_time))

echo " The Total time taken to Execeute $Total_time seconds"


#! /bin/bash

USERID=$(id -u )
TIMESTAMP=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$Script_Name-$TIMESTAMP.log
DIRECTORY=/app

if [ $USERID -eq 0 ]
then
    echo " You are in super user mode u can run the script"
else
    echo " Please run the script in Su mode"
fi

validate(){
    if [ $1 -eq 0 ]
    then
        echo "$2 is successful "
    else
        echo "$2 is failure"
    fi
}


dnf module disable nodejs -y &>>$LOGFILE
validate $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
validate $? "Enabling node js 20"

dnf install nodejs -y &>>$LOGFILE
validate $? "Installing Nodejs"

id roboshop &>>$LOGFILE
if [ $? -eq 0 ]
then 
    echo "user exists"
else
    useradd roboshop # need to check the user exists or not
fi

if [ -d "$DIRECTORY" ]; 
then
    echo "removing the directory"
    rm -rf $DIRECTORY
    mkdir -p  $DIRECTORY
else
    mkdir -p $DIRECTORY
fi

curl -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip &>>$LOGFILE
validate $? "Downloading the code"

cd /app 
validate $? "changing the directory to app"

unzip /tmp/user.zip &>>$LOGFILE
validate $? "Unzip the files"

npm install &>>$LOGFILE
validate $? "Installation of dependencies"

cp -rf /home/ec2-user/Roboshop_linux/user.service /etc/systemd/system/user.service &>>$LOGFILE
validate $? "copy the user service"

systemctl daemon-reload &>>$LOGFILE
validate $? "deamon reload"

systemctl enable user &>>$LOGFILE
validate $? "enabling the user service"

systemctl start user &>>$LOGFILE
validate $? "Start the user"


cp -rf /home/ec2-user/Roboshop_linux/mongo.repo /etc/yum.repos.d/mongo.repo &>>$LOGFILE
validate $? "copying mongo repo"

dnf install mongodb-mongosh -y &>>$LOGFILE
validate $? "installing mongo-db"

# mongosh --host MONGODB-SERVER-IPADDRESS </app/schema/user.js &>>$LOGFILE
# validate $? " loading mongo DB sechema"

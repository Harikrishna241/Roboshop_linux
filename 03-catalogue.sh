#! /bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$Script_Name-$TIMESTAMP.log
if [ $USERID -eq 0]
then
    echo " you are in su mode"
else
    echo " You need to run this script in SU Mode"
fi

validate(){

    if [ $1 -eq 0 ]
    then 
        echo "$2 is succefull"
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

useradd roboshop # need to check the user exists or not 

mkdir /app # need to check the app dir if exists need to remove and re create

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

cd /app 
validate $? "changing the directory to app"

unzip /tmp/catalogue.zip &>>$LOGFILE
validate $? "Unzip the files"

cd /app &>>$LOGFILE
validate $? "Changing the directory to app"

npm install &>>$LOGFILE
validate $? "Installation of dependencies"

cp -rf catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
validate $? "copy the catlogue service"

systemctl daemon-reload &>>$LOGFILE
validate $? "deamon reload"

systemctl start catalogue &>>$LOGFILE
validate $? "Start the catlogue"


#vim /etc/yum.repos.d/mongo.repo here we need verify the mongo DB 

dnf install -y mongodb-mongosh &>>$LOGFILE
validate $? "install Mongodb"

mongosh --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js &>>$LOGFILE
validate $? "Loading the schema"
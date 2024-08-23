#! /bin/bash

USERID=$(id -u )
TIMESTAMP=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$Script_Name-$TIMESTAMP.log
DIRECTORY=/app

if [ $USERID -eq 0 ]
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

if [ -d "$DIRECTORY" ]; 
then
    rm -rf $DIRECTORY
    mkdir $DIRECTORY
else
    mkdir $DIRECTORY
fi

rm -rf /app &>>$LOGFILE
validate $? "remove the directory"

# creating the app dir if exists need to remove and re create
mkdir -p /app  &>>$LOGFILE
validate $? "Creating the app directory "

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip

cd /app 
validate $? "changing the directory to app"

unzip /tmp/catalogue.zip &>>$LOGFILE
validate $? "Unzip the files"

# cd /app &>>$LOGFILE
# validate $? "Changing the directory to app"

npm install &>>$LOGFILE
validate $? "Installation of dependencies"

cp -rf /home/ec2-user/Roboshop_linux/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE
validate $? "copy the catlogue service"

systemctl daemon-reload &>>$LOGFILE
validate $? "deamon reload"

systemctl start catalogue &>>$LOGFILE
validate $? "Start the catlogue"


cp -rf /home/ec2-user/Roboshop_linux/mongo.repo   /etc/yum.repos.d/mongo.repo
validate $? "copy mongo.repo"


dnf install -y mongodb-mongosh &>>$LOGFILE
validate $? "install Mongodb"

# mongosh --host MONGODB-SERVER-IPADDRESS </app/schema/catalogue.js &>>$LOGFILE
# validate $? "Loading the schema"
#! /bin/bash

USERID=$(id -u )
TIMESTAMP=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$Script_Name-$TIMESTAMP.log

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

# need to check the user exists or not 
id roboshop &>>$LOGFILE
if [ id -eq 0 ]
then 
    echo "user exists"
else
    useradd roboshop 
fi

if [ -d -eq "/app" ]
then
    echo app folder exist.removing the folder 
    rm -rf /app
    mkdir -p /app # need to check the app dir if exists need to remove and re create
else 
    mkdir -p /app
fi


curl  -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>>$LOGFILE
validate $? "download  the files"

cd /app &>>$LOGFILE
validate $? "changing the directory to app"

unzip /tmp/cart.zip &>>$LOGFILE
validate $? "copy the cart service"

npm install &>>$LOGFILE
validate $? "Installation of dependencies"

cp -rf /home/ec2-user/Roboshop_linux/cart.service vim /etc/systemd/system/cart.service &>>$LOGFILE
validate $? "copy the cart service"

systemctl daemon-reload &>>$LOGFILE
validate $? "deamon reload"

systemctl enable cart &>>$LOGFILE
validate $? "enabling the cart service"

systemctl start cart &>>$LOGFILE
validate $? "Start the cart"

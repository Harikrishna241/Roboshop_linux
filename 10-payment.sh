#! /bin/bash

USERID=$(id -u )
TIMESTAMP=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$Script_Name-$TIMESTAMP.log
DIRECTORY=/app

if [ $USERID -eq 0 ]
then
    echo " you are in super user"
else
    echo "You need to run this script in SU mode"
    exit 1
fi

validate(){
    if [ $1 -eq 0 ]
    then 
        echo "$2 succefully completed"
    else    
        echo "$2 failed to complete"
    fi
}

dnf install python3.11 gcc python3-devel -y &>>$LOGFILE
validate $? "Installing python"

id roboshop &>>$LOGFILE
if [ $? -eq 0 ]
then 
    echo "user exists"
else 
    useradd roboshop &>>$LOGFILE
    validate $? " adding roboshop"
fi

if [ -d "$DIRECTORY" ]; 
then
    echo "removing the directory"
    rm -rf $DIRECTORY
    mkdir -p  $DIRECTORY
else
    mkdir -p $DIRECTORY
fi

curl -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip &>>$LOGFILE
validate $? "download payment code"

cd /app  &>>$LOGFILE
validate $? "moving to app folder"

unzip /tmp/payment.zip &>>$LOGFILE
validate $? "Unzip the payment service"

pip3.11 install -r requirements.txt &>>$LOGFILE
validate $? "Installing modules"

cp -rf /home/ec2-user/Roboshop_linux/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
validate $? " cp payment service to  systemd"

systemctl daemon-reload &>>$LOGFILE
validate $? "deamon -relaod"

systemctl enable payment &>>$LOGFILE
validate $? "Start the enable service"

systemctl start payment &>>$LOGFILE
validate $? "Start the enable service"



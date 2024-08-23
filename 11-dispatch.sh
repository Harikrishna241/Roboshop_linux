#! /bin/bash

USERID=$(id -u )
TIMESTAMP=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$Script_Name-$TIMESTAMP.log

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

dnf install golang -y &>>$LOGFILE
validate $? "Installing golang"

useradd roboshop &>>$LOGFILE
validate  $? "user creation"

mkdir /app &>>$LOGFILE
validate $? "creating app folder"

curl -L -o /tmp/dispatch.zip https://roboshop-builds.s3.amazonaws.com/dispatch.zip &>>$LOGFILE
validate $? "download the dispatch code"

cd /app &>>$LOGFILE
validate $? "moving to app folder"

unzip /tmp/dispatch.zip &>>$LOGFILE
validate $? "Unzip the source code"

# dependencies 
cd /app 
go mod init dispatch
go get 
go build

cp -rf dispatch.service /etc/systemd/system/dispatch.service &>>$LOGFILE
validate $? "copying the service file"

systemctl daemon-reload &>>$LOGFILE
validate $? "daemon reload"

systemctl enable dispatch &>>$LOGFILE 
validate $? "Enabling the disapatch"

systemctl start dispatch &>>$LOGFILE
validate $? "start dispatch service"

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

dnf install maven -y &>>$LOGFILE
validate $? "installing maven"

useradd roboshop &>>$LOGFILE
validate $? "Creating roboshop user"

if [ -d "$DIRECTORY" ]; 
then
    echo "removing the directory"
    rm -rf $DIRECTORY
    mkdir -p  $DIRECTORY
else
    mkdir -p $DIRECTORY
fi

curl  -o /tmp/shipping.zip https://roboshop-builds.s3.amazonaws.com/shipping.zip &>>$LOGFILE
validate $? "downloading shiiping code"

cd /app &>>$LOGFILE
validate $? "changing the app folder"

unzip /tmp/shipping.zip &>>$LOGFILE
validate $? "unzip the shiiping code"

mvn clean package &>>$LOGFILE
Validate $? "Clean package"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
validate $? "Changing shipping jar file name"

cp /home/ec2-user/Roboshop_linux/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
validate $? "Copy the service file to systemd"

systemctl daemon-reload &>>$LOGFILE
validate $? "deamon -relaod"

systemctl start shipping &>>$LOGFILE
validate $? "Start the shipping service"

dnf install mysql -y &>>$LOGFILE
validate $? "installing mysql"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/schema/shipping.sql &>>$LOGFILE
validate $? "loading schema to mysql" 

systemctl restart shipping &>>$LOGFILE
validate $? "restarting the shipping service"
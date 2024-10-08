#! /bin/bash

USERID=$(id -u )
TIMESTAMP=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$Script_Name-$TIMESTAMP.log

if [ $USERID -eq 0 ]
then 
    echo " you are in super user"
else 
    echo "please run the script in SU mode"
fi
validate(){

    if [ $1 -eq 0 ]
    then 
        echo "$2  successfully"
    else
        echo " $2  failed"
    fi
} 

cp -rf mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "mongodb copy"


dnf install mongodb-org -y &>>$LOGFILE
validate $? "mongodb installation"


systemctl enable mongod &>>$LOGFILE
validate $? "enabling mongodb"

systemctl start mongod &>>$LOGFILE
validate $? "mongodb start"


#vim /etc/mongod.conf
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOGFILE
validate $? "Remote server access"

systemctl restart mongod &>>$LOGFILE
validate $? "mongodb restart"


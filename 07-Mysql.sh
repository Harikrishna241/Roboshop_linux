#! /bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." =f1)
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

dnf install mysql-server -y &>>$LOGFILE
validate $? "mysql server installation"

systemctl enable mysqld &>>$LOGFILE
validate $? "mysql server enable"

systemctl start mysqld &>>$LOGFILE
validate $? "mysql start"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOGFILE
validate $? "Setting root password"

#mysql -uroot -pRoboShop@1
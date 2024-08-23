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

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>>$LOGFILE
validate $? "Package cloud download"

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>>$LOGFILE
validate $? "Package cloud download"

dnf install rabbitmq-server -y &>>$LOGFILE
validate $? "rabbitmq insatallation"

systemctl enable rabbitmq-server &>>$LOGFILE 
validate $? "enabling rabbitmmq"

systemctl start rabbitmq-server &>>$LOGFILE
validate $? "starting rabbit mq"

rabbitmqctl add_user roboshop roboshop123 &>>$LOGFILE
validate $? "Creating a user"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGFILE
validate $? "setting permission"

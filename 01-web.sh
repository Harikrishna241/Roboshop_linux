USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
Script_Name=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$Script_Name-$TIMESTAMP.log

if [ $USERID -eq 0 ]
then 
    echo "you are in super usermode" 
else 
    echo "you need to run the script in SU mode"
    exit 1
fi

validate(){

    if [ $1 -eq 0 ]
    then 
        echo " $2 is successful"
    else 
        echo "$2 is failure "
    fi 

}

dnf install nginx -y &>>$LOGFILE
validate $? "nginx installation"

systemctl enable nginx &>>$LOGFILE
validate $? "Nginx enable "

systemctl start nginx &>>$LOGFILE
validate $? "Start nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
validate $? "removing the Nginx"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip &>>$LOGFILE
validate $? "Download the web code"

cd /usr/share/nginx/html &>>$LOGFILE
validate $? "change the folder"

unzip /tmp/web.zip &>>$LOGFILE
validate $? "unzip the code"

cp -rf roboshop.conf  /etc/nginx/default.d/roboshop.conf &>>$LOGFILE
validate $? "copy roboshop file"

systemctl restart nginx  &>>$LOGFILE
validate $? "Restart the nginx"

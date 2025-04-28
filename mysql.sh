#!/bin/bash
 
 USERID=$(id -u)
 TIMESTAMP=$(date +%F-%H-%M-%S)
 SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
 LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
 R="\e[31m"
 G="\e[32m"
 Y="\e[33m"
 N="\e[0m"
 
 VALIDATE(){
    if [ $1 -ne 0 ]
    then
         echo -e "$2...$R FAILURE $N"
         exit 1
     else
         echo -e "$2...$G SUCCESS $N"
     fi
 }
 
 if [ $USERID -ne 0 ]
 then
     echo "Please run this script with root access."
     exit 1 # manually exit if error comes.
 else
     echo "You are super user."
 fi
 
 
 dnf install mysql-server -y &>>$LOGFILE
 VALIDATE $? "Installing MySQL Server"
 
 systemctl enable mysqld &>>$LOGFILE
 VALIDATE $? "Enabling MySQL Server"
 
 systemctl start mysqld &>>$LOGFILE
 VALIDATE $? "Starting MySQL Server"
 
#  mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#  VALIDATE $? "Setting up root password"

# Below code will be usefull for idempotent nature
# Shell script does not support idempotency
# Idempotent --> Result should not change even though how many times we run the script

mysql -h db.daws-78s.space -uroot -pExpenseApp@1 -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
    VALIDATE $? "MySQL root password setup"
else
    echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi
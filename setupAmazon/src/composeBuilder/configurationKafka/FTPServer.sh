#!/usr/bin/env bash
#!/usr/bin/env bash
#
# @created by Eynar
# @date 28/03/2018
#


# $1 : String IP
# $2 : String USER
# $3 : String PASSWORD
# $4 : String ORIGEN_PATH
# $5 : String PROCESSED_PATH

setupFTP(){

    # variables
    IP=$1
    USER=$2
    PASSWORD=$3
    ORIGEN_PATH=$4
    PROCESSED_PATH=$5
    PATH_FTP_FOLDER=/home/ftp
    PORT=21

    sudo mkdir $PATH_FTP_FOLDER
    cd $PATH_FTP_FOLDER
    sudo mkdir $ORIGEN_PATH
    sudo mkdir $PROCESSED_PATH
    sudo chown _apt:input $PATH_FTP_FOLDER/$ORIGEN_PATH
    sudo chown _apt:input $PATH_FTP_FOLDER/$PROCESSED_PATH

    chmod 777 -R $PATH_FTP_FOLDER

echo "from pyftpdlib.authorizers import DummyAuthorizer
from pyftpdlib.handlers import FTPHandler
from pyftpdlib.servers import FTPServer
authorizer = DummyAuthorizer()
authorizer.add_user(\"$USER\", \"$PASSWORD\", \"$PATH_FTP_FOLDER\", perm=\"elradfmw\")
handler = FTPHandler
handler.authorizer = authorizer
server = FTPServer((\"$IP\", $PORT), handler)
server.serve_forever()" > /home/ftp-server.py

    sleep 5s
    sudo pip install pyftpdlib
    echo "FTP Server Ready to Run"
}


startFTP(){
    sleep 15s
    VIZIX_COMPOSE=$1
    file="/tmp/pythonFTPServer.log"
    if [ -f "$file" ]
    then
        PID_FTP=$(cat /tmp/pythonFTPServer.log | grep pid | cut -d "=" -f2 |tr -d ' '| tr '<' ' ')
        echo "INFO > FTP PID : $PID_FTP"
        echo "INFO > kill -9 $PID_FTP"
        kill -9 $PID_FTP
        echo "INFO > Ftp Server was killed"
    fi
    sleep 15s
    echo "INFO > FTP will be started."
    echo "INFO > sudo nohup python /home/ftp-server.py > /tmp/pythonFTPServer.log 2>&1 &"
    sudo nohup python /home/ftp-server.py > /tmp/pythonFTPServer.log 2>&1 &
    sleep 30s
    echo "INFO> waiting 90 seconds while FTP Server is starting ..."
    echo "INFO> PID FTP : "$(cat /tmp/pythonFTPServer.log | grep pid)
    #netstat -ntlp check manually port used
    echo "INFO> FTP has started....."
}



#**************************** MAIN ******************************#
#@parameters
# $1 : String IP
# $2 : String USER
# $3 : String PASSWORD
# $4 : String ORIGEN_PATH
# $5 : String PROCESSED_PATH

IP=$1
USER=$2
PASSWORD=$3
ORIGEN_PATH=$4
PROCESSED_PATH=$5

setupFTP $IP $USER $PASSWORD $ORIGEN_PATH $PROCESSED_PATH
startFTP
#!/usr/bin/env bash
# @autor: Eynar Pari
# @date : 18/06/2018

#global var
IS_IT_COPIED=1

#@params
# $1 PATH_FILE_PEM -> String path of pem file (i.e.: /tmp/pems/)
# $2 LOCAL_PATH_TO_COPY > String local path to copied the reports.json (i.e.: /tmp/)
# $3 IP_LIST_FILE -> String path of ips.txt (i.e.: /tmp/ips.txt)
getJsonReport(){
   #params
    PATH_FILE_PEM=$1
    LOCAL_PATH_TO_COPY=$2
    IP_LIST_FILE=$3

    for line in $(cat ${IP_LIST_FILE} | grep -v "^$"); do
            echo "INFO > Search on : $line"
            existFile $PATH_FILE_PEM $LOCAL_PATH_TO_COPY
    done
    echo "INFO> Completed !"
}

#@params
# $1 String path of pem file (i.e.: /tmp/pems/)
# $2 String local path to copie the reports.json (i.e.: /tmp/)
existFile(){
    IS_IT_COPIED=1
    PATH_FILE_PEM=$1
    LOCAL_PATH_TO_COPY=$2
    while [[ $IS_IT_COPIED -eq 1 ]];do
             sleep 30
              echo "INFO > waiting while the report.json is creating on $line ...."
             if ssh -i $PATH_FILE_PEM/awsqa.pem ubuntu@$line "stat /home/ubuntu/vizix_repositories/vizix-qa-automation/build/reports/cucumber/done.json > /dev/null 2>&1";
             then
                if ssh -i $PATH_FILE_PEM/awsqa.pem ubuntu@$line "stat /home/ubuntu/vizix_repositories/vizix-qa-automation/build/reports/cucumber/report.tar.gz > /dev/null 2>&1";
                then
                    scp -i $PATH_FILE_PEM/awsqa.pem ubuntu@$line:/home/ubuntu/vizix_repositories/vizix-qa-automation/build/reports/cucumber/report.tar.gz $LOCAL_PATH_TO_COPY/$line.tar.gz;
                    echo "INFO > file was copied $line"
                    sleep 30
                    IS_IT_COPIED=0
                else
                    echo "INFO > file report.json was not copied $line"
                    IS_IT_COPIED=1
                fi
             else
                    echo "INFO > file done.json does not exist on $line"
                    IS_IT_COPIED=1
             fi
             echo "INFO > value copied : $IS_IT_COPIED"
        done
}

################ MAIN ####################

echo "**********[Bash Script]**************"
echo "*   Get Json Report of Cloud VM     *"
echo "*************************************"

PATH_FILE_PEM=$1
LOCAL_PATH_TO_COPY=$2
IP_LIST_FILE=$3
getJsonReport $PATH_FILE_PEM $LOCAL_PATH_TO_COPY $IP_LIST_FILE


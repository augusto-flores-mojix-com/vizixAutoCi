#!/usr/bin/env bash

#-----------------------------------------
# $1 - IP from where to download the report
# $2 - Local path in which to save the report
# $3 - Location of private key (i.e: ~/.ssh/aws.pem)
#-----------------------------------------
exist_file_cucumber(){
isItCopied=1
filePath=$2
while [[ $isItCopied -eq 1 ]];do
         sleep 5
         echo "waiting while the cucumber report.json is creating on $1 ...."
         if ssh -i $3 ubuntu@$1 "stat /tmp/done.json > /dev/null 2>&1";
         then
            if ssh -i $3 ubuntu@$1 "stat /home/ubuntu/vizix_repositories/vizix-qa-automation/build/reports/cucumber/report.tar.gz > /dev/null 2>&1";
            then
                scp -i $3 ubuntu@$1:/home/ubuntu/vizix_repositories/vizix-qa-automation/build/reports/cucumber/report.tar.gz $filePath/$1.tar.gz;
                echo "cucumber file was copied $1"
                sleep 5
                isItCopied=0
            else
                echo "cucumber file report.json was not copied $1"
                isItCopied=1
            fi
         else
            echo "cucumber file done.json does not exist on $1"
            isItCopied=1
         fi
         echo "cucumber value copied : $isItCopied"
    done
}

#-----------------------------------------
# $1 - IP from where to download the report
# $2 - Local path in which to save the report
# $3 - Location of private key (i.e: ~/.ssh/aws.pem)
#-----------------------------------------
exist_file_jmeter(){
isItCopied=1
filePath=$2
while [[ $isItCopied -eq 1 ]];do
         sleep 5
          echo "waiting while the jmeter report.json is creating on $1 ...."
          if ssh -i $3 ubuntu@$1 "stat /tmp/done.json > /dev/null 2>&1";
            then
                if ssh -i $3 ubuntu@$1 "stat /home/ubuntu/vizix_repositories/vizix-qa-automation-jmeter/vizix.automation.performance/*.tar.gz";
                then
                    scp -i $3 ubuntu@$1:/home/ubuntu/vizix_repositories/vizix-qa-automation-jmeter/vizix.automation.performance/*.tar.gz $filePath;
                    echo "jmeter file was copied $1"
                    sleep 5
                    isItCopied=0
                else
                    echo "jmeter file report.json was not copied $1"
                    isItCopied=1
                fi
            else
                echo "jmeter file done.json does not exist on $1"
                isItCopied=1
         fi
         echo "jmeter value copied : $isItCopied"
    done
}

# --------------Main--------------------
# Script to download the result reports
#@params
# $1 - String : kind of execution (i.e: cucumber/jmeter)
# $2 - String : Local path where to save the reports (i.e: /tmp)
# $3 - String : IP from client from where to download the report (i.e: 54.158.234.194)
# $4 - String : Location of private key (i.e: ~/.ssh/aws.pem)
#======================================================================
TYPE_EXECUTION=$1
PATH_REPORTS=$2
PUBLIC_IP=$3
KEY_PATH=$4
#=====================================================================
export PATH=$PATH:/bin:/usr/bin
echo "Start Script: Get Reports"
mkdir -p ${PATH_REPORTS}reports
case "$TYPE_EXECUTION" in

cucumber)
    echo "exist_file_cucumber" $PUBLIC_IP ${PATH_REPORTS}reports $KEY_PATH
    exist_file_cucumber $PUBLIC_IP ${PATH_REPORTS}reports $KEY_PATH
    ;;
jmeter)
    echo "exist_file_jmeter" $PUBLIC_IP ${PATH_REPORTS}reports $KEY_PATH
    exist_file_jmeter $PUBLIC_IP ${PATH_REPORTS}reports $KEY_PATH
    ;;
both)
    echo "both"
    exist_file_cucumber $PUBLIC_IP ${PATH_REPORTS}reports $KEY_PATH
    exist_file_jmeter $PUBLIC_IP ${PATH_REPORTS}reports $KEY_PATH
    ;;
*) echo "Option: $1 will not be processed"
   ;;
esac

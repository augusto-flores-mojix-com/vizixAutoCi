#!/bin/bash
set -e

execute_ui() {
    echo "********************************************************************************************************"
    echo "*                                  RUN PERFORMANCE TEST UI                                             *"
    echo "********************************************************************************************************"
    MANAGER_PUBLIC_IP=$1
    CATEGORY_TO_EXECUTE=$(echo $2 | tr '*' ' ')
    PATH_REPOS=$3
    PATH_COMPOSE=$4
    REPORT_SAVED=$5/UI
    echo "****************** PARAMETERS **********************"
    echo "MANAGER_PUBLIC_IP: "$MANAGER_PUBLIC_IP
    echo "CATEGORY_TO_EXECUTE: "$CATEGORY_TO_EXECUTE
    echo "PATH_REPOS: "$PATH_REPOS
    echo "PATH_COMPOSE: "$PATH_COMPOSE
    echo "REPORT_SAVED: "$REPORT_SAVED
    echo "****************** ********** **********************"

    AUTOMATION_PATH=$PATH_REPOS/vizix-qa-automation
    ARRAY=($CATEGORY_TO_EXECUTE)
    echo "INFO > # of elements to create: "${ARRAY[1]}

    cd $AUTOMATION_PATH
    export GRADLE_HOME=/usr/local/gradle
    echo $GRADLE_HOME
    export PATH=$GRADLE_HOME/bin:$PATH
    echo $PATH
    mkdir -p $REPORT_SAVED
    echo "INFO > gradle clean automationTest -Pcategory=@SetupPerformanceUI -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=CHROMEGRID" ${ARRAY[1]}
    gradle clean automationTest -Pcategory=@SetupPerformanceUI -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=CHROMEGRID ${ARRAY[1]}
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/SetupPerfUI$MANAGER_PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=CHROMEGRID"
    gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotKafka -PisUsingMosquitto=true -PrefreshCoreBridge=20 -PservicesProcessingTime=20 -PmongoProcessingTime=20 -Puser=root -Ppwd=Control123! -Pport=80 -PaleDataPort=9091 -PisUsingtoken=False -Pbrowser=CHROMEGRID
}

# =================================================================================
# $1 - String : Ip to use as server for the execution (i.e: 172.31.16.200)
# $2 - String : Category to execute (i.e: WebUIPerformance)
# $3 - String : Main path of repos (i.e. /home/ubuntu/vizix_repositories)
# $4 - String : Path of compose files (i.e. /home/ubuntu/vizix-compose)
# $4 - String : Path to save the result files (i.e. /tmp/)
# =================================================================================
echo "INFO> execute_ui" $1 $2 $3 $4 $5
execute_ui $1 $2 $3 $4 $5

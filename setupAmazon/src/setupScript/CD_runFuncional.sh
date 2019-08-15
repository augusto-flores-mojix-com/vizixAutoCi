#!/usr/bin/env bash
#
# @autor:Eynar Pari
# @date : 14/03/18
#

# This method is to execute functional test categories
# and generated the done.json report
# @params
# $1 String = AUTOMATION_PATH (Automation Folder Path)
# $2 String = CATEGORY_TO_EXECUTE (Category to execute also it can contain parameters)
# $3 String = PRIVATE_IP (private IP)
# $4 String = PUBLIC_IP (public IP)
# $5 String = REPORT_SAVED (path to save report /home/ubuntu/reports)
# $6 Boolean = IS_KAFKA (true or false)
# $7 VIZIX_COMPOSE
# $8 PARAMETERS_TO_ADD
runAutomatedTest(){
   echo "********************************************************************************************************"
   echo "*                      RUN  FUNCTIONAL TEST FOR BRIDGES & SERVICES                                     *"
   echo "********************************************************************************************************"

    local startTime=$(date)

    # vars
    ##################
    AUTOMATION_PATH=$1
    CATEGORY_TO_EXECUTE=$(echo $2 | tr '*' ' ')
    PRIVATE_IP=$3
    PUBLIC_IP=$4
    REPORT_SAVED=$5
    IS_KAFKA=$6
    VIZIX_COMPOSE=$7
    PARAMETERS_TO_ADD=$(echo $8 | tr '*' ' ')
    ###################

    echo "INFO > clean report folder"
    echo "INFO > exporting gradle var env on machine"
    export GRADLE_HOME=/usr/local/gradle
    export PATH=${GRADLE_HOME}/bin:${PATH}

    cd $AUTOMATION_PATH

    if [ "$IS_KAFKA" == "true" ]
    then
      echo "INFO > gradle clean automationTest -Pnocategory=~@NotKafka -PisUsingMosquitto=true -PkafkaHost=$PRIVATE_IP:9092 -PrefreshCoreBridge=5 -PservicesProcessingTime=5 -PmongoProcessingTime=20 -Puser=root -Ppwd=Control123! -Pport=80 -PaleDataPort=9091 -PdockerPath=$VIZIX_COMPOSE -Pcategory=@$CATEGORY_TO_EXECUTE $PARAMETERS_TO_ADD"
      gradle clean automationTest -Pnocategory=~@NotKafka -PisUsingMosquitto=true -PkafkaHost=$PRIVATE_IP:9092 -PrefreshCoreBridge=5 -PservicesProcessingTime=5 -PmongoProcessingTime=20 -Puser=root -Ppwd=Control123! -Pport=80 -PaleDataPort=9091 -PdockerPath=$VIZIX_COMPOSE -Pcategory=@$CATEGORY_TO_EXECUTE $PARAMETERS_TO_ADD
    else
      echo "INFO > gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -Puser=root -Ppwd=Control123! -Pport=80 -PhazelcastAddress=hazelcast -PrefreshCoreBridge=10 -PdockerPath=$VIZIX_COMPOSE $PARAMETERS_TO_ADD"
      gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -Puser=root -Ppwd=Control123! -Pport=80 -PhazelcastAddress=hazelcast -PrefreshCoreBridge=10 -PdockerPath=$VIZIX_COMPOSE $PARAMETERS_TO_ADD
    fi

    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/ExecutionTest$PUBLIC_IP.json
    sleep 15

    local endTime=$(date)

    echo "INFO > Suite : [$CATEGORY_TO_EXECUTE] , Start Time : [$startTime]  -  End Time: [$endTime] "  > $REPORT_SAVED/suiteTime$PUBLIC_IP.txt
    cp /tmp/setuplog.log $REPORT_SAVED/reconfigureAndExecution$PUBLIC_IP.txt && sleep 5s

    cd $REPORT_SAVED
    sleep 10s
    echo $(pwd)
    tar -zcvf report.tar.gz *.*
    cp report.tar.gz $AUTOMATION_PATH/build/reports/cucumber/report.tar.gz
    echo "completed" > $AUTOMATION_PATH/build/reports/cucumber/done.json
    sudo rm -rf $REPORT_SAVED
    sudo mkdir $REPORT_SAVED
}
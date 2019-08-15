#!/usr/bin/env bash
#
# @autor:Eynar Pari
# @date : 10/06/19
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
# $8 TENANT1
# $9 TENANT2
# $10 PARAMETERS_TO_ADD
runMultitenancyAutomatedTest(){
    echo "********************************************************************************************************"
    echo "*                      RUN  FUNCTIONAL TEST FOR BRIDGES & SERVICES                                     *"
    echo "********************************************************************************************************"

    local startTime=$(date)

    # vars
    ##################
    local AUTOMATION_PATH=$1
    local CATEGORY_TO_EXECUTE=$(echo $2 | tr '*' ' ')
    local PRIVATE_IP=$3
    local PUBLIC_IP=$4
    local REPORT_SAVED=$5
    local IS_KAFKA=$6
    local VIZIX_COMPOSE=$7
    local TENANT1=$8
    local TENANT2=$9
    local PARAMETERS_TO_ADD=$(echo ${10} | tr '*' ' ')
    ###################

    echo "INFO > clean report folder"
    echo "INFO > exporting gradle var env on machine"
    export GRADLE_HOME=/usr/local/gradle
    export PATH=${GRADLE_HOME}/bin:${PATH}

    cd $AUTOMATION_PATH

    echo "INFO > gradle clean automationTest -POrganizationShopCX=$TENANT1 -Pnocategory=~@NotKafka -PisUsingMosquitto=true -PkafkaHost=$PRIVATE_IP:9092 -PrefreshCoreBridge=5 -PservicesProcessingTime=5 -PmongoProcessingTime=20 -Puser=${TENANT1}root1 -Ppwd=Control123! -Pport=80 -PaleDataPort=9091 -PdockerPath=$VIZIX_COMPOSE -Pcategory=@$CATEGORY_TO_EXECUTE $PARAMETERS_TO_ADD"
    gradle clean automationTest -POrganizationShopCX=$TENANT1 -Pnocategory=~@NotKafka -PisUsingMosquitto=true -PkafkaHost=$PRIVATE_IP:9092 -PrefreshCoreBridge=5 -PservicesProcessingTime=5 -PmongoProcessingTime=20 -Puser=${TENANT1}root1 -Pport=80 -PaleDataPort=9091 -PdockerPath=$VIZIX_COMPOSE -Pcategory=@$CATEGORY_TO_EXECUTE $PARAMETERS_TO_ADD
    addWordToScenarios $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/ExecutionTest${TENANT1}${PUBLIC_IP}.json $TENANT1
    sleep 15

    echo "INFO > gradle clean automationTest -POrganizationShopCX=$TENANT2 -Pnocategory=~@NotKafka -PisUsingMosquitto=true -PkafkaHost=$PRIVATE_IP:9092 -PrefreshCoreBridge=5 -PservicesProcessingTime=5 -PmongoProcessingTime=20 -Puser=${TENANT2}root1 -Ppwd=Control123! -Pport=80 -PaleDataPort=9091 -PdockerPath=$VIZIX_COMPOSE -Pcategory=@$CATEGORY_TO_EXECUTE $PARAMETERS_TO_ADD"
    gradle clean automationTest -POrganizationShopCX=$TENANT2 -Pnocategory=~@NotKafka -PisUsingMosquitto=true -PkafkaHost=$PRIVATE_IP:9092 -PrefreshCoreBridge=5 -PservicesProcessingTime=5 -PmongoProcessingTime=20 -Puser=${TENANT2}root1 -Ppwd=Control123! -Pport=80 -PaleDataPort=9091 -PdockerPath=$VIZIX_COMPOSE -Pcategory=@$CATEGORY_TO_EXECUTE $PARAMETERS_TO_ADD

    addWordToScenarios $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/ExecutionTest${TENANT2}${PUBLIC_IP}.json $TENANT2
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

#ORIGINAL_JSON_FILE
#UPDATE_JSON_FILE
#WORD_TO_ADD
addWordToScenarios(){
    local ORIGINAL_JSON_FILE=$1
    local UPDATE_JSON_FILE=$2
    local WORD_TO_ADD=$3

    local TMP_JSON_NAMES=/tmp/jsonNames.txt

    cat $ORIGINAL_JSON_FILE | jq ".[].name" > $TMP_JSON_NAMES

    echo "INFO > names to update : " && cat $TMP_JSON_NAMES

   while IFS= read -r line
   do
     local tmpLine=$(echo $line | tr -d '"')
     local lineToReplace="\"Tenant ${WORD_TO_ADD}: ${tmpLine}\""
     local lineToReplace=$(echo $lineToReplace | sed -r 's/\//\\\//g' | sed -r 's/"/\\"/g' )
     local lineOriginal=$(echo $line | sed -r 's/\//\\\//g' | sed -r 's/"/\\"/g')
     sed -i "s/$lineOriginal/$lineToReplace/g" $ORIGINAL_JSON_FILE
   done < "$TMP_JSON_NAMES"

   cat $ORIGINAL_JSON_FILE > $UPDATE_JSON_FILE
   echo "INFO > names updated :"
   cat $UPDATE_JSON_FILE | jq .[].name
}
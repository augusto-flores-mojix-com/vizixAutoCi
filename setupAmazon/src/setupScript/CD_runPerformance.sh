#!/usr/bin/env bash
#
# @autor:Eynar Pari
# @date : 15/04/2018
#

# This method is to execute the Jmeter Performance Test for services
# $1 PARAMETERS_JMETER
# $2 AUTOMATION_JMETER_PATH
# $3 PRIVATE_IP
# $4 REPORT_SAVED
# $5 VIZIX_COMPOSE
# $6 TOOL_JMETER_PATH
# $7 AUTOMATION_PATH
runPerformanceServicesTest(){
   echo "********************************************************************************************************"
   echo "*                      RUN  PERFORMANCE TEST FOR SERVICES                                              *"
   echo "********************************************************************************************************"

    PARAMETERS_JMETER=$(echo $1 | tr '*' ' ')
    AUTOMATION_JMETER_PATH=$2
    PRIVATE_IP=$3
    REPORT_SAVED=$4
    VIZIX_COMPOSE=$5
    TOOL_JMETER_PATH=$6
    AUTOMATION_PATH=$7
    PORT=80

    export ANT_HOME=/usr/share/ant && export PATH=${ANT_HOME}/bin:${PATH}
    export PATH=${TOOL_JMETER_PATH}/bin:${PATH}

    echo "INFO > -----------------------------Automated Performance Test is staring---------------------------------"
    cd $AUTOMATION_JMETER_PATH
    echo "INFO > ./runJmeterTest.sh $PARAMETERS_JMETER $PRIVATE_IP $PORT $REPORT_SAVED $AUTOMATION_JMETER_PATH $TOOL_JMETER_PATH"
    ./runJmeterTest.sh $PARAMETERS_JMETER $PRIVATE_IP $PORT $REPORT_SAVED $AUTOMATION_JMETER_PATH $TOOL_JMETER_PATH > $REPORT_SAVED/jmeterExecution.log
    echo "INFO > Showing Execution Logs ..."
    cat $REPORT_SAVED/jmeterExecution.log
    echo "INFO > Getting the html results to join and compress"

    cd $REPORT_SAVED && sleep 10s && echo $(pwd)
    tar -zcvf report.tar.gz *
    cp report.tar.gz $AUTOMATION_PATH/build/reports/cucumber/report.tar.gz
    echo "completed" > $AUTOMATION_PATH/build/reports/cucumber/done.json
    echo "INFO >-----------------------------Automated Performance Test were executed---------------------------------"
    sudo rm -rf $REPORT_SAVED
    sudo mkdir $REPORT_SAVED
}

# $1 AUTOMATION_PATH
# $2 CATEGORY_TO_EXECUTE
# $3 PRIVATE_IP
# $4 PUBLIC_IP
# $5 REPORT_SAVED
# $6 VIZIX_KAFKA_REPOSITORY
runPerformanceUITest(){
    echo "********************************************************************************************************"
    echo "*                                   RUN  UI PERFORMANCE TEST ON DOCKER                                 *"
    echo "********************************************************************************************************"
    #######################
    AUTOMATION_PATH=$1
    CATEGORY_TO_EXECUTE=$(echo $2 | tr '*' ' ')
    PRIVATE_IP=$3
    PUBLIC_IP=$4
    REPORT_SAVED=$5
    VIZIX_KAFKA_REPOSITORY=$6
    BROWSER=CHROMEGRID
    #######################

    echo "INFO > Configuring Container UI to use private IP"
    cd $VIZIX_KAFKA_REPOSITORY

    echo "INFO > sed -i "/SERVICES_URL=/c SERVICES_URL=$PRIVATE_IP:80" .env"
    sudo sed -i "/SERVICES_URL=/c SERVICES_URL=$PRIVATE_IP:80" .env
    cat .env && sudo docker-compose up -d ui && sudo docker-compose -f vizix-automation-ui.yml up -d

    echo "INFO > clean report folder"
    sudo rm -rf $REPORT_SAVED && sudo mkdir $REPORT_SAVED
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}

    cd $AUTOMATION_PATH

    echo "INFO > gradle clean automationTest -Pcategory=@SetupPerformanceUI -Pnocategory=~@NotImplemented -PisUsingtoken=False -P-PnumberThingsSimulation=10000 -PbrowserOrMobile=$BROWSER"
    gradle clean automationTest -Pcategory=@SetupPerformanceUI -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER -PnumberThingsSimulation=10000
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/SetupPerfUI$PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER"
    gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/ExecutionTest$PUBLIC_IP.json

    sleep 15 && echo "INFO > saving performance reports"
    cd $REPORT_SAVED && sleep 10s
    tar -zcvf report.tar.gz *.*
    cp report.tar.gz $AUTOMATION_PATH/build/reports/cucumber/report.tar.gz
    echo "completed" > $AUTOMATION_PATH/build/reports/cucumber/done.json
}

#
# PENDING...
# TODO
#
runPerformanceBridgesKafkaTest(){
   echo "********************************************************************************************************"
   echo "*                      RUN  PERFORMANCE TEST FOR KAFKA COREBRIDGE                                      *"
   echo "********************************************************************************************************"
}

# $1 PATH_COLLECTOR_SCRIPT
# $2 AUTOMATION_PATH
# $3 CATEGORY_TO_EXECUTE
# $4 NUMBER_THREADS_CB
# $5 PRIVATE_IP
# $6 PUBLIC_IP
runPerformanceBridgesCbMtTest(){
   echo "********************************************************************************************************"
   echo "*                      RUN  PERFORMANCE TEST FOR COREBRIDGE MT                                         *"
   echo "********************************************************************************************************"

   PATH_COLLECTOR_SCRIPT=$1
   AUTOMATION_PATH=$2
   CATEGORY_TO_EXECUTE=$3
   NUMBER_THREADS_CB=$4
   PRIVATE_IP=$5
   PUBLIC_IP=$6
   MAIN_PATH="/home/ubuntu"
   REPORT_PYTHON_PATH="reportPython"

    echo "INFO > Starting to collect metrics for docker resources"
    cd $PATH_COLLECTOR_SCRIPT
    nohup ./collectorMetrics.sh &

    echo "INFO > Collecting data [5 minutes] before start the test" && sleep 300
    cd $AUTOMATION_PATH

    echo "INFO > gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented "
    gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_PYTHON_PATH/ExecutionTest$PUBLIC_IP.json

    echo "INFO > Collecting data [5 minutes] after complete the test" && sleep 300

    mkdir $MAIN_PATH/$REPORT_PYTHON_PATH
    cd $AUTOMATION_PATH
    ID_DOCKER=$(docker inspect --format="{{.Id}}" corebridge)

    echo "INFO > gradle generatorPython -PactualBridgeLog=/var/lib/docker/containers/$ID_DOCKER/$ID_DOCKER-json.log -PnumberCores=$NUMBER_THREADS_CB -PreportPath=$REPORT_PYTHON_PATH -PisDockerLogFile=True -Pmongo_host=$PRIVATE_IP -Pfile_metrics_resources=/home/metrics.txt"
    gradle generatorPython -PactualBridgeLog=/var/lib/docker/containers/$ID_DOCKER/$ID_DOCKER-json.log -PnumberCores=$NUMBER_THREADS_CB -PreportPath=$REPORT_PYTHON_PATH -PisDockerLogFile=True -Pmongo_host=$PRIVATE_IP -Pfile_metrics_resources=/home/metrics.txt
    sleep 30

    cd $MAIN_PATH
    tar -zcvf report.tar.gz $REPORT_PYTHON_PATH/
    cp report.tar.gz $AUTOMATION_PATH/build/reports/cucumber/
    echo "completed" > $AUTOMATION_PATH/build/reports/cucumber/done.json
}
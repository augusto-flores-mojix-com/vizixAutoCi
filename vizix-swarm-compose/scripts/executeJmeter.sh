#!/bin/bash
set -e

execute_jmeter() {
    echo "********************************************************************************************************"
    echo "*                             RUN PERFORMANCE TEST JMETER                                              *"
    echo "********************************************************************************************************"

    PARAMETERS_JMETER=$(echo $1 | tr '*' ' ')
    PRIVATE_IP=$2
    REPORT_SAVED=$3/Jmeter
    PATH_REPOS=$4
    TOOL_JMETER_PATH=$5
    echo "****************** PARAMETERS **********************"
    echo "PARAMETERS_JMETER: "$PARAMETERS_JMETER
    echo "PRIVATE_IP: "$PRIVATE_IP
    echo "REPORT_SAVED: "$REPORT_SAVED
    echo "PATH_REPOS: "$PATH_REPOS
    echo "TOOL_JMETER_PATH: "$TOOL_JMETER_PATH
    echo "****************** ********** **********************"
    AUTOMATION_JMETER_PATH=$PATH_REPOS/vizix-qa-automation-jmeter/vizix.automation.performance
    PORT=80

    export ANT_HOME=/usr/share/ant
    export PATH=${ANT_HOME}/bin:${PATH}
    export PATH=${TOOL_JMETER_PATH}/bin:${PATH}
    export GRADLE_HOME=/usr/local/gradle
    export PATH=${GRADLE_HOME}/bin:${PATH}
    export PATH=$PATH:/bin:/usr/bin

#    sudo sed -i s/JMETER_MIN_HEAP_VALUE/512/g /home/ubuntu/vizix_repositories/apache-jmeter-3.2/bin/jmeter
#    sudo sed -i s/JMETER_MAX_HEAP_VALUE/$HEAP_MAX_MEMORY/g /home/ubuntu/vizix_repositories/apache-jmeter-3.2/bin/jmeter
    mkdir -p $REPORT_SAVED
    echo "INFO > -----------------------------Automated Jmeter Performance Test is staring---------------------------------"
    cd $AUTOMATION_JMETER_PATH
    echo "INFO > ./runJmeterTest.sh $PARAMETERS_JMETER $PRIVATE_IP $PORT $REPORT_SAVED $AUTOMATION_JMETER_PATH $TOOL_JMETER_PATH"
    ./runJmeterTest.sh $PARAMETERS_JMETER $PRIVATE_IP $PORT $REPORT_SAVED $AUTOMATION_JMETER_PATH $TOOL_JMETER_PATH > $REPORT_SAVED/jmeterExecution.log
    sleep 10
}

# This method is to execute the Jmeter Performance Test for services
# $1 PARAMETERS_JMETER      Separated by an '*' it contains the TEST_SCRIP_NAME,CONFIG_NUMBER_USERS, CONFIG_LOOP_VALUE, CONFIG_RAMPUP_PERIOD, PATH_SCRIPT (i.e. thingsImport*1*1*0*/test/services/importExport/)
# $2 PRIVATE_IP             IP of the server (i.e. 10.100.0.155)
# $3 REPORT_SAVED           File where to save the result of the execution (i.e. /tmp/reportPerformance)
# $4 PATH_REPOS             Path of automation repositories (i.e. /home/ubuntu/vizix_repositories)
# $5 TOOL_JMETER_PATH       Path where the Jmeter tool is (i.e. /home/ubuntu/files/apache-jmeter-3.2)
echo "INFO> execute_jmeter "$1 $2 $3 $4 $5
execute_jmeter $1 $2 $3 $4 $5

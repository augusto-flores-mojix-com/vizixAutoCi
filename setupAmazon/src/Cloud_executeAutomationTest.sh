#!/bin/bash
#
# @autor:Eynar Pari
# @date : 14/03/18
#

#@params
# $1 IPS_FILE
# $2 PEM_PATH
# $3 DOCKER_BRANCH_SERVICES
# $4 DOCKER_BRANCH_BRIDGES
# $5 DOCKER_BRANCH_UI
# $6 DOCKER_BRANCH_TOOLS
# $7 DOCKER_USER
# $8 DOCKER_PASSWORD
# $9 GIT_USER
# $10 GIT_PASSWORD
# $11 GIT_BRANCH
# $12 GIT_JMETER_BRANCH
# $13 NUMBER_THREADS_CB
# $14 IS_SETUP_ENV
# $15 POPDB_NAME
# $16 IS_KAFKA
# $17 BRANCH_CI
# $18 SUITE_FILE
# $19 CLOUD_TYPE
# $20 DOCKER_MICROSERVICES
executeAutomationTestOnCloud(){
    #params
    IPS_FILE=$1
    PEM_PATH=$2
    DOCKER_BRANCH_SERVICES=$3
    DOCKER_BRANCH_BRIDGES=$4
    DOCKER_BRANCH_UI=$5
    DOCKER_BRANCH_TOOLS=$6
    DOCKER_USER=$7
    DOCKER_PASSWORD=$8
    GIT_USER=$9
    GIT_PASSWORD=${10}
    GIT_BRANCH=${11}
    GIT_JMETER_BRANCH=${12}
    NUMBER_THREADS_CB=${13}
    IS_SETUP_ENV=${14}
    POPDB_NAME=${15}
    IS_KAFKA=${16}
    BRANCH_CI=${17}
    SUITE_FILE=${18}
    CLOUD_TYPE=${19}
    DOCKER_MICROSERVICES=${20}

    echo "INFO > reading ip ...."
    counter=1
    while IFS='' read -r ipLine || [[ -n "$ipLine" ]]; do
        echo "$ipLine"
        ssh-keyscan -H $ipLine >> ~/.ssh/known_hosts

        CATEGORY_TO_EXECUTE=$(awk 'NR=='"$counter"'{print $1}' ${SUITE_FILE})
        CONTAINER_TO_ADD=$(awk 'NR=='"$counter"'{print $2}' ${SUITE_FILE})
        TYPE_EXECUTION=$(awk 'NR=='"$counter"'{print $3}' ${SUITE_FILE})
        MIGRATION_CLIENT=$(awk 'NR=='"$counter"'{print $4}' ${SUITE_FILE})

        if [[ $CONTAINER_TO_ADD = "" ]]; then
            CONTAINER_TO_ADD=basic
        fi
        if [[ $TYPE_EXECUTION = "" ]]; then
            TYPE_EXECUTION=servicesBridges
        fi
        if [[ $MIGRATION_CLIENT = "" ]]; then
            MIGRATION_CLIENT=no_migration_test
        fi

        echo "INFO> Reading Suite File By Line"
        echo "INFO> Category To Execute : $CATEGORY_TO_EXECUTE , Docker compose to build $CONTAINER_TO_ADD , TypeExecution : $TYPE_EXECUTION and MigrationClient : $MIGRATION_CLIENT"
        connectionCloudAndRunUsingSSH $ipLine $PEM_PATH $DOCKER_BRANCH_SERVICES $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_UI $DOCKER_BRANCH_TOOLS $DOCKER_USER $DOCKER_PASSWORD $GIT_USER $GIT_PASSWORD $GIT_BRANCH $GIT_JMETER_BRANCH $NUMBER_THREADS_CB $IS_SETUP_ENV $IS_KAFKA $POPDB_NAME $CATEGORY_TO_EXECUTE $CONTAINER_TO_ADD $MIGRATION_CLIENT $TYPE_EXECUTION $BRANCH_CI $CLOUD_TYPE $DOCKER_MICROSERVICES
        counter=$(($counter+1));
    done < "$IPS_FILE"
}

# @params
# $1 IP_AWS String : ip to connect by ssh
# $2 PEM_PATH String : path aws pem (i.e:/tmp/pem/)
# $3 DOCKER_BRANCH_SERVICES
# $4 DOCKER_BRANCH_BRIDGES
# $5 DOCKER_BRANCH_UI
# $6 DOCKER_BRANCH_TOOLS
# $7 DOCKER_USER
# $8 DOCKER_PASSWORD
# $9 GIT_USER
# ${10} GIT_PASSWORD
# ${11} GIT_BRANCH
# ${12} GIT_JMETER_BRANCH
# ${13} NUMBER_THREADS_CB
# ${14} IS_SETUP_ENV
# ${15} IS_KAFKA
# ${16} POPDB_NAME
# ${17] CATEGORY_TO_EXECUTE String : automation tags to run
# ${18} CONTAINER_TO_ADD
# ${19} MIGRATION_CLIENT
# ${20} TYPE_EXECUTION String : automation tags to run
# ${21} BRANCH_CI
# ${22} CLOUD_TYPE
# ${23} DOCKER_MICROSERVICES
connectionCloudAndRunUsingSSH(){
    #@params
    IP_AWS=$1
    PEM_PATH=$2
    DOCKER_BRANCH_SERVICES=$3
    DOCKER_BRANCH_BRIDGES=$4
    DOCKER_BRANCH_UI=$5
    DOCKER_BRANCH_TOOLS=$6
    DOCKER_USER=$7
    DOCKER_PASSWORD=$8
    GIT_USER=$9
    GIT_PASSWORD=${10}
    GIT_BRANCH=${11}
    GIT_JMETER_BRANCH=${12}
    NUMBER_THREADS_CB=${13}
    IS_SETUP_ENV=${14}
    IS_KAFKA=${15}
    POPDB_NAME=${16}
    CATEGORY_TO_EXECUTE=${17}
    CONTAINER_TO_ADD=${18}
    MIGRATION_CLIENT=${19}
    TYPE_EXECUTION=${20}
    BRANCH_CI=${21}
    CLOUD_TYPE=${22}
    DOCKER_MICROSERVICES=${23}

    MAIN_SCRIPT_PATH_AUTOMATION_CI=/home/ubuntu/vizix_repositories/vizix-qa-automation-ci/setupAmazon/src/setupScript/CD_main.sh

    echo "INFO > Script "$MAIN_SCRIPT_PATH_AUTOMATION_CI
    echo "INFO > Connecting by ssh ...."
    COMMAND="sh -c 'sudo nohup $MAIN_SCRIPT_PATH_AUTOMATION_CI $DOCKER_BRANCH_SERVICES $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_UI $DOCKER_BRANCH_TOOLS $DOCKER_USER $DOCKER_PASSWORD $GIT_USER $GIT_PASSWORD $GIT_BRANCH $GIT_JMETER_BRANCH $CATEGORY_TO_EXECUTE $CONTAINER_TO_ADD $NUMBER_THREADS_CB $IS_SETUP_ENV $IS_KAFKA $POPDB_NAME $MIGRATION_CLIENT $TYPE_EXECUTION $CLOUD_TYPE $DOCKER_MICROSERVICES > /tmp/setuplog.log 2>&1 &'"

    if [ "$IS_SETUP_ENV" != "false" ]
    then
      echo "INFO > cloning automation ci , branch : $BRANCH_CI"
      ssh -n -i $PEM_PATH/awsqa.pem ubuntu@$IP_AWS "sh -c 'cd /home/ubuntu/vizix_repositories/ && sudo git clone -b $BRANCH_CI https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation-ci.git && sleep 15 '"
    fi

    echo "INFO > executing automation test cases"
    ssh -n -i $PEM_PATH/awsqa.pem ubuntu@$IP_AWS "$COMMAND"
    echo "INFO > script was launched" && echo "INFO > the execution logs will be attached in the cucumber report."
}


# ____main____
# $1 IPS_FILE (i.e. " /tmp/ip.txt)
# $2 PEM_PATH (i.e. " /tmp/")
# $3 DOCKER_BRANCH_SERVICES
# $4 DOCKER_BRANCH_BRIDGES
# $5 DOCKER_BRANCH_UI
# $6 DOCKER_BRANCH_TOOLS
# $7 DOCKER_USER
# $8 DOCKER_PASSWORD
# $9 GIT_USER
# $10 GIT_PASSWORD
# $11 GIT_BRANCH
# $12 GIT_JMETER_BRANCH
# $13 NUMBER_THREADS_CB
# $14 IS_SETUP_ENV (boolean true or false)
# $15 IS_KAFKA (boolean true or false)
# $16 POPDB_NAME (Automation)
# $17 BRANCH_CI (develop)
# $18 SUITE_FILE (/tmp/Suite)
# $19 CLOUD_TYPE (aws/azure/others)
# ${20} DOCKER_MICROSERVICES (i.e: vizix-tenant-versioning:dev_6.x.x,vizix-repository1:dev_6.x.x,vizix_repository2:dev_6.x.x)

IPS_FILE=$1
PEM_PATH=$2
DOCKER_BRANCH_SERVICES=$3
DOCKER_BRANCH_BRIDGES=$4
DOCKER_BRANCH_UI=$5
DOCKER_BRANCH_TOOLS=$6
DOCKER_USER=$7
DOCKER_PASSWORD=$8
GIT_USER=$9
GIT_PASSWORD=${10}
GIT_BRANCH=${11}
GIT_JMETER_BRANCH=${12}
NUMBER_THREADS_CB=${13}
IS_SETUP_ENV=${14}
POPDB_NAME=${15}
IS_KAFKA=${16}
BRANCH_CI=${17}
SUITE_FILE=${18}
CLOUD_TYPE=${19}
DOCKER_MICROSERVICES=${20}

echo "INFO > if docker microservices versions is empty, it takes the value empty"
if [ -z "$DOCKER_MICROSERVICES" ]
then
    DOCKER_MICROSERVICES="empty"
fi


echo "**************************[Bash Script]*******************************"
echo "*          Script : Executing automation test on $CLOUD_TYPE         *"
echo "**********************************************************************"
echo "INFO > path ips.txt : "$IPS_FILE
echo "INFO > path pem : "$PEM_PATH
echo "INFO > Suites to Run : " && cat $SUITE_FILE && echo " "
echo "INFO > IP Machines : " && cat $IPS_FILE && echo " "
executeAutomationTestOnCloud $IPS_FILE $PEM_PATH $DOCKER_BRANCH_SERVICES $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_UI $DOCKER_BRANCH_TOOLS $DOCKER_USER $DOCKER_PASSWORD $GIT_USER $GIT_PASSWORD $GIT_BRANCH $GIT_JMETER_BRANCH $NUMBER_THREADS_CB $IS_SETUP_ENV $POPDB_NAME $IS_KAFKA $BRANCH_CI $SUITE_FILE $CLOUD_TYPE $DOCKER_MICROSERVICES
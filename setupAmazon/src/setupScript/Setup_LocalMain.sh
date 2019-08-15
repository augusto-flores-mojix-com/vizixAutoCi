#!/usr/bin/env bash
#
# @autor: Eynar Pari
# @date : 24/04/18
#
#@params
# $1 DOCKER_BRANCH_SERVICES
# $2 DOCKER_BRANCH_BRIDGES
# $3 DOCKER_BRANCH_UI
# $4 DOCKER_USER
# $5 DOCKER_PASSWORD
# $6 GIT_USER
# $7 GIT_PASSWORD
# $8 GIT_BRANCH
# $9 CATEGORY_TO_EXECUTE
# ${10} ADD_CONTAINERS
# ${11} NUMBER_THREADS_CB -> integer
# ${12} IS_SETUP_ENV -> boolean (true,false)
# ${13} IS_MIGRATION -> boolean (true,false)
# ${14} POPDB_NAME -> (popdb type and  migration)
# ${15} IS_UI -> boolean (true,false)
# ${16} IS_OWASP -> boolean (true,false)
# ${17} IS_KAFKA -> boolean (true,false)
# ${18} MIGRATION_CLIENT  -> Migration client
# ${19} DOCKER_BRANCH_TOOLS
# ${20} IS_PERFORMANCE
# ${21} PERFORMANCE_TYPE
#vars
################### PARAMETERS TO VARS ################################

DOCKER_BRANCH_SERVICES=$1
DOCKER_BRANCH_BRIDGES=$2
DOCKER_BRANCH_UI=$3
DOCKER_USER=$4
DOCKER_PASSWORD=$5

GIT_USER=$6
GIT_PASSWORD=$7
GIT_BRANCH=$8

CATEGORY_TO_EXECUTE=$9
ADD_CONTAINERS=${10}
NUMBER_THREADS_CB=${11}
IS_SETUP_ENV=${12}
IS_MIGRATION=${13}
POPDB_NAME=${14}
IS_UI=${15}
IS_OWASP=${16}
IS_KAFKA=${17}

MIGRATION_CLIENT=${18}
DOCKER_BRANCH_TOOLS=${19}

IS_PERFORMANCE=${20}
PERFORMANCE_TYPE=${21}

########################## IPS AWS #################################
PRIVATE_IP=
PUBLIC_IP=IP


########################## PATHS #################################
MAIN_PATH=/home/ubuntu
AUTOMATION_PATH=$MAIN_PATH/vizix_repositories/vizix-qa-automation
AUTOMATION_JMETER_PATH=$MAIN_PATH/vizix_repositories/vizix-qa-automation-jmeter/vizix.automation.performance
TOOL_JMETER_PATH=/home/apache-jmeter-3.2
PATH_REPOSITORIES=$MAIN_PATH/vizix_repositories
REPORT_SAVED=$MAIN_PATH/reports
VIZIX_COMPOSE=$MAIN_PATH/vizix-compose
PATH_COMPOSE_BUILDER=$PATH_REPOSITORIES/vizix-qa-automation-ci/setupAmazon/src/composeBuilder


######## Start Dependencies ################
PATH_DEPENDENCIES=$PATH_REPOSITORIES/vizix-qa-automation-ci/setupAmazon/src/setupScript
source $PATH_DEPENDENCIES/CD_runFuncional.sh
source $PATH_DEPENDENCIES/CD_runMigration.sh
source $PATH_DEPENDENCIES/CD_runUI.sh
source $PATH_DEPENDENCIES/CD_setupEnvironment.sh
source $PATH_DEPENDENCIES/CD_Utils.sh
source $PATH_DEPENDENCIES/CD_runPerformance.sh
PATH_UTILS=$PATH_DEPENDENCIES/CD_Utils.sh
######## End - Dependencies #################

# this condition is to have the basic config
# when the environment is kafka or cbmt
if [ "$IS_KAFKA" == "true" ]
   then
       BASIC_CONFIG=$PATH_COMPOSE_BUILDER/configurationKafka
   else
       BASIC_CONFIG=$PATH_COMPOSE_BUILDER/configurationCbMt
fi

# this condition is to verify if new parameters
# will be added if the data base to use is oracle
ORACLE_PARAMETERS=""
IS_ORACLE=false
if [[ $ADD_CONTAINERS = *"oracle"* ]]; then
  IS_ORACLE=true
  ORACLE_PARAMETERS="-PportDatabase=1521*-PdataBaseName=ORCLCBD*-PuserDatabase=C##VIZIX*-PpasswordDatabase=7GHnREKP+Ns14*-Pdatabase=oracle.jdbc.OracleDriver*-PdatabasePrefix=jdbc:oracle:thin:@"
fi


###################################################### MAIN ############################################################
echo "INFO> #########Conditional Configuration###############"
echo "INFO> # Is SETUP Environment ?: $IS_SETUP_ENV , with  PopDb Name : $POPDB_NAME"
echo "INFO> # Is KAFKA? : $IS_KAFKA"
echo "INFO> # Is MIGRATION? : $IS_MIGRATION with Data : $MIGRATION_CLIENT"
echo "INFO> # Is UI? : $IS_UI , with Owasp ? : $IS_OWASP "
echo "INFO> # Containers to Add to basic : $ADD_CONTAINERS, need to use oracle database : $IS_ORACLE"
echo "INFO> # Is PERFORMANCE test ? : $IS_PERFORMANCE, Performanc Type is : $PERFORMANCE_TYPE"
echo "INFO> ################################################"

# This variable isConfigured is to check if the environment
# need to be reconfigured when the ip was regenerated
isConfigured=false

######################################## SETUP ENVIRONMENT #############################################################
if [ "$IS_SETUP_ENV" == "true" ]
then

  echo "INFO > Clean Container and Images"
  docker stop $(docker ps -aq)
  docker rm $(docker ps -aq)
  docker rmi $(docker images)
  echo "INFO > remove persistent file and create it again"
  rm -rf $VIZIX_COMPOSE
  mkdir $VIZIX_COMPOSE

  echo "INFO > Building the docker-compose"
  builderDockerCompose $PATH_COMPOSE_BUILDER $ADD_CONTAINERS $VIZIX_COMPOSE $IS_KAFKA $BASIC_CONFIG
  echo "INFO > Call Setup Environment .."
  CATEGORY_TO_EXECUTE=CBblink

  if [ "$IS_KAFKA" == "true" ]
  then
    setupEnvironmentKafka $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $IS_ORACLE $ORACLE_PARAMETERS
  else
    setupEnvironmentCbMT $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $IS_ORACLE $ORACLE_PARAMETERS
  fi
  isConfigured=true
fi


##################################### EXECUTION AUTOMATION TEST ########################################################
if [ "$IS_MIGRATION" == "true" ]
then
  echo "INFO >Call Run Automation for MIGRATION TEST ......" &&  echo "CALL >runMigrationTest $AUTOMATION_PATH $MAIN_PATH $POPDB_NAME $PRIVATE_IP $PUBLIC_IP $VIZIX_COMPOSE $CATEGORY_TO_EXECUTE $NUMBER_THREADS_CB $IS_KAFKA"
  runMigrationTest $AUTOMATION_PATH $MAIN_PATH $MIGRATION_CLIENT $PRIVATE_IP $PUBLIC_IP $VIZIX_COMPOSE $CATEGORY_TO_EXECUTE $NUMBER_THREADS_CB $IS_KAFKA
else
  if [ "$IS_UI" == "true" ]
    then
       echo "INFO >Call Run Automation WEB UI TEST......" &&  echo "CALL >runUITest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $IS_OWASP $VIZIX_COMPOSE"
       runUITest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $IS_OWASP $VIZIX_COMPOSE
    else
        if [ "$IS_PERFORMANCE" == "true" ]
        then
           echo "INFO> Call Run Automation PERFORMANCE TEST for : $PERFORMANCE_TYPE (it can be : services,bridges,ui)"
           runPerformance $PERFORMANCE_TYPE $CATEGORY_TO_EXECUTE $AUTOMATION_JMETER_PATH $PRIVATE_IP $REPORT_SAVED $VIZIX_COMPOSE $TOOL_JMETER_PATH $AUTOMATION_PATH
        else
           echo "INFO >Call Run Automation SERVICES & BRIDGES TEST......." && echo "CALL >runAutomatedTest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $IS_KAFKA $VIZIX_COMPOSE $ORACLE_PARAMETERS"
           runAutomatedTest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $IS_KAFKA $VIZIX_COMPOSE $ORACLE_PARAMETERS
        fi
  fi
fi


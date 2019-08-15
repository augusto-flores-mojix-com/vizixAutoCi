#!/usr/bin/env bash
# @autor: Eynar Pari
# @date : 15/03/18

#@params
# $1 DOCKER_BRANCH_SERVICES
# $2 DOCKER_BRANCH_BRIDGES
# $3 DOCKER_BRANCH_UI
# $4 DOCKER_BRANCH_TOOLS
# $5 DOCKER_USER
# $6 DOCKER_PASSWORD
# $7 GIT_USER
# $8 GIT_PASSWORD
# $9 GIT_BRANCH
# ${10} GIT_BRANCH_JMETER
# ${11} CATEGORY_TO_EXECUTE
# ${12} ADD_CONTAINERS
# ${13} NUMBER_THREADS_CB -> integer
# ${14} IS_SETUP_ENV -> boolean (true,false)
# ${15} IS_KAFKA -> boolean (true,false)
# ${16} POPDB_NAME -> (popdb name)
# ${17} MIGRATION_CLIENT  -> Migration client
# ${18} TYPE_EXECUTION (ie. ui/uiOwasp/migration/servicesBridges/servicesPerformance/bridgesPerformance/uiPerformance/uiDocker)
# ${19} CLOUD_TYPE (i.e. azure , aws, googlecloud, others)
# ${20} DOCKER_MICROSERVICES (i.e: vizix-tenant-versioning:dev_6.x.x,vizix-repository1:dev_6.x.x,vizix_repository2:dev_6.x.x)

#vars
################### PARAMETERS TO VARS ################################

DOCKER_BRANCH_SERVICES=$1
DOCKER_BRANCH_BRIDGES=$2
DOCKER_BRANCH_UI=$3
DOCKER_BRANCH_TOOLS=$4
DOCKER_USER=$5
DOCKER_PASSWORD=$6

GIT_USER=$7
GIT_PASSWORD=$8
GIT_BRANCH=$9
GIT_JMETER_BRANCH=${10}

CATEGORY_TO_EXECUTE=${11}
ADD_CONTAINERS=${12}
NUMBER_THREADS_CB=${13}
IS_SETUP_ENV=${14}
IS_KAFKA=${15}
POPDB_NAME=${16}
MIGRATION_CLIENT=${17}
TYPE_EXECUTION=${18}
CLOUD_TYPE=${19}

DOCKER_MICROSERVICES=${20}

########################## PATHS #################################
MAIN_PATH=/home/ubuntu
AUTOMATION_PATH=$MAIN_PATH/vizix_repositories/vizix-qa-automation
AUTOMATION_JMETER_PATH=$MAIN_PATH/vizix_repositories/vizix-qa-automation-jmeter/vizix.automation.performance
TOOL_JMETER_PATH=/home/apache-jmeter-3.2
PATH_REPOSITORIES=$MAIN_PATH/vizix_repositories
REPORT_SAVED=$MAIN_PATH/reports
VIZIX_COMPOSE=$MAIN_PATH/vizix-compose
PATH_COMPOSE_BUILDER=$PATH_REPOSITORIES/vizix-qa-automation-ci/setupAmazon/src/composeBuilder
PATH_COLLECTOR_SCRIPT=$AUTOMATION_PATH/src/test/java/generatorByPython

########################## IPS CLOUD #################################

case "$CLOUD_TYPE" in
    azure)
       PUBLIC_IP=`curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2017-04-02&format=text"`
       PRIVATE_IP=`curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/privateIpAddress?api-version=2017-04-02&format=text"`
       ;;
    aws)
       PRIVATE_IP=`curl http://169.254.169.254/latest/meta-data/local-ipv4`
       PUBLIC_IP=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
       ;;
    *)
       echo " ***********************************************" && echo " *   INCORRECT CLOUD TYPE !!!! $CLOUD_TYPE     *" && echo " ***********************************************" && exit 1
       ;;
esac


######## Start Dependencies ################
PATH_DEPENDENCIES=$PATH_REPOSITORIES/vizix-qa-automation-ci/setupAmazon/src/setupScript
source $PATH_DEPENDENCIES/CD_runFuncional.sh
source $PATH_DEPENDENCIES/CD_runMigration.sh
source $PATH_DEPENDENCIES/CD_runUI.sh
source $PATH_DEPENDENCIES/CD_setupEnvironment.sh
source $PATH_DEPENDENCIES/CD_Utils.sh
source $PATH_DEPENDENCIES/CD_runPerformance.sh
source $PATH_DEPENDENCIES/CD_runMultitenancy.sh
PATH_UTILS=$PATH_DEPENDENCIES/CD_Utils.sh
######## End - Dependencies #################

# this condition is to have the basic config when the environment is kafka or cbmt
if [ "$IS_KAFKA" == "true" ]
   then
       BASIC_CONFIG=$PATH_COMPOSE_BUILDER/configurationKafka
   else
       BASIC_CONFIG=$PATH_COMPOSE_BUILDER/configurationCbMt
fi

# this condition is to verify if new parameters will be added if the data base to use is oracle
ORACLE_PARAMETERS=""
IS_ORACLE=false
if [[ $ADD_CONTAINERS = *"oracle"* ]]; then
  IS_ORACLE=true
  ORACLE_PARAMETERS="-PportDatabase=1521*-PdataBaseName=ORCLCBD*-PuserDatabase=C##VIZIX*-PpasswordDatabase=7GHnREKP+Ns14*-Pdatabase=oracle.jdbc.OracleDriver*-PdatabasePrefix=jdbc:oracle:thin:@"
fi

echo "******************************************* MAIN *******************************************************"
echo "*      INFO> # Is SETUP Environment ?: $IS_SETUP_ENV , with  PopDb Name : $POPDB_NAME                  *"
echo "*      INFO> # Is KAFKA? : $IS_KAFKA                                                                   *"
echo "*      INFO> # Type Execution : $TYPE_EXECUTION                                                        *"
echo "*      INFO> # Containers to Add to basic : $ADD_CONTAINERS, need to use oracle database : $IS_ORACLE  *"
echo "********************************************************************************************************"

# This variable isConfigured is to check if the environment need to be reconfigured when the ip was regenerated
isConfigured=false

######################################## SETUP ENVIRONMENT #############################################################

if [ "$IS_SETUP_ENV" == "true" ]
then
  echo "INFO > Building the docker-compose"
  builderDockerCompose $PATH_COMPOSE_BUILDER $ADD_CONTAINERS $VIZIX_COMPOSE $IS_KAFKA $BASIC_CONFIG
  echo "INFO > Call Setup Environment .."

  TYPE_EXECUTION=servicesBridges

 case "$ADD_CONTAINERS" in
    *shopcx*)
        CATEGORY_TO_EXECUTE=ShopCXStructure*-PisBasicAuthForShopCX=true*-PisUsingAutomationPopDb=false*-Puser=REDroot1*-POrganizationShopCX=RED
        ;;
    *eclipse*)
        CATEGORY_TO_EXECUTE=ShopCXStructure*-PisBasicAuthForShopCX=true*-PisUsingAutomationPopDb=false*-Puser=ECLIPSEroot1*-POrganizationShopCX=ECLIPSE
        ;;
    *)
       CATEGORY_TO_EXECUTE=CBblink
       ;;
  esac

  if [ "$IS_KAFKA" == "true" ]
  then
    setupEnvironmentKafka $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $GIT_JMETER_BRANCH $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_PARAMETERS
  else
    setupEnvironmentCbMT $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $IS_ORACLE $GIT_JMETER_BRANCH $ORACLE_PARAMETERS
  fi
  isConfigured=true
fi

###################################### RE-CONFIGURE ENVIRONMENT ########################################################
if [ "$isConfigured" == "false" ]
then
   echo "INFO >reconfigure environment because isConfigured ? : "$isConfigured
   configurationEnvironment $AUTOMATION_PATH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $IS_KAFKA $REPORT_SAVED $PATH_COMPOSE_BUILDER $ADD_CONTAINERS $BASIC_CONFIG $POPDB_NAME $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_PARAMETERS
fi

##################################### EXECUTION AUTOMATION TEST ########################################################

case "$TYPE_EXECUTION" in
    ui)
        echo "INFO >Call Run Automation WEB UI TEST......" &&  echo "CALL >runUITest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED false $VIZIX_COMPOSE"
        runUITest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED false $VIZIX_COMPOSE
        ;;
    uiDocker)
        echo "INFO >Call Run Automation WEB UI TEST on DOCKER......" &&  echo "CALL >runUIDocker $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_COMPOSE"
        runUIDocker $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_COMPOSE
        ;;
    uiGrid)
        echo "INFO >Call Run Automation WEB UI TEST on Grid ......" &&  echo "CALL >runUISeleniumGrid $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_COMPOSE"
        runUISeleniumGrid $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_COMPOSE
        ;;
    uiGridAll)
        echo "INFO >Call Run Automation WEB UI TEST on Grid All support Browser......" &&  echo "CALL >runUISeleniumGridAll $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_COMPOSE"
        runUISeleniumGridAll $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_COMPOSE
        ;;
    uiOwasp)
        echo "INFO >Call Run Automation WEB UI TEST & OWASP ......" &&  echo "CALL >runUITest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED true $VIZIX_COMPOSE"
        runUITest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED true $VIZIX_COMPOSE
        ;;
    migration)
       echo "INFO >Call Run Automation for MIGRATION TEST ......" &&  echo "CALL >runMigrationTest $AUTOMATION_PATH $MAIN_PATH $POPDB_NAME $PRIVATE_IP $PUBLIC_IP $VIZIX_COMPOSE $CATEGORY_TO_EXECUTE $NUMBER_THREADS_CB $IS_KAFKA"
       runMigrationTest $AUTOMATION_PATH $MAIN_PATH $MIGRATION_CLIENT $PRIVATE_IP $PUBLIC_IP $VIZIX_COMPOSE $CATEGORY_TO_EXECUTE $NUMBER_THREADS_CB $IS_KAFKA
       ;;
    servicesBridges)
       echo "INFO >Call Run Automation SERVICES & BRIDGES TEST......." && echo "CALL >runAutomatedTest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $IS_KAFKA $VIZIX_COMPOSE $ORACLE_PARAMETERS"
       runAutomatedTest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $IS_KAFKA $VIZIX_COMPOSE $ORACLE_PARAMETERS
       ;;
    servicesPerformance)
       echo "INFO> Call Run Automation for PERFORMANCE TEST SERVICES ......" && echo "CALL >runPerformanceServicesTest $CATEGORY_TO_EXECUTE $AUTOMATION_JMETER_PATH $PRIVATE_IP $REPORT_SAVED $VIZIX_COMPOSE $TOOL_JMETER_PATH $AUTOMATION_PATH"
       runPerformanceServicesTest $CATEGORY_TO_EXECUTE $AUTOMATION_JMETER_PATH $PRIVATE_IP $REPORT_SAVED $VIZIX_COMPOSE $TOOL_JMETER_PATH $AUTOMATION_PATH
       ;;
    bridgesMtPerformance)
       echo "INFO> Call Run Automation for PERFORMANCE TEST COREBRIDGE MT......" && echo "CALL > runPerformanceBridgesCbMtTest $PATH_COLLECTOR_SCRIPT $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $NUMBER_THREADS_CB $PRIVATE_IP $PUBLIC_IP"
       runPerformanceBridgesCbMtTest $PATH_COLLECTOR_SCRIPT $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $NUMBER_THREADS_CB $PRIVATE_IP $PUBLIC_IP
       ;;
    bridgesKafkaPerformance)
       echo "INFO> calling runPerformanceBridgeTest"
       echo " PENDING......."
       ;;
    uiPerformance)
       echo "INFO >Call Run Automation WEB UI PERFORMANCE TEST on DOCKER......" &&  echo "CALL >runPerformanceUITest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_COMPOSE"
       runPerformanceUITest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_COMPOSE
       ;;
    multitenancyRed)
       TENANT1=RED
       TENANT2=RED1
       echo "INFO> Call Run Automation for Multitenancy Shopcx RED & RED1" && echo "CALL > runMultitenancyAutomatedTest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $IS_KAFKA $VIZIX_COMPOSE $TENANT1 $TENANT2 $ORACLE_PARAMETERS"
       runMultitenancyAutomatedTest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $IS_KAFKA $VIZIX_COMPOSE $TENANT1 $TENANT2 $ORACLE_PARAMETERS
       ;;
    multitenancyEclipse)
       TENANT1=ECLIPSE
       TENANT2=ECLIPSE1
       echo "INFO> Call Run Automation for Multitenancy Shopcx $TENANT1 & $TENANT2" && echo "CALL > runMultitenancyAutomatedTest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $IS_KAFKA $VIZIX_COMPOSE $TENANT1 $TENANT2 $ORACLE_PARAMETERS"
       runMultitenancyAutomatedTest $AUTOMATION_PATH $CATEGORY_TO_EXECUTE $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $IS_KAFKA $VIZIX_COMPOSE $TENANT1 $TENANT2 $ORACLE_PARAMETERS
       ;;
    *)
       echo " *****************************************************************************************************************************"
       echo " *                              INCORRECT CATEGORY !!!! $TYPE_EXECUTION                                                      *"
       echo " *   you have to select : ui/uiOwasp/migration/servicesBridges/servicesPerformance/bridgesPerformance/uiPerformance/uiDocker *"
       echo " *****************************************************************************************************************************"
       exit 1
       ;;
esac
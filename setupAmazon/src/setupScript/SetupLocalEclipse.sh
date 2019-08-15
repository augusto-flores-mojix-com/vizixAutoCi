#!/usr/bin/env bash
#
# @Autor :Eynar
# @Date : 16/05/2019
#

cleanEnvironment(){
    echo "INFO > Clean Environment"
    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)
    #docker rmi $(docker images)
}

updateEnvFile(){
    local VIZIX_COMPOSE=$1
    local DOCKER_BRANCH_UI=$2
    local DOCKER_BRANCH_BRIDGES=$3
    local DOCKER_BRANCH_SERVICES=$4
    local PUBLIC_IP=$5
    local DOCKER_BRANCH_TOOLS=$6
    local DOCKER_MICROSERVICES=$7

    cd $VIZIX_COMPOSE
    docker-compose stop

    echo "INFO > ***************** configuring .env file**************"
    echo "INFO > DOCKER_BRANCH_SERVICES : $DOCKER_BRANCH_SERVICES , DOCKER_BRANCH_BRIDGES : $DOCKER_BRANCH_BRIDGES , DOCKER_BRANCH_UI:$DOCKER_BRANCH_UI , DOCKER_BRANCH_TOOLS :$DOCKER_BRANCH_TOOLS"

    local versionsMicroServices=$DOCKER_MICROSERVICES
    local arrayVersion=$(echo $versionsMicroServices | tr "," "\n")

    for version in $arrayVersion
    do
        echo "INFO > Version to update on .env file : $version"
        case "$version" in
            vizix-tenant-versioning*)
               local VIZIX_TENANT_VERSIONING=$(echo ${version} | sed -e "s/vizix-tenant-versioning://")
               sed -i "/vizix-tenant-versioning:/c VERSIONING=mojix/vizix-tenant-versioning:$VIZIX_TENANT_VERSIONING" .env
               ;;
            configuration-api-devices*)
               local CONFIGURATION_API_DEVICES=$(echo ${version} | sed -e "s/configuration-api-devices://")
               sed -i "/configuration-api-devices:/c API_DEVICES=mojix/configuration-api-devices:$CONFIGURATION_API_DEVICES" .env
               ;;
            configuration-api-languages*)
               local CONFIGURATION_API_LANGUAGES=$(echo ${version} | sed -e "s/configuration-api-languages://")
               sed -i "/configuration-api-languages:/c API_LANGUAGES=mojix/configuration-api-languages:$CONFIGURATION_API_LANGUAGES" .env
               ;;
            dp-asn-auto-engine*)
               local DP_ASN_AUTO_ENGINE=$(echo ${version} | sed -e "s/dp-asn-auto-engine://")
               sed -i "/dp-asn-auto-engine:/cASN_AUTO=mojix/dp-asn-auto-engine:$DP_ASN_AUTO_ENGINE" .env
               ;;
            dp-instant-event-generation*)
               local DP_INSTANT_EVENT_GENERATION=$(echo ${version} | sed -e "s/dp-instant-event-generation://")
               sed -i "/dp-instant-event-generation:/c INSTANT_EVENT_GENERATION=mojix/dp-instant-event-generation:$DP_INSTANT_EVENT_GENERATION" .env
               ;;
            dp-retroactive-event-generation*)
               local DP_RETROACTIVE_EVENT_GENERATION=$(echo ${version} | sed -e "s/dp-retroactive-event-generation://")
               sed -i "/dp-retroactive-event-generation:/c RETROACTIVE_EVENT_GENERATION=mojix/dp-retroactive-event-generation:$DP_RETROACTIVE_EVENT_GENERATION" .env
               ;;
            red-amqp-servicebus*)
               local RED_AMQP_SERVICE=$(echo ${version} | sed -e "s/red-amqp-servicebus://")
               sed -i "/red-amqp-servicebus:/c RED_AMQP_SERVICE=mojix/red-amqp-servicebus:$RED_AMQP_SERVICE" .env
               ;;
            serialization-api*)
               local SERIALIZATION_API=$(echo ${version} | sed -e "s/serialization-api://")
               sed -i "/serialization-api:/c SERIALIZATION_API=mojix/serialization-api:$SERIALIZATION_API" .env
               ;;
            vizix-api-transformer*)
               local VIZIX_API_TRANSFORMER=$(echo ${version} | sed -e "s/vizix-api-transformer://")
               sed -i "/EXTERNAL_TRANSFORMER/c EXTERNAL_TRANSFORMER=mojix/vizix-api-transformer:$VIZIX_API_TRANSFORMER" .env
               ;;
            sysconfig*)
               local SYSCONFIG=$(echo ${version} | sed -e "s/sysconfig://")
               sed -i "/SYSCONFIG/c SYSCONFIG=$SYSCONFIG" .env
               ;;
            report-generator*)
               local REPORT_GENERATOR_VERSION=$(echo ${version} | sed -e "s/report-generator://")
               sed -i "/REPORTGENERATOR/c REPORTGENERATOR=mojix/riot-core-bridges:$REPORT_GENERATOR_VERSION" .env
               ;;
            dp-dashboard*)
               local DP_DASHBOARD=$(echo ${version} | sed -e "s/dp-dashboard://")
               sed -i "/DP_DASHBOARD/c DP_DASHBOARD=mojix/dp-dashboard:$DP_DASHBOARD" .env
               ;;
            tag-management*)
               local TAG_MANAGEMENT=$(echo ${version} | sed -e "s/tag-management://")
               sed -i "/TAG_MANAGEMENT/c TAG_MANAGEMENT=mojix/tag-management:$TAG_MANAGEMENT" .env
               ;;
            tag-auth*)
               local TAG_AUTH=$(echo ${version} | sed -e "s/tag-auth://")
               sed -i "/TAG_AUTH/c TAG_AUTH=docker-pull.factory.shopcx.io/tag-auth-api:$TAG_AUTH" .env
               ;;
            reverse-proxy-devices*)
               local REVERSE_PROXY_DEVICES=$(echo ${version} | sed -e "s/reverse-proxy-devices://")
               sed -i "/REVERSE_PROXY_DEVICES/c REVERSE_PROXY_DEVICES=mojix/reverse-proxy-devices:$REVERSE_PROXY_DEVICES" .env
               ;;
            dashboard-epcis-search*)
               local DASHBOARD_EPCIS_SEARCH=$(echo ${version} | sed -e "s/dashboard-epcis-search://")
               sed -i "/DASHBOARD_EPCIS_SEARCH/c DASHBOARD_EPCIS_SEARCH=mojix/dashboard-epcis-search:$DASHBOARD_EPCIS_SEARCH" .env
               ;;
            configuration-dashboard*)
               local CONFIGURATION_DASHBOARD=$(echo ${version} | sed -e "s/configuration-dashboard://")
               sed -i "/CONFIGURATION_DASHBOARD/c CONFIGURATION_DASHBOARD=mojix/configuration-dashboard:$CONFIGURATION_DASHBOARD" .env
               ;;
            statemachine-api-dashboard-configuration*)
               local STATEMACHINE_API_DASHBOARD_CONFIG=$(echo ${version} | sed -e "s/statemachine-api-dashboard-configuration://")
               sed -i "/STATEMACHINE_API_DASHBOARD_CONFIG/c STATEMACHINE_API_DASHBOARD_CONFIG=mojix/statemachine-api-dashboard-configuration:$STATEMACHINE_API_DASHBOARD_CONFIG" .env
               ;;
            reports*)
               local REPORTS=$(echo ${version} | sed -e "s/reports://")
               sed -i "/REPORTS/c REPORTS=mojix/riot-core-reports:$REPORTS" .env
               ;;
            monitoring-api*)
               local MONITORING=$(echo ${version} | sed -e "s/monitoring-api://")
               sed -i "/MONITORING_API/c MONITORING_API=mojix/monitoring-api:$MONITORING" .env
               ;;
            *)
               echo "WARN > WARN!!!  No Container was found : "$version
               ;;
        esac
    done

    sed -i "/riot-core-ui:/c UI=mojix/riot-core-ui:$DOCKER_BRANCH_UI" .env
    sed -i "/BRIDGES=/c BRIDGES=mojix/riot-core-bridges:$DOCKER_BRANCH_BRIDGES" .env
    sed -i "/riot-core-services:/c SERVICES=mojix/riot-core-services:$DOCKER_BRANCH_SERVICES" .env
    sed -i "/vizix-tools:/c VIZIXTOOLS=mojix/vizix-tools:$DOCKER_BRANCH_SERVICES" .env
    sed -i "/UI_URL=/c UI_URL=$PUBLIC_IP" .env
    sed -i "/SERVICES_URL=/c SERVICES_URL=$PUBLIC_IP:80" .env
    sed -i s/localhost/$PUBLIC_IP/g .env
    sed -i "/VIZIX_DATA_PATH/c VIZIX_DATA_PATH=$VIZIX_COMPOSE" .env
    sed -i "/VIZIXTOOLS/c VIZIXTOOLS=mojix/vizix-tools:$DOCKER_BRANCH_TOOLS" .env
    cat .env && echo "INFO > ************** File configured ******************"
}

builderDockerCompose(){
   local PATH_COMPOSE_BUILDER=$1
   local ADD_CONTAINERS=$2
   local VIZIX_COMPOSE=$3
   local BASIC_CONFIG=$4

   sudo rm -rf $VIZIX_COMPOSE
   sudo mkdir $VIZIX_COMPOSE

   local ADD_CONTAINERS_SEPARATED=$(echo $ADD_CONTAINERS | tr ',' ' ')

   BASIC_CONTAINER="$PATH_COMPOSE_BUILDER/templates/services_kafka $PATH_COMPOSE_BUILDER/templates/mysql"
   BASIC_COMPOSE="$PATH_COMPOSE_BUILDER/templates/basic-compose-kafka.yml $BASIC_CONTAINER"

   cd $PATH_COMPOSE_BUILDER/templates/
   sudo cat $BASIC_COMPOSE $ADD_CONTAINERS_SEPARATED > $VIZIX_COMPOSE/docker-compose.yml

   echo "INFO > **** docker-compose.yml ****"
   sudo cp -a -r $BASIC_CONFIG/* $VIZIX_COMPOSE/
   sudo cp $BASIC_CONFIG/.env $VIZIX_COMPOSE/
   cd $VIZIX_COMPOSE
   cat .env
   echo " " && echo "INFO >*************************Docker Compose was Created"
}


setupEnvironmentLocalEclipse(){

    echo "********************************************************************************************************"
    echo "*                          SETUP ENVIRONMENT FOR KAFKA VIZIX SHOPCX                                    *"
    echo "********************************************************************************************************"
    #vars
    #######################

    local PATH_REPOSITORIES=$1
    local GIT_USER=$2
    local GIT_PASSWORD=$3
    local AUTOMATION_PATH=$4
    local VIZIX_COMPOSE=$5
    local DOCKER_BRANCH_UI=$6
    local DOCKER_BRANCH_BRIDGES=$7
    local DOCKER_BRANCH_SERVICES=$8
    local PUBLIC_IP=$9
    local POPDB_NAME=${10}
    local DOCKER_BRANCH_TOOLS=${11}
    local DOCKER_MICROSERVICES=${12}

    # step to setup env
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    cd $AUTOMATION_PATH && git pull
    cd $VIZIX_COMPOSE

    rm Caddyfile
    cat ShopCXCaddyfile > Caddyfile

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES

    NEW_AUTH=$(echo -n 'ECLIPSEroot1:Control123!' | base64)
    sed -i "s/BASIC_AUTH_USER=UkVEcm9vdDE6Q29udHJvbDEyMyE=/BASIC_AUTH_USER=$NEW_AUTH/g" .env

    BRANCH_SYSCONFIG=$(cat .env | grep "SYSCONFIG" | awk -F= '{print $2}')
    echo "INFO > Cloning repository for Sysconfig on branch : $BRANCH_SYSCONFIG"
    git clone -b $BRANCH_SYSCONFIG https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/riot-core-sysconfig.git

    docker-compose pull && sleep 10

    echo "INFO > Added admin user to mongo"
    docker-compose up -d mongo && sleep 20s
    docker-compose exec -T mongo mongo admin --eval "db.createUser({user:'admin', pwd:'control123!',roles:['userAdminAnyDatabase']});"
    docker-compose exec -T mongo mongo admin -u admin -p control123! --authenticationDatabase admin --eval "db.createRole({role:'executeFunctions',privileges:[{resource:{anyResource:true},actions:['anyAction']}],roles:[]});db.grantRolesToUser('admin',[{ role: 'executeFunctions', db: 'admin' },{ role : 'readWrite', db : 'viz_root' },{ role : 'readWrite', db : 'viz_mojix' }]);"

    docker-compose up -d mysql mosquitto kafka

    echo "INFO > Configure variables for platform-core-root popDB"
    sed -i "s/VIZIX_SYSCONFIG_OPTION: automation-core/VIZIX_SYSCONFIG_OPTION: platform-core-root/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_CREATE_TENANT: \"false\"/VIZIX_SYSCONFIG_CREATE_TENANT: \"true\"/g" vizix-tools.yml

    cat vizix-tools.yml && sleep 20s
    docker-compose -f vizix-tools.yml up
    docker-compose up -d services
    sleep 30s

    echo "INFO > Configure variables for retail-core-epcis popDB"
    sed -i "s/VIZIX_SYSCONFIG_OPTION: platform-core-root/VIZIX_SYSCONFIG_OPTION: retail-core-epcis/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_TENANT_CODE: root/VIZIX_SYSCONFIG_TENANT_CODE: ECLIPSE/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_TENANT_NAME: root/VIZIX_SYSCONFIG_TENANT_NAME: ECLIPSE/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_HIERARCHY: \">root\"/VIZIX_SYSCONFIG_HIERARCHY: \">ECLIPSE\"/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_CLEAN: \"true\"/VIZIX_SYSCONFIG_CLEAN: \"false\"/g" vizix-tools.yml
    sed -i "s/VIZIX_KAFKA_DATA_RETENTION_UPDATER: \"true\"/VIZIX_KAFKA_DATA_RETENTION_UPDATER: \"false\"/g" vizix-tools.yml
    sed -i "s/VIZIX_KAFKA_CREATE_TOPICS: \"true\"/VIZIX_KAFKA_CREATE_TOPICS: \"false\"/g" vizix-tools.yml
    cat vizix-tools.yml && sleep 40s
    docker-compose -f vizix-tools.yml up
    sleep 1m
    docker-compose up -d flow ntpdserver ntpd logio logs proxy flow rpui rpin mongoinjector hbridge m2kbridge k2m m2kbridge transformbridge actionprocessor services mongo mysql kafka mosquitto ui
    docker-compose restart services
    sleep 1m
    docker-compose ps

    cd $AUTOMATION_PATH
    #ip instead of localhost
    sed -i s/localhost/$PUBLIC_IP/g build.gradle
    #setup license and connections
    export GRADLE_HOME=/usr/local/gradle
    export PATH=${GRADLE_HOME}/bin:${PATH}


    echo "INFO>Preparing Environment using Automation Test ..................."

    echo "INFO > gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=false -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=false -Pport=80 -PisUsingAutomationPopDb=false

    echo "INFO > gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false

    sleep 10s

    echo "INFO > gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false

    cd $VIZIX_COMPOSE
    sed -i "/EXTERNAL_IP/c EXTERNAL_IP=$PUBLIC_IP" .env
    sed -i "/INTERNAL_IP/c INTERNAL_IP=$PUBLIC_IP" .env
    echo "INFO > Value .env file " && echo " " && cat .env
    echo "INFO > Configure shopCX environment"
    docker-compose up -d shopcx-mysql
    sleep 20s

    echo "INFO > Create mysql databases"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database information_schema CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database advancloud CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database aggregates CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database businessproducts CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database configurationdevices CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database configurationlanguages CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database labstore CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database mysql CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database performance_schema CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database printing CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database recommendation CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database riot_main CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database serialization CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database statemachine CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database supplychain CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database sys CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database tagauth CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database tagmanagement CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

    echo '[rabbitmq_management,rabbitmq_shovel,rabbitmq_shovel_management].' > enabled_plugins
    docker-compose up -d shopcx-rabbitmq

    echo "INFO > Up the other components"
    docker-compose up -d configuration-api-devices
    docker-compose up -d dashboard-epcis-search

    APIKEY=$(docker-compose exec -T mysql mysql -uroot -pcontrol123! riot_main --execute "select apiKey from VIZ_APC_USER where username='root';" | grep -v -e "Using a password on the command line interface can be insecure" -e "id"  -e "apiKey")
    echo "INFO > Obtaining Api key root: $APIKEY from mysql"
    sed -i "/VIZIX_API_KEY/c VIZIX_API_KEY=$APIKEY" .env

    docker-compose up -d shopcx-rabbitmq && sleep 20s
    docker-compose up -d reportgenerator && sleep 20s
    docker-compose up -d externaltransformer && sleep 30s
    docker-compose up -d internaltransformer reverse-proxy-devices proxySCX
    docker-compose up -d && sleep 30s

    echo "INFO > Added Definition on rabbitmq"
    echo "INFO > curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PUBLIC_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D"
    curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PUBLIC_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "************ Info Definition Created ***************" && sleep 10s
    curl -v -X GET  http://$PUBLIC_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "****************************************************"

    echo "INFO > Environment is Ready"
    cd $AUTOMATION_PATH

    echo "INFO > gradle clean automationTest -Pcategory=@RequirementDataEclipse -Pnocategory=~@NotImplemented -Penvironment=docker  -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=ECLIPSE"
    gradle clean automationTest -Pcategory=@RequirementDataEclipse -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=ECLIPSE

    cd $VIZIX_COMPOSE && sleep 15s

    APIKEY=$(docker-compose exec -T mysql mysql -uroot -pcontrol123! riot_main --execute "select apiKey from VIZ_APC_USER where username='ECLIPSEroot1';" | grep -v -e "Using a password on the command line interface can be insecure" -e "id"  -e "apiKey")
    echo "INFO > ********** Obtaining Api key ECLIPSEroot1 : $APIKEY from mysql **************"
    sed -i "/VIZIX_API_KEY/c VIZIX_API_KEY=$APIKEY" .env

    docker-compose up -d externaltransformer && sleep 90s && docker-compose up -d
    docker-compose restart services && sleep 2m
    docker-compose restart externaltransformer && sleep 90s
    docker-compose restart internaltransformer  && sleep 30s

    echo " curl -v -X POST http://$PUBLIC_IP:8099/tag-auth-api/rest/encryption/key -H 'Content-Type: application/json' -d '{\"secret": "FLXZilOA\",\"salt\": \"LLTUS5oI\",\"key\":\"1dfdefff4f823d158eacd3ec405ca2ee\"}'"
    curl -v -X POST http://$PUBLIC_IP:8099/tag-auth-api/rest/encryption/key -H 'Content-Type: application/json' -d '{"secret": "FLXZilOA","salt": "LLTUS5oI","key":"1dfdefff4f823d158eacd3ec405ca2ee"}'

    echo "---------------------------- Complete Setup Environment - ShopCX ---------------------"

    cd $AUTOMATION_PATH
    echo "INFO > gradle clean automationTest -Pcategory=@ShopCXStructure -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=ECLIPSEroot1 -POrganizationShopCX=ECLIPSE -Pnocategory=~@NotImplemented -PisUsingAutomationPopDb=false -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@ShopCXStructure -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=ECLIPSEroot1 -POrganizationShopCX=ECLIPSE -Pnocategory=~@NotImplemented -PisUsingAutomationPopDb=false -PcleanAllEntities=false

    echo "INFO > gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=1 -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=ECLIPSE -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=1 -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=ECLIPSE -PcleanAllEntities=false
}


#======================  VARIABLES  ===============================
PATH_REPOSITORIES=/home/eynar/Desktop/vizix_repositories
VIZIX_COMPOSE=/home/ubuntu/vizix-compose
AUTOMATION_PATH=$PATH_REPOSITORIES/vizix-qa-automation
PATH_COMPOSE_BUILDER=$PATH_REPOSITORIES/vizix-qa-automation-ci/setupAmazon/src/composeBuilder
BASIC_CONFIG=$PATH_COMPOSE_BUILDER/configurationKafka

PUBLIC_IP=10.100.1.199

POPDB_NAME=retail-core-epcis
GIT_USER="<USER>"
GIT_PASSWORD="<PWD>"
ADD_CONTAINERS=eclipse


 if [ -z $1 ]; then
    DOCKER_BRANCH_UI=v6.49.0
 else
    DOCKER_BRANCH_UI=$1
 fi

 if [ -z $2 ]; then
    DOCKER_BRANCH_BRIDGES=v6.49.0
 else
    DOCKER_BRANCH_BRIDGES=$2
 fi

 if [ -z $3 ]; then
    DOCKER_BRANCH_SERVICES=v6.49.0
 else
    DOCKER_BRANCH_SERVICES=$3
 fi

 if [ -z $4 ]; then
    DOCKER_BRANCH_TOOLS=v6.49.0
 else
    DOCKER_BRANCH_TOOLS=$4
 fi

 if [ -z $5 ]; then
    DOCKER_MICROSERVICES=configuration-api-devices:v6.51.0,configuration-api-languages:v6.51.0,dp-asn-auto-engine:v6.51.0,dp-instant-event-generation:v6.51.0,dp-retroactive-event-generation:v6.51.0,red-amqp-servicebus:v6.51.0,serialization-api:v6.51.0,vizix-api-transformer:v6.51.0,vizix-tenant-versioning:v6.51.0,report-generator:v6.51.0,sysconfig:v6.51.0,tag-management:v6.51.0,reports:dev_6.x.x
 else
    DOCKER_MICROSERVICES=$5
 fi

#====================== MAIN ====================
#$1 DOCKER_BRANCH_UI
#$2 DOCKER_BRANCH_BRIDGES
#$3 DOCKER_BRANCH_SERVICES
#$4 DOCKER_BRANCH_TOOLS
#$5 DOCKER_MICROSERVICES

cleanEnvironment
rm -rf $VIZIX_COMPOSE
builderDockerCompose $PATH_COMPOSE_BUILDER $ADD_CONTAINERS $VIZIX_COMPOSE $BASIC_CONFIG
setupEnvironmentLocalEclipse $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $POPDB_NAME $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES



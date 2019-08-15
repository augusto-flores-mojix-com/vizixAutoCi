#!/usr/bin/env bash
#
# @autor: Eynar Pari
# @date : 19/03/18
# This method is to configure again the IP on the environment

# $1 AUTOMATION_PATH
# $2 VIZIX_COMPOSE
# $3 DOCKER_BRANCH_UI
# $4 DOCKER_BRANCH_BRIDGES
# $5 DOCKER_BRANCH_SERVICES
# $6 PUBLIC_IP
# $7 PRIVATE_IP
# $8 NUMBER_THREADS_CB
# $9 IS_KAFKA
# ${10} REPORT_SAVED
# ${11} PATH_COMPOSE_BUILDER
# ${12} ADD_CONTAINERS
# ${13} BASIC_CONFIG
# ${14} POPDB_NAME
# ${15} DOCKER_BRANCH_TOOLS
# ${16} DOCKER_MICROSERVICES
# ${17} IS_ORACLE
# ${18} ORACLE_LOCAL_PARAMETERS
configurationEnvironment(){

  AUTOMATION_PATH=$1
  VIZIX_COMPOSE=$2
  DOCKER_BRANCH_UI=$3
  DOCKER_BRANCH_BRIDGES=$4
  DOCKER_BRANCH_SERVICES=$5
  PUBLIC_IP=$6
  PRIVATE_IP=$7
  NUMBER_THREADS_CB=$8
  IS_KAFKA=$9
  REPORT_SAVED=${10}
  PATH_COMPOSE_BUILDER=${11}
  ADD_CONTAINERS=${12}
  BASIC_CONFIG=${13}
  POPDB_NAME=${14}
  DOCKER_BRANCH_TOOLS=${15}
  DOCKER_MICROSERVICES=${16}
  IS_ORACLE=${17}
  ORACLE_LOCAL_PARAMETERS=${18}

  echo "INFO > clean report and done.json"
  export GRADLE_HOME=/usr/local/gradle
  export PATH=${GRADLE_HOME}/bin:${PATH}
  echo "INFO > cd $AUTOMATION_PATH"

  cd $AUTOMATION_PATH
  gradle clean

  sudo rm -rf $REPORT_SAVED
  sudo mkdir $REPORT_SAVED

  replaceDockerComposeUpdated $IS_KAFKA $PATH_COMPOSE_BUILDER $VIZIX_COMPOSE $ADD_CONTAINERS

  echo "INFO > Re-Configuring Environment ..."
  if [ "$IS_KAFKA" == "true" ]
    then
       case "$POPDB_NAME" in

           automation-core)
               configurationEnvironmentKafkaVizixCore $AUTOMATION_PATH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $BASIC_CONFIG $POPDB_NAME $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
               ;;
           retail-core-epcis)
               configurationEnvironmentKafkaVizixShopCX $AUTOMATION_PATH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $BASIC_CONFIG $POPDB_NAME $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
               ;;
           retail-core-epcis-eclipse)
               POPDB_NAME=retail-core-epcis
               configurationEnvironmentKafkaVizixEclipse $AUTOMATION_PATH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $BASIC_CONFIG $POPDB_NAME $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
               ;;
           tracker-retail)
                echo "INFO> todo - add logic for new popdb for tracker retail - mobile"
               ;;
           retail-core-epcis-red-red)
               POPDB_NAME=retail-core-epcis
               configurationEnvironmentVizixRedRed $AUTOMATION_PATH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $BASIC_CONFIG $POPDB_NAME $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
               ;;
           retail-core-epcis-eclipse-eclipse)
               POPDB_NAME=retail-core-epcis
               configurationEnvironmentVizixEclipseEclipse $AUTOMATION_PATH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $BASIC_CONFIG $POPDB_NAME $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
               ;;
           *)
               echo "ERROR >  ERROR !!!! There is not process for the popdb name : "$POPDB_NAME
               ;;
        esac
    else
      configurationEnvironmentCbMT $AUTOMATION_PATH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $BASIC_CONFIG $POPDB_NAME $DOCKER_BRANCH_TOOLS $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
  fi

}

# $1 AUTOMATION_PATH
# $2 VIZIX_COMPOSE
# $3 DOCKER_BRANCH_UI
# $4 DOCKER_BRANCH_BRIDGES
# $5 DOCKER_BRANCH_SERVICES
# $6 PUBLIC_IP
# $7 PRIVATE_IP#
# $8 BASIC_CONFIG
# $9 POPDB_NAME
# ${10} DOCKER_BRANCH_TOOLS
# ${11} IS_ORACLE
# ${12} ORACLE_LOCAL_PARAMETERS
configurationEnvironmentKafkaVizixCore(){
    echo "INFO> reconfiguring the environment for ViZix Core"
    local AUTOMATION_PATH=$1
    local VIZIX_COMPOSE=$2
    local DOCKER_BRANCH_UI=$3
    local DOCKER_BRANCH_BRIDGES=$4
    local DOCKER_BRANCH_SERVICES=$5
    local PUBLIC_IP=$6
    local PRIVATE_IP=$7
    local BASIC_CONFIG=$8
    local POPDB_NAME=$9
    local DOCKER_BRANCH_TOOLS=${10}
    local DOCKER_MICROSERVICES=${11}
    local IS_ORACLE=${12}
    local ORACLE_LOCAL_PARAMETERS=$(echo ${13} | tr '*' ' ')
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    docker stop $(docker ps -aq)
    sudo cp $BASIC_CONFIG/.env $VIZIX_COMPOSE/

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES

    docker-compose up -d mysql mosquitto hazelcast kafka && sleep 15
    docker-compose up -d
    docker-compose restart services && sleep 40
    cd $AUTOMATION_PATH
    git reset --hard
    sed -i s/localhost/$PRIVATE_IP/g build.gradle
    gradle clean automationTest -Pcategory=@SetupEnvironmentConnectionKafka -Pnocategory=@$POPDB_NAME -Pport=80

    cd $VIZIX_COMPOSE
    docker-compose restart services && sleep 15
    docker-compose up -d rpin && sleep 15
    docker-compose up -d rpui && sleep 15
    docker-compose up -d mongoinjector && sleep 15
    docker-compose up -d m2kbridge && sleep 15
    docker-compose up -d transformbridge && sleep 15
    docker-compose up -d actionprocessor && sleep 15
    docker-compose up -d k2m && sleep 15
    docker-compose stop versioning && docker-compose rm -f versioning && sleep 15
    docker-compose up -d && sleep 20
}

# $1 AUTOMATION_PATH
# $2 VIZIX_COMPOSE
# $3 DOCKER_BRANCH_UI
# $4 DOCKER_BRANCH_BRIDGES
# $5 DOCKER_BRANCH_SERVICES
# $6 PUBLIC_IP
# $7 PRIVATE_IP#
# $8 BASIC_CONFIG
# $9 POPDB_NAME
# ${10} DOCKER_BRANCH_TOOLS
# ${11} IS_ORACLE
# ${12} ORACLE_LOCAL_PARAMETERS
configurationEnvironmentKafkaVizixShopCX(){
    echo "INFO> reconfiguring the environment for ViZix ShopCX"
    local AUTOMATION_PATH=$1
    local VIZIX_COMPOSE=$2
    local DOCKER_BRANCH_UI=$3
    local DOCKER_BRANCH_BRIDGES=$4
    local DOCKER_BRANCH_SERVICES=$5
    local PUBLIC_IP=$6
    local PRIVATE_IP=$7
    local BASIC_CONFIG=$8
    local POPDB_NAME=$9
    local DOCKER_BRANCH_TOOLS=${10}
    local DOCKER_MICROSERVICES=${11}
    local IS_ORACLE=${12}
    local ORACLE_LOCAL_PARAMETERS=$(echo ${13} | tr '*' ' ')

    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)

    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    docker stop $(docker ps -aq)
    sudo cp $BASIC_CONFIG/.env $VIZIX_COMPOSE/

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES

    docker-compose up -d mysql mosquitto hazelcast kafka && sleep 15
    docker-compose up -d
    docker-compose restart services && sleep 40

    cd $AUTOMATION_PATH
    git reset --hard
    sed -i s/localhost/$PRIVATE_IP/g build.gradle

    echo "INFO > gradle clean automationTest -Pcategory=@SetupEnvironmentConnectionKafka -Pnocategory=@$POPDB_NAME -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@SetupEnvironmentConnectionKafka -Pnocategory=@$POPDB_NAME -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false

    echo "INFO > gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false"
    gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false

    cd $VIZIX_COMPOSE

    docker-compose restart services && sleep 15s
    docker-compose up -d rpin && sleep 15s
    docker-compose up -d ui && sleep 15s
    docker-compose up -d mongoinjector && sleep 15s
    docker-compose up -d m2kbridge && sleep 15s
    docker-compose up -d transformbridge && sleep 15s
    docker-compose up -d actionprocessor && sleep 15s
    docker-compose up -d k2m && sleep 15s
    docker-compose stop versioning && docker-compose rm -f versioning && sleep 15s
    docker-compose up -d shopcx-mysql && sleep 20s
    docker-compose up -d shopcx-elasticsearch-monitoring
    docker-compose up -d influxdb && sleep 20s
    docker-compose up -d shopcx-rabbitmq
    docker-compose up -d red-amqp-servicebus
    docker-compose up -d configuration-api-devices
    docker-compose up -d configuration-api-languages
    docker-compose up -d dp-asn-auto-engine
    docker-compose up -d dp-dashboard
    docker-compose up -d dp-instant-event-generation
    docker-compose up -d dp-retroactive-event-generation
    docker-compose up -d serialization-api
    docker-compose up -d statemachine-api-dashboard-configuration
    docker-compose up -d configuration-dashboard
    docker-compose up -d dashboard-epcis-search
    docker-compose up -d api-gateway
    docker-compose up -d nginx-api-gateway
    docker-compose up -d redis
    docker-compose up -d minio
    docker-compose up -d monitoring-api

    APIKEY=$(docker-compose exec -T mysql mysql -uroot -pcontrol123! riot_main --execute "select apiKey from VIZ_APC_USER where username='REDroot1';" | grep -v -e "Using a password on the command line interface can be insecure" -e "id"  -e "apiKey")
    echo "INFO > Obtaining Api key REDroot1 : $APIKEY from mysql"
    sed -i "/VIZIX_API_KEY/c VIZIX_API_KEY=$APIKEY" .env

    docker-compose up -d shopcx-rabbitmq && sleep 20s
    docker-compose up -d reportgenerator && sleep 20s
    docker-compose up -d externaltransformer && sleep 30s
    docker-compose up -d internaltransformer
    docker-compose up -d proxySCX
    docker-compose up -d reverse-proxy-devices
    docker-compose up -d && sleep 30s
    docker-compose restart dp-asn-auto-engine && sleep 15s
    docker-compose stop configuration-api-languages && docker-compose rm -f configuration-api-languages && docker-compose up -d configuration-api-languages && sleep 15s
    docker-compose stop configuration-api-devices && docker-compose rm -f configuration-api-devices && docker-compose up -d configuration-api-devices && sleep 15s
    echo "INFO > Added Definition on rabbitmq"
    echo "INFO > curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D"
    curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "************ Info Definition Created ***************" && sleep 10s
    curl -v -X GET  http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "****************************************************"
}


configurationEnvironmentVizixRedRed(){
    echo "INFO> reconfiguring the environment for MULTITENANCY RED / RED "
    local AUTOMATION_PATH=$1
    local VIZIX_COMPOSE=$2
    local DOCKER_BRANCH_UI=$3
    local DOCKER_BRANCH_BRIDGES=$4
    local DOCKER_BRANCH_SERVICES=$5
    local PUBLIC_IP=$6
    local PRIVATE_IP=$7
    local BASIC_CONFIG=$8
    local POPDB_NAME=$9
    local DOCKER_BRANCH_TOOLS=${10}
    local DOCKER_MICROSERVICES=${11}
    local IS_ORACLE=${12}
    local ORACLE_LOCAL_PARAMETERS=$(echo ${13} | tr '*' ' ')

    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)

    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    docker stop $(docker ps -aq)
    sudo cp $BASIC_CONFIG/.env $VIZIX_COMPOSE/

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES

    docker-compose up -d mysql mosquitto hazelcast kafka && sleep 15
    docker-compose up -d
    docker-compose restart services && sleep 40

    cd $AUTOMATION_PATH
    git reset --hard
    sed -i s/localhost/$PRIVATE_IP/g build.gradle

    echo "INFO > gradle clean automationTest -Pcategory=@SetupEnvironmentConnectionKafka -Pnocategory=@$POPDB_NAME -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@SetupEnvironmentConnectionKafka -Pnocategory=@$POPDB_NAME -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false

    echo "INFO > gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false"
    gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false

    cd $VIZIX_COMPOSE

    docker-compose restart services && sleep 15s
    docker-compose up -d rpin && sleep 15s
    docker-compose up -d ui && sleep 15s
    docker-compose up -d mongoinjector && sleep 15s
    docker-compose up -d m2kbridge && sleep 15s
    docker-compose up -d transformbridge && sleep 15s
    docker-compose up -d actionprocessor && sleep 15s
    docker-compose up -d k2m && sleep 15s
    docker-compose stop versioning && docker-compose rm -f versioning && sleep 15s
    docker-compose up -d shopcx-mysql && sleep 20s
    docker-compose up -d shopcx-elasticsearch-monitoring
    docker-compose up -d influxdb && sleep 20s
    docker-compose up -d shopcx-rabbitmq
    docker-compose up -d red-amqp-servicebus
    docker-compose up -d configuration-api-devices
    docker-compose up -d configuration-api-languages
    docker-compose up -d dp-asn-auto-engine
    docker-compose up -d dp-dashboard
    docker-compose up -d dp-instant-event-generation
    docker-compose up -d dp-retroactive-event-generation
    docker-compose up -d serialization-api
    docker-compose up -d statemachine-api-dashboard-configuration
    docker-compose up -d configuration-dashboard
    docker-compose up -d dashboard-epcis-search
    docker-compose up -d api-gateway
    docker-compose up -d nginx-api-gateway
    docker-compose up -d redis
    docker-compose up -d minio
    docker-compose up -d monitoring-api

    APIKEY=$(docker-compose exec -T mysql mysql -uroot -pcontrol123! riot_main --execute "select apiKey from VIZ_APC_USER where username='root';" | grep -v -e "Using a password on the command line interface can be insecure" -e "id"  -e "apiKey")
    echo "INFO > Obtaining Api key root : $APIKEY from mysql"
    sed -i "/VIZIX_API_KEY/c VIZIX_API_KEY=$APIKEY" .env

    docker-compose up -d shopcx-rabbitmq && sleep 20s
    docker-compose up -d reportgenerator && sleep 20s
    docker-compose up -d externaltransformer && sleep 30s
    docker-compose up -d proxySCX
    docker-compose up -d reverse-proxy-devices
    docker-compose up -d && sleep 30s
    docker-compose restart dp-asn-auto-engine && sleep 15s
    docker-compose stop configuration-api-languages && docker-compose rm -f configuration-api-languages && docker-compose up -d configuration-api-languages && sleep 15s
    docker-compose stop configuration-api-devices && docker-compose rm -f configuration-api-devices && docker-compose up -d configuration-api-devices && sleep 15s
    echo "INFO > Added Definition on rabbitmq"
    echo "INFO > curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D"
    curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "************ Info Definition Created ***************" && sleep 10s
    curl -v -X GET  http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "****************************************************"
}

# $1 AUTOMATION_PATH
# $2 VIZIX_COMPOSE
# $3 DOCKER_BRANCH_UI
# $4 DOCKER_BRANCH_BRIDGES
# $5 DOCKER_BRANCH_SERVICES
# $6 PUBLIC_IP
# $7 PRIVATE_IP
# $8 BASIC_CONFIG
# $9 POPDB_NAME
# ${10} DOCKER_BRANCH_TOOLS
# ${11} DOCKER_MICROSERVICES
# ${12} IS_ORACLE
# ${13} ORACLE_LOCAL_PARAMETERS
configurationEnvironmentVizixEclipseEclipse(){
    echo "INFO> reconfiguring the environment for MULTITENANCY ECLIPSE / ECLIPSE "
    local AUTOMATION_PATH=$1
    local VIZIX_COMPOSE=$2
    local DOCKER_BRANCH_UI=$3
    local DOCKER_BRANCH_BRIDGES=$4
    local DOCKER_BRANCH_SERVICES=$5
    local PUBLIC_IP=$6
    local PRIVATE_IP=$7
    local BASIC_CONFIG=$8
    local POPDB_NAME=$9
    local DOCKER_BRANCH_TOOLS=${10}
    local DOCKER_MICROSERVICES=${11}
    local IS_ORACLE=${12}
    local ORACLE_LOCAL_PARAMETERS=$(echo ${13} | tr '*' ' ')

    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)

    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    sudo cp $BASIC_CONFIG/.env $VIZIX_COMPOSE/

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES

    docker-compose up -d mysql mosquitto hazelcast kafka && sleep 15
    docker-compose up -d
    docker-compose restart services && sleep 40

    echo "INFO > Start FTP Server"
    ./FTPServer.sh $PRIVATE_IP Automation Control123! files
    sleep 15s
    echo "INFO > ****** Status FTP Server *********" && cat /tmp/pythonFTPServer.log && echo "INFO > ********************************* "
    cd $AUTOMATION_PATH

    git reset --hard
    sed -i s/localhost/$PRIVATE_IP/g build.gradle

    echo "INFO > gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false"
    gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false

    cd $VIZIX_COMPOSE

    docker-compose restart services && sleep 15s
    docker-compose up -d rpin && sleep 15s
    docker-compose up -d ui && sleep 15s
    docker-compose up -d mongoinjector && sleep 15s
    docker-compose up -d m2kbridge && sleep 15s
    docker-compose up -d transformbridge && sleep 15s
    docker-compose up -d actionprocessor && sleep 15s
    docker-compose up -d k2m && sleep 15s
    docker-compose up -d shopcx-mysql && sleep 20s
    docker-compose up -d shopcx-rabbitmq
    docker-compose up -d configuration-api-devices
    docker-compose up -d dashboard-epcis-search

    APIKEY=$(docker-compose exec -T mysql mysql -uroot -pcontrol123! riot_main --execute "select apiKey from VIZ_APC_USER where username='root';" | grep -v -e "Using a password on the command line interface can be insecure" -e "id"  -e "apiKey")
    echo "INFO > Obtaining Api key root : $APIKEY from mysql"
    sed -i "/VIZIX_API_KEY/c VIZIX_API_KEY=$APIKEY" .env

    docker-compose up -d shopcx-rabbitmq && sleep 20s
    docker-compose up -d reportgenerator && sleep 20s
    docker-compose up -d externaltransformer && sleep 30s
    docker-compose up -d proxySCX
    docker-compose up -d reverse-proxy-devices
    docker-compose stop tag-management && docker-compose rm -f tag-management && docker-compose up -d tag-management
    docker-compose up -d && sleep 30s

    echo "INFO > Added Definition on rabbitmq"
    echo "INFO > curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D"
    curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "************ Info Definition Created ***************" && sleep 10s
    curl -v -X GET  http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "****************************************************"
    echo " curl -v -X POST http://$PRIVATE_IP:8099/tag-auth-api/rest/encryption/key -H 'Content-Type: application/json' -d '{\"secret": "FLXZilOA\",\"salt\": \"LLTUS5oI\",\"key\":\"1dfdefff4f823d158eacd3ec405ca2ee\"}'"
    curl -v -X POST http://$PRIVATE_IP:8099/tag-auth-api/rest/encryption/key -H 'Content-Type: application/json' -d '{"secret": "FLXZilOA","salt": "LLTUS5oI","key":"1dfdefff4f823d158eacd3ec405ca2ee"}'

    echo "****************************************************"
}

configurationEnvironmentKafkaVizixEclipse(){
    echo "INFO> reconfiguring the environment for ViZix Eclipse"
    local AUTOMATION_PATH=$1
    local VIZIX_COMPOSE=$2
    local DOCKER_BRANCH_UI=$3
    local DOCKER_BRANCH_BRIDGES=$4
    local DOCKER_BRANCH_SERVICES=$5
    local PUBLIC_IP=$6
    local PRIVATE_IP=$7
    local BASIC_CONFIG=$8
    local POPDB_NAME=$9
    local DOCKER_BRANCH_TOOLS=${10}
    local DOCKER_MICROSERVICES=${11}
    local IS_ORACLE=${12}
    local ORACLE_LOCAL_PARAMETERS=$(echo ${13} | tr '*' ' ')

    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)

    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    sudo cp $BASIC_CONFIG/.env $VIZIX_COMPOSE/

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES
    NEW_AUTH=$(echo -n 'ECLIPSEroot1:Control123!' | base64)
    sed -i "s/BASIC_AUTH_USER=UkVEcm9vdDE6Q29udHJvbDEyMyE=/BASIC_AUTH_USER=$NEW_AUTH/g" .env

    docker-compose up -d mysql mosquitto hazelcast kafka && sleep 15
    docker-compose up -d
    docker-compose restart services && sleep 40

    echo "INFO > Start FTP Server"
    ./FTPServer.sh $PRIVATE_IP Automation Control123! files
    sleep 15s
    echo "INFO > ****** Status FTP Server *********" && cat /tmp/pythonFTPServer.log && echo "INFO > ********************************* "
    cd $AUTOMATION_PATH

    git reset --hard
    sed -i s/localhost/$PRIVATE_IP/g build.gradle

    echo "INFO > gradle clean automationTest -Pcategory=@SetupEnvironmentConnectionKafka -Pnocategory=@$POPDB_NAME -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@SetupEnvironmentConnectionKafka -Pnocategory=@$POPDB_NAME -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false

    echo "INFO > gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false"
    gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false -PcleanAllEntities=false

    cd $VIZIX_COMPOSE

    docker-compose restart services && sleep 15s
    docker-compose up -d rpin && sleep 15s
    docker-compose up -d ui && sleep 15s
    docker-compose up -d mongoinjector && sleep 15s
    docker-compose up -d m2kbridge && sleep 15s
    docker-compose up -d transformbridge && sleep 15s
    docker-compose up -d actionprocessor && sleep 15s
    docker-compose up -d k2m && sleep 15s
    docker-compose stop versioning && docker-compose rm -f versioning && sleep 15s
    docker-compose up -d shopcx-mysql && sleep 20s
    docker-compose up -d shopcx-rabbitmq
    docker-compose up -d configuration-api-devices
    docker-compose up -d dashboard-epcis-search

    APIKEY=$(docker-compose exec -T mysql mysql -uroot -pcontrol123! riot_main --execute "select apiKey from VIZ_APC_USER where username='ECLIPSEroot1';" | grep -v -e "Using a password on the command line interface can be insecure" -e "id"  -e "apiKey")
    echo "INFO > Obtaining Api key ECLIPSEroot1 : $APIKEY from mysql"
    sed -i "/VIZIX_API_KEY/c VIZIX_API_KEY=$APIKEY" .env

    docker-compose up -d shopcx-rabbitmq && sleep 20s
    docker-compose up -d reportgenerator && sleep 20s
    docker-compose up -d externaltransformer && sleep 30s
    docker-compose up -d internaltransformer
    docker-compose up -d proxySCX
    docker-compose up -d reverse-proxy-devices
    docker-compose up -d && sleep 30s
    docker-compose restart dp-asn-auto-engine && sleep 15s

    echo "INFO > Added Definition on rabbitmq"
    echo "INFO > curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D"
    curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "************ Info Definition Created ***************" && sleep 10s
    curl -v -X GET  http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "****************************************************"
    echo " curl -v -X POST http://$PRIVATE_IP:8099/tag-auth-api/rest/encryption/key -H 'Content-Type: application/json' -d '{\"secret": "FLXZilOA\",\"salt\": \"LLTUS5oI\",\"key\":\"1dfdefff4f823d158eacd3ec405ca2ee\"}'"
    curl -v -X POST http://$PRIVATE_IP:8099/tag-auth-api/rest/encryption/key -H 'Content-Type: application/json' -d '{"secret": "FLXZilOA","salt": "LLTUS5oI","key":"1dfdefff4f823d158eacd3ec405ca2ee"}'

}

# $1 AUTOMATION_PATH
# $2 VIZIX_COMPOSE
# $3 DOCKER_BRANCH_UI
# $4 DOCKER_BRANCH_BRIDGES
# $5 DOCKER_BRANCH_SERVICES
# $6 PUBLIC_IP
# $7 PRIVATE_IP
# $8 NUMBER_THREADS_CB
# $9 BASIC_CONFIG
# $10 POPDB_NAME
# $11 DOCKER_BRANCH_TOOLS
# $12 IS_ORACLE
# $13 ORACLE_LOCAL_PARAMETERS
configurationEnvironmentCbMT(){

    AUTOMATION_PATH=$1
    VIZIX_COMPOSE=$2
    DOCKER_BRANCH_UI=$3
    DOCKER_BRANCH_BRIDGES=$4
    DOCKER_BRANCH_SERVICES=$5
    PUBLIC_IP=$6
    PRIVATE_IP=$7
    NUMBER_THREADS_CB=$8
    BASIC_CONFIG=$9
    POPDB_NAME=${10}
    DOCKER_BRANCH_TOOLS=${11}
    IS_ORACLE=${12}
    ORACLE_LOCAL_PARAMETERS=$(echo ${13} | tr '*' ' ')

    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    docker stop $(docker ps -aq)
    docker rm $(docker ps -aq)

    sudo cp $BASIC_CONFIG/.env $VIZIX_COMPOSE/

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS

    if [ "$IS_ORACLE" == "true" ]
    then
        SCRIPT_CONNECTION=SetupEnvironmentConnectionOracle
        docker-compose up -d mosquitto oracle hazelcast && sleep 15s
        chmod 777 oracle
        docker-compose up -d oracle
        waitToCheckIfOracleContainerIsReady
        docker-compose up -d
    else
        SCRIPT_CONNECTION=SetupEnvironmentConnection
        docker-compose up -d mosquitto mysql hazelcast && sleep 15 && docker-compose up -d
    fi

    cd $AUTOMATION_PATH
    git reset --hard
    sed -i s/localhost/$PRIVATE_IP/g build.gradle

    gradle clean automationTest -Pcategory=@$SCRIPT_CONNECTION,@RunCoreBridge,@RunAleBridge -Pnocategory=@$POPDB_NAME -PnumberCores=$NUMBER_THREADS_CB -Puser=root -Ppwd=Control123! -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS

    cd $VIZIX_COMPOSE
    docker-compose stop hazelcast services
    docker-compose up -d hazelcast
    docker-compose up -d services && sleep 15
    docker-compose restart corebridge && sleep 30
    docker-compose restart alebridge && sleep 30
    docker-compose up -d && sleep 15
    cd $AUTOMATION_PATH
    gradle automationTest -Pcategory=@RunCoreBridge -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS
    sleep 40
    gradle automationTest -Pcategory=@RunAleBridge -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS
    sleep 40
}

# This method is to reconfigure the .env file
# $1 String VIZIX_COMPOSE
# $2 String DOCKER_BRANCH_UI
# $3 String DOCKER_BRANCH_BRIDGES
# $4 String DOCKER_BRANCH_SERVICES
# $5 String PUBLIC_IP
# $6 String PRIVATE_IP
# $7 String DOCKER_BRANCH_TOOLS
# $8 String $DOCKER_MICROSERVICES
updateEnvFile(){
    local DOCKER_BRANCH_UI=$2
    local DOCKER_BRANCH_BRIDGES=$3
    local DOCKER_BRANCH_SERVICES=$4
    local PUBLIC_IP=$5
    local PRIVATE_IP=$6
    local VIZIX_COMPOSE=$1
    local DOCKER_BRANCH_TOOLS=$7
    local DOCKER_MICROSERVICES=$8

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
            monitoring-dashboard*)
               local MONITORING_DASHBOARD=$(echo ${version} | sed -e "s/monitoring-dashboard://")
               sed -i "/MONITORING_DASHBOARD/c MONITORING_DASHBOARD=mojix/statemachine-api-dashboard-monitoring:$MONITORING_DASHBOARD" .env
               ;;
            epcis-event-generator*)
               local EVENTGENERATOR=$(echo ${version} | sed -e "s/epcis-event-generator://")
               sed -i "/EVENTGENERATOR/c EVENTGENERATOR=mojix/vizix-epcis-event-generator:$EVENTGENERATOR" .env
               ;;
            *)
               echo "WARN > WARN!!!  No Container was found : "$version
               ;;
        esac
    done

    sed -i "/riot-core-ui:/c UI=mojix/riot-core-ui:$DOCKER_BRANCH_UI" .env
    sed -i "/BRIDGES=/c BRIDGES=mojix/riot-core-bridges:$DOCKER_BRANCH_BRIDGES" .env
    sed -i "/SERVICES=/c SERVICES=mojix/riot-core-services:$DOCKER_BRANCH_SERVICES" .env
    sed -i "/vizix-tools:/c VIZIXTOOLS=mojix/vizix-tools:$DOCKER_BRANCH_SERVICES" .env
    sed -i "/UI_URL=/c UI_URL=$PUBLIC_IP" .env
    sed -i "/SERVICES_URL=/c SERVICES_URL=$PUBLIC_IP:80" .env
    sed -i s/localhost/$PRIVATE_IP/g .env
    sed -i "/VIZIX_DATA_PATH/c VIZIX_DATA_PATH=$VIZIX_COMPOSE" .env
    sed -i "/VIZIXTOOLS/c VIZIXTOOLS=mojix/vizix-tools:$DOCKER_BRANCH_TOOLS" .env

    echo "INFO> ****************** cat .env ********************* " && cat .env && echo "INFO > ******************* File configured ******************"
}


# $1 PATH_COMPOSE_BUILDER
# $2 ADD_CONTAINERS
# $3 VIZIX_COMPOSE
# $4 IS_KAFKA
# $5 BASIC_CONFIG
builderDockerCompose(){
   PATH_COMPOSE_BUILDER=$1
   ADD_CONTAINERS=$2
   VIZIX_COMPOSE=$3
   IS_KAFKA=$4
   BASIC_CONFIG=$5

   echo "INFO > ***********************Starting Docker Compose Builder *********************************"
   echo "INFO > sudo mkdir $VIZIX_COMPOSE"
   sudo mkdir $VIZIX_COMPOSE

   replaceDockerComposeUpdated $IS_KAFKA $PATH_COMPOSE_BUILDER $VIZIX_COMPOSE $ADD_CONTAINERS

   echo "cp $BASIC_CONFIG/*.* $VIZIX_COMPOSE/"
   sudo cp -a -r $BASIC_CONFIG/* $VIZIX_COMPOSE/
   sudo cp $BASIC_CONFIG/.env $VIZIX_COMPOSE/
   cd $VIZIX_COMPOSE
   cat .env
   echo " " && echo "INFO >*************************Docker Compose was Created"
}

#
# This method is to recreate the docker-compose
#
#$1 BASIC_COMPOSE
#$2 PATH_COMPOSE_BUILDER
#$3 VIZIX_COMPOSE
#$4 ADD_CONTAINERS
replaceDockerComposeUpdated(){
   IS_KAFKA=$1
   PATH_COMPOSE_BUILDER=$2
   VIZIX_COMPOSE=$3
   ADD_CONTAINERS=$(echo $4 | tr ',' ' ')

   BASIC_CONTAINER=""

   # building basic container
   if [[ $ADD_CONTAINERS = *"basic"* ]]; then
       if [ "$IS_KAFKA" == "true" ]
       then
           BASIC_CONTAINER="$PATH_COMPOSE_BUILDER/templates/services_kafka $PATH_COMPOSE_BUILDER/templates/mysql"
       else
           BASIC_CONTAINER="$PATH_COMPOSE_BUILDER/templates/services_cbmt $PATH_COMPOSE_BUILDER/templates/mysql"
       fi
   fi

  #building docker compose
  # if the container does not contains the _basic it uses the default basic-compose-kafka
  # if the container contains some _basic , it should have a basic config
  echo "INFO> container : $ADD_CONTAINERS"
  if [[ "$ADD_CONTAINERS" != *"_basic"* ]]
    then
       BASIC_COMPOSE="$PATH_COMPOSE_BUILDER/templates/basic-compose-kafka.yml $BASIC_CONTAINER"
       echo "INFO> String does not contins _basic structure, it is taking the default : $PATH_COMPOSE_BUILDER/templates/basic-compose-kafka.yml $BASIC_CONTAINER"
  fi

   echo "INFO > Updating Docker Compose with new containers : $ADD_CONTAINERS"
   echo "INFO > cat $BASIC_COMPOSE $ADD_CONTAINERS > $VIZIX_COMPOSE/docker-compose.yml"

   cd $PATH_COMPOSE_BUILDER/templates/
   sudo cat $BASIC_COMPOSE $ADD_CONTAINERS > $VIZIX_COMPOSE/docker-compose.yml

   echo "INFO > DockerCompose was created with $ADD_CONTAINERS"
   echo "INFO > **** docker-compose.yml ****"
   cat $VIZIX_COMPOSE/docker-compose.yml
}

#
# This method is to wait while Oracle is ready to use
#
waitToCheckIfOracleContainerIsReady(){
    echo "INFO> --------- start method to wait Oracle Container -------"
    CONTAINERID=$(docker inspect --format="{{.Id}}" oracle)
    isCompleted=true
    timeout=1
    result="ERROR >!!!!!!!!!!! FAILED ORACLE CONTAINER IS NOT READY IN 30 MINUTES !!!!!!!!!!!!"
    while [ $isCompleted = true ] && [ $timeout -lt 30 ] ;
    do
       sleep 1m
       if [ "$(grep -c 'DATABASE IS READY TO USE' /var/lib/docker/containers/${CONTAINERID}/${CONTAINERID}-json.log)" -gt 0 ]
       then
          isCompleted=false
          result="INFO > Oracle container is READY to use !"
       fi
       echo "INFO >waiting time : $timeout minute"
       timeout=$((timeout+1))
    done
      echo $result
}

#
# this method is to install Python 3.6
#
installPython(){
    ##### Install Python 3.6 required for shopcx test ####
    echo "INFO > sudo add-apt-repository ppa:jonathonf/python-3.6 -y" && echo " "
    sudo add-apt-repository ppa:jonathonf/python-3.6 -y
    echo "INFO > sudo apt-get update" && echo " "
    sleep 10s && sudo apt-get update
    echo "INFO > sudo apt-get install python3.6 -y" && echo " "
    sleep 10s && sudo apt-get install python3.6 -y && sleep 10s
    echo "INFO > sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1" && echo " "
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.5 1
    echo "INFO > sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2" && echo " "
    sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2
    echo "INFO > sudo wget https://bootstrap.pypa.io/get-pip.py" && echo " "
    sudo wget https://bootstrap.pypa.io/get-pip.py && sleep 30
    echo "INFO > sudo python3.6 get-pip.py" && echo " "
    sudo python3.6 get-pip.py && sleep 5s
    sudo pip3 -V
    echo "INFO > sudo pip3 install bitstring" && echo " "
    sudo pip3 install bitstring
    echo "***** Version Python : $(sudo python3 -V)" && echo "****** Version Python : $(sudo pip3 -V)"

}
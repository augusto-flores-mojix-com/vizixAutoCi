#!/usr/bin/env bash
#
# @autor: Eynar Pari
# @date : 14/03/18

# This method is to setup environment type kafka
# $1 DOCKER_USER
# $2 DOCKER_PASSWORD
# $3 PATH_REPOSITORIES
# $4 GIT_USER
# $5 GIT_PASSWORD
# $6 AUTOMATION_PATH
# $7 GIT_BRANCH
# $8 VIZIX_COMPOSE
# $9 DOCKER_BRANCH_UI
# ${10} DOCKER_BRANCH_BRIDGES
# ${11} DOCKER_BRANCH_SERVICES
# ${12} PUBLIC_IP
# ${13} PRIVATE_IP
# ${14} NUMBER_THREADS_CB
# ${15} REPORT_SAVED
# ${16} POPDB_NAME
# ${17} PATH_UTILS
# ${18} DOCKER_BRANCH_TOOLS
# ${19} GIT_JMETER_BRANCH
# ${20} DOCKER_MICROSERVICES
# ${21} IS_ORACLE
# ${22} ORACLE_LOCAL_PARAMETERS
setupEnvironmentKafka(){
    local PATH_UTILS=${17}
    source $PATH_UTILS
    #vars
    #######################
    local DOCKER_USER=$1
    local DOCKER_PASSWORD=$2
    local PATH_REPOSITORIES=$3
    local GIT_USER=$4
    local GIT_PASSWORD=$5
    local AUTOMATION_PATH=$6
    local GIT_BRANCH=$7
    local VIZIX_COMPOSE=$8
    local DOCKER_BRANCH_UI=$9
    local DOCKER_BRANCH_BRIDGES=${10}
    local DOCKER_BRANCH_SERVICES=${11}
    local PUBLIC_IP=${12}
    local PRIVATE_IP=${13}
    local NUMBER_THREADS_CB=${14}
    local REPORT_SAVED=${15}
    local POPDB_NAME=${16}
    local DOCKER_BRANCH_TOOLS=${18}
    local GIT_JMETER_BRANCH=${19}
    local DOCKER_MICROSERVICES=${20}
    local IS_ORACLE=${21}
    local ORACLE_LOCAL_PARAMETERS=${22}

    echo "INFO> Setup Environmnet for POPDB : $POPDB_NAME"
    case "$POPDB_NAME" in

        automation-core)
            echo "INFO > Execute setupEnvironmentKafkaViZixCore"
            setupEnvironmentKafkaViZixCore $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $GIT_JMETER_BRANCH $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
            ;;
        retail-core-epcis)
            echo "INFO > Execute setupEnvironmentKafkaShopCX $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $GIT_JMETER_BRANCH $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS"
            setupEnvironmentKafkaShopCX $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $GIT_JMETER_BRANCH $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
            ;;
        retail-core-epcis-eclipse)
            POPDB_NAME=retail-core-epcis
            echo "INFO > Execute setupEnvironmentKafkaEclipse $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $GIT_JMETER_BRANCH $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS"
            setupEnvironmentKafkaEclipse $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $GIT_JMETER_BRANCH $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
            ;;

        retail-core-epcis-red-red)
            POPDB_NAME=retail-core-epcis
            echo "INFO > Execute setupEnvironmentRedRed $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $GIT_JMETER_BRANCH $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS"
            setupEnvironmentRedRed $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $GIT_JMETER_BRANCH $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
            ;;
        retail-core-epcis-eclipse-eclipse)
            POPDB_NAME=retail-core-epcis
            echo "INFO > Execute setupEnvironmentEclipseEclipse $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $GIT_JMETER_BRANCH $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS"
            setupEnvironmentEclipseEclipse $DOCKER_USER $DOCKER_PASSWORD $PATH_REPOSITORIES $GIT_USER $GIT_PASSWORD $AUTOMATION_PATH $GIT_BRANCH $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $NUMBER_THREADS_CB $REPORT_SAVED $POPDB_NAME $PATH_UTILS $DOCKER_BRANCH_TOOLS $GIT_JMETER_BRANCH $DOCKER_MICROSERVICES $IS_ORACLE $ORACLE_LOCAL_PARAMETERS
            ;;
        tracker-retail)
            echo "INFO> todo - add logic for new popdb for tracker retail - mobile"
            ;;

        *)
           echo "ERROR >  ERROR !!!! There is not process for the popdb name : "$POPDB_NAME
           ;;
    esac
}



# This method is to setup environment type kafka
# $1 DOCKER_USER
# $2 DOCKER_PASSWORD
# $3 PATH_REPOSITORIES
# $4 GIT_USER
# $5 GIT_PASSWORD
# $6 AUTOMATION_PATH
# $7 GIT_BRANCH
# $8 VIZIX_COMPOSE
# $9 DOCKER_BRANCH_UI
# ${10} DOCKER_BRANCH_BRIDGES
# ${11} DOCKER_BRANCH_SERVICES
# ${12} PUBLIC_IP
# ${13} PRIVATE_IP
# ${14} NUMBER_THREADS_CB
# ${15} REPORT_SAVED
# ${16} POPDB_NAME
# ${17} PATH_UTILS
# ${18} DOCKER_BRANCH_TOOLS
# ${19} GIT_JMETER_BRANCH
# ${20} DOCKER_MICROSERVICES
# ${21} IS_ORACLE
# ${22} ORACLE_LOCAL_PARAMETERS
setupEnvironmentKafkaViZixCore(){
    PATH_UTILS=${17}
    source $PATH_UTILS
    echo "********************************************************************************************************"
    echo "*                          SETUP ENVIRONMENT FOR KAFKA VIZIX CORE                                      *"
    echo "********************************************************************************************************"
    #vars
    #######################
    local DOCKER_USER=$1
    local DOCKER_PASSWORD=$2
    local PATH_REPOSITORIES=$3
    local GIT_USER=$4
    local GIT_PASSWORD=$5
    local AUTOMATION_PATH=$6
    local GIT_BRANCH=$7
    local VIZIX_COMPOSE=$8
    local DOCKER_BRANCH_UI=$9
    local DOCKER_BRANCH_BRIDGES=${10}
    local DOCKER_BRANCH_SERVICES=${11}
    local PUBLIC_IP=${12}
    local PRIVATE_IP=${13}
    local NUMBER_THREADS_CB=${14}
    local REPORT_SAVED=${15}
    local POPDB_NAME=${16}
    local DOCKER_BRANCH_TOOLS=${18}
    local GIT_JMETER_BRANCH=${19}
    local DOCKER_MICROSERVICES=${20}
    local IS_ORACLE=${21}
    local ORACLE_LOCAL_PARAMETERS=$(echo ${22} | tr '*' ' ')

    mkdir $REPORT_SAVED
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    echo "INFO > login on dockerhub"
    docker login -u$DOCKER_USER -p$DOCKER_PASSWORD
    echo "INFO > cloning repository for Automation on branch : $GIT_BRANCH"
    cd $PATH_REPOSITORIES
    git clone -b $GIT_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation.git
    git clone -b $GIT_JMETER_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation-jmeter.git
    cd $AUTOMATION_PATH && git branch && git pull

    cd $VIZIX_COMPOSE
    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES
    docker-compose pull && sleep 10

    echo "INFO > added admin user to mongo"
    docker-compose up -d mongo && sleep 20s
    docker-compose exec -T mongo mongo admin --eval "db.createUser({user:'admin', pwd:'control123!',roles:['userAdminAnyDatabase']});"
    docker-compose exec -T mongo mongo admin -u admin -p control123! --authenticationDatabase admin --eval "db.createRole({role:'executeFunctions',privileges:[{resource:{anyResource:true},actions:['anyAction']}],roles:[]});db.grantRolesToUser('admin',[{ role: 'executeFunctions', db: 'admin' },{ role : 'readWrite', db : 'viz_root' },{ role : 'readWrite', db : 'viz_mojix' }]);"

    docker-compose up -d mysql mosquitto hazelcast kafka

    echo "INFO > Updating PopDb : $POPDB_NAME"
    sed -i "s/VIZIX_POPDB_OPTION: POPDB_NAME/VIZIX_POPDB_OPTION: $POPDB_NAME/g" vizix-tools.yml
    cat vizix-tools.yml && sleep 60s

    echo "INFO > up vizix-tools.yml  > /tmp/popdb.log"
    docker-compose -f vizix-tools.yml up > /tmp/popdb.log
    checkErrorOnFile /tmp/popdb.log
    echo "POPDB > ****************** Show logs PopDb ******************"
    cat /tmp/popdb.log && sleep 30
    echo "**************************************************************"
    docker-compose up -d flow ntpdserver ntpd logio logs proxy flow rpui rpin mongoinjector hbridge m2kbridge k2m m2kbridge transformbridge actionprocessor services mongo mysql kafka mosquitto
    docker-compose restart services && sleep 60

    cd $AUTOMATION_PATH
    echo "INFO > replace $PRIVATE_IP instead of localhost on build.gradle"
    sed -i s/localhost/$PRIVATE_IP/g build.gradle

    echo "INFO > gradle clean automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=False -Pport=80"
    gradle clean automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=False -Pport=80
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -Pcategory=@License -Pnocategory=~@NotKafka -Pport=80"
    gradle clean automationTest -Pcategory=@License -Pnocategory=~@NotKafka -Pport=80
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/2SetupLicense$PUBLIC_IP.json

    sleep 20
    echo "INFO > gradle clean automationTest -Pcategory=@SetupEnvironmentConnectionKafka -Pnocategory=@$POPDB_NAME -Pport=80"
    gradle clean automationTest -Pcategory=@SetupEnvironmentConnectionKafka -Pnocategory=@$POPDB_NAME -Pport=80
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/3SetupConnectionKafka$PUBLIC_IP.json

    cd $AUTOMATION_PATH
    echo "INFO > gradle clean automationTest -Pcategory=@RunAleBridgeKafka -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast"
    gradle clean automationTest -Pcategory=@RunAleBridgeKafka -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/4ConfigureAleBrdige$PUBLIC_IP.json
    sleep 60
    cd $VIZIX_COMPOSE
    docker-compose up -d services rpin rpui mongoinjector m2kbridge transformbridge actionprocessor hbridge && sleep 60
    docker-compose up -d k2m && sleep 15
    sudo docker ps > /tmp/docker.log
    sudo docker images > /tmp/dockerimages.log
    cat /tmp/dockerimages.log /tmp/docker.log

    checkErrorOnContainerLogs

    echo "INFO > Environment is Ready"
    echo "INFO > getting log for setup environment :  gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False"
    cp /tmp/setuplog.log /tmp/setuplog2.log && sleep 5
    cd $AUTOMATION_PATH
    gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False
    sleep 5s && cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/5GetLog$PUBLIC_IP.json && sleep 5s
    echo "---------------------------- Complete Setup And Configure Environment---------------------"
}


# This method is to setup environment type kafka
# $1 DOCKER_USER
# $2 DOCKER_PASSWORD
# $3 PATH_REPOSITORIES
# $4 GIT_USER
# $5 GIT_PASSWORD
# $6 AUTOMATION_PATH
# $7 GIT_BRANCH
# $8 VIZIX_COMPOSE
# $9 DOCKER_BRANCH_UI
# ${10} DOCKER_BRANCH_BRIDGES
# ${11} DOCKER_BRANCH_SERVICES
# ${12} PUBLIC_IP
# ${13} PRIVATE_IP
# ${14} NUMBER_THREADS_CB
# ${15} REPORT_SAVED
# ${16} POPDB_NAME
# ${17} PATH_UTILS
# ${18} DOCKER_BRANCH_TOOLS
# ${19} GIT_JMETER_BRANCH
# ${20} DOCKER_MICROSERVICES
# ${21} IS_ORACLE
# ${22} ORACLE_LOCAL_PARAMETERS
setupEnvironmentKafkaShopCX(){

    PATH_UTILS=${17}
    source $PATH_UTILS
    echo "********************************************************************************************************"
    echo "*                          SETUP ENVIRONMENT FOR KAFKA VIZIX SHOPCX                                    *"
    echo "********************************************************************************************************"
    #vars
    #######################
    local DOCKER_USER=$1
    local DOCKER_PASSWORD=$2
    local PATH_REPOSITORIES=$3
    local GIT_USER=$4
    local GIT_PASSWORD=$5
    local AUTOMATION_PATH=$6
    local GIT_BRANCH=$7
    local VIZIX_COMPOSE=$8
    local DOCKER_BRANCH_UI=$9
    local DOCKER_BRANCH_BRIDGES=${10}
    local DOCKER_BRANCH_SERVICES=${11}
    local PUBLIC_IP=${12}
    local PRIVATE_IP=${13}
    local NUMBER_THREADS_CB=${14}
    local REPORT_SAVED=${15}
    local POPDB_NAME=${16}
    local DOCKER_BRANCH_TOOLS=${18}
    local GIT_JMETER_BRANCH=${19}
    local DOCKER_MICROSERVICES=${20}
    local IS_ORACLE=${21}
    local ORACLE_LOCAL_PARAMETERS=$(echo ${22} | tr '*' ' ')

    local PATH_MONITORING=/home

    rm -rf ${PATH_MONITORING}/dp-monitoring-init
    cd ${PATH_MONITORING}/
    git clone -b dev/6.x.x https://${GIT_USER}:${GIT_PASSWORD}@github.com/tierconnect/dp-monitoring-init.git
    cd ${PATH_MONITORING}/dp-monitoring-init
    docker build .

    mkdir $REPORT_SAVED
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    echo "INFO > Login on dockerhub"
    docker login -u$DOCKER_USER -p$DOCKER_PASSWORD
    echo "INFO > Cloning repository for Automation on branch : $GIT_BRANCH"
    cd $PATH_REPOSITORIES
    git clone -b $GIT_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation.git
    git clone -b $GIT_JMETER_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation-jmeter.git
    cd $AUTOMATION_PATH && git branch && git pull

    cd $VIZIX_COMPOSE

    rm Caddyfile
#    sed -i "s/httpbridge:8080/${PRIVATE_IP}:9091/g" ShopCXCaddyfile
    cat ShopCXCaddyfile > Caddyfile

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES

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

    docker-compose -f vizix-tools.yml up > /tmp/popdb-platform-core-root.log
    echo "INFO > ********** Popdb popdb-platform-core-root logs **********" && cat /tmp/popdb-platform-core-root.log
    docker-compose up -d services
    sleep 30s

    echo "INFO > Configure variables for retail-core-epcis popDB"
    sed -i "s/VIZIX_SYSCONFIG_OPTION: platform-core-root/VIZIX_SYSCONFIG_OPTION: retail-core-epcis/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_TENANT_CODE: root/VIZIX_SYSCONFIG_TENANT_CODE: RED/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_TENANT_NAME: root/VIZIX_SYSCONFIG_TENANT_NAME: RED/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_HIERARCHY: \">root\"/VIZIX_SYSCONFIG_HIERARCHY: \">RED\"/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_CLEAN: \"true\"/VIZIX_SYSCONFIG_CLEAN: \"false\"/g" vizix-tools.yml
    sed -i "s/VIZIX_KAFKA_DATA_RETENTION_UPDATER: \"true\"/VIZIX_KAFKA_DATA_RETENTION_UPDATER: \"false\"/g" vizix-tools.yml
    sed -i "s/VIZIX_KAFKA_CREATE_TOPICS: \"true\"/VIZIX_KAFKA_CREATE_TOPICS: \"false\"/g" vizix-tools.yml
    sleep 10s && docker-compose -f vizix-tools.yml up > /tmp/popdb-retail-core-epcis.log
    echo "INFO > ********** Popdb popdb-retail-core-epcis logs *********" && cat /tmp/popdb-retail-core-epcis.log
    sleep 1m
    docker-compose up -d flow ntpdserver ntpd logio logs proxy flow rpui rpin mongoinjector hbridge m2kbridge k2m m2kbridge transformbridge actionprocessor services mongo mysql kafka mosquitto ui
    docker-compose restart services
    sleep 1m
    docker-compose ps

    cd $AUTOMATION_PATH
    sed -i s/localhost/$PRIVATE_IP/g build.gradle
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}

    echo "INFO>Preparing Environment using Automation Test ..................."
    echo "INFO > gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=false -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=false -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    echo "INFO > gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    sleep 10s

    echo "INFO > gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    cd $VIZIX_COMPOSE
    sed -i "/EXTERNAL_IP/c EXTERNAL_IP=$PUBLIC_IP" .env
    sed -i "/INTERNAL_IP/c INTERNAL_IP=$PRIVATE_IP" .env
    echo "INFO > Configure shopCX environment"
    docker-compose up -d shopcx-mysql && sleep 20s

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

    echo "INFO> Configure ElasticSearch"
    sysctl -w vm.max_map_count=262144
    sysctl -w vm.max_map_count=262144 && echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
    sysctl -p

    docker-compose up -d shopcx-elasticsearch-monitoring
    docker-compose up -d influxdb
    sleep 20s
    echo "INFO > Configure influxDB"
    docker-compose exec -T influxdb influx -execute "CREATE DATABASE telegraf"
    docker-compose exec -T influxdb influx -execute "CREATE DATABASE asnauto"
    docker-compose exec -T influxdb influx -execute "CREATE USER admin WITH PASSWORD 'control123!' WITH ALL PRIVILEGES"

    echo '[rabbitmq_management,rabbitmq_shovel,rabbitmq_shovel_management].' > enabled_plugins
    docker-compose up -d shopcx-rabbitmq

    echo "INFO > Up the other components"
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
    echo "INFO > Obtaining Api key root: $APIKEY from mysql"
    sed -i "/VIZIX_API_KEY/c VIZIX_API_KEY=$APIKEY" .env

    docker-compose restart red-amqp-servicebus && sleep 10s
    docker-compose up -d shopcx-rabbitmq && sleep 20s
    docker-compose up -d reportgenerator && sleep 20s
    docker-compose up -d externaltransformer && sleep 30s
    docker-compose up -d internaltransformer
    docker-compose up -d reverse-proxy-devices
    docker-compose up -d proxySCX

    docker-compose up -d && sleep 30s

    docker-compose restart dp-asn-auto-engine && sleep 15s

    echo "INFO > Added Definition on rabbitmq"
    echo "INFO > curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D"
    curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "************ Info Definition Created ***************" && sleep 10s
    curl -v -X GET  http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "****************************************************"


    echo "INFO > Environment is Ready"
    cd $AUTOMATION_PATH
    echo "INFO > gradle clean automationTest -Pcategory=@RequirementData -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false"
    gradle clean automationTest -Pcategory=@RequirementData -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/RequirementsShopCX$PUBLIC_IP.json

    cd $VIZIX_COMPOSE

    APIKEY=$(docker-compose exec -T mysql mysql -uroot -pcontrol123! riot_main --execute "select apiKey from VIZ_APC_USER where username='REDroot1';" | grep -v -e "Using a password on the command line interface can be insecure" -e "id"  -e "apiKey")
    echo "INFO > ********** Obtaining Api key REDroot1 : $APIKEY from mysql **************"
    sed -i "/VIZIX_API_KEY/c VIZIX_API_KEY=$APIKEY" .env

    docker-compose up -d externaltransformer && sleep 90s
    docker-compose up -d
    docker-compose restart services && sleep 2m
    docker-compose restart externaltransformer && sleep 90s
    docker-compose restart internaltransformer  && sleep 30s
    docker-compose restart configuration-api-languages  && sleep 15s
    docker-compose restart configuration-api-devices  && sleep 15s

    cd $AUTOMATION_PATH
    echo "INFO > gradle clean automationTest -Pcategory=@ShopCXStructure -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=REDroot1 -POrganizationShopCX=RED -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80"
    gradle clean automationTest -Pcategory=@ShopCXStructure -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=REDroot1 -POrganizationShopCX=RED -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Structure$PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=RED -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=RED -PcleanAllEntities=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/RequirementsEnabledRule$PUBLIC_IP.json

    cd $VIZIX_COMPOSE
    echo "INFO> *************** Containers Information ***************"
    sudo docker ps > /tmp/docker.log
    sudo docker images > /tmp/dockerimages.log
    cat /tmp/dockerimages.log /tmp/docker.log
    checkErrorOnContainerLogs

    cd $AUTOMATION_PATH

    echo "INFO > gradle clean automationTest -Pcategory=@ShopCXStructureFixture -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=REDroot1 -POrganizationShopCX=RED -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80"
    gradle clean automationTest -Pcategory=@ShopCXStructureFixture -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=REDroot1 -POrganizationShopCX=RED -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/StructureFixture$PUBLIC_IP.json

    echo "INFO > getting log for setup environment :  gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False"
    cp /tmp/setuplog.log /tmp/setuplog2.log && sleep 5

    cd $AUTOMATION_PATH
    gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False
    sleep 5s && cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/5GetLog$PUBLIC_IP.json && sleep 5s

    echo "---------------------------- Complete Setup Environment - ShopCX ---------------------"
}

# $1 DOCKER_USER
# $2 DOCKER_PASSWORD
# $3 PATH_REPOSITORIES
# $4 GIT_USER
# $5 GIT_PASSWORD
# $6 AUTOMATION_PATH
# $7 GIT_BRANCH
# $8 VIZIX_COMPOSE
# $9 DOCKER_BRANCH_UI
# ${10} DOCKER_BRANCH_BRIDGES
# ${11} DOCKER_BRANCH_SERVICES
# ${12} PUBLIC_IP
# ${13} PRIVATE_IP
# ${14} NUMBER_THREADS_CB
# ${15} REPORT_SAVED
# ${16} POPDB_NAME
# ${17} PATH_UTILS
# ${18} DOCKER_BRANCH_TOOLS
# ${19} GIT_JMETER_BRANCH
# ${20} DOCKER_MICROSERVICES
# ${21} IS_ORACLE
# ${22} ORACLE_LOCAL_PARAMETERS
setupEnvironmentKafkaEclipse(){

    PATH_UTILS=${17}
    source $PATH_UTILS
    echo "********************************************************************************************************"
    echo "*                          SETUP ENVIRONMENT FOR KAFKA VIZIX ECLIPSE                                   *"
    echo "********************************************************************************************************"
    #vars
    #######################
    local DOCKER_USER=$1
    local DOCKER_PASSWORD=$2
    local PATH_REPOSITORIES=$3
    local GIT_USER=$4
    local GIT_PASSWORD=$5
    local AUTOMATION_PATH=$6
    local GIT_BRANCH=$7
    local VIZIX_COMPOSE=$8
    local DOCKER_BRANCH_UI=$9
    local DOCKER_BRANCH_BRIDGES=${10}
    local DOCKER_BRANCH_SERVICES=${11}
    local PUBLIC_IP=${12}
    local PRIVATE_IP=${13}
    local NUMBER_THREADS_CB=${14}
    local REPORT_SAVED=${15}
    local POPDB_NAME=${16}
    local DOCKER_BRANCH_TOOLS=${18}
    local GIT_JMETER_BRANCH=${19}
    local DOCKER_MICROSERVICES=${20}
    local IS_ORACLE=${21}
    local ORACLE_LOCAL_PARAMETERS=$(echo ${22} | tr '*' ' ')

    mkdir $REPORT_SAVED
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    echo "INFO > Login on Docker Hub" && docker login -u$DOCKER_USER -p$DOCKER_PASSWORD && docker login docker-pull.factory.shopcx.io -umojixpull -pYWaQPtC9DDnfHN2Q
    echo "INFO > Cloning repository for Automation on branch : $GIT_BRANCH"
    cd $PATH_REPOSITORIES
    git clone -b $GIT_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation.git
    git clone -b $GIT_JMETER_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation-jmeter.git
    cd $AUTOMATION_PATH && git branch && git pull

    cd $VIZIX_COMPOSE
    rm Caddyfile
    cat ShopCXCaddyfile > Caddyfile

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES
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
    docker-compose -f vizix-tools.yml up > /tmp/popdb-platform-core-root.log
    echo "INFO > ********* Popdb popdb-platform-core-root logs ****************** " && cat /tmp/popdb-platform-core-root.log
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
    docker-compose -f vizix-tools.yml up > /tmp/popdb-retail-core-epcis.log
    echo "INFO > ********** Popdb popdb-retail-core-epcis logs ***********" && cat /tmp/popdb-retail-core-epcis.log
    sleep 1m
    docker-compose up -d flow ntpdserver ntpd logio logs proxy flow rpui rpin mongoinjector hbridge m2kbridge k2m m2kbridge transformbridge actionprocessor services mongo mysql kafka mosquitto ui
    docker-compose restart services
    sleep 1m

    echo "INFO > Start FTP Server"
    ./FTPServer.sh $PRIVATE_IP Automation Control123! files
    sleep 15s
    echo "INFO > ****** Status FTP Server *********" && cat /tmp/pythonFTPServer.log && echo "INFO > ********************************* "

    cd $AUTOMATION_PATH
    sed -i s/localhost/$PRIVATE_IP/g build.gradle
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}

    echo "INFO>Preparing Environment using Automation Test ..................."

    echo "INFO > gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=false -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=false -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    echo "INFO > gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    sleep 10s

    echo "INFO > gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Configuration$PUBLIC_IP.json

    cd $VIZIX_COMPOSE
    sed -i "/EXTERNAL_IP/c EXTERNAL_IP=$PUBLIC_IP" .env
    sed -i "/INTERNAL_IP/c INTERNAL_IP=$PRIVATE_IP" .env
    echo "INFO > Configure shopCX environment"
    docker-compose up -d shopcx-mysql && sleep 20s

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
    echo "INFO > curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D"
    curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "************ Info Definition Created ***************" && sleep 10s
    curl -v -X GET  http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "****************************************************"

    echo "INFO > Environment is Ready"
    cd $AUTOMATION_PATH

    echo "INFO > gradle clean automationTest -Pcategory=@RequirementDataEclipse -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=ECLIPSE"
    gradle clean automationTest -Pcategory=@RequirementDataEclipse -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=ECLIPSE
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/RequirementsShopCX$PUBLIC_IP.json

    cd $VIZIX_COMPOSE && sleep 15s

    APIKEY=$(docker-compose exec -T mysql mysql -uroot -pcontrol123! riot_main --execute "select apiKey from VIZ_APC_USER where username='ECLIPSEroot1';" | grep -v -e "Using a password on the command line interface can be insecure" -e "id"  -e "apiKey")
    echo "INFO > ********** Obtaining Api key ECLIPSEroot1 : $APIKEY from mysql **************"
    sed -i "/VIZIX_API_KEY/c VIZIX_API_KEY=$APIKEY" .env

    local BASIC_AUTH=$(echo "root:Control123!"| base64)
    sed -i "/BASIC_AUTH_USER/c BASIC_AUTH_USER=$BASIC_AUTH" .env

    docker-compose up -d externaltransformer && sleep 90s && docker-compose up -d
    docker-compose restart services && sleep 2m
    docker-compose restart externaltransformer && sleep 90s
    docker-compose restart internaltransformer  && sleep 30s

    cd $AUTOMATION_PATH
    echo "INFO > gradle clean automationTest -Pcategory=@ShopCXStructure -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=ECLIPSEroot1 -POrganizationShopCX=ECLIPSE -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80"
    gradle clean automationTest -Pcategory=@ShopCXStructure -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=ECLIPSEroot1 -POrganizationShopCX=ECLIPSE -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Structure$PUBLIC_IP.json


    echo "INFO > gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=ECLIPSE  -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=ECLIPSE -PcleanAllEntities=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/RequirementsEnabledRule$PUBLIC_IP.json

    cd $VIZIX_COMPOSE
    echo "INFO> *************** Containers Information ***************"
    sudo docker ps > /tmp/docker.log
    sudo docker images > /tmp/dockerimages.log
    cat /tmp/dockerimages.log /tmp/docker.log
    checkErrorOnContainerLogs
    echo " curl -v -X POST http://$PRIVATE_IP:8099/tag-auth-api/rest/encryption/key -H 'Content-Type: application/json' -d '{\"secret": "FLXZilOA\",\"salt\": \"LLTUS5oI\",\"key\":\"1dfdefff4f823d158eacd3ec405ca2ee\"}'"
    curl -v -X POST http://$PRIVATE_IP:8099/tag-auth-api/rest/encryption/key -H 'Content-Type: application/json' -d '{"secret": "FLXZilOA","salt": "LLTUS5oI","key":"1dfdefff4f823d158eacd3ec405ca2ee"}'

    echo "INFO > getting log for setup environment :  gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False"
    cp /tmp/setuplog.log /tmp/setuplog2.log && sleep 5

    cd $AUTOMATION_PATH

    gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False
    sleep 5s && cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/5GetLog$PUBLIC_IP.json && sleep 5s

    echo "---------------------------- Complete Setup Environment - Eclipse---------------------"
}

# This method is to setup environment type CBMT
# $1 DOCKER_USER
# $2 DOCKER_PASSWORD
# $3 PATH_REPOSITORIES
# $4 GIT_USER
# $5 GIT_PASSWORD
# $6 AUTOMATION_PATH
# $7 GIT_BRANCH
# $8 VIZIX_COMPOSE
# $9 DOCKER_BRANCH_UI
# ${10} DOCKER_BRANCH_BRIDGES
# ${11} DOCKER_BRANCH_SERVICES
# ${12} PUBLIC_IP
# ${13} PRIVATE_IP
# ${14} NUMBER_THREADS_CB
# ${15} REPORT_SAVED
# ${16} POPDB_NAME
# ${17} PATH_UTILS
# ${18} DOCKER_BRANCH_TOOLS
# ${19} IS_ORACLE
# ${20} ORACLE_LOCAL_PARAMETERS
# ${21} GIT_JMETER_BRANCH
setupEnvironmentCbMT(){
    PATH_UTILS=${17}
    source $PATH_UTILS
    echo "********************************************************************************************************"
    echo "*                      SETUP ENVIRONMENT FOR COREBRIDGE MT                                             *"
    echo "********************************************************************************************************"
    DOCKER_USER=$1
    DOCKER_PASSWORD=$2
    PATH_REPOSITORIES=$3
    GIT_USER=$4
    GIT_PASSWORD=$5
    AUTOMATION_PATH=$6
    GIT_BRANCH=$7
    VIZIX_COMPOSE=$8
    DOCKER_BRANCH_UI=$9
    DOCKER_BRANCH_BRIDGES=${10}
    DOCKER_BRANCH_SERVICES=${11}
    PUBLIC_IP=${12}
    PRIVATE_IP=${13}
    NUMBER_THREADS_CB=${14}
    REPORT_SAVED=${15}
    POPDB_NAME=${16}
    DOCKER_BRANCH_TOOLS=${18}
    IS_ORACLE=${19}
    GIT_JMETER_BRANCH=${21}
    ORACLE_LOCAL_PARAMETERS=$(echo ${21} | tr '*' ' ')
    mkdir $REPORT_SAVED
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    docker login -u$DOCKER_USER -p$DOCKER_PASSWORD
    echo "INFO > cloning repository for Automation on branch : $GIT_BRANCH"
    cd $PATH_REPOSITORIES
    git clone -b $GIT_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation.git
    git clone -b $GIT_JMETER_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation-jmeter.git
    cd $AUTOMATION_PATH
    git branch && git pull
    cd $VIZIX_COMPOSE
    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS
    docker-compose pull
    docker-compose rm -f
    rm -rf mongo mysql flows
    echo "INFO > added admin user to mongo"
    docker-compose up -d mongo && sleep 20s
    docker-compose exec -T mongo mongo admin --eval "db.createUser({user:'admin', pwd:'control123!',roles:['userAdminAnyDatabase']});"
    docker-compose exec -T mongo mongo admin -u admin -p control123! --authenticationDatabase admin --eval "db.createRole({role:'executeFunctions',privileges:[{resource:{anyResource:true},actions:['anyAction']}],roles:[]});db.grantRolesToUser('admin',[{ role: 'executeFunctions', db: 'admin' },{ role : 'readWrite', db : 'viz_root' }]);"
    echo "INFO > start mosquitto popdb"


    if [ "$IS_ORACLE" == "true" ]
    then
        SCRIPT_CONNECTION=SetupEnvironmentConnectionOracle
        docker-compose up -d mosquitto oracle hazelcast && sleep 15s
        chmod 777 oracle
        docker-compose up -d oracle
        waitToCheckIfOracleContainerIsReady

    else
        SCRIPT_CONNECTION=SetupEnvironmentConnection
        docker-compose up -d mosquitto mysql hazelcast && sleep 15s
    fi

    echo "INFO > start popdb for : $POPDB_NAME"
    docker-compose run --rm services /run.sh install $POPDB_NAME clean -f
    sleep 5s && docker-compose up -d && sleep 60s
    cd $AUTOMATION_PATH
    sed -i s/localhost/$PRIVATE_IP/g build.gradle
    echo "INFO > gradle clean automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=False -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS "
    gradle clean automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=False -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUser$PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Puser=root -Ppwd=Control123! -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS"
    gradle clean automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Puser=root -Ppwd=Control123! -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/2License$PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -Pcategory=@$SCRIPT_CONNECTION -Pnocategory=@$POPDB_NAME -PnumberCores=$NUMBER_THREADS_CB -Puser=root -Ppwd=Control123! -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS"
    gradle clean automationTest -Pcategory=@$SCRIPT_CONNECTION -Pnocategory=@$POPDB_NAME -PnumberCores=$NUMBER_THREADS_CB -Puser=root -Ppwd=Control123! -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/3SetupConnection$PUBLIC_IP.json

    echo "INFO > clean automationTest -Pcategory=@RunCoreBridge -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS"
    gradle clean automationTest -Pcategory=@RunCoreBridge -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/4RunCoreBridge$PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -Pcategory=@RunAleBridge -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS"
    gradle clean automationTest -Pcategory=@RunAleBridge -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/5RunAleBridge$PUBLIC_IP.json

    cd $VIZIX_COMPOSE
    docker-compose stop hazelcast
    docker-compose stop services
    docker-compose up -d hazelcast
    docker-compose up -d services && sleep 15
    docker-compose restart corebridge && sleep 60
    docker-compose restart alebridge && sleep 60
    cd $AUTOMATION_PATH
    echo "INFO > gradle clean automationTest -Pcategory=@RunCoreBridge -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS"
    gradle automationTest -Pcategory=@RunCoreBridge -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/6StartCoreBridge$PUBLIC_IP.json
    sleep 60
    echo "INFO > gradle clean automationTest -Pcategory=@RunAleBridge -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS"
    gradle automationTest -Pcategory=@RunAleBridge -Pnocategory=@$POPDB_NAME -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast $ORACLE_LOCAL_PARAMETERS
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/7StartAleBridge$PUBLIC_IP.json
    sleep 60

    echo "ASSERT > Check Containers ================================================================="
    sudo docker ps > /tmp/docker.log
    sudo docker images > /tmp/dockerimages.log
    cat /tmp/docker.log /tmp/dockerimages.log

    checkErrorOnContainerLogs

    echo "INFO > Environment is Ready"
    echo "INFO > getting log for setup environment :  gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False $ORACLE_LOCAL_PARAMETERS"
    cp /tmp/setuplog.log /tmp/setuplog2.log && sleep 5
    cd $AUTOMATION_PATH && gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False $ORACLE_LOCAL_PARAMETERS
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/8GetLog$PUBLIC_IP.json
    echo "---------------------------- Complete Setup Environment---------------------"
}


# This method is to setup environment type kafka
# $1 DOCKER_USER
# $2 DOCKER_PASSWORD
# $3 PATH_REPOSITORIES
# $4 GIT_USER
# $5 GIT_PASSWORD
# $6 AUTOMATION_PATH
# $7 GIT_BRANCH
# $8 VIZIX_COMPOSE
# $9 DOCKER_BRANCH_UI
# ${10} DOCKER_BRANCH_BRIDGES
# ${11} DOCKER_BRANCH_SERVICES
# ${12} PUBLIC_IP
# ${13} PRIVATE_IP
# ${14} NUMBER_THREADS_CB
# ${15} REPORT_SAVED
# ${16} POPDB_NAME
# ${17} PATH_UTILS
# ${18} DOCKER_BRANCH_TOOLS
# ${19} GIT_JMETER_BRANCH
# ${20} DOCKER_MICROSERVICES
# ${21} IS_ORACLE
# ${22} ORACLE_LOCAL_PARAMETERS
setupEnvironmentRedRed(){

    PATH_UTILS=${17}
    source $PATH_UTILS
    echo "********************************************************************************************************"
    echo "*                          SETUP ENVIRONMENT  MULTITENANCY RED / RED                                   *"
    echo "********************************************************************************************************"
    #vars
    #######################
    local DOCKER_USER=$1
    local DOCKER_PASSWORD=$2
    local PATH_REPOSITORIES=$3
    local GIT_USER=$4
    local GIT_PASSWORD=$5
    local AUTOMATION_PATH=$6
    local GIT_BRANCH=$7
    local VIZIX_COMPOSE=$8
    local DOCKER_BRANCH_UI=$9
    local DOCKER_BRANCH_BRIDGES=${10}
    local DOCKER_BRANCH_SERVICES=${11}
    local PUBLIC_IP=${12}
    local PRIVATE_IP=${13}
    local NUMBER_THREADS_CB=${14}
    local REPORT_SAVED=${15}
    local POPDB_NAME=${16}
    local DOCKER_BRANCH_TOOLS=${18}
    local GIT_JMETER_BRANCH=${19}
    local DOCKER_MICROSERVICES=${20}
    local IS_ORACLE=${21}
    local ORACLE_LOCAL_PARAMETERS=$(echo ${22} | tr '*' ' ')
    local PATH_MONITORING=/home

    local TENANT1=RED
    local TENANT2=RED1


    rm -rf ${PATH_MONITORING}/dp-monitoring-init
    cd ${PATH_MONITORING}/
    git clone -b dev/6.x.x https://${GIT_USER}:${GIT_PASSWORD}@github.com/tierconnect/dp-monitoring-init.git
    cd ${PATH_MONITORING}/dp-monitoring-init

    docker build .

    mkdir $REPORT_SAVED
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    docker login -u$DOCKER_USER -p$DOCKER_PASSWORD
    echo "INFO > Cloning repository for Automation on branch : $GIT_BRANCH"
    cd $PATH_REPOSITORIES
    git clone -b $GIT_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation.git
    git clone -b $GIT_JMETER_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation-jmeter.git
    cd $AUTOMATION_PATH && git branch && git pull

    cd $VIZIX_COMPOSE

    rm Caddyfile
    sed -i "s/internaltransformer:8080/externaltransformer:8080/g" ShopCXCaddyfile
    cat ShopCXCaddyfile > Caddyfile

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES

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

    docker-compose -f vizix-tools.yml up > /tmp/popdb-platform-core-root.log
    echo "INFO > ********** Popdb popdb-platform-core-root logs **********" && cat /tmp/popdb-platform-core-root.log
    docker-compose up -d services
    sleep 30s

    echo "INFO > Configure variables for retail-core-epcis popDB for RED"
    sed -i "s/VIZIX_SYSCONFIG_OPTION: platform-core-root/VIZIX_SYSCONFIG_OPTION: retail-core-epcis/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_TENANT_CODE: root/VIZIX_SYSCONFIG_TENANT_CODE: $TENANT1/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_TENANT_NAME: root/VIZIX_SYSCONFIG_TENANT_NAME: $TENANT1/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_HIERARCHY: \">root\"/VIZIX_SYSCONFIG_HIERARCHY: \">$TENANT1\"/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_CLEAN: \"true\"/VIZIX_SYSCONFIG_CLEAN: \"false\"/g" vizix-tools.yml
    sed -i "s/VIZIX_KAFKA_DATA_RETENTION_UPDATER: \"true\"/VIZIX_KAFKA_DATA_RETENTION_UPDATER: \"false\"/g" vizix-tools.yml
    sed -i "s/VIZIX_KAFKA_CREATE_TOPICS: \"true\"/VIZIX_KAFKA_CREATE_TOPICS: \"false\"/g" vizix-tools.yml
    sleep 10s && docker-compose -f vizix-tools.yml up > /tmp/popdb-retail-core-epcis.log
    echo "INFO > ********** Popdb RED :  popdb-retail-core-epcis logs *********" && cat /tmp/popdb-retail-core-epcis.log
    sleep 1m
    docker-compose up -d flow ntpdserver ntpd logio logs proxy flow rpui rpin mongoinjector hbridge m2kbridge k2m m2kbridge transformbridge actionprocessor services mongo mysql kafka mosquitto ui
    docker-compose restart services
    sleep 1m
    docker-compose ps

    cd $AUTOMATION_PATH
    sed -i s/localhost/$PRIVATE_IP/g build.gradle
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}

    echo "INFO>Preparing Environment using Automation Test ..................."
    echo "INFO > gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=false -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=false -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    echo "INFO > gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    sleep 10s

    echo "INFO > gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    cd $VIZIX_COMPOSE

    echo "INFO > Configure variables for retail-core-epcis popDB for RED1"
    sed -i "s/VIZIX_SYSCONFIG_TENANT_CODE: $TENANT1/VIZIX_SYSCONFIG_TENANT_CODE: $TENANT2/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_TENANT_NAME: $TENANT1/VIZIX_SYSCONFIG_TENANT_NAME: $TENANT2/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_HIERARCHY: \">$TENANT1\"/VIZIX_SYSCONFIG_HIERARCHY: \">$TENANT2\"/g" vizix-tools.yml

    sleep 10s && docker-compose -f vizix-tools.yml up > /tmp/popdb-retail-core-epcis2.log
    echo "INFO > ********** Popdb RED1 :  popdb-retail-core-epcis logs *********" && cat /tmp/popdb-retail-core-epcis2.log
    sleep 1m

    sed -i "/EXTERNAL_IP/c EXTERNAL_IP=$PUBLIC_IP" .env
    sed -i "/INTERNAL_IP/c INTERNAL_IP=$PRIVATE_IP" .env
    echo "INFO > Configure shopCX environment"
    docker-compose up -d shopcx-mysql && sleep 20s

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

    echo "INFO> Configure ElasticSearch"
    sysctl -w vm.max_map_count=262144
    sysctl -w vm.max_map_count=262144 && echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
    sysctl -p

    docker-compose up -d shopcx-elasticsearch-monitoring
    docker-compose up -d influxdb
    sleep 20s
    echo "INFO > Configure influxDB"
    docker-compose exec -T influxdb influx -execute "CREATE DATABASE telegraf"
    docker-compose exec -T influxdb influx -execute "CREATE DATABASE asnauto"
    docker-compose exec -T influxdb influx -execute "CREATE USER admin WITH PASSWORD 'control123!' WITH ALL PRIVILEGES"

    echo '[rabbitmq_management,rabbitmq_shovel,rabbitmq_shovel_management].' > enabled_plugins
    docker-compose up -d shopcx-rabbitmq

    echo "INFO > Up the other components"
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

    APIKEY=$(docker-compose exec -T mysql mysql -uroot -pcontrol123! riot_main --execute "select apiKey from VIZ_APC_USER where username='root';" | grep -v -e "Using a password on the command line interface can be insecure" -e "id"  -e "apiKey")
    echo "INFO > Obtaining Api key root: $APIKEY from mysql"
    sed -i "/VIZIX_API_KEY/c VIZIX_API_KEY=$APIKEY" .env

    docker-compose restart red-amqp-servicebus && sleep 10s
    docker-compose up -d shopcx-rabbitmq && sleep 20s
    docker-compose up -d reportgenerator && sleep 20s
    docker-compose up -d externaltransformer && sleep 30s
    docker-compose up -d reverse-proxy-devices
    docker-compose up -d proxySCX

    docker-compose up -d && sleep 30s

    docker-compose restart dp-asn-auto-engine && sleep 15s

    echo "INFO > Added Definition on rabbitmq"
    echo "INFO > curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D"
    curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "************ Info Definition Created ***************" && sleep 10s
    curl -v -X GET  http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "****************************************************"

    echo "INFO > Environment is Ready"
    cd $AUTOMATION_PATH
    echo "INFO > gradle clean automationTest -POrganizationShopCX=$TENANT1 -Pcategory=@RequirementData -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false"
    gradle clean automationTest -POrganizationShopCX=$TENANT1 -Pcategory=@RequirementData -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Requirements$TENANT1$PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -POrganizationShopCX=$TENANT2 -Pcategory=@RequirementData -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false"
    gradle clean automationTest -POrganizationShopCX=$TENANT2 -Pcategory=@RequirementData -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Requirements$TENANT2$PUBLIC_IP.json

    cd $VIZIX_COMPOSE

    docker-compose up -d externaltransformer && sleep 90s
    docker-compose up -d
    docker-compose restart services && sleep 2m
    docker-compose restart externaltransformer && sleep 90s
    docker-compose restart configuration-api-languages  && sleep 15s
    docker-compose restart configuration-api-devices  && sleep 15s

    cd $AUTOMATION_PATH

    echo "INFO > gradle clean automationTest -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=${TENANT1}root1 -POrganizationShopCX=$TENANT1 -Pcategory=@ShopCXStructure -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true"
    gradle clean automationTest -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=${TENANT1}root1 -POrganizationShopCX=$TENANT1 -Pcategory=@ShopCXStructure -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Structure$TENANT1$PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=${TENANT2}root1 -POrganizationShopCX=$TENANT2 -Pcategory=@ShopCXStructure -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true "
    gradle clean automationTest -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=${TENANT2}root1 -POrganizationShopCX=$TENANT2 -Pcategory=@ShopCXStructure -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Structure$TENANT2$PUBLIC_IP.json


    echo "INFO > gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=$TENANT1  -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=$TENANT1 -PcleanAllEntities=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/RequirementsEnabledRule$PUBLIC_IP$TENANT1.json

    echo "INFO > gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=$TENANT2  -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=$TENANT2 -PcleanAllEntities=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/RequirementsEnabledRule$PUBLIC_IP$TENANT2.json

    cd $VIZIX_COMPOSE
    echo "INFO> *************** Containers Information ***************"
    sudo docker ps > /tmp/docker.log
    sudo docker images > /tmp/dockerimages.log
    cat /tmp/dockerimages.log /tmp/docker.log
    checkErrorOnContainerLogs

    echo "INFO > getting log for setup environment :  gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False"
    cp /tmp/setuplog.log /tmp/setuplog2.log && sleep 5

    cd $AUTOMATION_PATH
    gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False
    sleep 5s && cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/5GetLog$PUBLIC_IP.json && sleep 5s

    echo "---------------------------- Complete Setup Environment - Multitenancy ShopCX ---------------------"
}

# This method is to setup environment type kafka and ShopCX Eclipse with multitenancy configuration
# $1 DOCKER_USER
# $2 DOCKER_PASSWORD
# $3 PATH_REPOSITORIES
# $4 GIT_USER
# $5 GIT_PASSWORD
# $6 AUTOMATION_PATH
# $7 GIT_BRANCH
# $8 VIZIX_COMPOSE
# $9 DOCKER_BRANCH_UI
# ${10} DOCKER_BRANCH_BRIDGES
# ${11} DOCKER_BRANCH_SERVICES
# ${12} PUBLIC_IP
# ${13} PRIVATE_IP
# ${14} NUMBER_THREADS_CB
# ${15} REPORT_SAVED
# ${16} POPDB_NAME
# ${17} PATH_UTILS
# ${18} DOCKER_BRANCH_TOOLS
# ${19} GIT_JMETER_BRANCH
# ${20} DOCKER_MICROSERVICES
# ${21} IS_ORACLE
# ${22} ORACLE_LOCAL_PARAMETERS
setupEnvironmentEclipseEclipse(){

    PATH_UTILS=${17}
    source $PATH_UTILS
    echo "********************************************************************************************************"
    echo "*                       SETUP ENVIRONMENT  MULTITENANCY ECLIPSE / ECLIPSE                              *"
    echo "********************************************************************************************************"
    #vars
    #######################
    local DOCKER_USER=$1
    local DOCKER_PASSWORD=$2
    local PATH_REPOSITORIES=$3
    local GIT_USER=$4
    local GIT_PASSWORD=$5
    local AUTOMATION_PATH=$6
    local GIT_BRANCH=$7
    local VIZIX_COMPOSE=$8
    local DOCKER_BRANCH_UI=$9
    local DOCKER_BRANCH_BRIDGES=${10}
    local DOCKER_BRANCH_SERVICES=${11}
    local PUBLIC_IP=${12}
    local PRIVATE_IP=${13}
    local NUMBER_THREADS_CB=${14}
    local REPORT_SAVED=${15}
    local POPDB_NAME=${16}
    local DOCKER_BRANCH_TOOLS=${18}
    local GIT_JMETER_BRANCH=${19}
    local DOCKER_MICROSERVICES=${20}
    local IS_ORACLE=${21}
    local ORACLE_LOCAL_PARAMETERS=$(echo ${22} | tr '*' ' ')

    local TENANT1=ECLIPSE
    local TENANT2=ECLIPSE1

    local SHOPCX_USER=mojixpull
    local SHOPCX_PASS=YWaQPtC9DDnfHN2Q

    cd $VIZIX_COMPOSE
    docker login docker-pull.factory.shopcx.io -u${SHOPCX_USER} -p${SHOPCX_PASS}
    docker-compose pull tag-auth

    mkdir $REPORT_SAVED
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
    docker login -u$DOCKER_USER -p$DOCKER_PASSWORD
    echo "INFO > Cloning repository for Automation on branch : $GIT_BRANCH"
    cd $PATH_REPOSITORIES
    git clone -b $GIT_BRANCH https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation.git
    cd $AUTOMATION_PATH && git branch && git pull

    cd $VIZIX_COMPOSE

    rm Caddyfile
    sed -i "s/internaltransformer:8080/externaltransformer:8080/g" ShopCXCaddyfile
    cat ShopCXCaddyfile > Caddyfile

    updateEnvFile $VIZIX_COMPOSE $DOCKER_BRANCH_UI $DOCKER_BRANCH_BRIDGES $DOCKER_BRANCH_SERVICES $PUBLIC_IP $PRIVATE_IP $DOCKER_BRANCH_TOOLS $DOCKER_MICROSERVICES

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

    docker-compose -f vizix-tools.yml up > /tmp/popdb-platform-core-root.log
    echo "INFO > ********** Popdb popdb-platform-core-root logs **********" && cat /tmp/popdb-platform-core-root.log
    docker-compose up -d services
    sleep 30s

    echo "INFO > Configure variables for retail-core-epcis popDB for ECLIPSE Multitenant"
    sed -i "s/VIZIX_SYSCONFIG_OPTION: platform-core-root/VIZIX_SYSCONFIG_OPTION: retail-core-epcis/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_TENANT_CODE: root/VIZIX_SYSCONFIG_TENANT_CODE: $TENANT1/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_TENANT_NAME: root/VIZIX_SYSCONFIG_TENANT_NAME: $TENANT1/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_HIERARCHY: \">root\"/VIZIX_SYSCONFIG_HIERARCHY: \">$TENANT1\"/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_CLEAN: \"true\"/VIZIX_SYSCONFIG_CLEAN: \"false\"/g" vizix-tools.yml
    sed -i "s/VIZIX_KAFKA_DATA_RETENTION_UPDATER: \"true\"/VIZIX_KAFKA_DATA_RETENTION_UPDATER: \"false\"/g" vizix-tools.yml
    sed -i "s/VIZIX_KAFKA_CREATE_TOPICS: \"true\"/VIZIX_KAFKA_CREATE_TOPICS: \"false\"/g" vizix-tools.yml
    sleep 10s && docker-compose -f vizix-tools.yml up > /tmp/popdb-retail-core-epcis.log
    echo "INFO > ********** Popdb ECLIPSE :  popdb-retail-core-epcis logs *********" && cat /tmp/popdb-retail-core-epcis.log
    sleep 1m
    docker-compose up -d flow ntpdserver ntpd logio logs proxy flow rpui rpin mongoinjector hbridge m2kbridge k2m m2kbridge transformbridge actionprocessor services mongo mysql kafka mosquitto ui
    docker-compose restart services
    sleep 1m
    docker-compose ps

    cd $AUTOMATION_PATH
    sed -i s/localhost/$PRIVATE_IP/g build.gradle
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}

    echo "INFO > Preparing Environment using Automation Test ..................."
    echo "INFO > gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=false -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=false -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    echo "INFO > gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    sleep 10s

    echo "INFO > gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false"
    gradle automationTest -Pcategory=@retail-core-epcis -Pnocategory=~@NotImplemented -Pport=80 -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1SetupEnvUserPwdUpdated$PUBLIC_IP.json

    cd $VIZIX_COMPOSE

    echo "INFO > Configure variables for retail-core-epcis popDB for ECLIPSE1 Multitenant"
    sed -i "s/VIZIX_SYSCONFIG_TENANT_CODE: $TENANT1/VIZIX_SYSCONFIG_TENANT_CODE: $TENANT2/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_TENANT_NAME: $TENANT1/VIZIX_SYSCONFIG_TENANT_NAME: $TENANT2/g" vizix-tools.yml
    sed -i "s/VIZIX_SYSCONFIG_HIERARCHY: \">$TENANT1\"/VIZIX_SYSCONFIG_HIERARCHY: \">$TENANT2\"/g" vizix-tools.yml

    sleep 10s && docker-compose -f vizix-tools.yml up > /tmp/popdb-retail-core-epcis2.log
    echo "INFO > ********** Popdb ECLIPSE1 :  popdb-retail-core-epcis logs *********" && cat /tmp/popdb-retail-core-epcis2.log
    sleep 1m

    sed -i "/EXTERNAL_IP/c EXTERNAL_IP=$PUBLIC_IP" .env
    sed -i "/INTERNAL_IP/c INTERNAL_IP=$PRIVATE_IP" .env
    echo "INFO > Configure shopCX environment"
    docker-compose up -d shopcx-mysql && sleep 20s

    echo "INFO > Create mysql databases"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database information_schema CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database advancloud CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database aggregates CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database businessproducts CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database configurationdevices CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database labstore CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database mysql CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database performance_schema CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database printing CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database recommendation CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database riot_main CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database statemachine CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database supplychain CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database sys CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database tagauth CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
    docker-compose exec -T shopcx-mysql mysql -uroot -pcontrol123! --execute "create database tagmanagement CHARACTER SET utf8 COLLATE utf8_unicode_ci;"

    echo "INFO> Configure ElasticSearch"
    sysctl -w vm.max_map_count=262144 && echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
    sysctl -p

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
    docker-compose up -d reverse-proxy-devices
    docker-compose up -d proxySCX

    docker-compose up -d && sleep 30s

    echo "INFO > Added Definition on rabbitmq"
    echo "INFO > curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D"
    curl -v -F file=@rabbit_shopcx-rabbitmq.json http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "************ Info Definition Created ***************" && sleep 10s
    curl -v -X GET  http://$PRIVATE_IP:15672/api/definitions?auth=YWRtaW46Y29udHJvbDEyMyE%3D
    echo "****************************************************"

    echo "INFO > Environment is Ready"
    cd $AUTOMATION_PATH
    echo "INFO > gradle clean automationTest -POrganizationShopCX=$TENANT1 -Pcategory=@RequirementDataEclipse -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false"
    gradle clean automationTest -POrganizationShopCX=$TENANT1 -Pcategory=@RequirementDataEclipse -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Requirements$TENANT1$PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -POrganizationShopCX=$TENANT2 -Pcategory=@RequirementDataEclipse -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false"
    gradle clean automationTest -POrganizationShopCX=$TENANT2 -Pcategory=@RequirementDataEclipse -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Requirements$TENANT2$PUBLIC_IP.json

    cd $VIZIX_COMPOSE

    docker-compose up -d externaltransformer && sleep 90s
    docker-compose up -d
    docker-compose restart services && sleep 2m
    docker-compose restart externaltransformer && sleep 90s
    docker-compose restart configuration-api-devices  && sleep 15s

    cd $AUTOMATION_PATH

    echo "INFO > gradle clean automationTest -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=${TENANT1}root1 -POrganizationShopCX=$TENANT1 -Pcategory=@ShopCXStructure -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true"
    gradle clean automationTest -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=${TENANT1}root1 -POrganizationShopCX=$TENANT1 -Pcategory=@ShopCXStructure -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Structure$TENANT1$PUBLIC_IP.json

    echo "INFO > gradle clean automationTest -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=${TENANT2}root1 -POrganizationShopCX=$TENANT2 -Pcategory=@ShopCXStructure -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true "
    gradle clean automationTest -PisBasicAuthForShopCX=true -PisUsingAutomationPopDb=false -Puser=${TENANT2}root1 -POrganizationShopCX=$TENANT2 -Pcategory=@ShopCXStructure -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/Structure$TENANT2$PUBLIC_IP.json


    echo "INFO > gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=$TENANT1  -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=$TENANT1 -PcleanAllEntities=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/RequirementsEnabledRule$PUBLIC_IP$TENANT1.json

    echo "INFO > gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=$TENANT2  -PcleanAllEntities=false"
    gradle clean automationTest -Pcategory=@EnableTransformRule -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast -PisUsingtoken=true -PisUsingAutomationPopDb=false -POrganizationShopCX=$TENANT2 -PcleanAllEntities=false
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/RequirementsEnabledRule$PUBLIC_IP$TENANT2.json

    cd $VIZIX_COMPOSE
    echo "INFO> *************** Containers Information ***************"
    sudo docker ps > /tmp/docker.log
    sudo docker images > /tmp/dockerimages.log
    cat /tmp/dockerimages.log /tmp/docker.log
    checkErrorOnContainerLogs

    echo "INFO > getting log for setup environment :  gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False"
    cp /tmp/setuplog.log /tmp/setuplog2.log && sleep 5

    cd $AUTOMATION_PATH
    gradle clean automationTest -Pcategory=@getSetupLog -Pnocategory=~@NotImplemented -PisUsingtoken=False
    sleep 5s && cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/5GetLog$PUBLIC_IP.json && sleep 5s

    echo "---------------------------- Complete Setup Environment - Multitenancy ShopCX Eclipse ---------------------"
}

#
# This method is to found ERROR word in a file
# $1 FILE
checkErrorOnFile(){
 FILE=$1
 TOTAL_ERROR=$(cat ${FILE} | grep --count ERROR)
 if [ $TOTAL_ERROR -gt 0 ]; then
   echo "*****************************************************************"
   echo "*                      ERROR $FILE                              *"
   echo "*****************************************************************"
   cat $FILE | grep -A 2 ERROR
   echo "*****************************************************************"
 fi
}

#
# This method is to found ERROR words in container logs from all containers
#
checkErrorOnContainerLogs(){

    local tmpFileName=/tmp/nameContainers.txt
    docker ps --format "{{.Names}}" > $tmpFileName
    echo "INFO > Containers :" && echo " " && cat $tmpFileName

    while read -r line; do
        CONTAINER_NAME="$line"
        CONTAINERID=$(docker inspect --format="{{.Id}}" $CONTAINER_NAME)
        if [ "$(grep -c 'ERROR\|SEVERE\|FATAL' /var/lib/docker/containers/$CONTAINERID/$CONTAINERID*.log )" -gt 0 ] ;
          then
          echo "********************LIST ERROR $CONTAINER_NAME ******************"
          grep 'ERROR\|SEVERE' /var/lib/docker/containers/$CONTAINERID/$CONTAINERID*.log > /tmp/Error$CONTAINER_NAME.log
          cat /tmp/Error$CONTAINER_NAME.log
          echo "*****************************************************************"
        fi
    done < "$tmpFileName"
}


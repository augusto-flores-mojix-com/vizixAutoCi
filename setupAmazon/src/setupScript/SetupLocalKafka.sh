#!/bin/bash
#
# @Created By Eynar
# 
# This script is to setup local environment  - Draft
# @requirement
# clone automation repository
# clone automation-ci repository
# configure the variables
#======================================================================
MAIN=/home/eynar/Desktop/vizix_repositories
VIZIX_COMPOSE=/home/ubuntu/vizix-compose
AUTOMATION_REPOSITORY=$MAIN/vizix-qa-automation
COMPOSE_BUILDER=$MAIN/vizix-qa-automation-ci/setupAmazon/src/composeBuilder
PUBLIC_IP=10.100.1.199
CATEGORY_TO_EXECUTE=CBblink
KAFKA_ADDRESS=10.100.1.199
CLIENT=automation-core

# $1 DOCKER_BRANCH_UI
# $2 DOCKER_BRANCH_SERVICES
# $3 DOCKER_BRANCH_BRIDGES
# $4 DOCKER_BRANCH_TOOLS
# $5 DOCKER_BRANCH_VERSIONING

if [ -z $1 ]; then
    DOCKER_BRANCH_UI=v6.51.0
else
    DOCKER_BRANCH_UI=$1
fi
if [ -z $2 ]; then
    DOCKER_BRANCH_SERVICES=v6.51.0
else
    DOCKER_BRANCH_SERVICES=$2
fi
if [ -z $3 ]; then
    DOCKER_BRANCH_BRIDGES=v6.51.0
else
    DOCKER_BRANCH_BRIDGES=$3
fi
if [ -z $4 ]; then
    DOCKER_BRANCH_TOOLS=v6.51.0
else
    DOCKER_BRANCH_TOOLS=$4
fi
if [ -z $5 ]; then
    DOCKER_BRANCH_VERSIONING=v6.51.0
else
    DOCKER_BRANCH_VERSIONING=$5
fi
if [ -z $6 ]; then
    REPORTS=v6.52.0
else
    REPORTS=$6
fi

#======================================================================
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi $(docker images)
echo $(gradle --version)
rm -rf $VIZIX_COMPOSE
mkdir $VIZIX_COMPOSE
############################################# CONFIGURING DOCKER COMPOSE #################################################
echo "INFO>sudo cat $COMPOSE_BUILDER/templates/basic-compose-kafka.yml $COMPOSE_BUILDER/templates/services_kafka $COMPOSE_BUILDER/templates/mysql > $VIZIX_COMPOSE/docker-compose.yml"
sudo cat $COMPOSE_BUILDER/templates/basic-compose-kafka.yml $COMPOSE_BUILDER/templates/services_kafka $COMPOSE_BUILDER/templates/mysql  $COMPOSE_BUILDER/templates/ftpbridge $COMPOSE_BUILDER/templates/versioning> $VIZIX_COMPOSE/docker-compose.yml
echo "INFO>sudo cp -a $COMPOSE_BUILDER/configurationKafka/* $VIZIX_COMPOSE/"
sudo cp -a $COMPOSE_BUILDER/configurationKafka/* $VIZIX_COMPOSE/
echo "INFO>sudo cp $COMPOSE_BUILDER/configurationKafka/.env $VIZIX_COMPOSE/"
sudo cp $COMPOSE_BUILDER/configurationKafka/.env $VIZIX_COMPOSE/

cd $AUTOMATION_REPOSITORY
git pull

cd $VIZIX_COMPOSE
docker-compose stop
rm -rf mysql && rm -rf mongo && rm -rf actionprocessor-data && rm -rf attachments && rm -rf flows && rm -rf httpbridge-data && rm -rf k2m-data && rm -rf kafka-data
rm -rf m2k-data && rm -rf mongoinjector-data && rm -rf rulesprocessor-data && rm -rf transformbridge-data && rm -rf zookeeper-data

sed -i "/riot-core-ui:/c UI=mojix/riot-core-ui:$DOCKER_BRANCH_UI" .env
sed -i "/riot-core-bridges:/c BRIDGES=mojix/riot-core-bridges:$DOCKER_BRANCH_BRIDGES" .env
sed -i "/riot-core-services:/c SERVICES=mojix/riot-core-services:$DOCKER_BRANCH_SERVICES" .env
sed -i "/vizix-tools:/c VIZIXTOOLS=mojix/vizix-tools:$DOCKER_BRANCH_TOOLS" .env
sed -i "/vizix-tenant-versioning:/c VERSIONING=mojix/vizix-tenant-versioning:$DOCKER_BRANCH_VERSIONING" .env
sed -i "/riot-core-reports:/c REPORTS=mojix/riot-core-reports:$REPORTS" .env
sed -i "/UI_URL=/c UI_URL=$PUBLIC_IP" .env
sed -i "/SERVICES_URL=/c SERVICES_URL=$PUBLIC_IP:80" .env
sed -i s/localhost/$PUBLIC_IP/g .env
sed -i "/VIZIX_DATA_PATH/c VIZIX_DATA_PATH=$VIZIX_COMPOSE" .env
sed -i "s/VIZIX_POPDB_OPTION: POPDB_NAME/VIZIX_POPDB_OPTION: $CLIENT/g" vizix-tools.yml
sleep 5

########################################## CONFIGURING ENVIRONMENT ##############################################################
docker-compose pull

sleep 10
echo "INFO>added admin user to mongo"
docker-compose up -d mongo
sleep 20s
docker-compose exec -T mongo mongo admin --eval "db.createUser({user:'admin', pwd:'control123!',roles:['userAdminAnyDatabase']});"
docker-compose exec -T mongo mongo admin -u admin -p control123! --authenticationDatabase admin --eval "db.createRole({role:'executeFunctions',privileges:[{resource:{anyResource:true},actions:['anyAction']}],roles:[]});db.grantRolesToUser('admin',[{ role: 'executeFunctions', db: 'admin' },{ role : 'readWrite', db : 'viz_root' }]);"

docker-compose up -d mysql mosquitto kafka
sed -i "s/VIZIX_POPDB_OPTION: POPDB_NAME/VIZIX_POPDB_OPTION: $CLIENT/g" vizix-tools.yml
cat vizix-tools.yml && sleep 60s
docker-compose -f vizix-tools.yml up
sleep 30
docker-compose up -d
docker-compose restart services
sleep 60
####################################### CONFIGURING VIZIX ##########################################################################
cd $AUTOMATION_REPOSITORY

#ip instead of localhost
sed -i s/localhost/$PUBLIC_IP/g build.gradle
#setup license and connections
export GRADLE_HOME=/usr/local/gradle
export PATH=${GRADLE_HOME}/bin:${PATH}
echo "INFO>Preparing Environment using Automation Test ..................."
gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=False -Pport=80
gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Pport=80
sleep 20
gradle automationTest -Pcategory=@SetupEnvironmentConnectionKafka -Pnocategory=~@NotImplemented -Pport=80
gradle automationTest -Pcategory=@RunAleBridgeKafka -Pnocategory=~@NotImplemented -Pport=80

cd $VIZIX_COMPOSE

docker-compose up -d services rpin rpui mongoinjector m2kbridge transformbridge actionprocessor hbridge && sleep 60
docker-compose up -d k2m && sleep 15
docker-compose up -d
echo "INFO>running all"
cd $AUTOMATION_REPOSITORY
sleep 60
echo "INFO>Environment Ready"
echo "INFO>Execute Automation Test ...................."
gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotKafka -PisUsingMosquitto=true -PkafkaHost=$PUBLIC_IP:9092 -PrefreshCoreBridge=20 -PservicesProcessingTime=20 -PmongoProcessingTime=20 -Puser=root -Ppwd=Control123! -Pport=80 -PaleDataPort=9091
sleep 15

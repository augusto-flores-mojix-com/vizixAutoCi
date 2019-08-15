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

COMPOSE_BUILDER=$MAIN/vizix-qa-automation-ci/setupAmazon/src/composeBuilder
AUTOMATION_PATH=$MAIN/vizix-qa-automation

DOCKER_BRANCH=dev_5.x.x
PUBLIC_IP=10.100.1.199
NUMBER_THREADS_CB=1
CATEGORY_TO_EXECUTE=CBblink
CLIENT=Automation

################################## CLEANING IMAGES AND CONTAINERS ###################################
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
docker rmi $(docker images)


################################## BUILDING DOCKER COMPOSE #########################################
echo "INFO> sudo cat $COMPOSE_BUILDER/templates/basic-compose-cbmt.yml > $VIZIX_COMPOSE/docker-compose.yml"
sudo cat $COMPOSE_BUILDER/templates/basic-compose-cbmt.yml $COMPOSE_BUILDER/templates/services_cbmt $COMPOSE_BUILDER/templates/mysql $COMPOSE_BUILDER/templates/ftpbridge $COMPOSE_BUILDER/templates/mqtt_ssl_auth > $VIZIX_COMPOSE/docker-compose.yml
echo "INFO> sudo cp -a $COMPOSE_BUILDER/configurationCbMt/* $VIZIX_COMPOSE/"
sudo cp -a $COMPOSE_BUILDER/configurationCbMt/* $VIZIX_COMPOSE/
echo "INFO> sudo cp $COMPOSE_BUILDER/configurationCbMt/.env $VIZIX_COMPOSE/"
sudo cp $COMPOSE_BUILDER/configurationCbMt/.env $VIZIX_COMPOSE/

#################################### CONFIGURING  ENVIRONMENT ######################################
echo "INFO> Setup local environment"
cd $VIZIX_COMPOSE

sed -i "/riot-core-ui:/c UI=mojix/riot-core-ui:$DOCKER_BRANCH" .env
sed -i "/riot-core-bridges:/c BRIDGES=mojix/riot-core-bridges:$DOCKER_BRANCH" .env
sed -i "/riot-core-services:/c SERVICES=mojix/riot-core-services:$DOCKER_BRANCH" .env
sed -i "/SERVICES_URL=/c SERVICES_URL=$PUBLIC_IP" .env

docker-compose pull && docker-compose stop
sleep 10s
rm -rf mongo && rm -rf mysql && rm -rf flows
docker-compose rm -f

echo "INFO> added admin user to mongo"
docker-compose up -d mongo && sleep 20s
docker-compose exec mongo mongo admin --eval "db.createUser({user:'admin', pwd:'control123!',roles:['userAdminAnyDatabase']});"
docker-compose exec -T mongo mongo admin -u admin -p control123! --authenticationDatabase admin --eval "db.createRole({role:'executeFunctions',privileges:[{resource:{anyResource:true},actions:['anyAction']}],roles:[]});db.grantRolesToUser('admin',[{ role: 'executeFunctions', db: 'admin' },{ role : 'readWrite', db : 'riot_main' }]);"

echo "INFO> start mosquitto popdb"
docker-compose up -d mosquitto mysql hazelcast && sleep 15s
echo "INFO> start popdb"
docker-compose run --rm services /run.sh install $CLIENT clean -f
sleep 15s
docker-compose up -d && sleep 60s

################################# CONFIGURING VIZIX ###################################################
cd $AUTOMATION_PATH

#ip instead of localhost
sed -i s/localhost/$PUBLIC_IP/g build.gradle
export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}
gradle clean automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=False -Pport=80 -PhazelcastAddress=hazelcast
gradle clean automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -Puser=root -Ppwd=Control123! -Pport=80 -PhazelcastAddress=hazelcast
gradle clean automationTest -Pcategory=@SetupEnvironmentConnection -Pnocategory=~@NotImplemented -PnumberCores=$NUMBER_THREADS_CB -Puser=root -Ppwd=Control123! -Pport=80 -PhazelcastAddress=hazelcast
gradle clean automationTest -Pcategory=@RunCoreBridge -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast
gradle clean automationTest -Pcategory=@RunAleBridge -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast
cd $VIZIX_COMPOSE
docker-compose stop hazelcast
docker-compose stop services
docker-compose up -d hazelcast
docker-compose up -d services && sleep 15
docker-compose restart corebridge && sleep 60
docker-compose restart alebridge && sleep 60
cd $AUTOMATION_PATH
gradle clean automationTest -Pcategory=@RunCoreBridge -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast
sleep 30
gradle clean automationTest -Pcategory=@RunAleBridge -Pnocategory=~@NotImplemented -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -Pport=80 -PhazelcastAddress=hazelcast
sleep 30
gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -Puser=root -Ppwd=Control123! -Pport=80 -PhazelcastAddress=hazelcast -PnumberCores=$NUMBER_THREADS_CB
sleep 15
echo "INFO> Completed"


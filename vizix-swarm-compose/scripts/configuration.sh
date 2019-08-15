#!/bin/bash
set -e
# ===========================
GIT_USERNAME=$1
GIT_PASSWORD=$2
PATH_KEY=$3
PREFIX_SERVER=$4
REGION=$5
DOCKER_LOGIN=$6
DOCKER_PASS=$7
CURRENT_PROJECT_LOCATION=$8
BRANCH_UI=$9
BRANCH_SERVICES=${10}
BRANCH_BRIDGES=${11}
# ===========================

get_ips() {
#    cd /home/ubuntu/vizix_repositories/vizix-swarm-compose/ansible
    echo "********************************** Get IPs ***************************"
    echo "GetPublicIpFromVirtualMachine on /tmp/ips.txt"
    aws ec2 describe-instances --query 'Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[].Association.PublicIp' --filters 'Name=tag:Name,Values='$1 --region $2|jq .[] > /tmp/ips.txt
    sed -i 's/\"//g' /tmp/ips.txt
}

get_command_join_manager() {
    echo "********************************** Get command to join the manager ***************************"
    MANAGER_IP=$(terraform output Manager_public_IP)
    ssh-keyscan -H $MANAGER_IP >> ~/.ssh/known_hosts
    scp -i $1 ubuntu@${MANAGER_IP}:/tmp/join.txt /tmp/join.txt;
    echo "file was copied from $MANAGER_IP"
    cat /tmp/join.txt
}

join_instances_to_swarm() {
    echo "********************************** Join instances to swarm ***************************"
    rm -rf /tmp/managerHostname.txt /tmp/setupjoin.log
    echo "Remove managerHostname setupjoin"
    rm -rf /tmp/*hostname*
    echo "Remove all files"

    MANAGER_IP=$(terraform output Manager_public_IP)
    echo "Get manager ip"
    while IFS='' read -r line || [[ -n "$line" ]]; do
        ssh-keyscan -H $line >> ~/.ssh/known_hosts
        echo ${line}
        if [ "$line" == "$MANAGER_IP" ]
        then
            echo "Get hostname manager"
            ssh -n -i $1 ubuntu@$line "hostname" > /tmp/managerHostname.txt
        else
            COMMAND=$(head -1 /tmp/join.txt)
            echo ${COMMAND}
            ssh -n -i $1 ubuntu@$line "$COMMAND" > /tmp/setupjoin.log
            echo "join command was executed"
            ssh -n -i $1 ubuntu@$line "hostname" > /tmp/$line-hostname.txt
        fi
    done < "/tmp/ips.txt"
}

establish_labels() {
    CURRENT_PROJECT_LOCATION=$2
    echo "********************************** Establish labels ***************************"
    MANAGER_IP=$(terraform output Manager_public_IP)
    COMMAND="sudo docker node ls"
    ssh -n -i $1 ubuntu@${MANAGER_IP} "$COMMAND"
    MANAGER_HOSTNAME=$(head -1 /tmp/managerHostname.txt)
    echo "********************************** Manager labels ***************************"
    CVSLINE=$(grep 'services' $CURRENT_PROJECT_LOCATION/scripts/configFile.csv)
    echo ${CVSLINE}
    IFS=',' read -r -a array <<< "$CVSLINE"
    for element in "${array[@]}"
    do
        echo "Label $element added to manager!"
        COMMAND="sudo docker node update --label-add com.vizixcloud.swarm.$element=true "${MANAGER_HOSTNAME}
        echo ${COMMAND}
        ssh -n -i $1 ubuntu@${MANAGER_IP} "$COMMAND"
    done

    DATABASE_IP=$(terraform output DataBase_public_IP)
    ssh -n -i $1 ubuntu@$DATABASE_IP "hostname" > /tmp/DataBase-hostname.txt
    WORKER_HOSTNAME=$(head -1 /tmp/DataBase-hostname.txt)
    echo "********************************** Database labels ***************************"
    CVSLINE=$(grep 'mongo' $CURRENT_PROJECT_LOCATION/scripts/configFile.csv)
    echo ${CVSLINE}
    IFS=',' read -r -a array <<< "$CVSLINE"
    echo "Hostname Mongo: "${WORKER_HOSTNAME}
    echo ${line} >/tmp/mongoHost.txt
    for element in "${array[@]}"
    do
        echo "Label added to manager!"
        COMMAND="sudo docker node update --label-add com.vizixcloud.swarm.$element=true "${WORKER_HOSTNAME}
        echo ${COMMAND}
        ssh -n -i $1 ubuntu@${MANAGER_IP} "$COMMAND"
    done

    KAFKA_IP=$(terraform output Kafka_public_IP)
    ssh -n -i $1 ubuntu@$KAFKA_IP "hostname" > /tmp/Kafka-hostname.txt
    WORKER_HOSTNAME=$(head -1 /tmp/Kafka-hostname.txt)
    echo "********************************** Kafka labels ***************************"
    echo "Label added to manager!"
    COMMAND="sudo docker node update --label-add com.vizixcloud.swarm.kafka=true "${WORKER_HOSTNAME}
    echo ${COMMAND}
    ssh -n -i $1 ubuntu@${MANAGER_IP} "$COMMAND"

    counter=1
    CVSLINE=$(terraform output Rulesprocessor_public_IP)
    echo "********************************** RulesProcessor labels ***************************"
    echo ${CVSLINE}
    arrIN=(${CVSLINE//,/ })
    echo "Array1: "${arrIN[@]}
    for element in "${arrIN[@]}"
    do
        echo "Element: "${element}
        RULES_IP=${element}
        ssh -n -i $1 ubuntu@${RULES_IP} "hostname" > /tmp/Rulesprocessor$counter-hostname.txt
#        cat /tmp/Rulesprocessor$counter-hostname.txt
        WORKER_HOSTNAME=$(head -1 /tmp/Rulesprocessor$counter-hostname.txt)
        echo "********************************** RulesProcessor$counter labels ***************************"
        echo "Label added to manager!"
        COMMAND="sudo docker node update --label-add com.vizixcloud.swarm.rulesprocessor$counter=true "${WORKER_HOSTNAME}
        echo ${COMMAND}
        ssh -n -i $1 ubuntu@${MANAGER_IP} "$COMMAND"
        ((counter++))
        echo ${counter}
    done

    TRANSFORM_IP=$(terraform output TransformBridge_public_IP)
    ssh -n -i $1 ubuntu@${TRANSFORM_IP} "hostname" > /tmp/Transformbridge-hostname.txt
    WORKER_HOSTNAME=$(head -1 /tmp/Transformbridge-hostname.txt)
    echo "********************************** TransformBridge labels ***************************"
    CVSLINE=$(grep 'transformbridge' $CURRENT_PROJECT_LOCATION/scripts/configFile.csv)
    echo ${CVSLINE}
    IFS=',' read -r -a array <<< "$CVSLINE"
    for element in "${array[@]}"
    do
        echo "Label added to manager!"
        COMMAND="sudo docker node update --label-add com.vizixcloud.swarm.$element=true "${WORKER_HOSTNAME}
        echo ${COMMAND}
        ssh -n -i $1 ubuntu@${MANAGER_IP} "$COMMAND"
    done

    MONGO_INJECTOR_IP=$(terraform output MongoInjector_public_IP)
    ssh -n -i $1 ubuntu@${MONGO_INJECTOR_IP} "hostname" > /tmp/MongoInjector-hostname.txt
    WORKER_HOSTNAME=$(head -1 /tmp/MongoInjector-hostname.txt)
    echo "********************************** MongoInjector labels ***************************"
    echo "Label added to manager!"
    COMMAND="sudo docker node update --label-add com.vizixcloud.swarm.mongoinjector=true "${WORKER_HOSTNAME}
    echo ${COMMAND}
    ssh -n -i $1 ubuntu@${MANAGER_IP} "$COMMAND"
}

deploy_core() {
    echo "********************************** Deploy core.yml ***************************"
    MANAGER_IP=$(terraform output Manager_public_IP)
    BRANCH_SERVICES=$4
    BRANCH_BRIDGES=$5
    BRANCH_UI=$6
    COMMAND="sudo docker login -u"$1" -p"$2
    echo $COMMAND
    ssh -n -i $3 ubuntu@$MANAGER_IP "$COMMAND"
    COMMAND="sudo sed -i \"/--storageEngine=wiredTiger/c \    command: --storageEngine=wiredTiger --journal --slowms=5000 --profile=1 --cpu --dbpath=/data/db --directoryperdb --wiredTigerDirectoryForIndexes\" /home/ubuntu/vizix_repositories/core.yml"
    echo $COMMAND
    ssh -n -i $3 ubuntu@$MANAGER_IP "$COMMAND"
    COMMAND="sudo sed -i '/\      VIZIX_API_HOST:/c \      VIZIX_API_HOST: "${MANAGER_IP}":8080' /home/ubuntu/vizix_repositories/services.yml"
    echo $COMMAND
    ssh -n -i $3 ubuntu@$MANAGER_IP "$COMMAND"
    COMMAND="sudo sed -i '/riot-core-services:/c \\    image: mojix/riot-core-services:"${BRANCH_SERVICES}"' /home/ubuntu/vizix_repositories/services.yml"
    echo $COMMAND
    ssh -n -i $3 ubuntu@$MANAGER_IP "$COMMAND"
    COMMAND="sudo sed -i '/riot-core-ui:/c \\    image: mojix/riot-core-ui:"${BRANCH_UI}"' /home/ubuntu/vizix_repositories/services.yml"
    echo $COMMAND
    ssh -n -i $3 ubuntu@$MANAGER_IP "$COMMAND"
    COMMAND="sudo sed -i '/riot-core-bridges:/c \\    image: mojix/riot-core-bridges:"${BRANCH_BRIDGES}"' /home/ubuntu/vizix_repositories/actionprocessor.yml"
    echo $COMMAND
    ssh -n -i $3 ubuntu@$MANAGER_IP "$COMMAND"
    COMMAND="sudo sed -i '/riot-core-bridges:/c \\    image: mojix/riot-core-bridges:"${BRANCH_BRIDGES}"' /home/ubuntu/vizix_repositories/rulesprocessor.yml"
    echo $COMMAND
    ssh -n -i $3 ubuntu@$MANAGER_IP "$COMMAND"
    COMMAND="sudo sed -i '/riot-core-bridges:/c \\    image: mojix/riot-core-bridges:"${BRANCH_BRIDGES}"' /home/ubuntu/vizix_repositories/stream-apps.yml"
    echo $COMMAND
    ssh -n -i $3 ubuntu@$MANAGER_IP "$COMMAND"
    COMMAND="cd /home/ubuntu/vizix_repositories && sudo docker stack deploy -c core.yml vizix --with-registry-auth"
    echo $COMMAND
    ssh -n -i $3 ubuntu@$MANAGER_IP "$COMMAND" > /tmp/deployCore.log
    sleep 20
}

set_mongo() {
    echo "********************************** Set Mongo ***************************"
    DATABASE_IP=$(terraform output DataBase_public_IP)
    sleep 20
    echo "Connecting: "${DATABASE_IP}
    COMMAND="docker ps>info.txt"
    ssh -n -i $1 ubuntu@${DATABASE_IP} "$COMMAND"
    sleep 5
    COMMAND="grep --line-buffered 'mongo' info.txt | awk '{print \$1;}' > mongoid.txt"
    ssh -n -i $1 ubuntu@${DATABASE_IP} "$COMMAND"
    sleep 5
    COMMAND="MONGOID=\$(grep --line-buffered 'mongo' info.txt | awk '{print \$1;}') && echo \$MONGOID && docker exec -i \$MONGOID script -qc 'mongo admin --eval \"db.system.users.remove({});db.system.version.remove({});db.dropUser(\\\"admin\\\");db.createRole({role:\\\"executeFunctions\\\",privileges:[{resource:{anyResource:true},actions:[\\\"anyAction\\\"]}],roles:[]});db.createUser({user:\\\"admin\\\", pwd:\\\"control123!\\\",roles:[\\\"userAdminAnyDatabase\\\",\\\"executeFunctions\\\"]});\"'"
    ssh -n -i $1 ubuntu@${DATABASE_IP} "$COMMAND"
}

re_deploy_core() {
    echo "********************************** Re-Deploy core.yml ***************************"
    MANAGER_IP=$(terraform output Manager_public_IP)
    COMMAND="sudo sed -i \"/--storageEngine=wiredTiger/c \    command: --storageEngine=wiredTiger --journal --slowms=5000 --profile=1 --cpu --dbpath=/data/db --directoryperdb --wiredTigerDirectoryForIndexes --auth\" /home/ubuntu/vizix_repositories/core.yml"
    ssh -n -i $1 ubuntu@$MANAGER_IP "$COMMAND"
    COMMAND="cd /home/ubuntu/vizix_repositories && sudo docker stack deploy -c core.yml vizix --with-registry-auth"
    ssh -n -i $1 ubuntu@$MANAGER_IP "$COMMAND" > /tmp/deployCore.log
}

up_vizix_tools() {
    echo "********************************** Up vizix_tools.yml ***************************"
    MANAGER_IP=$(terraform output Manager_public_IP)
    COMMAND="sudo sed -i \"/platform-demo-mojix/c \      VIZIX_POPDB_OPTION: AutomationKafka\" /home/ubuntu/vizix_repositories/vizix-tools.yml"
    ssh -n -i $1 ubuntu@$MANAGER_IP "$COMMAND"
    COMMAND="sudo cat /home/ubuntu/vizix_repositories/vizix-tools.yml"
    ssh -n -i $1 ubuntu@$MANAGER_IP "$COMMAND"
    echo "********************************** PopDB ***************************"
    COMMAND="cd /home/ubuntu/vizix_repositories && sudo docker-compose -f vizix-tools.yml up"
    ssh -n -i $1 ubuntu@$MANAGER_IP "$COMMAND"
    sleep 15
    echo "********************************** siteconfig ***************************"
    COMMAND="cd /home/ubuntu/vizix_repositories && sudo docker-compose -f vizix-tools.yml run vizix-tools siteconfig"
    ssh -n -i $1 ubuntu@$MANAGER_IP "$COMMAND"
}

final_deploy() {
    echo "********************************** Start services ***************************"
    MANAGER_IP=$(terraform output Manager_public_IP)
    COMMAND="cd /home/ubuntu/vizix_repositories && sudo docker stack deploy -c services.yml vizix --with-registry-auth"
    echo "Start services"
    ssh -n -i $1 ubuntu@$MANAGER_IP "$COMMAND"
    echo "********************************** Start stream apps ***************************"
    COMMAND="cd /home/ubuntu/vizix_repositories && sudo docker stack deploy -c stream-apps.yml vizix --with-registry-auth"
    echo "Start stream apps"
    ssh -n -i $1 ubuntu@$MANAGER_IP "$COMMAND"
    counter=1
    CVSLINE=$(terraform output Rulesprocessor_public_IP)
    arrIN=(${CVSLINE//,/ })
    for element in "${arrIN[@]}"
    do
        echo "********************************** Start RulesProcessor$counter ***************************"
        echo "Start Rulesprocessor $counter!"
        COMMAND="sudo su -c\"sed s/ITERATOR/$counter/g /home/ubuntu/vizix_repositories/rulesprocessor.yml >> /home/ubuntu/vizix_repositories/rulesprocessor$counter.yml\""
        echo ${COMMAND}
        ssh -n -i $1 ubuntu@${MANAGER_IP} "$COMMAND"
        COMMAND="cd /home/ubuntu/vizix_repositories && sudo docker stack deploy -c rulesprocessor$counter.yml vizix --with-registry-auth"
        echo ${COMMAND}
        ssh -n -i $1 ubuntu@${MANAGER_IP} "$COMMAND"
        ((counter++))
        echo ${counter}
    done
    echo "********************************** Start action processor ***************************"
    COMMAND="cd /home/ubuntu/vizix_repositories && sudo docker stack deploy -c actionprocessor.yml vizix --with-registry-auth"
    echo "Start action processor"
    ssh -n -i $1 ubuntu@$MANAGER_IP "$COMMAND"
}

start_monitoring() {
    echo "********************************** Start Monitoring ***************************"
    DATABASE_IP=$(terraform output DataBase_public_IP)
    echo "Connecting: "${DATABASE_IP}
    COMMAND="cd /home/ubuntu/vizix_repositories/monitoring && sudo docker stack deploy -c monitoring.yml monitoring --with-registry-auth"
    ssh -n -i $1 ubuntu@${DATABASE_IP} "$COMMAND"
}

set_environment() {
    echo "********************************** Set Environment - Develop ***************************"
    rm -rf /tmp/blink.log
    CURRENT_PROJECT_LOCATION=$1
    GIT_USER=$2
    GIT_PASSWORD=$3
    echo $1","$2","$3","$4
    MANAGER_PRIVATE_IP=$(terraform output Manager_private_IP)
    MANAGER_PUBLIC_IP=$(terraform output Manager_public_IP)
    DATABASE_PRIVATE_IP=$(terraform output DataBase_private_IP)
    KAFKA_PRIVATE_IP=$(terraform output Kafka_private_IP)
    echo "Connecting: "${MANAGER_PUBLIC_IP}
    ssh -n -i $4 ubuntu@${MANAGER_PUBLIC_IP} "cd /home/ubuntu/vizix_repositories/ && sudo git clone https://$GIT_USER:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation.git"
    ssh -n -i $4 ubuntu@${MANAGER_PUBLIC_IP} "cd /home/ubuntu/vizix_repositories/vizix-qa-automation && sudo sed -i s/localhost/$MANAGER_PRIVATE_IP/g build.gradle"

    COMMAND="sudo su -c \"cd /home/ubuntu/vizix_repositories/vizix-qa-automation && export GRADLE_HOME=/usr/local/gradle && echo \\\$GRADLE_HOME && export PATH=\\\$GRADLE_HOME/bin:\\\$PATH && echo \$PATH && gradle automationTest -Pcategory=@SetupEnvironmentUserPasswordUpdated -Pnocategory=~@NotImplemented -PisUsingtoken=False -Pport=8080 -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP\""
    echo $COMMAND
    ssh -n -i $4 ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"
    sleep 10
    echo "Preparing Environment using Automation Test ..................."
    COMMAND="sudo su -c \"cd /home/ubuntu/vizix_repositories/vizix-qa-automation && export GRADLE_HOME=/usr/local/gradle && echo \\\$GRADLE_HOME && export PATH=\\\$GRADLE_HOME/bin:\\\$PATH && echo \$PATH && gradle automationTest -Pcategory=@License -Pnocategory=~@NotImplemented -PisUsingtoken=False -Pport=8080 -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP\""
    echo $COMMAND
    ssh -n -i $4 ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"
    sleep 10
    COMMAND="sudo su -c \"cd /home/ubuntu/vizix_repositories/vizix-qa-automation && export GRADLE_HOME=/usr/local/gradle && echo \\\$GRADLE_HOME && export PATH=\\\$GRADLE_HOME/bin:\\\$PATH && echo \$PATH && gradle automationTest -Pcategory=@RunAleBridgeKafka -Pnocategory=~@NotImplemented -PisUsingtoken=False -Pport=8080 -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP\""
    echo $COMMAND
    ssh -n -i $4 ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"
    sleep 10
    echo "********************************** Restart services ***************************"
    echo "Connecting: "${MANAGER_PUBLIC_IP}
    COMMAND="sudo docker ps>info.txt"
    ssh -n -i $4 ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"
    COMMAND="SERVICESID=\$(grep --line-buffered 'services' info.txt | awk '{print \$1;}') && echo \$SERVICESID && sudo docker restart \$SERVICESID"
    ssh -n -i $4 ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"
    sleep 40
    echo "********************************** Test Blink ***************************"
    COMMAND="sudo su -c \"cd /home/ubuntu/vizix_repositories/vizix-qa-automation && export GRADLE_HOME=/usr/local/gradle && echo \\\$GRADLE_HOME && export PATH=\\\$GRADLE_HOME/bin:\\\$PATH && echo \$PATH && gradle automationTest -Pcategory=@CBblink -Pnocategory=~@NotKafka -PisUsingtoken=False -Pport=8080 -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PcleanThingAfteSimulator=false\""
    echo $COMMAND
    ssh -n -i $4 ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND" > /tmp/blink.log
    sleep 10

    RESULT_BLINK=$(grep 'BUILD SUCCESSFUL' /tmp/blink.log)
    echo "===================== "$RESULT_BLINK" ====================="
    terraform output

    echo "********************************** Restart services ***************************"
    echo "Connecting: "${MANAGER_PUBLIC_IP}
    COMMAND="sudo docker ps>info.txt"
    ssh -n -i $4 ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"
    COMMAND="SERVICESID=\$(grep --line-buffered 'services' info.txt | awk '{print \$1;}') && echo \$SERVICESID && sudo docker restart \$SERVICESID"
    ssh -n -i $4 ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"
    sleep 40
}

sleep 10
get_ips $PREFIX_SERVER $REGION
sleep 15
get_command_join_manager $PATH_KEY
sleep 15
join_instances_to_swarm $PATH_KEY
sleep 20
establish_labels $PATH_KEY $CURRENT_PROJECT_LOCATION
sleep 15
deploy_core $DOCKER_LOGIN $DOCKER_PASS $PATH_KEY $BRANCH_SERVICES $BRANCH_BRIDGES $BRANCH_UI
sleep 30
set_mongo $PATH_KEY
sleep 15
re_deploy_core $PATH_KEY
sleep 15
up_vizix_tools $PATH_KEY
sleep 15
final_deploy $PATH_KEY
sleep 20

##Test Pending docker should be updated
#start_monitoring $PATH_KEY

set_environment $CURRENT_PROJECT_LOCATION $GIT_USERNAME $GIT_PASSWORD $PATH_KEY

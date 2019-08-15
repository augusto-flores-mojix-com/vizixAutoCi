#!/bin/bash
set -e
# ===========================
execute_kafka() {
    echo "********************************************************************************************************"
    echo "*                             RUN PERFORMANCE TEST KAFKA                                               *"
    echo "********************************************************************************************************"
    TIME=$(date +%Y%m%d%H%M%S)
    MANAGER_PUBLIC_IP=$1
    DATABASE_PRIVATE_IP=$2
    KAFKA_PRIVATE_IP=$3
    CATEGORY=$(echo $4 | tr '*' ' ')
    NTHREAD=$5
    PATH_REPOS=$6
    REPORT_SAVED=$7/Kafka
    AUTOMATION_PATH=$PATH_REPOS/vizix-qa-automation

    cd $AUTOMATION_PATH
    export GRADLE_HOME=/usr/local/gradle
    echo $GRADLE_HOME
    export PATH=$GRADLE_HOME/bin:$PATH
    echo $PATH
    mkdir -p $REPORT_SAVED

    if [[ $CATEGORY =~ "Rate" ]];
    then
        echo "=========================== Get rate ============================="
        echo "gradle automationTest -Pcategory=@setupThingTypeGetRate -Pnocategory=~@NotKafka -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PnumberCores=$NTHREAD"
        gradle automationTest -Pcategory=@setupThingTypeGetRate -Pnocategory=~@NotKafka -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PnumberCores=$NTHREAD > /tmp/setupThingTypeGetRate.log
        cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/setupThingTypeGetRate$MANAGER_PUBLIC_IP.json
        sleep 15
        echo "gradle automationTest -Pcategory=@setupReportGetRate -Pnocategory=~@NotKafka -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PnumberCores=$NTHREAD"
        gradle automationTest -Pcategory=@setupReportGetRate -Pnocategory=~@NotKafka -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PnumberCores=$NTHREAD > /tmp/setupReportGetRate.log
        cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/setupReportGetRate$MANAGER_PUBLIC_IP.json
        sleep 15
        echo "gradle automationTest -Pcategory=@$CATEGORY -Pnocategory=~@NotKafka -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PnumberCores=$NTHREAD"
        gradle automationTest -Pcategory=@$CATEGORY -Pnocategory=~@NotKafka -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PnumberCores=$NTHREAD > /tmp/getMaxRate.log
#        echo "gradle automationTest -Pcategory=@checkFunctionalityMaxRate -Pnocategory=~@NotKafka -Pport=8080 -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PnumberCores=$NTHREAD -PrateIncreaseNumberBlinks=0 "
#        gradle automationTest -Pcategory=@checkFunctionalityMaxRate -Pnocategory=~@NotKafka -Pport=8080 -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PnumberCores=$NTHREAD -PrateIncreaseNumberBlinks=0 > /tmp/checkFunctionalityMaxRate.log
#        sleep 15
    else
        echo "gradle automationTest -Pcategory=@$CATEGORY -Pnocategory=~@NotKafka -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PnumberCores=$NTHREAD /tmp/kafka$CATEGORY$TIME.log"
        gradle automationTest -Pcategory=@$CATEGORY -Pnocategory=~@NotKafka -PhostDatabase=$DATABASE_PRIVATE_IP -PhostMongo=$DATABASE_PRIVATE_IP -PkafkaHost=$KAFKA_PRIVATE_IP -PaleDataPort=9091 -PnumberCores=$NTHREAD > /tmp/kafka$CATEGORY$TIME.log
    fi
    sleep 15
}

# =================================================================================
# $1 - String : ip to use as server for the execution (i.e: 172.31.16.200)
# $2 - String : ip to use as database server for the execution (i.e: 172.31.16.200)
# $3 - String : ip to use as kafka server for the execution (i.e: 172.31.16.200)
# $4 - String : category to execute (i.e: SmokeServices)
# $5 - String : number of threads cucumber (i.e: 1)
# $6 - String : Location where repos of automation are (i.e: /home/ubuntu/vizix-compose)
# $7 - String : Location where the results will be saved (i.e: /tmp/)
# =================================================================================
echo "INFO> execute_kafka" $1 $2 $3 $4 $5
execute_kafka $1 $2 $3 $4 $5 $6 $7

#
# @autor:Eynar Pari
# @date : 15/03/18
#

# This method is to execute migration test
# @params
# $1 String : AUTOMATION_PATH
# $2 String : MAIN_PATH
# $3 String : MIGRATION_CLIENT
# $4 String : PRIVATE_IP
# $5 String : PUBLIC_IP
# $6 String : VIZIX_KAFKA_REPOSITORY
# $7 String : CATEGORY_TO_EXECUTE
# $8 String : NUMBER_THREADS_CB
# $9 Boolean = IS_KAFKA (true or false)
runMigrationTest(){
    echo "********************************************************************************************************"
    echo "*                                   RUN  MIGRATION TEST                                                *"
    echo "********************************************************************************************************"
    #vars
    ##################
    AUTOMATION_PATH=$1
    MAIN_PATH=$2
    MIGRATION_CLIENT=$3
    PRIVATE_IP=$4
    PUBLIC_IP=$5
    VIZIX_KAFKA_REPOSITORY=$6
    CATEGORY_TO_EXECUTE=$(echo $7 | tr '*' ' ')
    VERSION=$7
    NUMBER_THREADS_CB=$8
    IS_KAFKA=$9
    ##################

    REPORT_FOLDER=reports
    REPORT_SAVED=$MAIN_PATH/$REPORT_FOLDER

    getBackupsLocally $MAIN_PATH $REPORT_SAVED $REPORT_FOLDER

    MYSQL_BACKUPS=$MAIN_PATH/backups
    MONGO_BACKUPS=$MAIN_PATH/backups

    if [ "$IS_KAFKA" == "true" ]
     then
       migrationProcessToKafka $AUTOMATION_PATH $MAIN_PATH $MIGRATION_CLIENT $PRIVATE_IP $PUBLIC_IP $VIZIX_KAFKA_REPOSITORY $VERSION $NUMBER_THREADS_CB
     else
       migrationProcessToCbMt $AUTOMATION_PATH $MAIN_PATH $MIGRATION_CLIENT $PRIVATE_IP $PUBLIC_IP $VIZIX_KAFKA_REPOSITORY $VERSION $NUMBER_THREADS_CB
    fi

    cd $REPORT_SAVED
    sleep 10s
    echo $(pwd)
    addedInformationMigrationOnReport $REPORT_SAVED $VERSION
    sleep 10s
    tar -zcvf report.tar.gz *.*
    cp report.tar.gz $AUTOMATION_PATH/build/reports/cucumber/report.tar.gz
    echo "completed" > $AUTOMATION_PATH/build/reports/cucumber/done.json
}

# $1 String : AUTOMATION_PATH
# $2 String : MAIN_PATH
# $3 String : MIGRATION_CLIENT
# $4 String : PRIVATE_IP
# $5 String : PUBLIC_IP
# $6 String : VIZIX_KAFKA_REPOSITORY
# $7 String : CATEGORY_TO_EXECUTE
# $8 String : NUMBER_THREADS_CB
migrationProcessToKafka(){
    AUTOMATION_PATH=$1
    MAIN_PATH=$2
    MIGRATION_CLIENT=$3
    PRIVATE_IP=$4
    PUBLIC_IP=$5
    VIZIX_KAFKA_REPOSITORY=$6
    CATEGORY_TO_EXECUTE=$(echo $7 | tr '*' ' ')
    NUMBER_THREADS_CB=$8
    export GRADLE_HOME=/usr/local/gradle
    export PATH=${GRADLE_HOME}/bin:${PATH}

    if [ "$MIGRATION_CLIENT" == "AutomationKafka" ]
        then
           echo "INFO > **** functional test for Backup : $MIGRATION_CLIENT"
           FILTER=~@NotKafka
           ISPOPDBUSED=true
        else
           echo "INFO > **** functional test for Client - Backup : $MIGRATION_CLIENT"
           FILTER=@$MIGRATION_CLIENT
           ISPOPDBUSED=false
           cd $AUTOMATION_PATH/src/test/java/scriptsMigration/clients
           echo $(pwd)
           echo "INFO > stating FTP server"
           echo "INFO > nohup ./startFTPServer.sh $PRIVATE_IP &"
           nohup ./startFTPServer.sh $PRIVATE_IP &
           sleep 10s
           echo "INFO > nohup python /home/ftp-server.py > /tmp/pythonFTPServer.log 2>&1 &"
           sudo nohup python /home/ftp-server.py > /tmp/pythonFTPServer.log 2>&1 &
    fi

    cd $AUTOMATION_PATH

    echo "INFO > 1) **** gradle automationTest -Pcategory=@MigrationDocker -Pnocategory=~@NotKafka -PmigrateClient=@$MIGRATION_CLIENT -PmysqlBackupPath=$MYSQL_BACKUPS -PmongoBackupPath=$MONGO_BACKUPS -PdockerPath=$VIZIX_KAFKA_REPOSITORY -PinformationDbPath=/tmp/ -PisUsingAutomationPopDb=false -PshowLogRealTime=true $CATEGORY_TO_EXECUTE"
    gradle clean automationTest -Pcategory=@MigrationDocker -Pnocategory=~@NotKafka -PmigrateClient=@$MIGRATION_CLIENT -PmysqlBackupPath=$MYSQL_BACKUPS -PmongoBackupPath=$MONGO_BACKUPS -PdockerPath=$VIZIX_KAFKA_REPOSITORY -PinformationDbPath=/tmp/ -PisUsingAutomationPopDb=false -PshowLogRealTime=true $CATEGORY_TO_EXECUTE
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1Migration$PUBLIC_IP.json
    echo "INFO > copied html report"
    cp /tmp/ReportBeforeMigration.html $REPORT_SAVED/ReportBeforeMigration$PUBLIC_IP.html
    cp /tmp/ReportAfterMigration.html $REPORT_SAVED/ReportAfterMigration$PUBLIC_IP.html

    echo "INFO > 2) **** gradle automationTest -Pcategory=@License_5_2_X -Pnocategory=~@NotKafka -PisUsingAutomationPopDb=false"
    gradle clean automationTest -Pcategory=@License_5_2_X -Pnocategory=~@NotKafka -PisUsingAutomationPopDb=false -PdockerPath=$VIZIX_KAFKA_REPOSITORY
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/2License$PUBLIC_IP.json

    echo "INFO > 3) **** gradle automationTest -Pcategory=@GetTags -Pnocategory=~@NotKafka -PisUsingAutomationPopDb=false -PshowLogRealTime=true $CATEGORY_TO_EXECUTE"
    gradle clean automationTest -Pcategory=@GetTags -Pnocategory=~@NotKafka -PisUsingAutomationPopDb=false -PshowLogRealTime=true -PdockerPath=$VIZIX_KAFKA_REPOSITORY $CATEGORY_TO_EXECUTE
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/3GetTags$PUBLIC_IP.json
    sleep 20s

    TAGS_MIGRATION=$(cat /tmp/tagAutomationMigration.txt)
    TAGS_FUNCTIONAL=$(cat /tmp/tagAutomationFunctional.txt)

    echo "INFO > Tags for Migration : "$TAGS_MIGRATION
    echo "INFO > Tags Functional Get : "$TAGS_FUNCTIONAL

    cd $AUTOMATION_PATH
    echo "INFO > 4) *** Executing CheckBridges Logs .... "

    gradle clean automationTest -Pcategory=@CheckBridges -Pnocategory=$FILTER -PdockerPath=$VIZIX_KAFKA_REPOSITORY -PisUsingAutomationPopDb=false -Pport=80 $CATEGORY_TO_EXECUTE
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/4CheckBridges$PUBLIC_IP.json

    echo "INFO > 5) *** gradle automationTest -Pcategory=@RunAleBridgeKafka -PmigrateClient=@$MIGRATION_CLIENT -Pnocategory=$FILTER -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB PisUsingAutomationPopDb=$ISPOPDBUSED -Pport=80 -PhazelcastAddress=hazelcast"
    gradle automationTest -Pcategory=@RunAleBridgeKafka -PmigrateClient=@$MIGRATION_CLIENT -Pnocategory=$FILTER -Penvironment=docker -PnumberCores=$NUMBER_THREADS_CB -PisUsingAutomationPopDb=$ISPOPDBUSED -Pport=80 -PhazelcastAddress=hazelcast
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/5RunAleBridge$PUBLIC_IP.json

    echo "INFO > Executing Tags For Migration Test (Generic).... : "$TAGS_MIGRATION
    if [ -n "$TAGS_MIGRATION" ]; then
       echo "INFO > 6) **** gradle automationTest -Pcategory=$TAGS_MIGRATION -Pnocategory=~@NotKafka -PisUsingAutomationPopDb=false"
       gradle clean automationTest -Pcategory=$TAGS_MIGRATION -Pnocategory=~@NotKafka -PisUsingAutomationPopDb=false
       cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/6MigrationTags$PUBLIC_IP.json
    fi

    echo "INFO > Executing Tags For Functional Test (Specific).... : "$TAGS_FUNCTIONAL
    if [ -n "$TAGS_FUNCTIONAL" ]; then
       echo "INFO > 7) **** functional test for Backup : $FILTER"
       gradle clean automationTest -Pcategory=$TAGS_FUNCTIONAL -PmigrateClient=@$MIGRATION_CLIENT -Pnocategory=@$FILTER -PisUsingAutomationPopDb=$ISPOPDBUSED -PisUsingMosquitto=true -PkafkaHost=$PRIVATE_IP:9092 -PrefreshCoreBridge=20 -PservicesProcessingTime=20 -PmongoProcessingTime=20 -Puser=root -Ppwd=Control123! -Pport=80 -PaleDataPort=9091
       cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/7RunFunctional$PUBLIC_IP.json
    fi
}


# $1 String : AUTOMATION_PATH
# $2 String : MAIN_PATH
# $3 String : MIGRATION_CLIENT
# $4 String : PRIVATE_IP
# $5 String : PUBLIC_IP
# $6 String : VIZIX_KAFKA_REPOSITORY
# $7 String : CATEGORY_TO_EXECUTE
# $8 String : NUMBER_THREADS_CB
migrationProcessToCbMt(){
    AUTOMATION_PATH=$1
    MAIN_PATH=$2
    MIGRATION_CLIENT=$3
    PRIVATE_IP=$4
    PUBLIC_IP=$5
    VIZIX_CBMT_REPOSITORY=$6
    CATEGORY_TO_EXECUTE=$(echo $7 | tr '*' ' ')
    NUMBER_THREADS_CB=$8

    export GRADLE_HOME=/usr/local/gradle
    export PATH=${GRADLE_HOME}/bin:${PATH}
    cd $AUTOMATION_PATH
    echo "INFO>1) **** gradle automationTest -Pcategory=@MigrationDocker -Pnocategory=~@NotImplemented -PmysqlBackupPath=$MYSQL_BACKUPS -PmongoBackupPath=$MONGO_BACKUPS -PdockerPath=$VIZIX_CBMT_REPOSITORY -PinformationDbPath=/tmp/ -PisUsingAutomationPopDb=false -PshowLogRealTime=true $CATEGORY_TO_EXECUTE"
    gradle clean automationTest -Pcategory=@MigrationDocker -Pnocategory=~@NotImplemented -PmysqlBackupPath=$MYSQL_BACKUPS -PmongoBackupPath=$MONGO_BACKUPS -PdockerPath=$VIZIX_CBMT_REPOSITORY -PinformationDbPath=/tmp/ -PisUsingAutomationPopDb=false -PshowLogRealTime=true $CATEGORY_TO_EXECUTE
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/1Migration$PUBLIC_IP.json
    cp /tmp/ReportBeforeMigration.html $REPORT_SAVED/ReportBeforeMigration$PUBLIC_IP.html
    cp /tmp/ReportAfterMigration.html $REPORT_SAVED/ReportAfterMigration$PUBLIC_IP.html
    echo "INFO>2) **** gradle automationTest -Pcategory=@License_5_1_X -Pnocategory=~@NotImplemented -PisUsingAutomationPopDb=false"
    gradle clean automationTest -Pcategory=@License_5_1_X -Pnocategory=~@NotImplemented -PisUsingAutomationPopDb=false -PdockerPath=$VIZIX_CBMT_REPOSITORY
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/2License$PUBLIC_IP.json
    echo "INFO>3) **** gradle automationTest -Pcategory=@GetTags -Pnocategory=~@NotImplemented -PisUsingAutomationPopDb=false -PshowLogRealTime=true $CATEGORY_TO_EXECUTE"
    gradle clean automationTest -Pcategory=@GetTags -Pnocategory=~@NotImplemented -PisUsingAutomationPopDb=false -PshowLogRealTime=true -PdockerPath=$VIZIX_CBMT_REPOSITORY $CATEGORY_TO_EXECUTE
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/3GetTags$PUBLIC_IP.json
    sleep 20s

    TAGS_MIGRATION=$(cat /tmp/tagAutomationMigration.txt)
    TAGS_FUNCTIONAL=$(cat /tmp/tagAutomationFunctional.txt)

    echo "INFO> Tags for Migration : "$TAGS_MIGRATION
    echo "INFO> Tags Functional Get : "$TAGS_FUNCTIONAL
    echo "INFO> Executing Tags For Migration Test (Generic).... :"$TAGS_MIGRATION

    if [ -n "$TAGS_MIGRATION" ]; then
       echo "INFO> 4) **** gradle automationTest -Pcategory=$TAGS_MIGRATION -Pnocategory=~@NotImplemented -PisUsingAutomationPopDb=false"
       gradle clean automationTest -Pcategory=$TAGS_MIGRATION -Pnocategory=~@NotImplemented -PisUsingAutomationPopDb=false
       cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/4MigrationTags$PUBLIC_IP.json
    fi

    echo "INFO>Configuring Core And Ale Bridge .... "
    gradle clean automationTest -Pcategory=@RunCoreBridge -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/5RunCore$PUBLIC_IP.json
    sleep 60
    gradle clean automationTest -Pcategory=@RunAleBridge -Pnocategory=~@NotImplemented -Penvironment=docker -Pport=80 -PhazelcastAddress=hazelcast
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/6RunAle$PUBLIC_IP.json
    echo "INFO>Executing CheckBridges Logs .... "
    gradle clean automationTest -Pcategory=@CheckBridges -Pnocategory=~@NotImplemented -PdockerPath=$VIZIX_CBMT_REPOSITORY -PisUsingAutomationPopDb=false -Pport=80 $CATEGORY_TO_EXECUTE
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/7CheckBridges$PUBLIC_IP.json

    echo "INFO>Executing Tags For Functional Test (Specific).... :"$TAGS_FUNCTIONAL
    if [ -n "$TAGS_FUNCTIONAL" ]; then
        if [ "$MIGRATION_CLIENT" == "Automation" ]
        then
           echo "INFO>5) **** functional test for Backup : $MIGRATION_CLIENT"
           gradle clean automationTest -Pcategory=$TAGS_FUNCTIONAL -Pnocategory=~@NotImplemented -PisUsingAutomationPopDb=true
        else
           echo "INFO>5) **** functional test for Client - Backup : $MIGRATION_CLIENT"
           gradle automationTest -Pcategory=$TAGS_FUNCTIONAL -Pnocategory=$MIGRATION_CLIENT -PisUsingAutomationPopDb=false
        fi
        cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/8RunFunctional$PUBLIC_IP.json
    fi
}


# $1 MAIN_PATH
# $2 REPORT_SAVED
# $3 REPORT_FOLDER
getBackupsLocally(){
    MAIN_PATH=$1
    REPORT_SAVED=$2
    REPORT_FOLDER=$3
    echo "INFO > download backups"
    cd $MAIN_PATH
    mkdir backups
    rm -rf $REPORT_SAVED
    mkdir $REPORT_FOLDER
    cd backups
    wget https://www.dropbox.com/s/3dw691quab130md/5.2.0_RC04.tar.gz
    wget https://www.dropbox.com/s/kxincit3eeqw18p/KOHLS_5.1.7.tar.gz
    wget https://www.dropbox.com/s/co7ncu2gopqjfkr/5.1.3.tar.gz
    wget https://www.dropbox.com/s/f9idjduyazsluwi/5.1.4.tar.gz
    wget https://www.dropbox.com/s/8e4nhiniaucad3r/5.1.6.tar.gz
    wget https://www.dropbox.com/s/tjaqzw8gxksfg6b/5.1.7.tar.gz
    echo "INFO > uncompress backups "
    for fileBackup in $(ls -1 *.tar.gz); do tar -zxvf $fileBackup; done
}
#added key word in the result
# @params
#$1 path files jsons
#$2 category to get the versions
addedInformationMigrationOnReport(){
    echo "INFO > -------------- Added Information Migration On Reports -------------------"
    echo "INFO > params: PATH_JSON : $1  , VERSION : $2"
    echo "INFO > Added special version tag in to the reports"

    #vars
    ##################
    PATH_JSON=$1
    VERSION=$(echo $2 | tr '*' ' ')

    TAG_TO=""
    TAG_FROM=""
    ##################

    echo "INFO > Parameters to parse : "$VERSION
    parameters=$(echo $VERSION | tr " " "\n")

    for value in $parameters
    do
       echo "INFO > values : "$value
       if [[ "$value" == *"migrateToVersion"* ]]
       then
         TAG_TO=$(echo $value | sed -e "s/-PmigrateToVersion=//")
       fi

       if [[ "$value" == *"migrateFromVersion"* ]]
       then
         TAG_FROM=$(echo $value | sed -e "s/-PmigrateFromVersion=//")
       fi
    done

    ADDED=$(echo $TAG_FROM"_To_"$TAG_TO)
    echo "INFO > tag to add : "$ADDED
    cd $PATH_JSON
    for file in *.json
    do
      echo "INFO > updating json with the version : " $file
      cat $file | jq ".[].name = \"$ADDED : \"+(.[].name)" > $file.txt
    done
    echo "INFO > removing old json files"
    rm -rf *.json

    for file in *.txt
    do
      NAME=${file//.txt/ }
      echo "INFO > creating new json files .."
      cat $file > $NAME
    done

    echo "INFO > removing temporal files txt ..."
    rm -rf *.txt
    echo "INFO > -------------- json Reports Were Updated :$ADDED -------------------"
}

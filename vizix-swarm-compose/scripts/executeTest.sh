#!/bin/bash

execute_test() {
    echo "********************************** DOWNLOAD AUTOMATION & EXECUTE TESTS ***************************"
    # ===========================
    GIT_USERNAME=$1
    GIT_PASSWORD=$2
    PATH_KEY=$3
    BRANCH_AUTOMATION=$4
    TEST_CATEGORY=$5
    N_THREAD=$6
    PARAMETERS_JMETER=$7
    JMETER_TOOL_PATH=$8
    TEST_UI_CATEGORY=$9
    OPTION=${10}
    PATH_REPOS=${11}
    PATH_COMPOSE=${12}
    # ===========================
    echo "****************** PARAMETERS **********************"
    echo "PATH_KEY: "$PATH_KEY
    echo "BRANCH_AUTOMATION: "$BRANCH_AUTOMATION
    echo "TEST_CATEGORY: "$TEST_CATEGORY
    echo "N_THREAD: "$N_THREAD
    echo "PARAMETERS_JMETER: "$PARAMETERS_JMETER
    echo "JMETER_TOOL_PATH: "$JMETER_TOOL_PATH
    echo "TEST_UI_CATEGORY: "$TEST_UI_CATEGORY
    echo "OPTION: "$OPTION
    echo "PATH_REPOS: "$PATH_REPOS
    echo "PATH_COMPOSE: "$PATH_COMPOSE
    echo "****************** ********** **********************"
    CLIENT_PUBLIC_IP=$(terraform output Client_public_IP)
    ssh-keyscan -H $CLIENT_PUBLIC_IP >> ~/.ssh/known_hosts
    MANAGER_PRIVATE_IP=$(terraform output Manager_private_IP)
    MANAGER_PUBLIC_IP=$(terraform output Manager_public_IP)
    ssh-keyscan -H $MANAGER_PUBLIC_IP >> ~/.ssh/known_hosts
    DATABASE_PRIVATE_IP=$(terraform output DataBase_private_IP)
    KAFKA_PRIVATE_IP=$(terraform output Kafka_private_IP)
    # ===========================
    REPORT_SAVED=/tmp/PerformanceResults
    echo "Connecting: "${CLIENT_PUBLIC_IP}
    ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "cd $PATH_REPOS && sudo git clone https://$GIT_USERNAME:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation-jmeter.git"
    ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "cd $PATH_REPOS && sudo git clone https://$GIT_USERNAME:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation-ci.git"
    ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "cd $PATH_REPOS && sudo git clone -b $BRANCH_AUTOMATION https://$GIT_USERNAME:$GIT_PASSWORD@github.com/tierconnect/vizix-qa-automation.git"
    ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "cd $PATH_REPOS/vizix-qa-automation && sudo sed -i s/localhost/$MANAGER_PRIVATE_IP/g build.gradle"
    PATH_SCRIPT=$PATH_REPOS/vizix-qa-automation-ci/vizix-swarm-compose/scripts

    echo "OPTION: "$OPTION
    case "$OPTION" in

    kafka)
        COMMAND="sudo su -c \"cd $PATH_REPOS && ./executeKafka.sh $MANAGER_PRIVATE_IP $DATABASE_PRIVATE_IP $KAFKA_PRIVATE_IP $TEST_CATEGORY $N_THREAD $PATH_REPOS $REPORT_SAVED\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"
        # PREPARE RESULT REPORTS
        COMMAND="sudo su -c \"cp $PATH_REPOS/vizix-qa-automation/build/reports/cucumber/report.json $REPORT_SAVED/Kafka/ && cd $REPORT_SAVED/Kafka/ && tar -zcvf $CLIENT_PUBLIC_IP-Kafka.tar.gz *.json && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"
        ;;

    ui)
        # Change VIZIX_API_HOST to private IP of the server, in order to execute the UI tests
        COMMAND="sudo su -c \"cd $PATH_COMPOSE && sed -i '/SERVICES_URL/c SERVICES_URL='$MANAGER_PRIVATE_IP':80' .env && cat .env && sudo docker-compose up -d ui && sleep 15\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cd $PATH_REPOS/vizix-qa-automation-ci/setupAmazon/src/composeBuilder/configurationKafka && pwd && sudo docker-compose -f vizix-automation-ui.yml restart && sleep 15\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cd $PATH_SCRIPT && ./executeUI.sh $MANAGER_PUBLIC_IP $TEST_UI_CATEGORY $PATH_REPOS $PATH_COMPOSE $REPORT_SAVED > /tmp/ExecuteUI.log\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        # PREPARE RESULT REPORTS
        COMMAND="sudo su -c \"cp $PATH_REPOS/vizix-qa-automation/build/reports/cucumber/report.json $REPORT_SAVED/UI/ && /tmp/JsonPerformanceAverage.json $REPORT_SAVED/UI/ && cd $REPORT_SAVED/UI/ && tar -zcvf $CLIENT_PUBLIC_IP-UI.tar.gz *.json && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"
        ;;

    jmeter)
        COMMAND="sudo su -c \"cd $PATH_REPOS && ./executeJmeter.sh $PARAMETERS_JMETER $MANAGER_PRIVATE_IP $REPORT_SAVED $PATH_REPOS $JMETER_TOOL_PATH\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        # PREPARE RESULT REPORTS
        COMMAND="sudo su -c \"cd $PATH_REPOS && ./getJsonJmeter.sh $REPORT_SAVED/Jmeter/*.csv /tmp/JmeterPerformanceJson.json\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cp /tmp/JmeterPerformanceJson.json $REPORT_SAVED/Jmeter/ && cat $REPORT_SAVED/Jmeter/jmeterExecution.log && cd $REPORT_SAVED/Jmeter/ && tar -zcvf $CLIENT_PUBLIC_IP-Jmeter.tar.gz * && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"
        ;;

    kafka_ui)
        echo "*****************************************************************************************************************"
        echo "executeUI.sh $MANAGER_PRIVATE_IP $TEST_CATEGORY $PATH_REPOS $PATH_COMPOSE $REPORT_SAVED"
        echo "executeKafka.sh $MANAGER_PRIVATE_IP $DATABASE_PRIVATE_IP $KAFKA_PRIVATE_IP $TEST_CATEGORY $N_THREAD"
        echo "*****************************************************************************************************************"

        COMMAND="sudo su -c \"cd $PATH_COMPOSE && sed -i '/SERVICES_URL/c SERVICES_URL='$MANAGER_PRIVATE_IP':80' .env && cat .env && sudo docker-compose up -d ui && sleep 15\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cd $PATH_REPOS/vizix-qa-automation-ci/setupAmazon/src/composeBuilder/configurationKafka && pwd && sudo docker-compose -f vizix-automation-ui.yml restart && sleep 15\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"nohup .$PATH_REPOS/executeUI.sh $MANAGER_PUBLIC_IP $TEST_UI_CATEGORY $PATH_REPOS $PATH_COMPOSE $REPORT_SAVED &\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \".$PATH_REPOS/executeKafka.sh $MANAGER_PRIVATE_IP $DATABASE_PRIVATE_IP $KAFKA_PRIVATE_IP $TEST_CATEGORY $N_THREAD\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        # PREPARE RESULT REPORTS
        COMMAND="sudo su -c \"cp $PATH_REPOS/vizix-qa-automation/build/reports/cucumber/report.json $REPORT_SAVED/UI/ && /tmp/JsonPerformanceAverage.json $REPORT_SAVED/UI/ && cd $REPORT_SAVED/UI/ && tar -zcvf $CLIENT_PUBLIC_IP-UI.tar.gz *.json && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cp $PATH_REPOS/vizix-qa-automation/build/reports/cucumber/report.json $REPORT_SAVED/Kafka/ && cd $REPORT_SAVED/Kafka/ && tar -zcvf $CLIENT_PUBLIC_IP-Kafka.tar.gz *.json && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"
        ;;

    kafka_jmeter)
        echo "*****************************************************************************************************************"
        echo "executeJmeter.sh $PARAMETERS_JMETER $MANAGER_PRIVATE_IP $REPORT_SAVED $PATH_REPOS $JMETER_TOOL_PATH"
        echo "executeKafka.sh $MANAGER_PRIVATE_IP $DATABASE_PRIVATE_IP $KAFKA_PRIVATE_IP $TEST_CATEGORY $N_THREAD"
        echo "*****************************************************************************************************************"

        COMMAND="sudo su -c \"nohup .$PATH_REPOS/executeJmeter.sh $PARAMETERS_JMETER $MANAGER_PRIVATE_IP $REPORT_SAVED $PATH_REPOS $JMETER_TOOL_PATH &\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \".$PATH_REPOS/executeKafka.sh $MANAGER_PRIVATE_IP $DATABASE_PRIVATE_IP $KAFKA_PRIVATE_IP $TEST_CATEGORY $N_THREAD\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        # PREPARE RESULT REPORTS
        COMMAND="sudo su -c \"cd $PATH_REPOS && ./getJsonJmeter.sh $REPORT_SAVED/Jmeter/*.csv /tmp/JmeterPerformanceJson.json\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cp /tmp/JmeterPerformanceJson.json $REPORT_SAVED/Jmeter/ && cat $REPORT_SAVED/Jmeter/jmeterExecution.log && cd $REPORT_SAVED/Jmeter/ && tar -zcvf $CLIENT_PUBLIC_IP-Jmeter.tar.gz * && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cp $PATH_REPOS/vizix-qa-automation/build/reports/cucumber/report.json $REPORT_SAVED/Kafka/ && cd $REPORT_SAVED/Kafka/ && tar -zcvf $CLIENT_PUBLIC_IP-Kafka.tar.gz *.json && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"
        ;;

    ui_jmeter)
        echo "*****************************************************************************************************************"
        echo "executeUI.sh $MANAGER_PRIVATE_IP $TEST_UI_CATEGORY $PATH_REPOS $PATH_COMPOSE $REPORT_SAVED"
        echo "executeJmeter.sh $PARAMETERS_JMETER $MANAGER_PRIVATE_IP $REPORT_SAVED $PATH_REPOS $JMETER_TOOL_PATH"
        echo "*****************************************************************************************************************"

        COMMAND="sudo su -c \"cd $PATH_COMPOSE && sed -i '/SERVICES_URL/c SERVICES_URL='$MANAGER_PRIVATE_IP':80' .env && cat .env && sudo docker-compose up -d ui && sleep 15\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cd $PATH_REPOS/vizix-qa-automation-ci/setupAmazon/src/composeBuilder/configurationKafka && pwd && sudo docker-compose -f vizix-automation-ui.yml restart && sleep 15\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"nohup .$PATH_REPOS/executeUI.sh $MANAGER_PUBLIC_IP $TEST_UI_CATEGORY $PATH_REPOS $PATH_COMPOSE $REPORT_SAVED &\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cd $PATH_REPOS && ./executeJmeter.sh $PARAMETERS_JMETER $MANAGER_PRIVATE_IP $REPORT_SAVED $PATH_REPOS $JMETER_TOOL_PATH\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        # PREPARE RESULT REPORTS
        COMMAND="sudo su -c \"cp $PATH_REPOS/vizix-qa-automation/build/reports/cucumber/report.json $REPORT_SAVED/UI/ && /tmp/JsonPerformanceAverage.json $REPORT_SAVED/UI/ && cd $REPORT_SAVED/UI/ && tar -zcvf $CLIENT_PUBLIC_IP-UI.tar.gz *.json && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cd $PATH_REPOS && ./getJsonJmeter.sh $REPORT_SAVED/Jmeter/*.csv /tmp/JmeterPerformanceJson.json\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cp /tmp/JmeterPerformanceJson.json $REPORT_SAVED/Jmeter/ && cat $REPORT_SAVED/Jmeter/jmeterExecution.log && cd $REPORT_SAVED/Jmeter/ && tar -zcvf $CLIENT_PUBLIC_IP-Jmeter.tar.gz * && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"
        ;;

    all)
        echo "*****************************************************************************************************************"
        echo "executeJmeter.sh $PARAMETERS_JMETER $MANAGER_PRIVATE_IP $REPORT_SAVED $PATH_REPOS $JMETER_TOOL_PATH"
        echo "executeUI.sh $MANAGER_PRIVATE_IP $TEST_UI_CATEGORY $PATH_REPOS $PATH_COMPOSE $REPORT_SAVED"
        echo "executeKafka.sh $MANAGER_PRIVATE_IP $DATABASE_PRIVATE_IP $KAFKA_PRIVATE_IP $TEST_CATEGORY $N_THREAD"
        echo "*****************************************************************************************************************"

        COMMAND="sudo su -c \"cd $PATH_COMPOSE && sed -i '/SERVICES_URL/c SERVICES_URL='$MANAGER_PRIVATE_IP':80' .env && cat .env && sudo docker-compose up -d ui && sleep 15\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${MANAGER_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cd $PATH_REPOS/vizix-qa-automation-ci/setupAmazon/src/composeBuilder/configurationKafka && pwd && sudo docker-compose -f vizix-automation-ui.yml restart && sleep 15\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"nohup .$PATH_REPOS/executeJmeter.sh $PARAMETERS_JMETER $MANAGER_PRIVATE_IP $REPORT_SAVED $PATH_REPOS $JMETER_TOOL_PATH &\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"nohup .$PATH_REPOS/executeUI.sh $MANAGER_PUBLIC_IP $TEST_UI_CATEGORY $PATH_REPOS $PATH_COMPOSE $REPORT_SAVED &\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \".$PATH_REPOS/executeKafka.sh $MANAGER_PRIVATE_IP $DATABASE_PRIVATE_IP $KAFKA_PRIVATE_IP $TEST_CATEGORY $N_THREAD\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        # PREPARE RESULT REPORTS
        COMMAND="sudo su -c \"cp $PATH_REPOS/vizix-qa-automation/build/reports/cucumber/report.json $REPORT_SAVED/UI/ && /tmp/JsonPerformanceAverage.json $REPORT_SAVED/UI/ && cd $REPORT_SAVED/UI/ && tar -zcvf $CLIENT_PUBLIC_IP-UI.tar.gz *.json && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cd $PATH_REPOS && ./getJsonJmeter.sh $REPORT_SAVED/Jmeter/*.csv /tmp/JmeterPerformanceJson.json\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cp /tmp/JmeterPerformanceJson.json $REPORT_SAVED/Jmeter/ && cat $REPORT_SAVED/Jmeter/jmeterExecution.log && cd $REPORT_SAVED/Jmeter/ && tar -zcvf $CLIENT_PUBLIC_IP-Jmeter.tar.gz * && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"

        COMMAND="sudo su -c \"cp $PATH_REPOS/vizix-qa-automation/build/reports/cucumber/report.json $REPORT_SAVED/Kafka/ && cd $REPORT_SAVED/Kafka/ && tar -zcvf $CLIENT_PUBLIC_IP-Kafka.tar.gz *.json && echo \"completed\" > /tmp/done.txt\""
        echo $COMMAND
        ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "$COMMAND"
        ;;

    *) echo "Option: $1 does not exist"
       ;;
    esac
    ssh -n -i $PATH_KEY ubuntu@${CLIENT_PUBLIC_IP} "sudo su -c \"echo 'completed' > /tmp/done.txt\""
}

# =================================================================================
# This method executes one or more performance tests inside a client vm
# $1 GIT_USERNAME           Username that will allowed to clone some repos from GITHUB (i.e. user1)
# $2 GIT_PASSWORD           Password that will allowed to clone some repos from GITHUB (i.e. pass)
# $3 PATH_KEY               Path where the key of AWS is located (i.e. /home/ubuntu/.ssh/key.pem)
# $4 BRANCH_AUTOMATION      Automation branch to clone (i.e. develop)
# $5 TEST_CATEGORY          Name of the test to execute, sometimes can include extra parameters to use (i.e. CBblink)
# $6 N_THREAD               Number od threads to use in the execution (i.e. 2)
# $7 PARAMETERS_JMETER      Parameters to use in the execution of jmeter (i.e. reports*1*1*0*/test/analytics/reports)
# $8 JMETER_TOOL_PATH       Path where the tool of Jmeter is located (i.e. /home/ubuntu/files/apache-jmeter-3.2)
# $9 TEST_UI_CATEGORY       Name of the test to execute for ui, sometimes can include extra parameters to use (i.e. WebUIPerformance)
# $10 OPTION                Specifies if the execution will contemplate ui, jmeter, kafka or any combination of them (i.e. ui_jmeter)
# $11 PATH_REPOS            Path where the repos will be cloned (no final slash) (i.e. /home/ubuntu/vizix_repositories)
# $12 PATH_COMPOSE          Path where the files of the compose are located (i.e. /home/ubuntu/vizix-compose)

execute_test $1 $2 $3 $4 $5 $6 $7 $8 $9 ${10} ${11} ${12}

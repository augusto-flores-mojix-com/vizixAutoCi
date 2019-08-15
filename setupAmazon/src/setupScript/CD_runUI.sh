#!/usr/bin/env bash
#
# @autor:Eynar Pari
# @date : 15/03/18
#
#This method is to run UI test also the owasp if it is needed
# @params
# $1 AUTOMATION_PATH
# $2 CATEGORY_TO_EXECUTE
# $3 PRIVATE_IP
# $4 PUBLIC_IP
# $5 REPORT_SAVED
# $6 IS_OWASP
# $7 VIZIX_KAFKA_REPOSITORY
runUITest(){
   echo "********************************************************************************************************"
   echo "*                                            RUN  UI TEST                                              *"
   echo "********************************************************************************************************"
    #vars
    #######################
    AUTOMATION_PATH=$1
    CATEGORY_TO_EXECUTE=$(echo $2 | tr '*' ' ')
    PRIVATE_IP=$3
    PUBLIC_IP=$4
    REPORT_SAVED=$5
    IS_OWASP=$6
    VIZIX_KAFKA_REPOSITORY=$7

    BROWSER=CHROME
    ZAP_PATH=/home/ZAP_2.7.0/zap.sh
    #######################

    cd /tmp/
    sudo apt-get purge google-chrome-stable -y
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    sudo dpkg -i google-chrome-stable_current_amd64.deb

    echo "INFO > Configuring Container UI to use private IP"
    cd $VIZIX_KAFKA_REPOSITORY
    echo "INFO > current folder"
    echo $(pwd)
    echo "sed -i "/SERVICES_URL=/c SERVICES_URL=$PRIVATE_IP:80" .env"
    sudo sed -i "/SERVICES_URL=/c SERVICES_URL=$PRIVATE_IP:80" .env
    cat .env
    sudo docker-compose up -d ui

    echo "INFO > Configuring Display to execute UI test"
    echo "INFO > Xvfb :99 -ac -screen 0 1280x1024x24 &"
    echo "INFO > export DISPLAY=:99"
    Xvfb :99 -ac -screen 0 1280x1024x24 &
    export DISPLAY=:99

    echo "INFO > clean report folder"
    sudo rm -rf $REPORT_SAVED
    sudo mkdir $REPORT_SAVED

    echo "INFO > exporting gradle var env on machine"
    export GRADLE_HOME=/usr/local/gradle
    export PATH=${GRADLE_HOME}/bin:${PATH}

    cd $AUTOMATION_PATH

    if [ "$IS_OWASP" == "true" ]
    then
       cd $VIZIX_KAFKA_REPOSITORY
       docker-compose -f vizix-automation-ui.yml up -d owasp
       sleep 60s
       cd $AUTOMATION_PATH
       BROWSER=CHROMEPROXY
    fi

    echo "INFO > gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER"
    gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/ExecutionTest$PUBLIC_IP.json

    if [ "$IS_OWASP" == "true" ]
    then
       echo "INFO > gradle clean automationTest -Pcategory=@ReportOwasp -Pnocategory=~@NotImplemented -PisUsingtoken=False -PisGeneratingReportOwasp=true -PshowLogRealTime=true"
       gradle clean automationTest -Pcategory=@ReportOwasp -Pnocategory=~@NotImplemented -PisUsingtoken=False -PisGeneratingReportOwasp=true -PshowLogRealTime=false
       cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/ReportOwasp$PUBLIC_IP.json
    fi

    sleep 12m

    echo "INFO > saving reports"
    cd $REPORT_SAVED
    sleep 10s
    cp /tmp/vulnerabilityTest.html $REPORT_SAVED
    cp /tmp/summaryvulnerabilityTest.html $REPORT_SAVED
    cp /tmp/cleandetailOwasp.html $REPORT_SAVED
    cp /tmp/cleansummaryOwasp.html $REPORT_SAVED
    echo $(pwd)
    tar -zcvf report.tar.gz *.*
    cp report.tar.gz $AUTOMATION_PATH/build/reports/cucumber/report.tar.gz
    echo "completed" > $AUTOMATION_PATH/build/reports/cucumber/done.json
    echo "INFO >-----------------------------Automated UI Test were executed---------------------------------"
}

# @params
# $1 AUTOMATION_PATH
# $2 CATEGORY_TO_EXECUTE
# $3 PRIVATE_IP
# $4 PUBLIC_IP
# $5 REPORT_SAVED
# $6 VIZIX_KAFKA_REPOSITORY
runUIDocker(){
    echo "********************************************************************************************************"
    echo "*                                         RUN  UI TEST ON DOCKER                                       *"
    echo "********************************************************************************************************"
    #######################
    AUTOMATION_PATH=$1
    CATEGORY_TO_EXECUTE=$(echo $2 | tr '*' ' ')
    PRIVATE_IP=$3
    PUBLIC_IP=$4
    REPORT_SAVED=$5
    VIZIX_KAFKA_REPOSITORY=$6
    BROWSER=CHROMEGRID
    #######################

    echo "INFO > Configuring Container UI to use private IP"
    cd $VIZIX_KAFKA_REPOSITORY

    echo "INFO > sed -i "/SERVICES_URL=/c SERVICES_URL=$PRIVATE_IP:80" .env"
    sudo sed -i "/SERVICES_URL=/c SERVICES_URL=$PRIVATE_IP:80" .env
    cat .env && sudo docker-compose up -d ui && sudo docker-compose -f vizix-automation-ui.yml up -d

    echo "INFO > clean report folder"
    sudo rm -rf $REPORT_SAVED && sudo mkdir $REPORT_SAVED
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}

    cd $AUTOMATION_PATH
    echo "INFO > gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER"
    gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER
    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/ExecutionTest$PUBLIC_IP.json

    sleep 15 && echo "INFO > saving reports"
    cd $REPORT_SAVED && sleep 10s
    tar -zcvf report.tar.gz *.*
    cp report.tar.gz $AUTOMATION_PATH/build/reports/cucumber/report.tar.gz
    echo "completed" > $AUTOMATION_PATH/build/reports/cucumber/done.json
}

# to tun specific suite with specific browser and version
# @params
# $1 AUTOMATION_PATH
# $2 CATEGORY_TO_EXECUTE
# $3 PRIVATE_IP
# $4 PUBLIC_IP
# $5 REPORT_SAVED
# $6 VIZIX_KAFKA_REPOSITORY
runUISeleniumGrid(){
    echo "********************************************************************************************************"
    echo "*                                         RUN  UI TEST ON SELENIUM GRID                                *"
    echo "********************************************************************************************************"
    #######################
    AUTOMATION_PATH=$1
    CATEGORY_TO_EXECUTE=$(echo $2 | tr '*' ' ')
    PRIVATE_IP=$3
    PUBLIC_IP=$4
    REPORT_SAVED=$5
    VIZIX_KAFKA_REPOSITORY=$6
    BROWSER=SELENIUMGRID
    #######################

    cd $VIZIX_KAFKA_REPOSITORY && echo "path : $(pwd)"

    echo "INFO > sed -i "/SERVICES_URL=/c SERVICES_URL=$PUBLIC_IP:80" .env"
    sudo sed -i "/SERVICES_URL=/c SERVICES_URL=$PUBLIC_IP:80" .env
    cat .env && sudo docker-compose up -d ui

    echo "INFO > clean report folder" && sudo rm -rf $REPORT_SAVED && sudo mkdir $REPORT_SAVED
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}

    cd $AUTOMATION_PATH && echo "INFO > gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER -PurlwebUi=http://$PUBLIC_IP"
    gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER -PurlwebUi=http://$PUBLIC_IP

    cp $AUTOMATION_PATH/build/reports/cucumber/report.json $REPORT_SAVED/ExecutionTest$PUBLIC_IP.json

    # pending add browser in the json report before compress.
    sleep 15 && echo "INFO > saving reports" && cd $REPORT_SAVED && sleep 10s && tar -zcvf report.tar.gz *.*
    cp report.tar.gz $AUTOMATION_PATH/build/reports/cucumber/report.tar.gz && echo "completed" > $AUTOMATION_PATH/build/reports/cucumber/done.json
}

# to tun specific suite with specific in all last browsers
# @params
# $1 AUTOMATION_PATH
# $2 CATEGORY_TO_EXECUTE
# $3 PRIVATE_IP
# $4 PUBLIC_IP
# $5 REPORT_SAVED
# $6 VIZIX_KAFKA_REPOSITORY
runUISeleniumGridAll(){
    echo "********************************************************************************************************"
    echo "*                                         RUN  UI TEST ON SELENIUM GRID                                *"
    echo "********************************************************************************************************"
    #######################
    local AUTOMATION_PATH=$1
    local CATEGORY_TO_EXECUTE=$2
    local PRIVATE_IP=$3
    local PUBLIC_IP=$4
    local REPORT_SAVED=$5
    local VIZIX_KAFKA_REPOSITORY=$6
    local BROWSER=SELENIUMGRID
    #######################
    local USER=auto14
    local KEY=SRZ9DFgTB7T5h2wwLXco

    ######## MAC OSX
    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Safari*-PremoteBrowserVersion=11.1*-PremoteOs=\"OS*X\"*-PremoteOsVersion=\"High*Sierra\""
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Safari11.1_OSX_HighSierra

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Chrome*-PremoteBrowserVersion=70.0*-PremoteOs=\"OS*X\"*-PremoteOsVersion=\"High*Sierra\""
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Chrome70_OSX_HighSierra

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Firefox*-PremoteBrowserVersion=63.0*-PremoteOs=\"OS*X\"*-PremoteOsVersion=\"High*Sierra\""
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Firefox63_OSX_HighSierra

    ######## Windows 10
    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Chrome*-PremoteBrowserVersion=69.0*-PremoteOs=Windows*-PremoteOsVersion=10"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Chrome69_Windows10

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Chrome*-PremoteBrowserVersion=70.0*-PremoteOs=Windows*-PremoteOsVersion=10"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Chrome70_Windows10


    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Firefox*-PremoteBrowserVersion=62.0*-PremoteOs=Windows*-PremoteOsVersion=10"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_FireFox62_Windows10

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Firefox*-PremoteBrowserVersion=63.0*-PremoteOs=Windows*-PremoteOsVersion=10"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_FireFox63_Windows10


    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Edge*-PremoteBrowserVersion=15.0*-PremoteOs=Windows*-PremoteOsVersion=10"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Edge15_Windows10

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Edge*-PremoteBrowserVersion=16.0*-PremoteOs=Windows*-PremoteOsVersion=10"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Edge16_Windows10

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Edge*-PremoteBrowserVersion=17.0*-PremoteOs=Windows*-PremoteOsVersion=10"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Edge17_Windows10

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=IE*-PremoteBrowserVersion=11.0*-PremoteOs=Windows*-PremoteOsVersion=10"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_IE11_Windows10

    ######## Windows7

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Chrome*-PremoteBrowserVersion=69.0*-PremoteOs=Windows*-PremoteOsVersion=7"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Chrome69_Windows7

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Chrome*-PremoteBrowserVersion=70.0*-PremoteOs=Windows*-PremoteOsVersion=7"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Chrome70_Windows7

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Firefox*-PremoteBrowserVersion=62.0*-PremoteOs=Windows*-PremoteOsVersion=7"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_FireFox62_Windows7


    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Firefox*-PremoteBrowserVersion=63.0*-PremoteOs=Windows*-PremoteOsVersion=7"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_FireFox63_Windows7

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=IE*-PremoteBrowserVersion=11.0*-PremoteOs=Windows*-PremoteOsVersion=7"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_IE11_Windows7

    ######## Windows8.1

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Chrome*-PremoteBrowserVersion=69.0*-PremoteOs=Windows*-PremoteOsVersion=8.1"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Chrome69_Windows8.1

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Chrome*-PremoteBrowserVersion=70.0*-PremoteOs=Windows*-PremoteOsVersion=8.1"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_Chrome70_Windows8.1

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Firefox*-PremoteBrowserVersion=62.0*-PremoteOs=Windows*-PremoteOsVersion=8.1"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_FireFox62_Windows8.1

    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=Firefox*-PremoteBrowserVersion=63.0*-PremoteOs=Windows*-PremoteOsVersion=8.1"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_FireFox63_Windows8.1


    TmpParams=$CATEGORY_TO_EXECUTE"*-PremoteUserName=$USER*-PremoteKey=$KEY*-PremoteBrowser=IE*-PremoteBrowserVersion=11.0*-PremoteOs=Windows*-PremoteOsVersion=8.1"
    runUISeleniumGridTmpForAll $AUTOMATION_PATH $TmpParams $PRIVATE_IP $PUBLIC_IP $REPORT_SAVED $VIZIX_KAFKA_REPOSITORY Browser_IE11_Windows8.1



    sleep 15 && echo "INFO > saving reports" && cd $REPORT_SAVED && sleep 10s && tar -zcvf report.tar.gz *.*
    cp report.tar.gz $AUTOMATION_PATH/build/reports/cucumber/report.tar.gz && echo "completed" > $AUTOMATION_PATH/build/reports/cucumber/done.json

}

# @params
# $1 AUTOMATION_PATH
# $2 CATEGORY_TO_EXECUTE
# $3 PRIVATE_IP
# $4 PUBLIC_IP
# $5 REPORT_SAVED
# $6 VIZIX_KAFKA_REPOSITORY
# $7 TYPE_BROWSER
runUISeleniumGridTmpForAll(){
    echo "********************************************************************************************************"
    echo "*                                         RUN  UI TEST ON SELENIUM GRID                                *"
    echo "********************************************************************************************************"
    #######################
    local AUTOMATION_PATH=$1
    local CATEGORY_TO_EXECUTE=$(echo $2 | tr '*' ' ')
    local PRIVATE_IP=$3
    local PUBLIC_IP=$4
    local REPORT_SAVED=$5
    local VIZIX_KAFKA_REPOSITORY=$6

    BROWSER=SELENIUMGRID
    TYPE_BROWSER=$7

    echo "AUTOMATION_PATH : $AUTOMATION_PATH"
    echo "CATEGORY_TO_EXECUTE : $CATEGORY_TO_EXECUTE"
    echo "PRIVATE_IP : $PRIVATE_IP"
    echo "PUBLIC_IP : $PUBLIC_IP"
    echo "REPORT_SAVED : $REPORT_SAVED"
    echo "VIZIX_KAFKA_REPOSITORY : $VIZIX_KAFKA_REPOSITORY"
    echo "TYPE_BROWSER : $TYPE_BROWSER"
    #######################

    cd $VIZIX_KAFKA_REPOSITORY

    echo "INFO > clean report folder" && sudo mkdir $REPORT_SAVED
    export GRADLE_HOME=/usr/local/gradle && export PATH=${GRADLE_HOME}/bin:${PATH}

    cd $AUTOMATION_PATH && echo "INFO > gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER -PurlwebUi=http://${PUBLIC_IP}"
    gradle clean automationTest -Pcategory=@$CATEGORY_TO_EXECUTE -Pnocategory=~@NotImplemented -PisUsingtoken=False -PbrowserOrMobile=$BROWSER -PurlwebUi=http://${PUBLIC_IP}

    cat $AUTOMATION_PATH/build/reports/cucumber/report.json | jq ".[].name = \"$TYPE_BROWSER : \"+(.[].name)"  > $REPORT_SAVED/${TYPE_BROWSER}ExecutionTest${PUBLIC_IP}.json
}
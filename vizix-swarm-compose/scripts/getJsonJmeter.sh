#!/bin/bash
#
# @autor: jcussi
# @date : 31/05/18
#
# $1 - String - Path to report of JMETER csv extension
# $2 - String - Path where to save average by label
#
# Example of usage: getAverage /home/user/file.csv /tmp/outputFile.csv
getAverage(){
    PATH_JMETER_REPORT=$1
    PATH_OUTPUT_AVG=$2
    cat ${PATH_JMETER_REPORT} | grep -v "label" > /tmp/justData.csv
    awk -F "," '{a[$3]+=$2; b[$3]+=$14; c[$3]++} END  {for (i in a) {printf i "," a[i]/c[i] "," b[i]/c[i] "\n"}}' /tmp/justData.csv > ${PATH_OUTPUT_AVG}
    echo 'label,elapsed,Latency' | cat - ${PATH_OUTPUT_AVG} > temp && mv temp ${PATH_OUTPUT_AVG}
}

#
# MAIN
# $1 - String - Path to report of JMETER csv extension
# $2 - String - Path where to save json file
# Example of usage: ./vizix-swarm-compose/scripts/getJsonJmeter.sh /home/user/testReport.csv /tmp/file_converted.json
#

PATH_JMETER_REPORT=$1
PATH_OUTPUT_JSON_JMETER=$2
PATH_OUTPUT_AVG_JMETER=/tmp/averageCSV.csv

CURRENT_FOLDER=$(pwd)
echo ${CURRENT_FOLDER}
getAverage ${PATH_JMETER_REPORT} ${PATH_OUTPUT_AVG_JMETER}
echo "******************** CSV AVERAGE ****************************"
cat ${PATH_OUTPUT_AVG_JMETER}
echo "******************** CSV AVERAGE ****************************"
bash ${CURRENT_FOLDER}/vizix-swarm-compose/scripts/convertCSVtoJson.sh ${PATH_OUTPUT_AVG_JMETER} > ${PATH_OUTPUT_JSON_JMETER}
echo "******************** JSON AVERAGE ****************************"
cat ${PATH_OUTPUT_JSON_JMETER}
echo "******************** JSON AVERAGE ****************************"


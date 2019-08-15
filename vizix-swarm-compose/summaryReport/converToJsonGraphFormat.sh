#!/bin/bash

generateSummaryReport(){
    TYPE=$1
    FILE_NAME=$2
    OUTPUT_PATH=$3

    if [ -f "$FILE_NAME" ]
    then
        echo "INFO > $FILE_NAME found."
        FINAL_JSON='{ "cols": [{"id":"event","label":"Event","pattern":"","type":"string"}, {"id":"time","label":"Time","pattern":"","type":"number"}], "rows": ['

        while read -r line
        do
            echo "read from file - $line"
            IFS=',' read -r -a values <<< "$line"
            FINAL_JSON=$FINAL_JSON'{"c":[{"v":"'${values[0]}'","f":null},{"v":'${values[1]}',"f":null}]},'
        done < "$FILE_NAME"

        FINAL_JSON=${FINAL_JSON::-1}']}'
        echo $FINAL_JSON

        sed -i "s/REPLACE_DATA_$TYPE/$FINAL_JSON/g" $OUTPUT_PATH
    else
        echo "INFO >  $FILE_NAME not found."
    fi
}

generateSummaryReportServices(){
    TYPE=$1
    FILE_NAME=$2
    OUTPUT_PATH=$3

    if [ -f "$FILE_NAME" ]
    then
        echo "INFO > $FILE_NAME found."
        FINAL_JSON='{ "cols": [{"id":"label","label":"Label","pattern":"","type":"string"}, {"id":"elapsedTime","label":"ElapsedTime","pattern":"","type":"number"}, {"id":"latencyTime","label":"LatencyTime","pattern":"","type":"number"}], "rows": ['

        tail -n +2 "$FILE_NAME" > /tmp/justData.csv
        while read -r line
        do
            echo "read from file - $line"
            IFS=',' read -r -a values <<< "$line"
            FINAL_JSON=$FINAL_JSON'{"c":[{"v":"'${values[0]}'","f":null},{"v":'${values[1]}',"f":null},{"v":'${values[2]}',"f":null}]},'
        done < "/tmp/justData.csv"

        FINAL_JSON=${FINAL_JSON::-1}']}'
        echo $FINAL_JSON

        sed -i "s/REPLACE_DATA_$TYPE/$FINAL_JSON/g" $OUTPUT_PATH
    else
        echo "INFO >  $FILE_NAME not found."
    fi
}


CSV_UI=$1
CSV_SERVICES=$2
CSV_BRIDGES=$3
OUTPUT_PATH=$4
cp -rf vizix-swarm-compose/summaryReport/summaryReport.html $OUTPUT_PATH
generateSummaryReport UI $CSV_UI $OUTPUT_PATH
generateSummaryReportServices SERVICES $CSV_SERVICES $OUTPUT_PATH
generateSummaryReport BRIDGES $CSV_BRIDGES $OUTPUT_PATH

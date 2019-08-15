#!/usr/bin/env bash
# @autor: Eynar Pari
# @date : 18/06/2018

#global var
IS_IT_COPIED=1

#@params
# $1 PATH_FILE_PEM -> String path of pem file (i.e.: /tmp/pems/)
# $2 LOCAL_PATH_TO_COPY > String local path to copied the reports.json (i.e.: /tmp/)
# $3 IP_LIST_FILE -> String path of ips.txt (i.e.: /tmp/ips.txt)
# $4 CLOUD_TYPE
# $5 RESOURCE_GROUP
getJsonFiles(){
    #params
    PATH_FILE_PEM=$1
    LOCAL_PATH_TO_COPY=$2
    IP_LIST_FILE=$3
    CLOUD_TYPE=$4
    RESOURCE_GROUP=$5
    echo "@params PATH_FILE_PEM=$PATH_FILE_PEM"
    echo "@params LOCAL_PATH_TO_COPY=$LOCAL_PATH_TO_COPY"
    echo "@params IP_LIST_FILE=$IP_LIST_FILE"
    echo "@params CLOUD_TYPE=$CLOUD_TYPE"
    echo "@params RESOURCE_GROUP=$RESOURCE_GROUP"
    ####
    echo "INFO > count the total IPs on List IPs File"
    counter=$(awk 'END{print NR}' $IP_LIST_FILE)
    echo $counter
    while [[ $counter -gt 0 ]]; do
        counter=$(awk 'END{print NR}' $IP_LIST_FILE)
        echo $counter
        for i in `seq 1 $counter`; do
            line=$(awk 'NR=='"$i"'{print $PATH_FILE_PEM}' $IP_LIST_FILE)
            echo "INFO > Search on : $line"
            existFileRemoveInstanceCloud $PATH_FILE_PEM $LOCAL_PATH_TO_COPY $IP_LIST_FILE $CLOUD_TYPE $RESOURCE_GROUP
            echo "INFO > still ..."
        done
    done
}

#@params
# $1 PATH_FILE_PEM -> String path of pem file (i.e.: /tmp/pems/)
# $2 LOCAL_PATH_TO_COPY > String local path to copied the reports.json (i.e.: /tmp/)
# $3 IP_LIST_FILE -> String path of ips.txt (i.e.: /tmp/ips.txt)
# $4 CLOUD_TYPE
# $5 RESOURCE_GROUP
existFileRemoveInstanceCloud(){
   #params
   PATH_FILE_PEM=$1
   LOCAL_PATH_TO_COPY=$2
   IP_LIST_FILE=$3
   IS_IT_COPIED=1
   CLOUD_TYPE=$4
   RESOURCE_GROUP=$5
   echo "INFO > waiting while the report.json is creating on $line ...."
   if ssh -i $PATH_FILE_PEM/awsqa.pem ubuntu@$line "stat /home/ubuntu/vizix_repositories/vizix-qa-automation/build/reports/cucumber/done.json > /dev/null 2>&1";
   then
      if ssh -i $PATH_FILE_PEM/awsqa.pem ubuntu@$line "stat /home/ubuntu/vizix_repositories/vizix-qa-automation/build/reports/cucumber/report.tar.gz > /dev/null 2>&1";
      then
          scp -i $PATH_FILE_PEM/awsqa.pem ubuntu@$line:/home/ubuntu/vizix_repositories/vizix-qa-automation/build/reports/cucumber/report.tar.gz $LOCAL_PATH_TO_COPY/$line.tar.gz;
          echo "INFO > file was copied $line"
          echo "INFO > file to be removed $line"
          sed -i "/$line/d" $IP_LIST_FILE
          case "$CLOUD_TYPE" in
                azure)
                    echo "INFO> removing virtual machine with public ip : [$line] on azure"
                    imageId=$(az vm list -d | jq ' .[] | select( .publicIps=="'${line}'") | .id ' | tr -d \" )
                    nameVm=$(az vm list -d | jq ' .[] | select( .publicIps=="'${line}'") | .name ' | tr -d \" )

                    echo "INFO> get name for disk, publicip, securityGroup, networkInterface"
                    nameDisk=$(az disk list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${nameVm}'")) | .name' | tr -d \")
                    namePublicIp=$(az network public-ip list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${nameVm}'")) | .name' | tr -d \")
                    nameSecurityGroup=$(az network nsg list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${nameVm}'")) | .name' | tr -d \")
                    nameNetworkInterface=$(az network nic list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${nameVm}'")) | .name' | tr -d \")

                    echo "INFO> removing vm : az vm delete --ids $imageId --yes "
                    az vm delete --ids $imageId --yes
                    echo "INFO> removing nic : az network nic delete -g $RESOURCE_GROUP -n $nameNetworkInterface "
                    az network nic delete -g $RESOURCE_GROUP -n $nameNetworkInterface
                    echo "INFO> removing disk :  az disk delete --name $nameDisk --resource-group $RESOURCE_GROUP --yes "
                    az disk delete --name $nameDisk --resource-group $RESOURCE_GROUP --yes
                    echo "INFO> removing public-ip :  az network public-ip delete -g $RESOURCE_GROUP -n $namePublicIp "
                    az network public-ip delete -g $RESOURCE_GROUP -n $namePublicIp
                    echo "INFO> removing nsg :  az network nsg delete -g $RESOURCE_GROUP -n $nameSecurityGroup "
                    az network nsg delete -g $RESOURCE_GROUP -n $nameSecurityGroup

                    ;;
                aws)
                   echo "INFO> removing instance with public ip : [$line] on aws"
                   imageId=$(echo $(aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --filters "Name=ip-address,Values=$line"| jq .[])|sed 's/\"//g')
                   aws ec2 terminate-instances --instance-id $imageId
                    ;;
                *)
                   echo " ERROR! the script has no support : $CLOUD_TYPE "
                   exit 1
                   ;;
          esac
          sleep 20
          IS_IT_COPIED=0
      else
          echo "INFO > file report.json was not copied $line"
          IS_IT_COPIED=1
      fi
   else
           echo "INFO > file done.json does not exist on $line"
           IS_IT_COPIED=1
   fi
   echo "INFO > value copied : $IS_IT_COPIED"

}


###################### MAIN ########################

CLOUD_TYPE=$1
PATH_FILE_PEM=$2
LOCAL_PATH_TO_COPY=$3
IP_LIST_FILE=$4
RESOURCE_GROUP=$5

echo "***********[Bash Script]***************"
echo "*   Get Json & Remove on $CLOUD_TYPE  *"
echo "***************************************"

getJsonFiles $PATH_FILE_PEM $LOCAL_PATH_TO_COPY $IP_LIST_FILE $CLOUD_TYPE $RESOURCE_GROUP


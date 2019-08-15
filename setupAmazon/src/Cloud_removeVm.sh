#!/usr/bin/env bash
# @autor: Eynar Pari
# @date : 18/06/2018

#@params
# $1 PATH_IMAGES_ID_FILE String : path of imgids.txt
# $2 RESOURCE_GROUP
removeVmAzure(){
    PATH_IMAGES_ID_FILE=$1
    RESOURCE_GROUP=$2
    echo "@params_az PATH_IMAGES_ID_FILE=$PATH_IMAGES_ID_FILE"
    echo "@params_az RESOURCE_GROUP=$RESOURCE_GROUP"
    counter=1
    while IFS='' read -r line || [[ -n "$line" ]]; do

       nameVm=$(az vm list -d | jq ' .[] | select( .id=="'${line}'") | .name ' | tr -d \" )

       echo "INFO> get name for disk, publicip, securityGroup, networkInterface"
       nameDisk=$(az disk list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${nameVm}'")) | .name' | tr -d \")
       namePublicIp=$(az network public-ip list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${nameVm}'")) | .name' | tr -d \")
       nameSecurityGroup=$(az network nsg list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${nameVm}'")) | .name' | tr -d \")
       nameNetworkInterface=$(az network nic list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${nameVm}'")) | .name' | tr -d \")
       echo "INFO> deleting virtual machine with id : az vm delete --ids $line --yes"
       az vm delete --ids $line --yes
       echo "INFO> removing nic : az network nic delete -g $RESOURCE_GROUP -n $nameNetworkInterface "
       az network nic delete -g $RESOURCE_GROUP -n $nameNetworkInterface
       echo "INFO> removing disk :  az disk delete --name $nameDisk --resource-group $RESOURCE_GROUP --yes "
       az disk delete --name $nameDisk --resource-group $RESOURCE_GROUP --yes
       echo "INFO> removing public-ip :  az network public-ip delete -g $RESOURCE_GROUP -n $namePublicIp "
       az network public-ip delete -g $RESOURCE_GROUP -n $namePublicIp
       echo "INFO> removing nsg :  az network nsg delete -g $RESOURCE_GROUP -n $nameSecurityGroup "
       az network nsg delete -g $RESOURCE_GROUP -n $nameSecurityGroup

    done < "$PATH_IMAGES_ID_FILE"
    echo "INFO> virtual machines were removed" && sleep 30s
}

#@params
# $1 PATH_IMAGES_ID_FILE String : path of imgids.txt
removeVmAws(){
    PATH_IMAGES_ID_FILE=$1
    echo "@params_aws PATH_IMAGES_ID_FILE=$PATH_IMAGES_ID_FILE"
    counter=1
    while IFS='' read -r line || [[ -n "$line" ]]; do
        echo "INFO>deleting instance with id : [$line]"
        aws ec2 terminate-instances --instance-id $line
    done < "$PATH_IMAGES_ID_FILE"
    echo "INFO> instances were removed" && sleep 30s
}



#################### MAIN #####################

CLOUD_TYPE=$1

echo "*********[Bash Script]**********"
echo "*   Remove Vms on $CLOUD_TYPE  *"
echo "********************************"

case "$CLOUD_TYPE" in
    azure)
        PATH_IMAGES_ID_FILE=$2
        RESOURCE_GROUP=$3
        removeVmAzure $PATH_IMAGES_ID_FILE $RESOURCE_GROUP
        ;;
    aws)
        PATH_IMAGES_ID_FILE=$2
        removeVmAws $PATH_IMAGES_ID_FILE
        ;;
    *)
       echo " ERROR! the script has no support : $CLOUD_TYPE "
       exit 1
       ;;
esac
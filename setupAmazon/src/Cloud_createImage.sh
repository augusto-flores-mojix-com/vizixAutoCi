#!/usr/bin/env bash
# @autor: Eynar Pari
# @date : 18/06/2018


# this method is to generate image id from specific instance
#$1 String : AWS_CLI_PATH
#$2 String : NAME_INSTANCE
#$3 String : TMP_IMAGE_NAME i.e tmpBVT
#$4 String : TMP_IMAGE_ID_FILE i.e: bvtTemporal.txt
createImageAws(){
   AWS_CLI_PATH=$1
   NAME_INSTANCE=$2
   NAME_TEMP_IMAGE=$3
   TMP_IMAGE_ID_FILE=$4
   echo "@params_az AWS_CLI_PATH=$AWS_CLI_PATH"
   echo "@params_az NAME_INSTANCE=$NAME_INSTANCE"
   echo "@params_az NAME_TEMP_IMAGE=$NAME_TEMP_IMAGE"
   echo "@params_az TMP_IMAGE_ID_FILE=$TMP_IMAGE_ID_FILE"
   echo "INFO> name temporal image to use : $NAME_TEMP_IMAGE"
   cd $AWS_CLI_PATH
   ImageIDAWS=$(aws ec2 describe-images  --filters Name=name,Values=${NAME_TEMP_IMAGE} --query 'Images[*].{ID:ImageId}')
   if [ "$ImageIDAWS" != "[]" ]
    then
      ImageIDAWS=$(aws ec2 describe-images  --filters Name=name,Values=${NAME_TEMP_IMAGE} --query 'Images[*].{ID:ImageId}' | jq .[].ID | tr -d \" )
      echo "INFO > clean if is there AMI with name $NAME_TEMP_IMAGE ,id :"$ImageIDAWS
      aws ec2 deregister-image --image-id $ImageIDAWS
      sleep 15s
   fi

   InstanceIDAWS=$(aws ec2 describe-instances --query 'Reservations[].Instances[]' --filters 'Name=tag:Name,Values="'${NAME_INSTANCE}'"' | jq .[].InstanceId | tr -d \" )
   echo "INFO > aws ec2 stop-instances --instance-ids $InstanceIDAWS : "$InstanceIDAWS
   aws ec2 stop-instances --instance-ids $InstanceIDAWS

   statusInstance=$(aws ec2 describe-instances --query 'Reservations[].Instances[]' --filters 'Name=tag:Name,Values="'${NAME_INSTANCE}'"' | jq .[].State.Name | tr -d \")
   while [ "$statusInstance" != "stopped" ]
   do
       echo "INFO > waiting while the instance is stopped to be able to create Image, status : "$statusInstance
       sleep 15s
       statusInstance=$(aws ec2 describe-instances --query 'Reservations[].Instances[]' --filters 'Name=tag:Name,Values="'${NAME_INSTANCE}'"' | jq .[].State.Name | tr -d \")
   done

   ImageIDAWS=$(aws ec2 create-image --instance-id $InstanceIDAWS --name ${NAME_TEMP_IMAGE} | jq .ImageId | tr -d \")
   echo "INFO >Image ID Template":$ImageIDAWS
   echo "$ImageIDAWS" > $TMP_IMAGE_ID_FILE

   STATUS=$(aws ec2 describe-images --image-id $ImageIDAWS | jq .Images | jq .[].State | tr -d \" )

   while [ "$STATUS" != "available" ]
   do
       echo "INFO > waiting while AMI is ready, state : "$STATUS
       sleep 30s
       STATUS=$(aws ec2 describe-images --image-id $ImageIDAWS | jq .Images | jq .[].State | tr -d \" )
   done

   aws ec2 terminate-instances --instance-ids $InstanceIDAWS
   echo "INFO > Complete"
}

# this method is to generate image id from specific instance
#$1 String : AZ_CLI_PATH
#$2 String : NAME_INSTANCE
#$3 String : TMP_IMAGE_NAME i.e tmpBVT
#$4 String : TMP_IMAGE_ID_FILE i.e: bvtTemporal.txt
#$4 String : RESOURCE_GROUP i.e: automation.vizixcloud.com
createImageAzure(){
   AZ_CLI_PATH=$1
   NAME_INSTANCE=$21
   NAME_TEMP_IMAGE=$3
   TMP_IMAGE_ID_FILE=$4
   RESOURCE_GROUP=$5
   echo "@params_az AZ_CLI_PATH=$AZ_CLI_PATH"
   echo "@params_az NAME_INSTANCE=$NAME_INSTANCE"
   echo "@params_az NAME_TEMP_IMAGE=$NAME_TEMP_IMAGE"
   echo "@params_az TMP_IMAGE_ID_FILE=$TMP_IMAGE_ID_FILE"
   echo "@params_az RESOURCE_GROUP=$RESOURCE_GROUP"
   echo "INFO> name temporal image to create : $NAME_TEMP_IMAGE"
   cd $AZ_CLI_PATH
   ImageIDAWS=$(az image show --resource-group ${RESOURCE_GROUP} --name ${NAME_TEMP_IMAGE} | jq '.name' | tr -d \")
   if [ "$ImageIDAWS" != "" ]
    then
      echo "INFO > clean if there is IMAGE with name $NAME_TEMP_IMAGE "
      az image delete --name $NAME_TEMP_IMAGE --resource-group $RESOURCE_GROUP
      sleep 15s
      echo "INFO > IMAGE deleted"
   fi

   echo "INFO > az vm deallocate --resource-group $RESOURCE_GROUP --name $NAME_INSTANCE"
   az vm deallocate --resource-group $RESOURCE_GROUP --name $NAME_INSTANCE

   statusInstance=$(az vm list -d | jq '.[] | select ( .name=="'${NAME_INSTANCE}'") | .powerState ' | tr -d \")
   while [ "$statusInstance" != "VM deallocated" ]
   do
       echo "INFO > waiting while the instance is deallocated to be able to create Image, status : "$statusInstance
       sleep 15s
       statusInstance=$(az vm list -d | jq '.[] | select ( .name=="'${NAME_INSTANCE}'") | .powerState ' | tr -d \")
   done

   echo "INFO > az vm generalize --resource-group $RESOURCE_GROUP --name $NAME_INSTANCE"
   az vm generalize --resource-group $RESOURCE_GROUP --name $NAME_INSTANCE
   echo "INFO > waiting while the vm is generalize " && sleep 30s

   echo  "INFO > az image create  --resource-group $RESOURCE_GROUP --name $NAME_TEMP_IMAGE --source $NAME_INSTANCE"
   az image create  --resource-group $RESOURCE_GROUP --name $NAME_TEMP_IMAGE --source $NAME_INSTANCE

   echo "$NAME_TEMP_IMAGE" > $TMP_IMAGE_ID_FILE

   STATUS=$(az image show --resource-group ${RESOURCE_GROUP} --name ${NAME_TEMP_IMAGE} | jq '.provisioningState' | tr -d \")
   sleep 15s
   while [ "$STATUS" != "Succeeded" ]
   do
       echo "INFO > waiting while IMAGE is ready, state : "$STATUS
       sleep 15s
       STATUS=$(az image show --resource-group ${RESOURCE_GROUP} --name ${NAME_TEMP_IMAGE} | jq '.provisioningState' | tr -d \" )
   done

   nameDisk=$(az disk list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${NAME_INSTANCE}'")) | .name' | tr -d \")
   namePublicIp=$(az network public-ip list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${NAME_INSTANCE}'")) | .name' | tr -d \")
   nameSecurityGroup=$(az network nsg list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${NAME_INSTANCE}'")) | .name' | tr -d \")
   nameNetworkInterface=$(az network nic list --resource-group ${RESOURCE_GROUP} | jq '.[] | select (.name | contains("'${NAME_INSTANCE}'")) | .name' | tr -d \")

   echo "INFO> deleting virtual machine with id : az vm delete --resource-group ${RESOURCE_GROUP} --name $NAME_INSTANCE --yes"
   az vm delete --resource-group ${RESOURCE_GROUP} --name $NAME_INSTANCE --yes
   echo "INFO> removing nic : az network nic delete -g $RESOURCE_GROUP -n $nameNetworkInterface "
   az network nic delete -g $RESOURCE_GROUP -n $nameNetworkInterface
   echo "INFO> removing disk :  az disk delete --name $nameDisk --resource-group $RESOURCE_GROUP --yes "
   az disk delete --name $nameDisk --resource-group $RESOURCE_GROUP --yes
   echo "INFO> removing public-ip :  az network public-ip delete -g $RESOURCE_GROUP -n $namePublicIp "
   az network public-ip delete -g $RESOURCE_GROUP -n $namePublicIp
   echo "INFO> removing nsg :  az network nsg delete -g $RESOURCE_GROUP -n $nameSecurityGroup "
   az network nsg delete -g $RESOURCE_GROUP -n $nameSecurityGroup
   echo "INFO > Complete"
}

################## Main ##################

CLOUD_TYPE=$1
echo "***********[Bash Script]**********"
echo "*   Create Image on $CLOUD_TYPE  *"
echo "**********************************"
case "$CLOUD_TYPE" in
    azure)
        AZ_CLI_PATH=$2
        NAME_INSTANCE=$3
        NAME_TEMP_IMAGE=$4
        TMP_IMAGE_ID_FILE=$5
        RESOURCE_GROUP=$6
        createImageAzure $AZ_CLI_PATH $NAME_INSTANCE $NAME_TEMP_IMAGE $TMP_IMAGE_ID_FILE $RESOURCE_GROUP
        ;;
    aws)
        AWS_CLI_PATH=$2
        NAME_INSTANCE=$3
        TMP_IMAGE_NAME=$4
        TMP_IMAGE_ID_FILE=$5
        createImageAws $AWS_CLI_PATH $NAME_INSTANCE $TMP_IMAGE_NAME $TMP_IMAGE_ID_FILE
        ;;
    *)
       echo " ERROR! the script has no support : $CLOUD_TYPE "
       exit 1
       ;;
esac
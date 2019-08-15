#!/usr/bin/env bash
# @autor: Eynar Pari
# @date : 18/06/2018

createVmAzure(){
    AZ_CLI_PATH=$1
    IMAGE_ID=$2
    NEW_VMS_NUMBER=$3
    INSTANCE_TYPE=$4
    KEY_PUB_PEM=$5
    RESOURCE_GROUP=$6
    INSTANCE_LOCATION=$7
    INSTANCE_NAME=$8
    echo "@params_az AZ_CLI_PATH=$AZ_CLI_PATH"
    echo "@params_az IMAGE_ID=$IMAGE_ID"
    echo "@params_az NEW_VMS_NUMBER=$NEW_VMS_NUMBER"
    echo "@params_az INSTANCE_TYPE=$INSTANCE_TYPE"
    echo "@params_az KEY_PUB_PEM=$KEY_PUB_PEM"
    echo "@params_az RESOURCE_GROUP=$RESOURCE_GROUP"
    echo "@params_az INSTANCE_LOCATION=$INSTANCE_LOCATION"
    echo "@params_az INSTANCE_NAME=$INSTANCE_NAME"
    cd $AZ_CLI_PATH
    echo "CMD > Executing $NEW_VMS_NUMBER times the next command"
    echo "CMD > az vm create --name $INSTANCE_NAME --resource-group $RESOURCE_GROUP --image $IMAGE_ID --ssh-key-value $KEY_PUB_PEM --admin-username ubuntu --size $INSTANCE_TYPE  --storage-sku Standard_LRS  --location $INSTANCE_LOCATION"

    for (( i=1; i<=$NEW_VMS_NUMBER; i++))
        do
            echo "INFO> Creating virtual machine : [$i] , with name : $INSTANCE_NAME$i"
            az vm create --name $INSTANCE_NAME$i --resource-group $RESOURCE_GROUP --image $IMAGE_ID --ssh-key-value $KEY_PUB_PEM --admin-username ubuntu --size $INSTANCE_TYPE  --storage-sku Standard_LRS  --location $INSTANCE_LOCATION
            echo "INFO> vm created : [$INSTANCE_NAME$i]"
        done
    echo "INFO > virtual machines created : [$NEW_VMS_NUMBER]." && sleep 30s
}


createVmAws(){
    AWS_CLI_PATH=$1
    IMAGE_ID=$2
    NEW_VMS_NUMBER=$3
    INSTANCE_TYPE=$4
    KEY_NAME=$5
    SECURITY_GROUPS=$6
    INSTANCE_REGION=$7
    INSTANCE_NAME=$8
    echo "@params_aws AWS_CLI_PATH=$AWS_CLI_PATH"
    echo "@params_aws IMAGE_ID=$IMAGE_ID"
    echo "@params_aws NEW_VMS_NUMBER=$NEW_VMS_NUMBER"
    echo "@params_aws INSTANCE_TYPE=$INSTANCE_TYPE"
    echo "@params_aws KEY_NAME=$KEY_NAME"
    echo "@params_aws SECURITY_GROUPS=$SECURITY_GROUPS"
    echo "@params_aws INSTANCE_REGION=$INSTANCE_REGION"
    echo "@params_aws INSTANCE_NAME=$INSTANCE_NAME"
    cd $AWS_CLI_PATH
    echo "CMD> aws ec2 run-instances --image-id $IMAGE_ID --count $NEW_VMS_NUMBER --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-group-ids $SECURITY_GROUPS --region $INSTANCE_REGION --tag-specifications \"ResourceType=instance, Tags=[{Key=Name,Value=$INSTANCE_NAME}]\""
    aws ec2 run-instances --image-id $IMAGE_ID --count $NEW_VMS_NUMBER --instance-type $INSTANCE_TYPE --key-name $KEY_NAME --security-group-ids $SECURITY_GROUPS --region $INSTANCE_REGION --tag-specifications "ResourceType=instance, Tags=[{Key=Name,Value=$INSTANCE_NAME}]"
    echo "INFO > virtual machines created : [$NEW_VMS_NUMBER]." && sleep 30s
}


#################### MAIN ##########################
CLOUD_TYPE=$1
echo "**********[Bash Script]***********"
echo "*   Create VM on $CLOUD_TYPE  *"
echo "**********************************"
case "$CLOUD_TYPE" in
    azure)
        AZ_CLI_PATH=$2
        IMAGE_ID=$3
        NEW_VMS_NUMBER=$4
        INSTANCE_TYPE=$5
        KEY_PUB_PEM=$6
        RESOURCE_GROUP=$7
        INSTANCE_LOCATION=$8
        INSTANCE_NAME=$9
        createVmAzure $AZ_CLI_PATH $IMAGE_ID $NEW_VMS_NUMBER $INSTANCE_TYPE $KEY_PUB_PEM $RESOURCE_GROUP $INSTANCE_LOCATION $INSTANCE_NAME
        ;;
    aws)
       AWS_CLI_PATH=$2
       IMAGE_ID=$3
       NEW_VMS_NUMBER=$4
       INSTANCE_TYPE=$5
       KEY_NAME=$6
       SECURITY_GROUPS=$7
       INSTANCE_REGION=$8
       INSTANCE_NAME=$9
       createVmAws $AWS_CLI_PATH $IMAGE_ID $NEW_VMS_NUMBER $INSTANCE_TYPE $KEY_NAME $SECURITY_GROUPS $INSTANCE_REGION $INSTANCE_NAME
       ;;
    *)
       echo " ERROR! the script has no support : $CLOUD_TYPE "
       exit 1
       ;;
esac
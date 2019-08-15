#!/usr/bin/env bash
# @autor: Eynar Pari
# @date : 18/06/2018

getInstanceIdsAzure(){
  AZ_CLI_PATH=$1
  INSTANCE_NAME=$2
  IMAGES_PATH_TMP=$3
  echo "@params_az AZ_CLI_PATH=$AZ_CLI_PATH"
  echo "@params_az INSTANCE_NAME=$INSTANCE_NAME"
  echo "@params_az IMAGES_PATH_TMP=$IMAGES_PATH_TMP"
  cd $AZ_CLI_PATH
  az vm list -d | jq ' .[] | select( .name | contains ("'${INSTANCE_NAME}'")) | .id ' | tr -d \" > $IMAGES_PATH_TMP
  echo "INFO> waiting while file with id instances is created " && sleep 30s
  echo "INFO> File with Id instances " && cat $IMAGES_PATH_TMP && echo " "
}


getInstanceIdsAws(){
  AWS_CLI_PATH=$1
  INSTANCE_NAME=$2
  INSTANCE_REGION=$3
  IMAGES_PATH_TMP=$4
  echo "@params_aws AWS_CLI_PATH=$AWS_CLI_PATH"
  echo "@params_aws INSTANCE_NAME=$INSTANCE_NAME"
  echo "@params_aws INSTANCE_REGION=$INSTANCE_REGION"
  echo "@params_aws IMAGES_PATH_TMP=$IMAGES_PATH_TMP"
  cd $AWS_CLI_PATH
  aws ec2 describe-instances --query 'Reservations[].Instances[].InstanceId' --filters "Name=tag:Name,Values=$INSTANCE_NAME" --region $INSTANCE_REGION |jq .[] | tr -d \" > $IMAGES_PATH_TMP
  echo "INFO> waiting while file with id instnaces is created " && sleep 30s
  echo "INFO> File with Id instances " && cat $IMAGES_PATH_TMP && echo " "
}

#################### MAIN #########################

CLOUD_TYPE=$1
echo "***********[Bash Script]*************"
echo "*   Get Instance Id on $CLOUD_TYPE  *"
echo "*************************************"

case "$CLOUD_TYPE" in
    azure)
        AZ_CLI_PATH=$2
        INSTANCE_NAME=$3
        IMAGES_PATH_TMP=$5
        getInstanceIdsAzure $AZ_CLI_PATH $INSTANCE_NAME $IMAGES_PATH_TMP
        ;;
    aws)
       AWS_CLI_PATH=$2
       INSTANCE_NAME=$3
       INSTANCE_REGION=$4
       IMAGES_PATH_TMP=$5
       getInstanceIdsAws $AWS_CLI_PATH $INSTANCE_NAME $INSTANCE_REGION $IMAGES_PATH_TMP
       ;;
    *)
       echo " ERROR! the script has no support : $CLOUD_TYPE "
       exit 1
       ;;
esac
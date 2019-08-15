#!/usr/bin/env bash
# @autor: Eynar Pari
# @date : 18/06/2018

getPublicIpAzure(){
   INSTANCE_NAME=$1
   IP_PATH_TMP=$2
   echo "@params_az INSTANCE_NAME=$INSTANCE_NAME"
   echo "@params_az IP_PATH_TMP=$IP_PATH_TMP"
   az vm list-ip-addresses | jq  ' .[].virtualMachine | select ( .name | contains("'${INSTANCE_NAME}'")) | .network.publicIpAddresses[].ipAddress' | tr -d \" > $IP_PATH_TMP
   echo "INFO> waiting while file with ips is created " && sleep 30s
   echo "INFO> File with IPs " && cat $IP_PATH_TMP && echo " "
}

getPublicIpAws(){
    KEY_PEM_PATH=$1
    INSTANCE_NAME=$2
    INSTANCE_REGION=$3
    IP_PATH_TMP=$4
    echo "@params_aws KEY_PEM_PATH=$KEY_PEM_PATH"
    echo "@params_aws INSTANCE_NAME=$INSTANCE_NAME"
    echo "@params_aws INSTANCE_REGION=$INSTANCE_REGION"
    echo "@params_aws IP_PATH_TMP=$IP_PATH_TMP"
    aws ec2 describe-instances --query 'Reservations[].Instances[].NetworkInterfaces[].PrivateIpAddresses[].Association.PublicIp' --filters "Name=tag:Name,Values=$INSTANCE_NAME" --region $INSTANCE_REGION |jq .[] | tr -d \" > $IP_PATH_TMP
    echo "INFO> waiting while file with ips is created " && sleep 30s
    echo "INFO> File with IPs " && cat $IP_PATH_TMP && echo " "
}

############# MAIN ################
CLOUD_TYPE=$1
echo "************[Bash Script]***********"
echo "*   Get Public Ips on $CLOUD_TYPE  *"
echo "************************************"
case "$CLOUD_TYPE" in
    azure)
        INSTANCE_NAME=$3
        IP_PATH_TMP=$5
        getPublicIpAzure $INSTANCE_NAME $IP_PATH_TMP
        ;;
    aws)
        KEY_PEM_PATH=$2
        INSTANCE_NAME=$3
        INSTANCE_REGION=$4
        IP_PATH_TMP=$5
        getPublicIpAws $KEY_PEM_PATH $INSTANCE_NAME $INSTANCE_REGION $IP_PATH_TMP
        ;;
    *)
       echo " ERROR! the script has no support : $CLOUD_TYPE "
       exit 1
       ;;
esac
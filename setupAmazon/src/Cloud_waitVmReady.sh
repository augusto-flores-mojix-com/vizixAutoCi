#!/usr/bin/env bash
# @autor: Eynar Pari
# @date : 18/06/2018

waitVmReadyAzure(){
    PATH_AZ_CLI=$1
    NUMBER_VM=$2
    TAG_NAME=$3
    echo "@params_az PATH_AZ_CLI=$PATH_AZ_CLI"
    echo "@params_az NUMBER_VM=$NUMBER_VM"
    echo "@params_az TAG_NAME=$TAG_NAME"

    cd $PATH_AZ_CLI
    powerState=0
    while [ $powerState != $NUMBER_VM ]; do
        echo "INFO > waiting for machines are ready to use, with status VM running"
        sleep 30
        powerState=$(az vm list -d | jq '.[] | select ( .name | contains ("'${TAG_NAME}'")) | .powerState ' | grep -c "running")
        echo "INFO > number virtual machine on azure ready [$powerState] of [$NUMBER_VM] "
    done
}

#@params
# $1 - PATH_AWS_CLI String : path aws cli (i.e.: /tmp/aws/)
# $2 - NUMBER_VM Int : number virtual machines (i.e: 5)
# $3 - TAG_NAME String : tag name for the virtual machines
waitVmReadyAws(){
    PATH_AWS_CLI=$1
    NUMBER_VM=$2
    TAG_NAME=$3
    local RANDOM_VALUE=$(($(date +%s%N)/1000000))
    local INSTANCE_NAME=/tmp/IdinstancesByName$RANDOM_VALUE.txt
    local INSTANCE_ID=/tmp/instancesId$RANDOM_VALUE.txt

    echo "@params_aws PATH_AWS_CLI=$PATH_AWS_CLI"
    echo "@params_aws NUMBER_VM=$NUMBER_VM"
    echo "@params_aws TAG_NAME=$TAG_NAME"
    cd $PATH_AWS_CLI
    local InstanceStatus=0
    local SystemStatus=0
     while [ $InstanceStatus != $NUMBER_VM ]; do
        echo "INFO > waiting for machines are ready to use"
        sleep 30
        aws ec2 describe-instances --query 'Reservations[].Instances[]' --filters 'Name=tag:Name,Values="'${TAG_NAME}'"' 'Name=instance-state-code,Values=16'|jq .[].InstanceId > $INSTANCE_NAME
        sleep 10
        aws ec2 describe-instance-status --query 'InstanceStatuses[].InstanceId' --filter 'Name=instance-status.reachability,Values=passed' 'Name=system-status.reachability,Values=passed'|jq .[]>$INSTANCE_ID
        InstanceStatus=$(grep -c -F -x -f $INSTANCE_ID $INSTANCE_NAME)
        if [ -z "$InstanceStatus" ]
        then
          echo "INFO> instance found [0] ..... , InstanceStatus is defined as [0]"
          InstanceStatus=0
        fi
        echo "INFO > number Instances on aws ready [$InstanceStatus] of [$NUMBER_VM] "
    done
}

################## MAIN ######################

CLOUD_TYPE=$1
echo "************[Bash Script]***********"
echo "*   Wait Vm Ready on $CLOUD_TYPE   *"
echo "************************************"
case "$CLOUD_TYPE" in
    azure)
        PATH_AZ_CLI=$2
        NUMBER_VM=$3
        TAG_NAME=$4
        waitVmReadyAzure $PATH_AZ_CLI $NUMBER_VM $TAG_NAME
        ;;
    aws)
        PATH_AWS_CLI=$2
        NUMBER_VM=$3
        TAG_NAME=$4
        waitVmReadyAws $PATH_AWS_CLI $NUMBER_VM $TAG_NAME
        ;;
    *)
        echo " ERROR! the script has no support : $CLOUD_TYPE "
        exit 1
        ;;
esac
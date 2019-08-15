#!/bin/bash



#@params
# $1 String path of pem file (i.e.: /tmp/pems/)
# name of the container i.e mongo
# $3 String path of ips.txt (i.e.: /tmp/ips.txt)
# $4 path of vizix-qa-automation-ci
# $5 path of the logs


isItCopied=1
get_json_files(){

    counter=$(awk 'END{print NR}' $3)
    echo $counter

    for i in `seq 1 $counter`; do
        line=$(awk 'NR=='"$i"'{print $1}' $3)
        echo "Search on : $line"
        get_rp_mongoinjector $1 $2 $line $4 $5
        echo "still ..."
    done

}


#@params
# $1 String path of pem file (i.e.: /tmp/pems/)
# $2 name of the container i.e mongo
# $3 String ip
# $4 path of vizix-qa-automation-ci
# $5 path of the logs

get_rp_mongoinjector(){
echo $2
CONTAINER=$2
ssh -n -i $1/awsqa.pem ubuntu@$3 "sh -c 'sudo pip install docker'"
ssh -n -i $1/awsqa.pem ubuntu@$3 "sh -c 'cd $4 && sleep 1 && pwd && sudo python get_logs_by_container.py $CONTAINER '"
scp -i $1/awsqa.pem ubuntu@$3:/tmp/*.tar.gz $5 ;
}

#@params
#$1 path of the logs
uncompress(){
cd $1
for a in $(ls -1 *.tar.gz);
do
tar -zxvf $a;
cd $a
cat  *.txt > ALL$a.txt
done
}
get_json_files $1 $2 $3 $4 $5
uncompress $5

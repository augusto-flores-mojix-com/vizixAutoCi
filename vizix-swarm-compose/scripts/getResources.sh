#!/bin/bash

#@params
# $1 String path of pem file (i.e.: /tmp/pems/)
# $2 String path of ips.txt (i.e.: /tmp/ips.txt)
# $3 path of the resources


isItCopied=1
get_json_files(){

    counter=$(awk 'END{print NR}' $2)
    echo $counter

    for i in `seq 1 $counter`; do
        line=$(awk 'NR=='"$i"'{print $1}' $2)
        echo "Search on : $line"
        get_resources $1 $line $3
        echo "still ..."
    done

}


#@params
# $1 String path of pem file (i.e.: /tmp/pems/)
# $2 String ip
# $3 path of the resources

get_resources(){

ssh -n -i $1/awsqa.pem ubuntu@$2 "sh -c 'cd /home && tar -zcvf metrics.tar.gz metrics.txt '"
scp -i $1/awsqa.pem ubuntu@$3:/tmp/*.tar.gz $3 ;
}

#@params
#$1 path of the logs
uncompress(){
cd $1
for a in $(ls -1 *.tar.gz); do tar -zxvf $a; done
}

get_resources $1 $2 $3
uncompress $3

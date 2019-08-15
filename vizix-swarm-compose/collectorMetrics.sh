#
# collector metrics
# configure a file path
#
FILE_OUTPUT=/home/metrics.txt
rm -rf $FILE_OUTPUT
echo "name,cpu%,memory_usage,mem%,net_i,net_o,block_i,block_o,time" > $FILE_OUTPUT
while :
do
   echo "collecting data ...."
   sleep 5
   docker stats --format "table {{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.MemPerc}},{{.NetIO}},{{.BlockIO}}" --no-stream | sed 's/\//,/g' | sed -n '1!p'| sed 's/MiB/MB/g' | sed 's/GiB/GB/g' | sed 's/kB/KB/g'| sed 's/%//g' | sed "s/$/\t,$(date +%s)000/" >> $FILE_OUTPUT
done


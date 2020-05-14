#!/bin/sh

REDIS_HOME=$HOME/redis; export REDIS_HOME

### start redis cluster ##########################################################

logfile="$HOME/redis/log/rc-manage.log"

echo `date +'%F %T'` " * " "Begin to start redis cluster on user [ " `id -un` " ]" | tee -a $logfile

if [ ! -d $REDIS_HOME/conf ]
then
    echo `date +'%F %T'` " * " "...................................Start failed: no dir [ $HOME/conf ]" | tee -a $logfile
    exit 0
fi

nodes=""
for file in `ls $REDIS_HOME/conf/*.conf`
do
    datadir=`grep "^dir " $file|awk -F " " '{print $2}'`
    nodeconf=`grep "^cluster-config-file " $file|awk -F " " '{print $2}'`
    confname=$datadir"/"$nodeconf
    confname=`echo $confname|sed 's/"//g'`
    info=`cat $confname|grep -v currentEpoch|awk -F " " '{print $2}'`
    nodes=$nodes" "$info
done

for tt in `echo $nodes|tr -s " " "\n"|sort -u`
do
    ip=`echo $tt|awk -F ":" '{print $1}'`
    port=`echo $tt|awk -F ":" '{print $2}'|awk -F "@" '{print $1}'`

    if [ "$port" = "" ]
    then
        echo "port is null"
    else
        if [ "$ip" = "" ]
        then
            echo `date +'%F %T'` " * " " Start redis node [ $tt ] by [ redis-server redis-$port.conf ]" | tee -a $logfile
            $REDIS_HOME/bin/redis-server $HOME/redis/conf/redis-$port.conf
        else
            echo `date +'%F %T'` " * " " Start redis node [ $tt ] by [ ssh $ip redis-server redis-$port.conf ]" | tee -a $logfile
            ssh $ip $REDIS_HOME/bin/redis-server $HOME/redis/conf/redis-$port.conf          
        fi
    fi
done

echo `date +'%F %T'` " * " "...................................Start done" | tee -a $logfile

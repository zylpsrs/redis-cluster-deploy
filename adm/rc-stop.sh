#!/bin/sh

REDIS_HOME=$HOME/redis; export REDIS_HOME
REDIS_PWD=gXe1O9m^s

### stop redis cluster ##########################################################

logfile="$REDIS_HOME/log/rc-manage.log"

echo `date +'%F %T'` " * " "Begin to stop redis cluster on user [ " `id -un` " ]" | tee -a $logfile

if [ ! -d $REDIS_HOME/conf ]
then
    echo `date +'%F %T'` " * " "...................................Stop failed: no dir [ $HOME/conf ]" | tee -a $logfile
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
        echo `date +'%F %T'` " * " " Shutdown redis node [ $ip:$port ]" | tee -a $logfile
        if [ "$ip" = "" ]
        then
            $REDIS_HOME/bin/redis-cli -a "$REDIS_PWD" -p $port shutdown save &>/dev/null
        else
            $REDIS_HOME/bin/redis-cli -a "$REDIS_PWD" -h $ip -p $port shutdown save &>/dev/null
        fi
    fi
done

echo `date +'%F %T'` " * " "...................................Stop done" | tee -a $logfile

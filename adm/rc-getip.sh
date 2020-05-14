#!/bin/sh

if [ ! -d $HOME/redis/conf ]
then
    echo "There isn't redis cluster config"
    exit 1
fi

nodes=""
for file in `ls $HOME/redis/conf/*.conf`
do
    datadir=`grep "^dir " $file|awk -F " " '{print $2}'`
    nodeconf=`grep "^cluster-config-file " $file|awk -F " " '{print $2}'`
    confname=$datadir"/"$nodeconf
    confname=`echo $confname|sed 's/"//g'`
    if [ -e $confname ]
    then
        info=`cat $confname|grep -v currentEpoch|awk -F " " '{print $2}'`
        nodes=$nodes" "$info
    fi
done

hostip=""
for tt in `echo $nodes|tr -s " " "\n"|sort -u`
do
    ip=`echo $tt|awk -F ":" '{print $1}'`
    hostip=$hostip" "$ip
done

if [ "$hostip" = "" ]
then
    echo "There isn't redis cluster info"
    exit 2
else
    res=""
    for tt in `echo $hostip|tr -s " " "\n"|sort -u`
    do
        if [ "$tt" != "" ]
        then
            if [ "$res" = "" ]
            then
                res=$tt
            else
                res=$res","$tt
            fi
        fi
    done
    echo $res
fi

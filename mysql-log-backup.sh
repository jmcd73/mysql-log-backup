#!/bin/sh

LOG_DIR=$HOME/mysql-log-backup/ln09-logs

[ -d $LOG_DIR ] || mkdir -p $LOG_DIR

cd $LOG_DIR

LOGIN_PATH=logShipper

MYSQL_HOST=192.168.0.15

LAST_LOG=$(ls -1 $LOG_DIR/mysql-bin.* 2>/dev/null | tail -n 1)

if [ -z $LAST_LOG ]; then

    echo No mysql-bin files found in
    echo $LOG_DIR/
    logger -t MYSQLBINLOG You cant run this without having some mysql-bin.* log files in \$LOG_DIR
    echo Use touch mysql-bin.000XX to create the last log file to begin pulling from the MYSQL_SERVER
    echo and re-run this script
    exit 0
fi

LAST_LOG=$(basename $LAST_LOG)

logger -t MYSQLBINLOG Starting replication from $LAST_LOG

mysqlbinlog --login-path=$LOGIN_PATH --read-from-remote-server \
    --host=$MYSQL_HOST \
    --raw --stop-never \
    $LAST_LOG

logger -t MYSQLBINLOG Process ended

#!/bin/sh

LOG_DIR=$HOME/mysql-log-backup/ln09-logs

cd $LOG_DIR

LOGIN_PATH=logShipper

MYSQL_HOST=192.168.0.15

LAST_LOG=$(ls -1 $LOG_DIR/mysql-bin.* | tail -n 1)

LAST_LOG=$(basename $LAST_LOG)

mysqlbinlog --login-path=$LOGIN_PATH --read-from-remote-server \
    --host=$MYSQL_HOST \
    --raw --stop-never \
    $LAST_LOG

#!/bin/sh

LOG_DIR=$HOME/mysql-log-backup/bin-logs

cd $LOG_DIR

LOGIN_PATH=BINLOG_SHIPPER_LPATH

# create login path using
# mysql_config_editor set --login-path=BINLOG_SHIPPER_LPATH --host=10.11.12.13 --user=binlogShipper --password

MYSQL_HOST=10.11.12.13

# BINLOG_SHIPPER_USER user muse have REPLICATION CLIENT & REPLICATION SLAVE permissions on Remote server
LAST_LOG=$(echo "SHOW BINARY LOGS;" | mysql --login-path=BINLOG_SHIPPER_LPATH  | sed -n '2 p' | awk '{print $1}');
echo $LAST_LOG

mysqlbinlog --login-path=$LOGIN_PATH --read-from-remote-server \
    --host=$MYSQL_HOST \
    --raw --stop-never \
    $LAST_LOG

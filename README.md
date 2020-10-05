# MySQL Binary Log Backup

## Backup Setup

## Create Login Path 
You need mysql server not mariadb to use the `mysql_config_editor`

In order not to embed passwords in the system use the mysql_config_editor to create a login-path


## On the MYSQL Server

## Add a backup user and create a login-path so you can reference the credentials in the crontab

```
mysql_config_editor set --login-path=BACKUP_USER_LPATH --host=10.11.12.13 --user=backupUser --password

```

## Create Regular backups from MySQL

Create an automated backup with crontab

```
# m h 
5 */6 * * * /usr/bin/mysqldump --login-path=BACKUP_USER_LPATH --single-transaction --flush-logs --master-data=2 --opt palletsdb | gzip -c > /u1/backup/palletsdb/palletsdb-`date '+\%Y\%m\%d\%H\%M'`.sql.gz
```

## Using MYSQLBINLOG to do real-time log backups

The objective is to ship in real-time the BINARY LOGS from MYSQL_SERVER to BACKUP_SERVER so in the event of losing MYSQL_SERVER you can recover to the last successful transaction

MYSQL_SERVER ====> BACKUP_SERVER

The BACKUP_SERVER would ideally be:

- Not on the same disk array as your MYSQL_SERVER so after a total hardware failure you still have the logs and DB backups

## Check both the MYSQL_SERVER and BACKUP_SERVER have the same version of MySQL

On the BACKUP_SERVER install the same version of MySQL you have on the MYSQL_SERVER

```
mysql --version
mysql  Ver 14.14 Distrib 5.7.29, for Linux (x86_64) using  EditLine wrapper
# they should both be 5.x or 8.x 
```

```
git clone https://github.com/jmcd73/mysql-log-backup

```

Add a MySQL User Account on the MYSQL_SERVER so the backup script on BACKUP_SERVER can login

https://dev.mysql.com/doc/refman/8.0/en/replication-howto-repuser.html

```
mysql> CREATE USER 'binLogShipper'@'%' IDENTIFIED BY 'MyComplexPassword';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'binLogShipper'@'%';
mysql> GRANT REPLICATION USER ON *.* TO 'binLogShipper'@'%';

```



```
mysql_config_editor set --login-path BINLOG_SHIPPER_LPATH --user=binLogShipper --host=10.11.12.13 --password

```

To check the values of the `~/.mylogin.cnf` file

```
mysql_config_editor  print --all=true

[BINLOG_SHIPPER_LPATH]
user = binlogShipper
password = *****
host = 10.11.12.13

```

Use the value you specify for `--login-path` in the mysql-log-backup.sh script

```sh
# ...
LOGIN_PATH=BINLOG_SHIPPER_LPATH
# ...
```

## Install supervisor on the BACKUP_SERVER and copy the supervisor conf file to the right directory

```
apt-get install supervisor
cp mysql-log-backup.conf /etc/supervisor/conf.d

# restart supervisor
# use supervisorctl
supervisorctl
reload
restart all
```

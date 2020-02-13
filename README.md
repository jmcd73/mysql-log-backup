# MySQL Binary Log Backup

## Backup Setup

## Create Regular backups from MySQL

In order not to embed passwords in the system use the mysql_config_editor to create a login-path

```
5 */6 * * * /usr/bin/mysqldump --login-path=wmsBackupAlias --single-transaction --flush-logs --master-data=2 --opt pallets | gzip -c > /u1/backup/palletsdb/pallets-`date '+\%Y\%m\%d\%H\%M'`.sql.gz
```

## Using MYSQLBINLOG to do real-time log backups

The objective is to ship in real-time the BINARY LOGS from MYSQL_SERVER to BACKUP_SERVER so in the event of losing MYSQL_SERVER you can recover to the last successful transaction

MYSQL_SERVER <====> BACKUP_SERVER

The BACKUP_SERVER would ideally be:

- Not on the same disk array as your MYSQL_SERVER so after a total hardware failure you still have the logs and DB backups

On the BACKUP_SERVER install the same version of MySQL you have on the MYSQL_SERVER

```
mysql --version
mysql  Ver 14.14 Distrib 5.7.29, for Linux (x86_64) using  EditLine wrapper
```

```
git clone <this repo>
```

Add a MySQL User Account on the MYSQL_SERVER so the backup script on BACKUP_SERVER can login

https://dev.mysql.com/doc/refman/8.0/en/replication-howto-repuser.html

```
mysql> CREATE USER 'replication'@'%.example.com' IDENTIFIED BY 'password';
mysql> GRANT REPLICATION SLAVE ON *.* TO 'replication'@'%.example.com';
```

Check the values of the `~/.mylogin.cnf` files

```
mysql_config_editor  print --all=true
```

Add the account details to `~/.mylogin.cnf`

```
mysql_config_editor set --login-path BINLOG_SHIPPER --user 'replication'@'apf-ma-ln06.apfoods.local' -p --host 192.168.0.15
```

Use the value you specify for `--login-path` in the mysql-log-backup.sh script

```sh
LOGIN_PATH=BINLOG_SHIPPER
```

Install supervisor on the BACKUP_SERVER and copy the supervisor conf file to the right directory

```
apt-get install supervisor
cp mysql-log-backup.conf /etc/supervisor/conf.d

# restart supervisor
# use supervisorctl
supervisorctl
reload
restart all
```

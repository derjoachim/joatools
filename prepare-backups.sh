#!/bin/bash

CURRENTDATE=`date +"%Y-%m-%d"`

echo "Collecting package list"
echo "-----------------------"
trizen -Qqet > ~/backups/pacman/package_list_`hostname`_$CURRENTDATE

echo "Backupping pacman database"
echo "--------------------------"
tar -cjf ~/backups/pacman/pacman_database_$CURRENTDATE.tar.bz2 /var/lib/pacman/local

echo "Dumping MariaDB databases"
echo "-------------------------"

mysqldump -u root -p --all-databases > ~/backups/mariadb/backups-$CURRENTDATE.sql
bzip2 -9 ~/backups/mariadb/backups-$CURRENTDATE.sql

#echo "Cleaning up old backup files"
#echo "----------------------------"
#cd ~/backups/pacman
#find . -mtime +30 -delete

echo "Done"

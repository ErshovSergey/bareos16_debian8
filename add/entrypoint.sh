#!/bin/bash
set -e

# если папка с конфигами пуста
if [ `cd /SHARE_DIR && ls -a | wc -l` -eq 2 ]; then
# копируем файлы из дистрибутива
  mkdir /SHARE_DIR/etc-bareos
  cp -pR /etc/bareos.orig/* /SHARE_DIR/etc-bareos/
  rm -rf /SHARE_DIR/etc-bareos/bareos-sd.d

  mkdir /SHARE_DIR/MySQL_database
  chown -R mysql:mysql /SHARE_DIR/MySQL_database

  # копируем БД по умолчанию
  cp -pR /var/lib/mysql/* /SHARE_DIR/MySQL_database/

  /etc/init.d/mysql start

  #создаем базу данных
  /usr/lib/bareos/scripts/create_bareos_database
  /usr/lib/bareos/scripts/make_bareos_tables
  /usr/lib/bareos/scripts/grant_bareos_privileges
fi

##
touch        /SHARE_DIR/bareos.log /SHARE_DIR/msmtp.log /SHARE_DIR/bareos-audit.log
chmod 644    /SHARE_DIR/bareos.log /SHARE_DIR/msmtp.log /SHARE_DIR/bareos-audit.log
chown bareos /SHARE_DIR/bareos.log /SHARE_DIR/msmtp.log /SHARE_DIR/bareos-audit.log

##  sendmail заменяем на msmtp
[ ! -f /SHARE_DIR/msmtprc ] && cp /DEFAULT/msmtprc /SHARE_DIR/msmtprc
ln -sf /SHARE_DIR/msmtprc /etc/msmtprc

## пароль bareos-webui
[ ! -f /SHARE_DIR/web-admin.conf ] && cp /DEFAULT/web-admin.conf /SHARE_DIR/web-admin.conf
[ -f /etc/bareos/bareos-dir.d/console/admin.conf ] && rm /etc/bareos/bareos-dir.d/console/admin.conf
ln -sf /SHARE_DIR/web-admin.conf /etc/bareos/bareos-dir.d/console/admin.conf

##
[[ `service mysql status |grep "MySQL is stopped"` ]] && service mysql start

service apache2 start
service bareos-dir start
service bareos-fd start

sleep infinity


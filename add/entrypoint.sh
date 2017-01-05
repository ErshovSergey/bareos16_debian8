#!/bin/bash
set -e

echo
echo "++++++++++++++++++++ Starting container ++++++++++++++++++++"
# Time zone
echo "Europe/Moscow" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata


start_mysql (){
  if  ! pgrep 'mysqld_safe'>/dev/null ; then
    echo "  Start MySQL"
    trap "mysqladmin shutdown" TERM
    dpkg-reconfigure mysql-server-5.5
    mysqld_safe --bind-address=0.0.0.0 --user=mysql --skip-syslog &
    sleep 10
  fi
}

SHARE_DIR="/SHARE_DIR"
# если папка с конфигами пуста
if [[  -z "`ls $SHARE_DIR`" ]]; then
  echo "  Default settings"
  # копируем файлы из дистрибутива
  cp -pR /SHARE_DIR-default/* "$SHARE_DIR"
  cp -pR /etc/bareos.orig/*   "$SHARE_DIR"/etc-bareos/
  # БД по умолчанию
  mkdir -p "$SHARE_DIR"/MySQL_database && /bin/chown -R mysql:mysql "$SHARE_DIR"/MySQL_database

  #
  touch        "$SHARE_DIR"/bareos.log "$SHARE_DIR"/msmtp.log "$SHARE_DIR"/bareos-audit.log
  chmod 644    "$SHARE_DIR"/bareos.log "$SHARE_DIR"/msmtp.log "$SHARE_DIR"/bareos-audit.log
  chown bareos "$SHARE_DIR"/bareos.log "$SHARE_DIR"/msmtp.log "$SHARE_DIR"/bareos-audit.log

  /usr/bin/mysql_install_db --force --user=mysql --datadir=/SHARE_DIR/MySQL_database
  start_mysql

  echo "  Create bareos database"
  /usr/lib/bareos/scripts/create_bareos_database  mysql
  /usr/lib/bareos/scripts/make_bareos_tables      mysql
  /usr/lib/bareos/scripts/grant_bareos_privileges mysql
fi

start_mysql
echo "  Start apache2"
service apache2 start
echo "  Start bareos-dir"
service bareos-dir start
echo "  Start bareos-fd"
service bareos-fd start

wait
sleep infinity


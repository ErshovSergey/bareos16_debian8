FROM debian:jessie

ENV TERM linux

ENV DEBIAN_FRONTEND noninteractive

ENTRYPOINT ["/entrypoint.sh"]

RUN export DEBIAN_FRONTEND='noninteractive' \
  && apt-get update -qqy && apt-get upgrade -qqy \
## Set LOCALE to UTF8
  && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
  && echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen  \
  && apt-get install -yqq  --no-install-recommends --no-install-suggests locales \
  && echo "LANG=\"ru_RU.UTF-8\"" > /etc/default/locale \
  && echo "LC_ALL=\"ru_RU.UTF-8\"" >> /etc/default/locale \
  && locale-gen ru_RU.UTF-8 \
  && export LANG=ru_RU.UTF-8 \
  # удаляем все локали кроме этих
  && locale-gen --purge ru_RU.UTF-8 en_US.UTF-8 \
  && apt-get install --no-install-recommends -yqq wget \
# for debug
#  && apt-get install --no-install-recommends -yqq \
#                     nano telnet procps \
#  && echo "\nexport TERM=xterm" >> ~/.bashrc \
  && export DIST=Debian_8.0 \
  && URL=http://download.bareos.org/bareos/release/latest/$DIST/ && export URL \
  && echo "deb $URL /\n" > /etc/apt/sources.list.d/bareos.list \
  && wget -q $URL/Release.key -O- | apt-key add - \
# install Bareos packages
  && apt-get update \
  && apt-get install --no-install-recommends -yqq bareos-database-tools bareos-database-common \
  && apt-get install --no-install-recommends -yqq bareos-director bareos-filedaemon bareos-webui bareos-database-mysql \
                                                  mysql-server msmtp \
  && rm -rf /var/lib/mysql \
  && apt-get remove wget -yqq \
  && mkdir /SHARE_DIR \
## пароль bareos-webui
  && ln -sf /SHARE_DIR/web-admin.conf /etc/bareos/bareos-dir.d/console/admin.conf \
# /etc/bareos
  && rm -rf /etc/bareos/bareos-sd.d /etc/bareos/bareos-dir-export \
#  dbdriver = mysql
  && sed -i -e "s|dbdriver.*|dbdriver = mysql|" /etc/bareos/bareos-dir.d/catalog/MyCatalog.conf \
  && mv /etc/bareos /etc/bareos.orig \
  && ln -s /SHARE_DIR/etc-bareos /etc/bareos \
# replace sendmail
  && rm /usr/sbin/sendmail \
  && ln -s /usr/bin/msmtp /usr/sbin/sendmail \
# MySQL database folder
  && sed -i -e "s|^datadir.*|datadir         = /SHARE_DIR/MySQL_database|" /etc/mysql/my.cnf \
  && sed -i -e "s|^log_error = .*|log_error = /SHARE_DIR/MySQL_database/error.log|" /etc/mysql/my.cnf \
# apache redirect root
  && rm -f /etc/apache2/conf-enabled/bareos-redirect.conf \
  && ln -s /etc/apache2/conf-available/bareos-redirect.conf /etc/apache2/conf-enabled/bareos-redirect.conf \
##  msmtprc
  && rm -f /etc/msmtprc \
  && ln -sf /SHARE_DIR/msmtprc /etc/msmtprc \
  && apt-get autoremove -qqy \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/*

COPY [ "add/", "/" ]


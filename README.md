[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/github.com/ErshovSergey/master/LICENSE) ![Language](https://img.shields.io/badge/language-bash-yellowgreen.svg)
# bareos16_debian8
Резервное копирование, конкретнее [bareos версии16](https://www.bareos.org/en/news/bareos-16-2-4-major-version-released.html) на [Debian 8](https://www.debian.org/releases/stable/).

##Описание
Открытая система резерного копирования  [bareos версии 16](https://www.bareos.org/en/news/bareos-16-2-4-major-version-released.html), точнее director из bareos запускается на обновленном [Debian 8](https://www.debian.org/releases/stable/). Настройки хранятся вне контейнера.
#Эксплуатация данного проекта.
##Клонируем проект
```shell
git clone https://github.com/ErshovSergey/bareos16_debian8.git
```
##Собираем
```shell
cd bareos16_debian8/
docker build --rm=true --force-rm --tag=ershov/bareos16-debian8 .
```
Создаем папку для хранения настроек, логов и отчетов вне контейнера
```shell
export SHARE_DIR="/var/lib/mnt_point/4Tb/docker/bareos" && mkdir -p $SHARE_DIR
```
Правим файлы настроек:
 - *$/SHARE_DIR/msmtprc* - настройки **msmtp** для отправки почты от bareos
 - *$SHARE_DIR//SHARE_DIR/web-admin.conf* - пароль от web-консоли
 - *$SHARE_DIR/credetinals/videoserverd.config* - камеры, логи

##Запускаем
Определяем ip адрес на котором будет доступна web-управление и папку для хранения БД и конфигурационных файлов
```shell
export ip_addr=192.168.100.240
docker run -d --name bareos16-debian8 --restart=always \
-p $ip_addr:33081:80 \
-h bareos \
-v $SHARE_DIR:/SHARE_DIR \
ershov/bareos16-debian8
```

###Перечитать конф.файлы директора **bareos-dir**
```shell
docker exec -i -t bareos16-debian8 /etc/init.d/bareos-dir reload
```
##Удалить контейнер
```shell
docker stop bareos16-debian8 && docker rm -v bareos16-debian8
```
Если файлов настройки не существуют - используются файлы "по-умолчанию".
### <i class="icon-upload"></i>Ссылки
 - [bareos версии 16](https://www.bareos.org/en/news/bareos-16-2-4-major-version-released.html)
 - [Debian 8](https://www.debian.org/releases/stable/)
 - [docker](https://www.docker.com/)
 - [Запись в блоге](https://)
 - [Редактор readme.md](https://stackedit.io/)

### <i class="icon-refresh"></i>Лицензия MIT

> Copyright (c) 2016 &lt;[ErshovSergey](http://github.com/ErshovSergey/)&gt;

> Данная лицензия разрешает лицам, получившим копию данного программного обеспечения и сопутствующей документации (в дальнейшем именуемыми «Программное Обеспечение»), безвозмездно использовать Программное Обеспечение без ограничений, включая неограниченное право на использование, копирование, изменение, добавление, публикацию, распространение, сублицензирование и/или продажу копий Программного Обеспечения, также как и лицам, которым предоставляется данное Программное Обеспечение, при соблюдении следующих условий:

> Указанное выше уведомление об авторском праве и данные условия должны быть включены во все копии или значимые части данного Программного Обеспечения.

> ДАННОЕ ПРОГРАММНОЕ ОБЕСПЕЧЕНИЕ ПРЕДОСТАВЛЯЕТСЯ «КАК ЕСТЬ», БЕЗ КАКИХ-ЛИБО ГАРАНТИЙ, ЯВНО ВЫРАЖЕННЫХ ИЛИ ПОДРАЗУМЕВАЕМЫХ, ВКЛЮЧАЯ, НО НЕ ОГРАНИЧИВАЯСЬ ГАРАНТИЯМИ ТОВАРНОЙ ПРИГОДНОСТИ, СООТВЕТСТВИЯ ПО ЕГО КОНКРЕТНОМУ НАЗНАЧЕНИЮ И ОТСУТСТВИЯ НАРУШЕНИЙ ПРАВ. НИ В КАКОМ СЛУЧАЕ АВТОРЫ ИЛИ ПРАВООБЛАДАТЕЛИ НЕ НЕСУТ ОТВЕТСТВЕННОСТИ ПО ИСКАМ О ВОЗМЕЩЕНИИ УЩЕРБА, УБЫТКОВ ИЛИ ДРУГИХ ТРЕБОВАНИЙ ПО ДЕЙСТВУЮЩИМ КОНТРАКТАМ, ДЕЛИКТАМ ИЛИ ИНОМУ, ВОЗНИКШИМ ИЗ, ИМЕЮЩИМ ПРИЧИНОЙ ИЛИ СВЯЗАННЫМ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ ИЛИ ИСПОЛЬЗОВАНИЕМ ПРОГРАММНОГО ОБЕСПЕЧЕНИЯ ИЛИ ИНЫМИ ДЕЙСТВИЯМИ С ПРОГРАММНЫМ ОБЕСПЕЧЕНИЕМ.


Docker container for Observium Community Edition

It requires option of e.g. '--link observiumdb:observiumdb' with another MySQL or MariaDB container

Usage:
Either follow the choice A. or B. below to run Observium.

A. Manual Run Containers

Download observium-mysql-init.sh file for use with MySQL or MariaDB container from https://github.com/somsakc/observium. Place it under e.g. /home/docker/observium/mysql directory.

Run MySQL or MariaDB container
$ docker run --name observiumdb -v /home/docker/observium/db:/var/lib/mysql \

 -v /home/docker/observium/mysql:/docker-entrypoint-initdb.d \
 -e MYSQL_ROOT_PASSWORD=passw0rd \
 -e MYSQL_USER=observium \
 -e MYSQL_PASSWORD=passw0rd \
 -e MYSQL_DB_NAME=observium mariadb
Run this Observium container
$ mkdir /home/docker/observium/db
$ mkdir /home/docker/observium/lock
$ docker run --name observiumapp -it --link observiumdb:observiumdb \

 -v /home/docker/observium/lock:/opt/observium/lock \
 -e OBSERVIUM_ADMIN_USER=admin \
 -e OBSERVIUM_ADMIN_PASS=passw0rd \
 -e OBSERVIUM_DB_HOST=observiumdb \
 -e OBSERVIUM_DB_USER=observium \
 -e OBSERVIUM_DB_PASS=passw0rd \
 -e OBSERVIUM_DB_NAME=observium \
 -p 80:80 somsakc/observium
B. Use Docker Composer

Download observium-mysql-init.sh file for use with MySQL or MariaDB container and docker-compose.yml file from https://github.com/somsakc/observium.

For given files in github, place files and create extra directories as below.
$ cd /home/docker
$ mkdir -p observium
$ cd observium
$ mkdir db lock mysql

Place docker-compose.yml into /home/docker/observium directory.
Place observium-mysql-init.sh into /home/docker/mysql directory.

And let's go on current directory of /home/docker ...
$ docker-compose up

See source of project at https://github.com/somsakc/observium

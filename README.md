# Docker container for Observium Community Edition
Observium is network monitoring with intuition. It is a low-maintenance auto-discovering network monitoring platform supporting a wide range of device types, platforms and operating systems including Cisco, Windows, Linux, HP, Juniper, Dell, FreeBSD, Brocade, Netscaler, NetApp and many more. Observium focuses on providing a beautiful and powerful yet simple and intuitive interface to the health and status of your network. For more information, go to http://www.observium.org site.

Available platform are:-
* AMD64 (Intel x86_64) https://hub.docker.com/r/mbixtech/observium/
* ARM32v7 (Raspberri Pi 2/3) https://hub.docker.com/r/mbixtech/arm32v7-observium/

## Usage
Either follow the choice A. or B. below to run Observium.

### A. Manual Run Containers
- Prepare working directory for docker containers, for example below.
```
  $ mkdir /home/docker/observium
  $ cd /home/docker/observium
  $ mkidr data logs rrd
```
- Run official MariaDB container
```
  $ docker run --name observiumdb \
    -v /home/docker/observium/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=passw0rd \
    -e MYSQL_USER=observium \
    -e MYSQL_PASSWORD=passw0rd \
    -e MYSQL_DATABASE=observium \
    -e TZ=$(cat /etc/timezone) \
    mariadb
```

- Run this Observium container
```
  $ docker run --name observiumapp --link observiumdb:observiumdb \
    -v /home/docker/observium/logs:/opt/observium/logs \
    -v /home/docker/observium/rrd:/opt/observium/rrd \
    -e OBSERVIUM_ADMIN_USER=admin \
    -e OBSERVIUM_ADMIN_PASS=passw0rd \
    -e OBSERVIUM_DB_HOST=observiumdb \
    -e OBSERVIUM_DB_USER=observium \
    -e OBSERVIUM_DB_PASS=passw0rd \
    -e OBSERVIUM_DB_NAME=observium \
    -e OBSERVIUM_BASE_URL=http://yourserver.yourdomain:8080 \
    -e TZ=Asia/Bangkok
    -p 8080:80
    mbixtech/observium
```

> Note:
> - You must replace passwords specified in environment parameters of both containers with your secure passwords instead.
> - OBSERVIUM_BASE_URL supports AMD64 container only (plan to support ARM32v7 soon).

### B. Use Docker Composer
- Follow instuctions below to create extra working directory of docker containers.
```
  $ mkdir /home/docker/observium
  $ cd /home/docker/observium
  $ mkdir data logs mysql
```
> You can change /home/docker directory to your desired directory and you need to change the volume mapping directories in docker-compose.yml file also.

- Download docker-compose.yml file from https://github.com/somsakc/observium github repository. Then, place docker-compose.yml file into /home/docker/observium directory.

- Run both database and observium containers.
```
  $ docker-compose up
```

## Changes
- [2020-02-16] Enhanced docker image with Observium CE 19.8.10000
  - Revised initial/kickstart script for first time of container running with more information about database initialization.
  - Moved Apache http access and error logs to /opt/observium/logs directory.
  - Added logs of all cron jobs storing in /opt/observium/logs directory. 
  - Added logrotate for rotating logs in /opt/observium/logs directory.
  - Chnaged working directory of container image to /opt/observium for ease of managing Observium inside.
  - Fixed invalid cron parameter specified in supervisord.conf.
  - Revised Dockerfile file.
- [2018-10-28] Added 'Feature request: OBSERVIUM_BASE_URL #3' feature.
- [2017-08-19] Corrected error of "DB Error 1044: Access denied for user 'observium'@'%' to database 'observium'" by replacing MYSQL_DB_NAME environment variable of database container with MYSQL_DATABASE instead (regarding environment definition changed by official mariadb image).
- [2017-08-19] Add Observium image available on Raspberri Pi 2/3 (arm32v7) platform.

## Source Repository
See source of project at https://github.com/somsakc/observium

## Credits
- Official Observium web site [https://www.observium.org]
- Ubuntu installation from Observium web site [https://docs.observium.org/install_debian/]

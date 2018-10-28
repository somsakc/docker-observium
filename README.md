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
  $ docker run --name observiumdb
    -v /home/docker/observium/data:/var/lib/mysql \
    -e MYSQL_ROOT_PASSWORD=passw0rd \
    -e MYSQL_USER=observium \
    -e MYSQL_PASSWORD=passw0rd \
    -e MYSQL_DATABASE=observium
    -e TZ=Asia/Bangkok
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
  $ cd observium
  $ mkdir db lock mysql
```
> You can change /home/docker directory to your desired directory and you need to change the volume mapping directories in docker-compose.yml file also.

- Download docker-compose.yml file from https://github.com/somsakc/observium github repository. Then, place docker-compose.yml file into /home/docker/observium directory.

- Run both database and observium containers.
```
  $ docker-compose up
```

## Changes
- Corrected error of "DB Error 1044: Access denied for user 'observium'@'%' to database 'observium'" by replacing MYSQL_DB_NAME environment variable of database container with MYSQL_DATABASE instead (regarding environment definition changed by official mariadb image).
- Revised docker-compose.yml file and Dockerfile files.
- Add Observium image available on Raspberri Pi 2/3 (arm32v7) platform.

## Source Repository
See source of project at https://github.com/somsakc/observium

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
  $ mkdir -p /home/docker/observium/{data,logs,rrd}
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
- Follow instuctions below to create extra working directory of docker containers (You can change /home/docker directory to your desired directory).
```
  $ cd /home/docker
  $ git clone https://github.com/somsakc/docker-observium.git observium
  $ cd observium
  $ mkdir data logs mysql
```
> Note: You do not need to clone whole git repository. You can download docker-compose.yml file and .env file file. Then, place both files into e.g. /home/docker/observium directory mentioned above.

- Change some environments to your appropreate values in docker-compose.yml file, e.g. OBSERVIUM_ADMIN_USER, OBSERVIUM_ADMIN_PASS.

- Force pulling the latest observium image from docker hub web site. It is to ensure that you will get the latest one.
```
  $ docker-compose pull
```

- Run both database and observium containers.
```
  $ docker-compose up
```

- For your first time, you may add a new device, discover and poll that device. It is given an idea below (I follow https://docs.observium.org/install_debian/#perform-initial-discovery-and-poll).
```
  $ docker-compose exec app /opt/observium/add_device.php <hostname> <community> v2c
  $ docker-compose exec app /opt/observium/discovery.php -h all
  $ docker-compose exec app /opt/observium/poller.php -h all
```

## Changes
- [2021-08-26] Built docker image with Observium CE 20.9.10731 on AMD64 platform only
  - Upgraded base image to ubuntu:20.04
  - Upgraded package to higher version with following Observium installation document, e.g. php-7.4
  - Revised docker-compose.yml file and add .env file for specific project name (see source repository below)
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

## TODOs
I have a lot of plan to enhance this project. However, my work is priority to focus first. I hope I will have more time to do it.
- Enhance more on Kubernetes platform, for both AMD64 and ARM64 (Pi).
- Enhance more with secure TLS to Observium GUI.
- Secure more container image.

## Credits
- Official Observium web site [https://www.observium.org]
- Ubuntu installation from Observium web site [https://docs.observium.org/install_debian/]

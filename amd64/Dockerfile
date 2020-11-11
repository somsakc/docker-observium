# Docker container for Observium Community Edition
#
# It requires option of e.g. '--link observiumdb:observiumdb' with another MySQL or MariaDB container.
# Example usage:
# 1. MySQL or MariaDB container
#    $ mkdir -p /home/docker/observium/data
#    $ docker run --name observiumdb \
#        -v /home/docker/observium/data:/var/lib/mysql \
#        -e MYSQL_ROOT_PASSWORD=passw0rd \
#        -e MYSQL_USER=observium \
#        -e MYSQL_PASSWORD=passw0rd \
#        -e MYSQL_DATABASE=observium \
#        mariadb
#
# 2. This Observium container
#    $ mkdir -p /home/docker/observium/logs /home/docker/observium/rrd
#    $ docker run --name observiumapp --link observiumdb:observiumdb \
#        -v /home/docker/observium/logs:/opt/observium/logs \
#        -v /home/docker/observium/rrd:/opt/observium/rrd \
#        -e OBSERVIUM_ADMIN_USER=admin \
#        -e OBSERVIUM_ADMIN_PASS=passw0rd \
#        -e OBSERVIUM_DB_HOST=observiumdb \
#        -e OBSERVIUM_DB_USER=observium \
#        -e OBSERVIUM_DB_PASS=passw0rd \
#        -e OBSERVIUM_DB_NAME=observium \
#        -e OBSERVIUM_BASE_URL=http://yourserver.yourdomain:80 \
#        -p 8888:80 mbixtech/observium
#
# References:
#  - Follow platform guideline specified in https://github.com/docker-library/official-images
# 

FROM ubuntu:20.04

LABEL maintainer "somsakc@hotmail.com"
LABEL version="1.3"
LABEL description="Docker container for Observium Community Edition"

ARG OBSERVIUM_ADMIN_USER=admin
ARG OBSERVIUM_ADMIN_PASS=passw0rd
ARG OBSERVIUM_DB_HOST=observiumdb
ARG OBSERVIUM_DB_USER=observium
ARG OBSERVIUM_DB_PASS=passw0rd
ARG OBSERVIUM_DB_NAME=observium

# set environment variables
ENV LC_ALL C
ENV OBSERVIUM_DB_HOST=$OBSERVIUM_DB_HOST
ENV OBSERVIUM_DB_USER=$OBSERVIUM_DB_USER
ENV OBSERVIUM_DB_PASS=$OBSERVIUM_DB_PASS
ENV OBSERVIUM_DB_NAME=$OBSERVIUM_DB_NAME

# install prerequisites and cleanup
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update && \
    apt-get -y dist-upgrade
RUN apt install -y libapache2-mod-php7.4 \
                   php7.4-cli \
                   php7.4-mysql \
                   php7.4-mysqli \
                   php7.4-gd \
                   php7.4-json \
                   php-pear \
                   snmp \
                   fping \
                   mysql-server \
                   mysql-client \
                   rrdtool \
                   subversion \
                   whois \
                   mtr-tiny \
                   ipmitool \
                   graphviz \
                   imagemagick \
                   apache2 \
                   python3-mysqldb \
                   python3-pymysql \
                   python-is-python3
RUN apt-get install -y cron \
                       locales \
                       supervisor \
                       wget
RUN apt-get clean && \
    rm -f /etc/apache2/sites-available/* && \
    rm -f /etc/cron.d/* && \
    rm -f /etc/cron.hourly/* && \
    rm -f /etc/cron.daily/* && \
    rm -f /etc/cron.weekly/* && \
    rm -f /etc/cron.monthly/* && \
    rm -f /etc/logrotate.d/* && \
    rm -f /etc/supervisord/conf.d/* && \
    rm -fr /var/log/* && \
    rm -fr /var/www && \
    mkdir /var/log/apache2

# set locale
RUN locale-gen en_US.UTF-8

# install observium package
RUN mkdir -p /opt/observium /opt/observium/logs /opt/observium/rrd && \
    cd /opt && \
    wget http://www.observium.org/observium-community-latest.tar.gz && \
    tar zxvf observium-community-latest.tar.gz && \
    rm -f observium-community-latest.tar.gz

# configure observium package
RUN cd /opt/observium && \
    cp config.php.default config.php && \
    sed -i -e "s/= 'localhost';/= getenv('OBSERVIUM_DB_HOST');/g" config.php && \
    sed -i -e "s/= 'USERNAME';/= getenv('OBSERVIUM_DB_USER');/g" config.php && \
    sed -i -e "s/= 'PASSWORD';/= getenv('OBSERVIUM_DB_PASS');/g" config.php && \
    sed -i -e "s/= 'observium';/= getenv('OBSERVIUM_DB_NAME');/g" config.php && \
    echo "\$config['base_url'] = getenv('OBSERVIUM_BASE_URL');" >> config.php

COPY observium-init.sh /opt/observium/observium-init.sh

RUN chmod a+x /opt/observium/observium-init.sh && \
    chown -R www-data:www-data /opt/observium

# check version and installed files
RUN [ -f /opt/observium/VERSION ] && cat /opt/observium/VERSION && \
    find /opt -ls

# configure apache configuration and modules
COPY observium-apache24 /etc/apache2/sites-available/000-default.conf
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php7.4 && \
    a2enmod rewrite && \
    chmod 644 /etc/apache2/sites-available/000-default.conf && \
    sed -i -e "s/\${APACHE_LOG_DIR}\//\/opt\/observium\/logs\/apache2-/g" /etc/apache2/apache2.conf

# configure cron and logrotate
COPY logrotate-conf /etc/logrotate.conf
COPY logrotate-cron /etc/cron.d/logrotate
COPY observium-cron /etc/cron.d/observium
RUN chmod 644 /etc/logrotate.conf /etc/cron.d/logrotate /etc/cron.d/observium

# configure working directory
WORKDIR /opt/observium

# configure entry point
COPY supervisord.conf /etc/supervisord.conf
ENTRYPOINT [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]

# expose tcp port
EXPOSE 80/tcp

# set volumes
VOLUME ["/opt/observium/logs","/opt/observium/rrd"]


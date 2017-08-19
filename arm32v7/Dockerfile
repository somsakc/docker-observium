# Docker container for Observium Community Edition
#
# It requires option of e.g. '--link observiumdb:observiumdb' with another MySQL or MariaDB container.
# Example usage:
# 1. MySQL or MariaDB container
#    $ docker run --name observiumdb \
#        -v /home/docker/observium/data:/var/lib/mysql \
#        -e MYSQL_ROOT_PASSWORD=passw0rd \
#        -e MYSQL_USER=observium \
#        -e MYSQL_PASSWORD=passw0rd \
#        -e MYSQL_DATABASE=observium \
#        mariadb
#
# 2. This Observium container
#    $ docker run --name observiumapp --link observiumdb:observiumdb \
#        -v /home/docker/observium/logs:/opt/observium/logs \
#        -v /home/docker/observium/rrd:/opt/observium/rrd \
#        -e OBSERVIUM_ADMIN_USER=admin \
#        -e OBSERVIUM_ADMIN_PASS=passw0rd \
#        -e OBSERVIUM_DB_HOST=observiumdb \
#        -e OBSERVIUM_DB_USER=observium \
#        -e OBSERVIUM_DB_PASS=passw0rd \
#        -e OBSERVIUM_DB_NAME=observium \
#        -p 80:80 somsakc/observium
#
# References:
#  - Follow platform guideline specified in https://github.com/docker-library/official-images
# 

FROM arm32v7/ubuntu:16.04

LABEL maintainer "somsakc@hotmail.com"
LABEL version="1.1"
LABEL description="Docker container for Observium Community Edition"

ARG OBSERVIUM_ADMIN_USER=admin
ARG OBSERVIUM_ADMIN_PASS=passw0rd
ARG OBSERVIUM_DB_HOST=observiumdb
ARG OBSERVIUM_DB_USER=observium
ARG OBSERVIUM_DB_PASS=passw0rd
ARG OBSERVIUM_DB_NAME=observium

# set environment variables
ENV LANG en_US.utf8
ENV LANGUAGE en_US.utf8
ENV OBSERVIUM_DB_HOST=$OBSERVIUM_DB_HOST
ENV OBSERVIUM_DB_USER=$OBSERVIUM_DB_USER
ENV OBSERVIUM_DB_PASS=$OBSERVIUM_DB_PASS
ENV OBSERVIUM_DB_NAME=$OBSERVIUM_DB_NAME

# install prerequisites
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update
RUN apt-get install -y libapache2-mod-php7.0 php7.0-cli php7.0-mysql php7.0-mysqli php7.0-gd php7.0-mcrypt php7.0-json \
      php-pear snmp fping mysql-client python-mysqldb rrdtool subversion whois mtr-tiny ipmitool \
      graphviz imagemagick apache2
RUN apt-get install -y libvirt-bin
RUN apt-get install -y cron supervisor wget locales
RUN apt-get clean

# set locale
RUN locale-gen en_US.utf8

# install observium package
RUN mkdir -p /opt/observium /opt/observium/lock /opt/observium/logs /opt/observium/rrd
RUN cd /opt && \
    wget http://www.observium.org/observium-community-latest.tar.gz && \
    tar zxvf observium-community-latest.tar.gz && \
    rm observium-community-latest.tar.gz

# configure observium package
RUN cd /opt/observium && \
    cp config.php.default config.php && \
    sed -i -e "s/= 'localhost';/= getenv('OBSERVIUM_DB_HOST');/g" config.php && \
    sed -i -e "s/= 'USERNAME';/= getenv('OBSERVIUM_DB_USER');/g" config.php && \
    sed -i -e "s/= 'PASSWORD';/= getenv('OBSERVIUM_DB_PASS');/g" config.php && \
    sed -i -e "s/= 'observium';/= getenv('OBSERVIUM_DB_NAME');/g" config.php

COPY observium-init /opt/observium/observium-init.sh
RUN chmod a+x /opt/observium/observium-init.sh

RUN chown -R www-data:www-data /opt/observium
RUN find /opt -ls
#RUN cd /opt/observium && \
#    ./discovery.php -u && \
#    ./adduser.php $OBSERVIUM_ADMIN_USER $OBSERVIUM_ADMIN_PASS 10

# configure php modules
RUN phpenmod mcrypt

# configure apache modules
RUN a2dismod mpm_event && \
    a2enmod mpm_prefork && \
    a2enmod php7.0 && \
    a2enmod rewrite

# configure apache configuration
#RUN mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.orig
COPY observium-apache24 /etc/apache2/sites-available/000-default.conf
RUN rm -fr /var/www

# configure observium cron job
#COPY observium-cron /etc/cron.d/observium
COPY observium-cron /tmp/observium
RUN echo "" >> /etc/crontab && \
    cat /tmp/observium >> /etc/crontab && \
    rm -f /tmp/observium

# configure container interfaces
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]

EXPOSE 80/tcp

VOLUME ["/opt/observium/lock", "/opt/observium/logs","/opt/observium/rrd"]


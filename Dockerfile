## Install php and apache, this is build dev environment
FROM phusion/baseimage AS build-dev
MAINTAINER Chao Hu <huchao95@corp-ci.com>

RUN buildDeps=' \
    gcc \
    make \
    libpcre++-dev \
    libssl-dev \
    bzip2 \
    ' \
    set -x &&\

    apt-get update && \
    apt-get install -y --no-install-recommends $buildDeps \
    ## apache run library
    libapr1 \
    libaprutil1 \
    libaprutil1-ldap \
    libapr1-dev \
    libpcre++0v5 \
    libaprutil1-dev \
    libssl1.0.0 \
    ## php deps
    autoconf \
    file \
    libc-dev \
    pkg-config \
    re2c \
    
    libxml2-dev \
    ## for php extension build libs
    libcurl4-gnutls-dev \
    libmcrypt-dev \
    librabbitmq-dev \
    libmagickwand-dev \
    libmagickcore-dev \
    libpng12-dev && \

    
    ## clean
    rm -r /var/lib/apt/lists/* && \

    cd /home/ && \
    ## install apache file
    curl -LO http://mirrors.hust.edu.cn/apache//httpd/httpd-2.4.29.tar.bz2 && \
    bzip2 -d httpd-2.4.29.tar.bz2 && \
    tar -xf httpd-2.4.29.tar && \
    rm -rf httpd-2.4.29.tar && \
    cd httpd-2.4.29/srclib/ && \
    ## download lib
    curl -LO https://mirrors.tuna.tsinghua.edu.cn/apache//apr/apr-1.6.3.tar.bz2 && \
    curl -LO https://mirrors.tuna.tsinghua.edu.cn/apache//apr/apr-util-1.6.1.tar.bz2 && \
    bzip2 -d apr-1.6.3.tar.bz2 && \
    tar -xf apr-1.6.3.tar && \
    rm -rf apr-1.6.3.tar && \
    mv apr-1.6.3 apr && \

    bzip2 -d apr-util-1.6.1.tar.bz2 && \
    tar -xf apr-util-1.6.1.tar && \
    rm -rf apr-util-1.6.1.tar && \
    mv apr-util-1.6.1 apr-util && \

    cd .. && \
    ./configure --prefix=/opt/ci123/apache-2.4  --enable-headers --enable-deflate --enable-mime-magic --enable-so  --enable-rewrite --enable-ssl --with-ssl --enable-expires --enable-static-support --enable-suexec --with-included-apr --with-mpm=prefork  --disable-userdir &&\
    make && \
    make install && \


    ## install php
    cd .. && \
    curl -LO http://cn2.php.net/distributions/php-5.6.32.tar.bz2 && \
    bzip2 -d php-5.6.32.tar.bz2 && \
    tar -xf php-5.6.32.tar && \
    rm -rf php-5.6.32.tar && \
    cd php-5.6.32 && \
    ./configure --prefix=/opt/ci123/php --with-config-file-path=/opt/ci123/php/etc --with-apxs2=/opt/ci123/apache-2.4/bin/apxs --with-mysql --with-curl  --with-gd --with-gettext --with-mcrypt --with-mhash --with-mysqli --with-openssl  --with-pdo_mysql --with-xmlrpc --with-zlib --enable-bcmath --enable-exif --enable-ftp --enable-mbstring --enable-pcntl --enable-shmop --enable-soap --enable-sockets --enable-sysvsem --enable-zip --enable-phar && \
    make && \
    make install && \
    cp php.ini-development /opt/ci123/php/etc/php.ini && \

    ## install php module
    /opt/ci123/php/bin/pecl install amqp \
    apcu-4.0.11 \
    xhprof-0.9.4 \
    redis \
    memcache \
    imagick &&\

    ## Configure php.ini file
    echo extension=amqp.so >> /opt/ci123/php/etc/php.ini && \
    echo extension=imagick.so >> /opt/ci123/php/etc/php.ini && \
    echo extension=memcache.so >> /opt/ci123/php/etc/php.ini && \
    echo extension=redis.so >> /opt/ci123/php/etc/php.ini && \
    echo extension=xhprof.so >> /opt/ci123/php/etc/php.ini && \
    echo extension=apcu.so >> /opt/ci123/php/etc/php.ini && \
 

    cd /home/ && \
    rm -rf * && \
    ## clean 
    apt-get purge -y --auto-remove $buildDeps && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 



## Run environment
FROM phusion/baseimage
MAINTAINER Chao Hu <huchao95@corp-ci.com>

COPY --from=build-dev /opt/ci123/apache-2.4 /opt/ci123/apache2.4
COPY --from=build-dev /opt/ci123/php /opt/ci123/php


RUN \
    apt-get update && \
    apt-get install -y --no-install-recommends $buildDeps \
    ## apache run library
    libapr1 \
    libaprutil1 \
    libaprutil1-ldap \
    libapr1-dev \
    libpcre++0v5 \
    libaprutil1-dev \
    libssl1.0.0 \
    ## php deps
    autoconf \
    file \
    libc-dev \
    pkg-config \
    re2c &&\

    rm -r /var/lib/apt/lists/* 


EXPOSE 80 88 443

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]

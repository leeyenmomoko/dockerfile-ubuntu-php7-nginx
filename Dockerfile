FROM ubuntu:latest

MAINTAINER Lee Yen <leeyenwork@gmail.com>

ENV TERM xterm

# Docker Build Arguments
ARG RESTY_VERSION="1.11.2.1"
ARG RESTY_LUAROCKS_VERSION="2.3.0"
ARG RESTY_OPENSSL_VERSION="1.0.2h"
ARG RESTY_PCRE_VERSION="8.39"
ARG RESTY_J="1"
ARG RESTY_CONFIG_OPTIONS="\
    --prefix=/opt/openresty \
    --with-file-aio \
    --with-http_addition_module \
    --with-http_auth_request_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_geoip_module=dynamic \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module=dynamic \
    --with-http_mp4_module \
    --with-http_random_index_module \
    --with-http_realip_module \
    --with-http_secure_link_module \
    --with-http_slice_module \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_sub_module \
    --with-http_v2_module \
    --with-http_xslt_module=dynamic \
    --with-ipv6 \
    --with-mail \
    --with-mail_ssl_module \
    --with-md5-asm \
    --with-pcre-jit \
    --with-sha1-asm \
    --with-stream \
    --with-stream_ssl_module \
    --with-threads \
    "

# These are not intended to be user-specified
ARG _RESTY_CONFIG_DEPS="--with-openssl=/tmp/openssl-${RESTY_OPENSSL_VERSION} --with-pcre=/tmp/pcre-${RESTY_PCRE_VERSION}"


# 1) Install apt dependencies
# 2) Download and untar OpenSSL, PCRE, and OpenResty
# 3) Build OpenResty
# 4) Cleanup

RUN \
    DEBIAN_FRONTEND=noninteractive apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        libgd-dev \
        libgeoip-dev \
        libncurses5-dev \
        libperl-dev \
        libreadline-dev \
        libxslt1-dev \
        make \
        perl \
        unzip \
        zlib1g-dev \
    && cd /tmp \
    && curl -fSL https://www.openssl.org/source/openssl-${RESTY_OPENSSL_VERSION}.tar.gz -o openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && tar xzf openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
    && curl -fSL https://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-${RESTY_PCRE_VERSION}.tar.gz -o pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && tar xzf pcre-${RESTY_PCRE_VERSION}.tar.gz \
    && curl -fSL https://openresty.org/download/openresty-${RESTY_VERSION}.tar.gz -o openresty-${RESTY_VERSION}.tar.gz \
    && tar xzf openresty-${RESTY_VERSION}.tar.gz \
    && cd /tmp/openresty-${RESTY_VERSION} \
    && ./configure -j${RESTY_J} ${_RESTY_CONFIG_DEPS} ${RESTY_CONFIG_OPTIONS} \
    && make -j${RESTY_J} \
    && make -j${RESTY_J} install \
    && cd /tmp \
    && rm -rf \
        openssl-${RESTY_OPENSSL_VERSION} \
        openssl-${RESTY_OPENSSL_VERSION}.tar.gz \
        openresty-${RESTY_VERSION}.tar.gz openresty-${RESTY_VERSION} \
        pcre-${RESTY_PCRE_VERSION}.tar.gz pcre-${RESTY_PCRE_VERSION} \
    && curl -fSL http://luarocks.org/releases/luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz -o luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && tar xzf luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && cd luarocks-${RESTY_LUAROCKS_VERSION} \
    && ./configure \
        --prefix=/opt/openresty/luajit \
        --with-lua=/opt/openresty/luajit \
        --lua-suffix=jit-2.1.0-beta2 \
        --with-lua-include=/opt/openresty/luajit/include/luajit-2.1 \
    && make build \
    && make install \
    && cd /tmp \
    && rm -rf luarocks-${RESTY_LUAROCKS_VERSION} luarocks-${RESTY_LUAROCKS_VERSION}.tar.gz \
    && DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
    && ln -sf /dev/stdout /opt/openresty/nginx/logs/access.log \
    && ln -sf /dev/stderr /opt/openresty/nginx/logs/error.log

RUN apt-get -y update
RUN apt-get -y install php-gettext php-pear php-imagick \
    php7.0-curl php7.0-dev libgpgme11-dev libpcre3-dev \
    php7.0-fpm php7.0-gd php7.0-imap \
    php7.0-mcrypt php7.0-mysqlnd php7.0-sybase php7.0-mbstring \
    php7.0-intl php7.0-zip git nano wget supervisor curl

RUN curl -sL https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer

# html to pdf
 RUN apt-get install -y gdebi
 RUN cd /tmp && \
    wget http://download.gna.org/wkhtmltopdf/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb && \
    gdebi --n wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
RUN apt-get -y install wkhtmltox xvfb fonts-wqy-microhei

RUN apt-get remove -y vim-common
RUN apt-get install -y vim

#RUN DEBIAN_FRONTEND=noninteractive apt-get install -y xorg

RUN echo 'LANG="en_US.UTF-8"' > /etc/default/locale && \
    echo 'LANG="zh_TW.UTF-8"' > /etc/default/locale && \
    echo 'LANG="zh_HK.UTF-8"' > /etc/default/locale && \
    echo 'LANG="zh_CN.UTF-8"' > /etc/default/locale && \
    echo 'LANG="th_TH.UTF-8"' > /etc/default/locale && \
    echo 'LANG="id_ID.UTF-8"' > /etc/default/locale && \
    echo 'LANG="ko_KR.UTF-8"' > /etc/default/locale && \
    echo 'LANG="ja_JP.UTF-8"' > /etc/default/locale && \
    locale-gen en_US.UTF-8 && \
    locale-gen zh_TW.UTF-8 && \
    locale-gen zh_CN.UTF-8 && \
    locale-gen zh_HK.UTF-8 && \
    locale-gen th_TH.UTF-8 && \
    locale-gen id_ID.UTF-8 && \
    locale-gen ko_KR.UTF-8 && \
    locale-gen ja_JP.UTF-8

RUN mkdir /run/php

COPY ./configs/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY ./configs/supervisor/conf.d/ /etc/supervisor/conf.d/
COPY ./configs/php/php.ini /etc/php/7.0/fpm/php.ini
COPY ./configs/php/php.ini /etc/php/7.0/cli/php.ini
COPY ./configs/php/pool.d/www.conf /etc/php/7.0/fpm/pool.d/www.conf

COPY ./configs/nginx/nginx.conf /opt/openresty/nginx/conf/nginx.conf
RUN mkdir -p /opt/openresty/nginx/conf/sites-enabled \
    && mkdir -p /opt/openresty/nginx/conf/conf.d
COPY ./configs/nginx/sites-enabled/ /opt/openresty/nginx/conf/sites-enabled/
COPY ./configs/nginx/conf.d/ /opt/openresty/nginx/conf/conf.d/

#RUN ln -sf /dev/stdout /var/log/nginx/access.log \
#    && ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/www/html", "/opt/openresty/nginx/conf/conf.d", "/opt/openresty/nginx/conf/sites-enabled"]
CMD ["/usr/bin/supervisord"]

EXPOSE 80
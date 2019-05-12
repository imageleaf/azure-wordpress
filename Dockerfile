FROM wordpress:5.2-php7.2-fpm-alpine

MAINTAINER Yehuda Deutsch <yeh@uda.co.il>

# Based on https://github.com/Azure/app-service-quickstart-docker-images/blob/master/wordpress-mutli-container/0.1-fpm/Dockerfile

# ========
# ENV vars
# ========
# redis
ENV PHPREDIS_VERSION 4.3.0

# --------
# ~. tools
# --------
RUN set -ex \
  && apk update \
  && apk add --update openssl git net-tools tcpdump tcptraceroute vim curl wget bash

# ========
# install the PHP extensions we need
# ========
RUN docker-php-source extract \
    && curl -L -o /tmp/redis.tar.gz https://github.com/phpredis/phpredis/archive/$PHPREDIS_VERSION.tar.gz \
    && tar xfz /tmp/redis.tar.gz \
    && rm -r /tmp/redis.tar.gz \
    && mv phpredis-$PHPREDIS_VERSION /usr/src/php/ext/redis \
    && docker-php-ext-install redis \
    && docker-php-source delete \
    && curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# ----------
# ~. upgrade/clean up
# ----------
RUN set -ex \
	&& apk update \
	&& apk upgrade \
    && rm -rf /var/cache/apk/*

# =====
# final
# =====
COPY php.ini /usr/local/etc/php/php.ini
COPY uploads.ini /usr/local/etc/php/conf.d/

COPY BaltimoreCyberTrustRoot.crt.pem /usr/src

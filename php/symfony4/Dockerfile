ARG PHP_VERSION=7.2
ARG ALPINE_VERSION=3.7
FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION}

RUN apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		icu-dev \
		yarn \
		zlib-dev \
    imagemagick-dev \
    freetype-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libssh-dev

ENV APCU_VERSION 5.1.11

RUN set -xe

RUN apk add --no-cache git

RUN pecl install apcu-${APCU_VERSION}
RUN pecl install imagick
RUN pecl install xdebug

RUN docker-php-ext-enable --ini-name 20-apcu.ini apcu
RUN docker-php-ext-enable --ini-name 05-opcache.ini opcache
RUN docker-php-ext-enable imagick
RUN docker-php-ext-enable xdebug

RUN docker-php-ext-configure gd \
    	  --with-freetype-dir=/usr/include/ \
    	  --with-png-dir=/usr/include/ \
    	  --with-jpeg-dir=/usr/include/

RUN docker-php-ext-install -j$(getconf _NPROCESSORS_ONLN) gd
RUN docker-php-ext-install \
  exif \
  bcmath \
  sockets \
  pdo \
  pdo_mysql \
  intl \
  zip

RUN apk del .build-deps

COPY php.ini /usr/local/etc/php/php.ini
COPY php-fpm.conf /usr/local/etc/php-fpm.d/www-override.conf

ENV COMPOSER_ALLOW_SUPERUSER 1
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV PATH="${PATH}:/root/.composer/vendor/bin"

# Speed up composer builds - concurrent requests
#RUN composer global require "hirak/prestissimo:^0.3" --prefer-dist --no-suggest --classmap-authoritative
#
#WORKDIR /srv/api
#
# Prevent Symfony Flex from generating a project ID at build time
#ARG SYMFONY_SKIP_REGISTRATION=1
#ARG APP_ENV=prod
#
#COPY composer.json composer.lock ./
#RUN composer install --prefer-dist --no-dev --no-autoloader --no-scripts --no-suggest
#
#COPY . ./
#
#RUN mkdir -p var/cache var/sessions var/log
#
#RUN composer dump-autoload --classmap-authoritative --no-dev
#RUN chmod +x bin/console
#RUN chown -R www-data var
#
#VOLUME /srv/api/var
#
#COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint
#RUN chmod +x /usr/local/bin/docker-entrypoint
#
#ENTRYPOINT ["docker-entrypoint"]

CMD ["php-fpm"]
